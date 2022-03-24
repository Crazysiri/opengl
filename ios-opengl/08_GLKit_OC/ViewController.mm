//
//  ViewController.m
//  08_GLKit_OC
//
//  Created by 陈嘉琳 on 2020/7/24.
//  Copyright © 2020 CJL. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "Shader.hpp"
#import "Texture.h"
#include <cglm/cglm.h>
#if 1
unsigned long getVertexs(NSDictionary *center,NSArray *list,GLfloat **vertexes, size_t *vertexes_size, unsigned int **indices, size_t *indices_size) {
    unsigned long l = list.count;
    
    size_t points_size = sizeof(GLfloat) * (l + 1) * 5;
    GLfloat *points= (GLfloat *)malloc(points_size);
    points[0] = [center[@"x"] floatValue];
    points[1] = [center[@"y"] floatValue];
    points[2] = [center[@"radian"] floatValue];
    points[3] = 0.0;
    points[4] = 0.0;
    
    size_t line_indices_size = sizeof(unsigned int) * l * 3;

    unsigned int *line_indices= (unsigned int *)malloc(line_indices_size);

    for (int i = 0; i < list.count; i++) {
        NSDictionary *p = list[i];
        int j = (i + 1) * 5;
        points[j] = [center[@"x"] floatValue];
        points[j+1] = [center[@"y"] floatValue];
        points[j+2] = [center[@"radian"] floatValue];
        
        points[j+3] = [p[@"l"] floatValue];
        points[j+4] = [p[@"a"] floatValue];
        
        int k = i * 3;

        line_indices[k] = 0;
        line_indices[k+1] = i + 1;
        if (i+1 != l) {
            line_indices[k+2] = i + 2;
        } else {
            line_indices[k+2] = 1;
        }

    }
    
    if (vertexes) {
        *vertexes = points;
    }
    
    if (vertexes_size) {
        *vertexes_size = points_size;
    }
    
    if (indices) {
        *indices = line_indices;
    }
    
    if (indices_size) {
        *indices_size = line_indices_size;
    }
    
    
    return l;
}
#else
unsigned long getVertexs(NSDictionary *center,NSArray *list,GLfloat **vertexes, size_t *vertexes_size, unsigned int **indices, size_t *indices_size) {
    unsigned long l = list.count;
    
    size_t points_size = sizeof(GLfloat) * (l + 1) * 5;
    GLfloat *points= (GLfloat *)malloc(points_size);
    points[0] = [center[@"x"] floatValue];
    points[1] = [center[@"y"] floatValue];
    points[2] = [center[@"radian"] floatValue];
    points[3] = 0.0;
    points[4] = 0.0;
    
    size_t line_indices_size = sizeof(unsigned int) * l * 2;

    unsigned int *line_indices= (unsigned int *)malloc(line_indices_size);

    for (int i = 0; i < list.count; i++) {
        NSDictionary *p = list[i];
        int j = (i + 1) * 5;
        points[j] = [center[@"x"] floatValue];
        points[j+1] = [center[@"y"] floatValue];
        points[j+2] = [center[@"radian"] floatValue];
        
        points[j+3] = [p[@"l"] floatValue];
        points[j+4] = [p[@"a"] floatValue];
        
        int k = i * 2;

        line_indices[k] = 0;
        line_indices[k+1] = i + 1;
    }
    
    if (vertexes) {
        *vertexes = points;
    }
    
    if (vertexes_size) {
        *vertexes_size = points_size;
    }
    
    if (indices) {
        *indices = line_indices;
    }
    
    if (indices_size) {
        *indices_size = line_indices_size;
    }
    
    
    return l;
}
#endif

@interface ViewController ()
{
    EAGLContext *context;
    Shader *_shader;
    unsigned int _VAO;
    unsigned int _VBO;
    unsigned int _EBO;

    
    Shader *_mapShader;
    unsigned int _mapVAO;
    unsigned int _mapEBO;
    unsigned int _texture;
    unsigned long _point_count;
}
@end

@implementation ViewController

- (void)dealloc {
    delete _shader;
    _shader = NULL;
    
    delete _mapShader;
    _mapShader = NULL;
}

- (Shader *)createShader:(NSString *)name {
    NSString *vsPath = [NSBundle.mainBundle pathForResource:name ofType:@"vs"];
    NSString *fsPath = [NSBundle.mainBundle pathForResource:name ofType:@"fs"];

    Shader *s = new Shader([vsPath cStringUsingEncoding:NSUTF8StringEncoding],[fsPath cStringUsingEncoding:NSUTF8StringEncoding]);
    return s;
}

- (GLuint)setupTexture: (NSString *)fileName {
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"get Image failed");
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));

    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, spriteImage);
    
    CGContextRelease(context);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    
    return 0;
}


- (void)buildGL {
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //判断context是否创建成功
    if (!context) {
        NSLog(@"Create ES context Failed");
    }
    
    //设置当前上下文
    [EAGLContext setCurrentContext:context];
    
    //2.获取GLKView & 设置context
    GLKView * view = (GLKView *)self.view;
    view.context = context;
    
    //3.设置背景颜色
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
//    RobotControl.shared.laserCallback = ^(NSDictionary * _Nonnull params) {
//        GLfloat *points  = NULL;
//        unsigned int *line_indices = NULL;
//        size_t line_indices_size,points_size;
//        self->_point_count = getVertexs(params[@"center"], params[@"points"], &points, &points_size, &line_indices, &line_indices_size);
//        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self->_EBO);
//        glBufferData(GL_ELEMENT_ARRAY_BUFFER, line_indices_size, line_indices, GL_STATIC_DRAW);
//        glBindBuffer(GL_ARRAY_BUFFER, self->_VBO);
//        glBufferData(GL_ARRAY_BUFFER, points_size, points, GL_STATIC_DRAW);
//        free(points);
//        free(line_indices);
//        points = NULL;
//        line_indices = NULL;
//    };

    
    [self buildGL];
    
    Shader *s = [self createShader:@"shader"];
    _shader = s;
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSDictionary *json_data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *center = json_data[@"center"];
    NSArray *list = json_data[@"points"];
    GLfloat *points  = NULL;
    unsigned int *line_indices = NULL;
    size_t line_indices_size,points_size;
    _point_count = getVertexs(center, list, &points, &points_size, &line_indices, &line_indices_size);

    
    GLuint point_p = glGetAttribLocation(s->ID, "position");
    GLuint data_p = glGetAttribLocation(s->ID, "data");

    unsigned int VBO, VAO, EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, line_indices_size, line_indices, GL_STATIC_DRAW);
    
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, points_size, points, GL_STATIC_DRAW);
    glEnableVertexAttribArray(point_p);
    glVertexAttribPointer(point_p, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(data_p);
    glVertexAttribPointer(data_p, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);
    _VAO = VAO;
    _VBO = VBO;
    _EBO = EBO;
    free(points);
    free(line_indices);
    points = NULL;
    line_indices = NULL;
    
    
    Shader *mapS = [self createShader:@"map_shader"];
    _mapShader = mapS;
    
    NSString *mapPath = [NSBundle.mainBundle pathForResource:@"map" ofType:@"jpg"];
    [self setupTexture:mapPath];
    _mapShader->setInt("texture1", 0);

    float vertices[] = {
//      ---- 位置 -----        -- 纹理坐标 --
        1664.0,1708.0,0.0f, 1.0f,1.0f, //右上
        1664.0,0.0f,0.0f, 1.0f,0.0f, //右下
        0.0f,0.0f,0.0f, 0.0f,0.0f, //左下
        0.0f,1708.0,0.0f, 0.0f,1.0f, //左上
    };

    
    unsigned int indices[] = {
        0, 1, 3,
        1, 2, 3
    };
    
    GLuint map_point_p = glGetAttribLocation(_mapShader->ID, "position");
    GLuint map_data_p = glGetAttribLocation(s->ID, "data");

    unsigned int mVBO, mVAO, mEBO;
    
    glGenBuffers(1, &mEBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &mVAO);
    glBindVertexArray(mVAO);

    glGenBuffers(1, &mVBO);
    glBindBuffer(GL_ARRAY_BUFFER, mVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(map_point_p);
    glVertexAttribPointer(map_point_p, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(map_data_p);
    glVertexAttribPointer(map_data_p, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);
    
    _mapVAO = mVAO;
    _mapEBO = mEBO;
    
}

# pragma mark --  GLKViewDelegate

//绘制
//绘制视图的内容
/*
 GLKView对象使其OpenGL ES上下文成为当前上下文，并将其framebuffer绑定为OpenGL ES呈现命令的目标。然后，委托方法应该绘制视图的内容。
*/

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.2f,0.3f,0.3f,1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    _mapShader->use();
    mat4 projection = GLM_MAT4_IDENTITY_INIT;
//    glm_mat4_zero(projection);
    CGSize size = UIScreen.mainScreen.bounds.size;
    CGFloat scale = UIScreen.mainScreen.scale;
//    scale = 2;
    //1170,2532

    
    glm_ortho(0.0 ,size.width * scale , 0.0, size.height * scale, -1, 1, projection);
    mat4 model = GLM_MAT4_IDENTITY_INIT;
//    glm_mat4_zero(model);
//    vec3 position = {600,1572.0 / 2};
//    glm_translate(model, position);
//    vec3 m_size = {1315.0,1572.0,1.0};
//    glm_scale(model, m_size);
    
    vec3 v3_move = {-100.0,-1400.0,0.0};
    glm_translate(model, v3_move);
    vec3 v3_scale = {2,2,0.0};
    glm_scale(model, v3_scale);
    _mapShader->setMatrix4("projection", (float *)projection);
    _mapShader->setMatrix4("model", (float *)model);
    
    
    
    glBindVertexArray(_mapVAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _mapEBO);
//    glDrawArrays(GL_TRIANGLES, 0, 4);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    _shader->use();
    _shader->setMatrix4("projection", (float *)projection);
    _shader->setMatrix4("model", (float *)model);
    
    glBindVertexArray(_VAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
//    glDrawArrays(GL_LINES,0,2);
    glDrawElements(GL_TRIANGLES, _point_count * 3, GL_UNSIGNED_INT, 0);
    glDrawElements(GL_POINTS, _point_count * 3, GL_UNSIGNED_INT, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
//        1
//
//
//        0
//
//2               3
