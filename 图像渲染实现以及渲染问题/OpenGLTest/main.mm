//
//  main.m
//  OpenGLTest
//
//  Created by Zero on 2020/11/3.
//  Copyright © 2020 Lenz. All rights reserved.
//

#include "GLShaderManager.h"

#include "GLTools.h"

#include <glut/glut.h>

#include <GLFrustum.h>
#include <GLMatrixStack.h>
#include <GLGeometryTransform.h>
#include <GLFrame.h>
#include <math3d.h>
GLFrustum viewFrustum;
GLMatrixStack projectionMatrix;
GLMatrixStack modelViewMatrix;
GLGeometryTransform transformPipeline;

GLShaderManager shaderManager;

GLFrame viewFrame;

GLuint textures;

GLBatch pyramidBatch;
//#include <GLUT/glut.h>

void ChangeSize(int width,int height);
void SpecialKeys(int a,int b,int c);
void RenderScene();
void SetupRC();
bool LoadTGATexture(const char *name,GLenum minFilter,GLenum magFilter,GLenum wrapMode);
void MakePyramid(GLBatch &pyramidbatch);

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(800, 600);
    glutCreateWindow("ZB");
    
    glutReshapeFunc(ChangeSize);
    glutSpecialFunc(SpecialKeys);
    glutDisplayFunc(RenderScene);
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error:%s\n",glewGetErrorString(err));
        return 1;
    }
    
    
    SetupRC();
    
    glutMainLoop();
//    @autoreleasepool {


        
        // Setup code that might create autoreleased objects goes here.
//    }
//    return NSApplicationMain(argc, argv);
    return 0;
}

void SetupRC() {
    //背景色
    glClearColor(0.7, 0.7, 0.7, 1);//这是一个 状态设置 函数
    glClear(GL_COLOR_BUFFER_BIT); //这是一个 状态使用 函数
    
    shaderManager.InitializeStockShaders();
    
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //分配纹理对象
    //参数1:纹理对象个数 参数2: 纹理对象指针
    glGenTextures(1, &textures);
    
    //绑定纹理
    //参数1:纹理状态2D，参数2:纹理对象
    glBindTexture(GL_TEXTURE_2D, textures);
    
    //1: 纹理文件 2&3: 需要的缩小和放大过滤器 4:纹理坐标环绕模式
    LoadTGATexture("stone.tga", GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR, GL_CLAMP_TO_EDGE);
    
    MakePyramid(pyramidBatch);
    
    
    viewFrame.MoveForward(-10);
}

//参数1: 纹理名称 参数2&3: 需要的缩小和放大过滤器 参数4:纹理坐标的环绕模式
bool LoadTGATexture(const char *name,GLenum minFilter,GLenum magFilter,GLenum wrapMode) {
    GLbyte *pBits;
    int nWidth,nHeight,nComponents;
    GLenum eFormat;
    
    //1 读纹理位，读取像素
    //1:纹理文件 2:文件宽度 3:文件高度 4:文件组件 5:文件格式
    pBits = gltReadTGABits(name, &nWidth, &nHeight, &nComponents, &eFormat);
    
    if (pBits == NULL) {
        return false;
    }
    
    //2 设置纹理参数
    //1:纹理维度 2:为S/T坐标设置模式(s,t,r,q->x,y,z,w) 3:wrapMode，环绕模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapMode);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapMode);
    
    //纹理维度，线性过度，wrapMode 过度模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);

    //3 载入纹理
    //1: 纹理维度 2:mip贴图层次 3:纹理单元存储的颜色成分（从读取像素图获取） 4:加载纹理宽 5:加载纹理高 6:加载纹理的深度 7:像素数据的数据类型（GL_UNSIGNED_BYTE,每个颜色分量都是一个8位无符号整数） 8:指向纹理图像数据的指针
    glTexImage2D(GL_TEXTURE_2D, 0, nComponents, nWidth, nHeight, 0, eFormat, GL_UNSIGNED_BYTE, pBits);
    
    free(pBits);
    
    //4 加载 mip 纹理生成所有的mip层
    //参数：GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
    glGenerateMipmap(GL_TEXTURE_2D);
    return true;
    
}

/*
 -------- 前情导入 ---------
 1、 设置法线
 void Normal3f(GLfloat x, GLfloat y, GLfloat z);
 Normal3f: 添加一个表面发现（法线坐标与Vertex顶点坐标中的Y轴一致）
 表面法线是有方向的向量，代表表面或顶点面对的方向（相反的方向）。在多数的光照模式下必须使用

 2、 设置纹理坐标
 void MultiTexCoord2f(GLuint texture, GLclampf s, GLclampf t);
 参数1：texture，纹理层次，对于使用存储着色器来进行渲染，设置为0
 参数2：s: 对应顶点坐标中的x坐标
 参数3：t: 对应顶点坐标中的y
 (s,t,r,q对应顶点坐标的x,y,z,w)
 pyramidBatch.MultiTexCoord2f(0,s,t);

 3、 设置顶点坐标
 void Vertex3f(GLfloat x, GLfloat y, GLfloat z);
 void Vertex3fv(M3DVector3f vVertex);
 向三角形批次类添加顶点数据(x,y,z);
 pyramidBatch.Vertex3f(-1.0f, -1.0f, -1.0f);

 4、获取从三点找到一个坐标(三点确定一个面)
 void m3dFindNormal(result, point1, point2, point3);
 参数1：结果
 参数2~4：3个顶点数据
 */
void MakePyramid(GLBatch &pyramidbatch) {
    //通过pyramidBatch 组建三角形
    //1: 类型 2:顶点数 3:这个批次中将会应用一个纹理
    pyramidBatch.Begin(GL_TRIANGLES, 18,1);
    
    //塔顶
    M3DVector3f vApex = {0.0f,1.0f,0.0f};
    M3DVector3f vFrontLeft = {-1.0f,-1.0f,1.0f};
    M3DVector3f vFrontRight = {1.0f,-1.0f,-1.0f};
    M3DVector3f vBackLeft = {-1.0f,-1.0f,-1.0f};
    M3DVector3f vBackRight = {1.0f,-1.0f,-1.0f};
    
    M3DVector3f n;
    
    //塔底
    //底部四边形 = 三角形A + 三角形B
    //三角形A = {vBackLeft,vBackRight,vFrontRight}
    
    //找到A的法线
    m3dFindNormal(n, vBackLeft, vBackRight, vFrontRight);
    
    //vBackLeft
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 0.0f, 0.0f);
    pyramidBatch.Vertex3fv(vBackLeft);

    //vBackRight
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 1.0f, 0.0f);
    pyramidBatch.Vertex3fv(vBackRight);

    //vFrontRight
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 1.0f, 1.0f);
    pyramidBatch.Vertex3fv(vFrontRight);
    
    
    //找到B的法线
    m3dFindNormal(n,vFrontLeft, vBackLeft, vFrontRight);
    
    //vBackLeft
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 0.0f, 1.0f);
    pyramidBatch.Vertex3fv(vFrontLeft);

    //vBackLeft
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 1.0f, 0.0f);
    pyramidBatch.Vertex3fv(vBackLeft);

    //vFrontRight
    pyramidBatch.Normal3fv(n);
    pyramidBatch.MultiTexCoord2f(0, 1.0f, 1.0f);
    pyramidBatch.Vertex3fv(vFrontRight);
}

void RenderScene() {
    static GLfloat vLightPos [] = {1.0,1.0,1.0};
    static GLfloat vWhite [] = {1.0f,1.0f,1.0f,1.0f};
    
    //清除窗口和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    
    //3.当前模型视频压栈
    modelViewMatrix.PushMatrix();
    
    //添加相机
    M3DMatrix44f mCamera;
    viewFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.MultMatrix(mCamera);
    
    
    M3DMatrix44f mObjectFrame;
    
    
    modelViewMatrix.PopMatrix();
    
    glutSwapBuffers();
}

void SpecialKeys(int key,int x,int y) {
        // 1. 判断方向
        if (key == GLUT_KEY_UP) {
            // 2. 根据方向调整观察者位置
            // 参数1: 旋转的弧度
            // 参数2、3、4:表示绕哪个轴进行旋转
            viewFrame.RotateWorld(m3dDegToRad(-5), 1, 0, 0);
        }
        if (key == GLUT_KEY_DOWN) {
            viewFrame.RotateWorld(m3dDegToRad(5), 1, 0, 0);
        }
        if (key == GLUT_KEY_LEFT) {
            viewFrame.RotateWorld(m3dDegToRad(-5), 0, 1, 0);
        }
        if (key == GLUT_KEY_RIGHT) {
            viewFrame.RotateWorld(m3dDegToRad(5), 0, 1, 0);
        }
        // 3. 重新刷新
        glutPostRedisplay();
}
//第一次创建或者屏幕大小改变
void ChangeSize(int width,int height) {
    if (height == 0) {
        height = 1;
    }
    
    glViewport(0, 0, width, height);
    
    /*
     fFov:垂直⽅向上的视场⻆度
     fAspect:窗口的宽度与高度的纵横比
     fNear:近裁剪⾯距离 （视角到近裁剪面距离为fNear）
     fFar:远裁剪面距离（视角到远裁剪面距离为fFar）
     纵横比 = 宽(w)/⾼(h)
     */
    //创建投影矩阵，并将它载入投影矩阵堆栈中
    viewFrustum.SetPerspective(35, float(width)/(float)height, 1, 1000);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    
    //初始化渲染管线
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}


/*
 // 开启表面剔除（默认背面剔除）
 void glEnable(GL_CULL_FACE);

 // 关闭表面剔除（默认背面剔除）
 void glDisable(GL_CULL_FACE);

 // 用户选择剔除那个面（即可自定义剔除，默认为正面）
 void glCullFace(GLenum mode);
 mode参数为：GL_FRONT, GL_BACK, GL_FRONT_AND_BACK, 默认为GL_BACK

 // 用户也可以指定正面
 void glFrontFace(GLenum mode);
 mode参数为：GL_CW, GL_CCW, 默认为GL_CCW

 // 剔除正面实现
 glCullFace(GL_BACK);
 glFrontFace(GL_CW);
 或
 glCullface(GL_FRONT);

 */

/*
 向量：
 1.点乘：
    两个单位向量之间的点乘运算将得到一个标量（只有一个值），它表示两个向量之间的夹角。
    要进行这种运算，这两个向量必须为单位向量，返回的结果将在-1～1之间，实际上就是这两个向量之间夹角的余弦值
    m3dDotProduct3  余弦值
    m3dGetAngleBetweenVectors3 弧度值
 2.叉乘：
    两个向量之间叉乘所得的结果是另外一个向量，这个新向量与原来两个向量定义的平面垂直。要进行叉乘，这两个向量都不必为单位向量。 与点乘还有一个不同之处是叉乘不符合交换定律即 V1 X V2 != V2 X V1.
    m3dCrossProduct3
 
 矩阵：
 typedef float M3DMatrix33f[9]; typedef float M3DMatrix44f[16];
 视觉坐标
 视图变换
 模型变换
 投影变换
 视口变换
 
 顶点数据 vertex data
 -》顶点着色器 vertex shader
 -〉形状（图元）装配 shape assemebly
 -》几何着色器 geometry shader
 -〉光栅化 rasterization
 -》片段着色器 fragment shader
 -〉测试与混合 tests and blending
 
 */
