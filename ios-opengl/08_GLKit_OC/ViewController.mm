//
//  MapViewController.m
//  LenzRWControl
//
//  Created by Zero on 2022/3/22.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "Shader.hpp"
#import "Texture.h"
#include <cglm/cglm.h>
#import "Tool.h"
//#import "LenzRWControl-Swift.h"

#import <sys/timeb.h>

long long rw_getSystemTime(void)
{
    struct timeb t;
    ftime(&t);
    return 1000 * t.time + t.millitm;
}

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


@interface ViewController () <UITextFieldDelegate>
{
    EAGLContext *context;
    Shader *_shader;
    unsigned int _VAO;
    unsigned int _VBO;
    unsigned int _EBO;
    unsigned long _point_count;

    unsigned int _pathVAO;
    unsigned int _pathVBO;
    unsigned long _path_point_count;

//    unsigned int _pathEBO;

    
    Shader *_mapShader;
    unsigned int _mapVAO;
    unsigned int _mapVBO;
    unsigned int _mapEBO;
    unsigned int _texture;
    vec3 _map_scale; //scale
    vec3 _map_translate; //translate
    
    
    unsigned int _arrowVAO;
    unsigned int _arrowVBO;
    unsigned int _arrowEBO;
    unsigned int _arrowTexture;
    float _centerX;
    float _centerY;
    float _centerRadius;
    
    unsigned int _dstTexture;
    float _dstX;
    float _dstY;
    float _dstRadius;

}
@property (nonatomic, strong) MapBaseDataUpdater *mapBaseData;

@property (weak, nonatomic) IBOutlet UITextField *locationInputField;
@end

@implementation ViewController

- (void)dealloc {
    delete _shader;
    _shader = NULL;
    
    delete _mapShader;
    _mapShader = NULL;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSArray *coms = [textField.text componentsSeparatedByString:@"|"];
    if (coms.count == 3) {
        _dstX = [coms[0] floatValue];
        _dstY = [coms[1] floatValue];
        _dstRadius = [coms[2] floatValue];
    }
    return YES;
}

- (Shader *)createShader:(NSString *)name {
    NSString *vsPath = [NSBundle.mainBundle pathForResource:name ofType:@"vs"];
    NSString *fsPath = [NSBundle.mainBundle pathForResource:name ofType:@"fs"];

    Shader *s = new Shader([vsPath cStringUsingEncoding:NSUTF8StringEncoding],[fsPath cStringUsingEncoding:NSUTF8StringEncoding]);
    return s;
}

- (unsigned int)textureFromData:(NSData *)data width:(size_t)width height:(size_t)height {
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    //https://stackoverflow.com/questions/37664944/glteximage2d-reads-beyond-bounds-of-buffer-ios
    unsigned int texture;
    glGenTextures(1,&texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, fw, fh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data.bytes);
    return texture;
}


- (void)textureFromData:(NSData *)data texture:(unsigned int)texture width:(size_t)width height:(size_t)height {
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, fw, fh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data.bytes);
}

- (GLuint)setupTextureWithName: (NSString *)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"get Image failed");
        exit(1);
    }
    return [self setupTexture:spriteImage];
}

- (GLuint)setupTexture: (CGImageRef)spriteImage {

    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));

    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    /*
     https://www.jianshu.com/p/6e67d88744ad
    这两句代码用来，上下颠倒纹理，否则加载的纹理是倒立的
     */
    CGContextTranslateCTM(context, 0, rect.size.height);//向x,平移0,向y平移rect.size.height
    CGContextScaleCTM(context, 1.0, -1.0); //x,缩放1.0，y,缩放-1.0

    CGContextDrawImage(context, rect, spriteImage);
    
    CGContextRelease(context);
    unsigned int texture;
    glGenTextures(1,&texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    
    return texture;
}


- (void)buildGL {
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
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
    
    self.mapBaseData = [[MapBaseDataUpdater alloc] init];
    
    self.locationInputField.delegate = self;
    
    vec3 default_s = {1.0, 1.0, 1.0};
    glm_vec3_copy(default_s, _map_scale);

//    RobotControl.shared.mapDataCallback = ^(NSData * _Nonnull data) {
//        long long start = rw_getSystemTime();
//        data = data.zlibDeflate;
//        long long end = rw_getSystemTime();
//        NSLog(@"after get map: %ld",end - start);
////        UIImage *image = [Tool imageFromData:data];
////        self->_texture = [self textureFromData:data width:1662  height:1706];
//        [self textureFromData:data texture:self->_texture width:1662 height:1706];
//    };
//
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
//
//        self->_centerX = [params[@"center"][@"x"] floatValue];
//        self->_centerY = [params[@"center"][@"y"] floatValue];
//        self->_centerRadius = [params[@"center"][@"radian"] floatValue] - GLM_PI_2;
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
    glBindVertexArray(VAO);

    glGenBuffers(1, &VBO);
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
    
    
    
    NSString *pathPath = [[NSBundle mainBundle] pathForResource:@"path" ofType:@"json"];
    NSData *pathData = [NSData dataWithContentsOfFile:pathPath];
    NSArray *path_list = [NSJSONSerialization JSONObjectWithData:pathData options:NSJSONReadingAllowFragments error:nil];
    size_t path_points_size = sizeof(GLfloat) * (path_list.count) * 5;
    GLfloat *path_points= (GLfloat *)malloc(path_points_size);
    _path_point_count = path_list.count;
    for (int i = 0; i < path_list.count; i++) {
        NSDictionary *p = path_list[i];
        int j = i * 5;
        path_points[j] = [p[@"x"] floatValue];
        path_points[j+1] = [p[@"y"] floatValue];
        path_points[j+2] = 0;
        path_points[j+3] = 0;
        path_points[j+4] = 0;
    }
    unsigned int pathVBO, pathVAO;
    glGenVertexArrays(1, &pathVAO);
    glBindVertexArray(pathVAO);

    glGenBuffers(1, &pathVBO);
    glBindBuffer(GL_ARRAY_BUFFER, pathVBO);
    glBufferData(GL_ARRAY_BUFFER, path_points_size, path_points, GL_STATIC_DRAW);
    glEnableVertexAttribArray(point_p);
    glVertexAttribPointer(point_p, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(data_p);
    glVertexAttribPointer(data_p, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);
    _pathVAO = pathVAO;
    _pathVBO = pathVBO;
    free(path_points);
    path_points = NULL;

    
    
    
    Shader *mapS = [self createShader:@"map_shader"];
    _mapShader = mapS;
    
//    NSString *mapPath = [NSBundle.mainBundle pathForResource:@"map" ofType:@"jpg"];
    _texture = [self setupTextureWithName:@"map.jpg"];
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
    GLuint map_data_p = glGetAttribLocation(_mapShader->ID, "texCoord");

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
    _mapVBO = mVBO;
    _mapEBO = mEBO;
    
    
    
        
    _arrowTexture = [self setupTextureWithName:@"location"];
    
    float c_x = [center[@"x"] floatValue];
    float c_y = [center[@"y"] floatValue];
    float c_r= [center[@"radian"] floatValue];
    _centerX = c_x;
    _centerY = c_y;
    _centerRadius = c_r - GLM_PI_2;
    float arrow_vertices[] = {
//      ---- 位置 -----        -- 纹理坐标 --
        18.0,18.0,0.0f, 1.0f,1.0f, //右上
        18.0,-18.0f,0.0f, 1.0f,0.0f, //右下
        -18.0f,-18.0f,0.0f, 0.0f,0.0f, //左下
        -18.0f,18.0,0.0f, 0.0f,1.0f, //左上
    };

    unsigned int aVBO, aVAO;
    
    glGenVertexArrays(1, &aVAO);
    glBindVertexArray(aVAO);

    glGenBuffers(1, &aVBO);
    glBindBuffer(GL_ARRAY_BUFFER, aVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(arrow_vertices), arrow_vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(map_point_p);
    glVertexAttribPointer(map_point_p, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);
    
    glEnableVertexAttribArray(map_data_p);
    glVertexAttribPointer(map_data_p, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL+3);

    
    _arrowVAO = aVAO;
    _arrowVBO = aVBO;
    _arrowEBO = mEBO;
    
    _dstTexture = [self setupTextureWithName:@"location_loc"];
    [self setupGesture];
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

    glm_translate(model, _map_translate);
    glm_scale(model, _map_scale);
    _mapShader->setMatrix4("projection", (float *)projection);
    _mapShader->setMatrix4("model", (float *)model);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glBindBuffer(GL_ARRAY_BUFFER, _mapVBO);
    glBindVertexArray(_mapVAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _mapEBO);
//    glDrawArrays(GL_TRIANGLES, 0, 4);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    
    
    _shader->use();
    _shader->set2F("resolution", self.mapBaseData.resolutionX, self.mapBaseData.resolutionY);
    _shader->set2F("map", self.mapBaseData.positionX, self.mapBaseData.positionY);
    _shader->setMatrix4("projection", (float *)projection);
    _shader->setMatrix4("model", (float *)model);

    
    glBindVertexArray(_VAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    
//    glDrawArrays(GL_LINES,0,2);
    glDrawElements(GL_TRIANGLES, _point_count * 3, GL_UNSIGNED_INT, 0);
    glDrawElements(GL_POINTS, _point_count * 3, GL_UNSIGNED_INT, 0);

    
//    _shader->setMatrix4("projection", (float *)projection);
//    _shader->setMatrix4("model", (float *)model);
    glBindVertexArray(_pathVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _pathVBO);
//    glLineWidth(5);
    glDrawArrays(GL_POINTS, 0, _path_point_count);

    //GL_LINE_STRIP GL_LINES GL_LINE_LOOP
    _mapShader->use();
    mat4 arrowModel;
    glm_mat4_copy(model, arrowModel);
    vec3 axis = {0.0,0.0,1.0};
    float x_p = _centerX / self.mapBaseData.resolutionX + self.mapBaseData.positionX / self.mapBaseData.resolutionX;
    float y_p = (_centerY / self.mapBaseData.resolutionX + self.mapBaseData.positionY / self.mapBaseData.resolutionY);
    vec3 p = {x_p, y_p, 0.0};
    glm_translate(arrowModel, p);
    glm_rotate(arrowModel, _centerRadius, axis);
    
    _mapShader->setMatrix4("projection", (float *)projection);
    _mapShader->setMatrix4("model", (float *)arrowModel);
    glBindVertexArray(_arrowVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _arrowVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _arrowEBO);

    glBindTexture(GL_TEXTURE_2D, _arrowTexture);
//    glDrawArrays(GL_LINES,0,2);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

    mat4 locationModel;
    glm_mat4_copy(model, locationModel);
    vec3 axis_l = {0.0,0.0,1.0};
    float x_p_l = _dstX / self.mapBaseData.resolutionX + self.mapBaseData.positionX / self.mapBaseData.resolutionX;
    float y_p_l = (_dstY / self.mapBaseData.resolutionX + self.mapBaseData.positionY / self.mapBaseData.resolutionY);
    vec3 p_l = {x_p_l, y_p_l, 0.0};
    glm_translate(locationModel, p_l);
    glm_rotate(locationModel, _dstRadius, axis_l);
    _mapShader->setMatrix4("projection", (float *)projection);
    _mapShader->setMatrix4("model", (float *)locationModel);
    
    glBindTexture(GL_TEXTURE_2D, _dstTexture);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

vec3 _current_scale;
BOOL _pinch = NO;
BOOL _move = NO;

- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer{
     /*获取状态*/
    UIGestureRecognizerState state = [recognizer state];
    if (state == UIGestureRecognizerStateBegan) {
        glm_vec3_copy(_map_scale, _current_scale);
        _pinch = YES;
    } else if (state == UIGestureRecognizerStateChanged){
       /*获取捏合大小比例*/
       CGFloat scale = [recognizer scale];
        NSLog(@"scale %f",scale);
       /*获取捏合的速度*/
       CGFloat velocity = [recognizer velocity];
       NSLog(@"velocity %f",velocity);
//       [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, scale, scale)];
//       [recognizer setScale:1.0];
        vec3 s = {(float)scale, (float)scale, 0.0};
        glm_vec3_mul(_current_scale, s, _map_scale);
    } else if (state == UIGestureRecognizerStateEnded){
        _pinch = NO;
    }
}

- (void)setupGesture {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
//    [pinchGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchGestureRecognizer];

}

CGPoint _start_point;
vec3 _current_translate;
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint start_point = [touch locationInView:touch.view];
    _start_point = start_point;
    glm_vec3_copy(_map_translate, _current_translate);
//    NSLog(@"start:%f, %f", start_point.x, start_point.y);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_pinch) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint end_point = [touch locationInView:touch.view];
    UIScreen *screen = UIScreen.mainScreen;
    CGFloat scale = screen.scale;
    float x = (end_point.x - _start_point.x) * scale;
    float y = (end_point.y - _start_point.y) * scale;
    NSLog(@"move:%f, %f", x, y);

    vec3 s = {x, -y , 0.0};
    glm_vec3_add(_current_translate, s, _map_translate);
//    glm_vec3_copy(s, _map_translate);
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end


@implementation MapBaseDataUpdater

- (id)init {
    self = [super init];
    if (self) {
        self.width = 1662;
        self.height = 1706;
        self.resolutionX = 0.05;
        self.resolutionY = 0.05;
        self.positionX = 23.05;
        self.positionY = 73.8;
//        RobotControl.shared.mapDataBaseCallback = ^(NSInteger w, NSInteger h, float p_x, float p_y, float res_x, float res_y) {
//            self.width = w;
//            self.height = h;
//            self.positionX = -p_x;
//            self.positionY = -p_y;
//            self.resolutionX = res_x;
//            self.resolutionY = res_y;
//        };
    }
    return self;
}

@end
