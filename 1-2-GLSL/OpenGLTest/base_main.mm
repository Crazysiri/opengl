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

GLTriangleBatch torusBatch;

//#include <GLUT/glut.h>

void ChangeSize(int width,int height);
void SpecialKeys(int a,int b,int c);
void RenderScene();
void SetupRC();
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
    glClearColor(0.3, 0.3, 0.3, 1);
    
    shaderManager.InitializeStockShaders();
    
    //将相机向后移动7个单元肉眼到物体的距离
    viewFrame.MoveForward(5.0);
    
    gltMakeTorus(torusBatch, 1, 0.3, 88, 33);
    
    glPointSize(4.0);
}

void RenderScene() {
    //清除窗口和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_CULL_FACE); //正背面剔除
    glEnable(GL_DEPTH_TEST); //深度测试
    glCullFace(GL_BACK);
    
    //把相机矩阵压入模型矩阵中
    modelViewMatrix.PushMatrix(viewFrame);
    
    GLfloat vRed[] = {1,0,0,1};
    //平面着色器
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT,transformPipeline.GetModelViewMatrix(),transformPipeline.GetProjectionMatrix(),vRed);
    torusBatch.Draw();
    //出栈，绘制完成恢复
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
 */
