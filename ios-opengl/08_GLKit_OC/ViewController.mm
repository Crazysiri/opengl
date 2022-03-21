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

@interface ViewController ()
{
    EAGLContext *context;
    Shader *_shader;
    unsigned int _VAO;
    unsigned int _EBO;

    
    Shader *_mapShader;
    unsigned int _mapVAO;
    unsigned int _mapEBO;
    unsigned int _texture;

}

@end

@implementation ViewController

- (void)dealloc {
    delete _shader;
    _shader = NULL;
}

- (Shader *)createShader:(NSString *)name {
    NSString *vsPath = [NSBundle.mainBundle pathForResource:name ofType:@"vs"];
    NSString *fsPath = [NSBundle.mainBundle pathForResource:name ofType:@"fs"];

    Shader *s = new Shader([vsPath cStringUsingEncoding:NSUTF8StringEncoding],[fsPath cStringUsingEncoding:NSUTF8StringEncoding]);
    return s;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = UIScreen.mainScreen.bounds.size;

    //1.初始化上下文&设置当前上下文
    /*
     EAGLContext 是苹果iOS平台下实现OpenGLES 渲染层.
     kEAGLRenderingAPIOpenGLES1 = 1, 固定管线
     kEAGLRenderingAPIOpenGLES2 = 2,
     kEAGLRenderingAPIOpenGLES3 = 3,
     */
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
    
    Shader *s = [self createShader:@"shader"];
    _shader = s;
    
//    _shader->use();

    
    GLfloat points[] = {
        500.0f, 500.0f, 0.0f,     0.0f, 0.0f,
        
        500.0f, 500.0f, 0.0f,     100.0f, 0.5235f, //x,y,z ,length ,angle 30
        500.0f, 500.0f, 0.0f,     80.0f, 0.7854f, //x,y,z ,length ,angle  45
        
        500.0f, 500.0f, 0.0f,     200.0f, 2.0944f, //x,y,z ,length ,angle 120
        500.0f, 500.0f, 0.0f,     150.0f, 2.3562f, //x,y,z ,length ,angle 135

        500.0f, 500.0f, 0.0f,     300.0f, 3.6652f, //x,y,z ,length ,angle 210
        500.0f, 500.0f, 0.0f,     250.0f, 3.9270f, //x,y,z ,length ,angle 225

        500.0f, 500.0f, 0.0f,     300.0f, 5.2360f, //x,y,z ,length ,angle 300
        500.0f, 500.0f, 0.0f,     200.0f, 5.4978f, //x,y,z ,length ,angle 315

        
        
//
//    0.0f, 0.0f, 0.0f,     1.0f, 0.0f,
//    -5.0f, -0.5f, 0.0f,    0.0f, 0.0f,
        
//      10.0f, 10.0f, 0.0f,  30.0f, 50.0f,
//      10.0f, 10.0f, 0.0f,  45.0f, 60.0f
    };
    
    
    unsigned int line_indices[] = {
        0, 1,
        0, 2,
        0, 3,
        0, 4,
        0, 5,
        0, 6,
        0, 7,
        0, 8
    };
    
    GLuint point_p = glGetAttribLocation(s->ID, "position");
    GLuint data_p = glGetAttribLocation(s->ID, "data");

    unsigned int VBO, VAO, EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(line_indices), line_indices, GL_STATIC_DRAW);
    
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(points), points, GL_STATIC_DRAW);
    glEnableVertexAttribArray(point_p);
    glVertexAttribPointer(point_p, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(data_p);
    glVertexAttribPointer(data_p, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);
    _VAO = VAO;
    _EBO = EBO;
//
    
    Shader *mapS = [self createShader:@"map_shader"];
    _mapShader = mapS;
//    Texture *t = new Texture();
//    unsigned int texture = t->begin();
//    _texture = texture;
    //发现问题：这里设置 GL_CLAMP_TO_EDGE test.jpg能显示 但设置其它就不能显示
//    t->setWrap2D(GL_CLAMP_TO_EDGE);
//    t->setFilter(GL_LINEAR);

//    NSString *mapPath = [NSBundle.mainBundle pathForResource:@"wall" ofType:@"jpg"];
    
    NSString *mapPath = [NSBundle.mainBundle pathForResource:@"map" ofType:@"jpg"];
    
//    t->end([mapPath cStringUsingEncoding:NSUTF8StringEncoding]);

    [self setupTexture:mapPath];
    _mapShader->setInt("texture1", 0);

    float vertices[] = {
//      ---- 位置 -----        -- 纹理坐标 --
        1315.0,1572.0,0.0f, 1.0f,1.0f, //右上
        1315.0,0.0f,0.0f, 1.0f,0.0f, //右下
        0.0f,0.0f,0.0f, 0.0f,0.0f, //左下
        0.0f,1572.0,0.0f, 0.0f,1.0f, //左上
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
    //1170,2532
    glm_ortho(0.0 ,size.width * scale , 0.0, size.height * scale, -1, 1, projection);
    mat4 model = GLM_MAT4_IDENTITY_INIT;
//    glm_mat4_zero(model);
//    vec3 position = {600,1572.0 / 2};
//    glm_translate(model, position);
//    vec3 m_size = {1315.0,1572.0,1.0};
//    glm_scale(model, m_size);
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
    glDrawElements(GL_LINES, 16, GL_UNSIGNED_INT, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
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


@end
