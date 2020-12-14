//
//  main.m
//  OpenGLTest
//
//  Created by Zero on 2020/11/3.
//  Copyright © 2020 Lenz. All rights reserved.
//

#include <iostream>

//#include <math3d.h>
//#include <OpenGL/gl.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <math.h>

#include "Shader.h"
#include "Texture.h"
#include "Camera.h"
//#include <glad/glad.h>

Camera camera(glm::vec3(0.0,0.0,3.0f));
float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间

float lastX = 400;
float lastY = 300;


using namespace std;

// settings
const unsigned int SCR_WIDTH = 800.0;
const unsigned int SCR_HEIGHT = 600.0;
void processInput(GLFWwindow *window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void framebuffer_size_callback(GLFWwindow* window, int width, int height);

void indices(int program,GLFWwindow *window);
void draw(Shader &shader,GLFWwindow *window);

int main(int argc, char * argv[]) {
//    glm::vec4 vec(1.0f,0.0f,0.0f,1.0f);
//    glm::mat4 trans = glm::mat4(1.0f);
//
//    trans = glm::translate(trans, glm::vec3(1.0f,1.0f,0.0f));
//    vec = trans * vec;
//    std::cout << vec.x << vec.y << vec.z << std::endl;
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    
    GLFWwindow *window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    if (window == NULL) {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    
    glfwSetCursorPosCallback(window, mouse_callback);
    
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "failed to initialize glad" << std::endl;
        return -1;
    }
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_DEPTH_TEST);

    
    Shader shader("./shader.vs","./shader.fs");
    
    //查询有多少个包含4分量的顶点属性可用
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

//    indices(shaderProgram,window);
    draw(shader,window);

    return 0;
}

void draw(Shader &shader,GLFWwindow *window) {
//    float vertices[] = {
////      ---- 位置 -----    ----- 颜色 -----    -- 纹理坐标 --
//        0.5f,0.5f,0.0f, 1.0f,0.0f,0.0f, 2.0f,2.0f, //右上
//        0.5f,-0.5f,0.0f, 0.0f,1.0f,0.0f, 2.0f,0.0f, //右下
//        -0.5f,-0.5f,0.0f, 0.0f,0.0f,1.0f, 0.0f,0.0f, //左下
//        -0.5f,0.5f,0.0f, 1.0f,1.0f,1.0f, 0.0f,2.0f //左上
//    };
//
    float vertices[] = {
//      ---- 位置 -----    -- 纹理坐标 --

        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };

    unsigned int indices[] = {
        0,1,3,
        1,2,3
    };
    
    int nums = 1;
    
    unsigned int VBOs[nums],VAOs[nums],EBOs[nums];
    glGenVertexArrays(nums,VAOs);
    glGenBuffers(nums,VBOs);
    
    glGenBuffers(nums,EBOs);
        
    for (int i = 0; i < nums; i++) {
                
        glBindVertexArray(VAOs[i]);
        glBindBuffer(GL_ARRAY_BUFFER,VBOs[i]);
        glBufferData(GL_ARRAY_BUFFER,sizeof(vertices),vertices,GL_STATIC_DRAW);
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,EBOs[i]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,sizeof(indices),indices,GL_STATIC_DRAW);
        
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void*)0);
        glEnableVertexAttribArray(0);
//        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)(3 * sizeof(float)));
//        glEnableVertexAttribArray(1);
        glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(2);
        

        
    }

    Texture t;
    unsigned int texture1 = t.begin();
    t.setWrap2D(GL_REPEAT);
    t.setFilter(GL_LINEAR);
    t.end("./wall.jpg");
    
    Texture t1;
    unsigned int texture2 = t1.begin(GL_TEXTURE1);
    t1.setWrap2D(GL_REPEAT);
    t1.setFilter(GL_NEAREST);
    t1.end("./1.png");
    
    shader.use();
    glUniform1i(glGetUniformLocation(shader.ID,"texture1"),0);
    shader.setInt("texture2", 1);
//    glm::mat4 trans(1.0f);
//    trans = glm::rotate(trans, glm::radians(90.0f), glm::vec3(0.0f,0.0f,1.0f));
//    trans = glm::scale(trans, glm::vec3(0.5,0.5,0.5));
//    glUniformMatrix4fv(glGetUniformLocation(shader.ID,"transform"),1,GL_FALSE,glm::value_ptr(trans));


    glm::vec3 cubePositions[] = {
      glm::vec3( 0.0f,  0.0f,  0.0f),
      glm::vec3( 2.0f,  5.0f, -15.0f),
      glm::vec3(-1.5f, -2.2f, -2.5f),
      glm::vec3(-3.8f, -2.0f, -12.3f),
      glm::vec3( 2.4f, -0.4f, -3.5f),
      glm::vec3(-1.7f,  3.0f, -7.5f),
      glm::vec3( 1.3f, -2.0f, -2.5f),
      glm::vec3( 1.5f,  2.0f, -2.5f),
      glm::vec3( 1.5f,  0.2f, -1.5f),
      glm::vec3(-1.3f,  1.0f, -1.5f)
    };
    
    while (!glfwWindowShouldClose(window)) {
        
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        processInput(window);
        
        glClearColor(0.2f,0.3f,0.3f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D,texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D,texture2);
        
        shader.use();
#if D2 //2d
        glm::mat4 trans(1.0f);
        //这里实际的变换顺序是相反的：是先旋转 再移动
        trans = glm::translate(trans, glm::vec3(0.5,-0.5,0.0));
        trans = glm::rotate(trans, (float)glfwGetTime(), glm::vec3(0.0f,0.0f,1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shader.ID,"transform"),1,GL_FALSE,glm::value_ptr(trans));
#else
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/SCR_HEIGHT , 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glUniformMatrix4fv(glGetUniformLocation(shader.ID,"view"),1,GL_FALSE,glm::value_ptr(view));
        glUniformMatrix4fv(glGetUniformLocation(shader.ID,"projection"),1,GL_FALSE,glm::value_ptr(projection));

#endif
        
        glBindVertexArray(VAOs[0]);
//        glDrawArrays(GL_TRIANGLES,0,36);
        for(unsigned int i = 0; i < 10; i++)
        {
            glm::mat4 model(1.0);
          model = glm::translate(model, cubePositions[i]);
          float angle = 20.0f * i;
          model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
          glUniformMatrix4fv(glGetUniformLocation(shader.ID,"model"),1,GL_FALSE,glm::value_ptr(model));

          glDrawArrays(GL_TRIANGLES, 0, 36);
        }
//        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    
    glDeleteVertexArrays(nums,VAOs);
    glDeleteBuffers(nums,VBOs);
    glDeleteBuffers(nums,EBOs);
    glfwTerminate();
}


void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    
    float cameraSpeed = 2.5 * deltaTime; // adjust accordingly
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.ProcessKeyboard(FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.ProcessKeyboard(BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.ProcessKeyboard(LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.ProcessKeyboard(RIGHT, deltaTime);
}

bool firstMouse = true;

void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    
    if(firstMouse) // 这个bool变量初始时是设定为true的
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
    
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;
    lastX = xpos;
    lastY = ypos;
    
    camera.ProcessMouseMovement(xoffset, yoffset);
}

void scroll_callback(GLFWwindow *window,double xoffset,double yoffset) {
    camera.ProcessMouseScroll(yoffset);
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    // make sure the viewport matches the new window dimensions; note that width and
    // height will be significantly larger than specified on retina displays.
    glViewport(0, 0, width, height);
}

/*
 向量：
 
 https://blog.csdn.net/weixin_42125757/article/details/80179147
 尽量满足乘法三定律：分配律 交换律 结合律
 点乘：
   结果是标量 不是 向量的原因：向量的交换律不成立（a在b方向的分量和b在a方向的分量不一样）
 
    用来计算向量角度 v¯⋅k¯=||v¯||⋅||k¯||⋅cosθ
    ｜ 0.6 ｜       ｜ 0｜
    ｜-0.8 ｜ .     ｜ 1｜  = (0.6 * 0) + (-0.8 * 1) + (0 * 0) = -0.8
    ｜ 0   ｜       ｜ 0｜
 
 
 叉乘：
    需要两个不平行向量作为输入，生成一个正交于两个输入向量的第三个向量。
 
   | Ax |   | Bx |   | Ay * Bz - Az * By |
   | Ay | x | By | = | Az * Bx - Ax * Bz |
   | Az |   | Bz |   | Ax * By - Ay * Bx |

 矩阵：
 (i,j) i 是行 j是列 (2 x 3 矩阵）
 | 1 2 3 |
 | 4 5 6 |
 
 矩阵与矩阵的加减法 只有在同维度的矩阵才有意义
 
 单位矩阵：一个除了对角线意外都是 0 的n * n 的矩阵
                (S1,S2,S3) 缩放因子 (Tx,Ty,Tz) 平移因子
 | 1 0 0 0| | S1 0 0 Tx|
 | 0 1 0 0| | 0 S2 0 Ty|
 | 0 0 1 0| | 0 0 S3 Tz|
 | 0 0 0 1| | 0 0  0 1|

 x轴：
 | 1   0      0    0 |
 | 0  cosθ  -sinθ  0 |
 | 0  sinθ   cosθ  0 |
 | 0   0      0    1 |
 y轴：
 | cosθ   0   sinθ  0 |
 | 0      1    0    0 |
 | -sinθ  0   cosθ  0 |
 | 0      0    0    1 |
 z轴：
 | cosθ -sinθ  0    0 |
 | sinθ  cosθ  0    0 |
 |  0      0   1    0 |
 |  0      0   0    1 |
 
 矩阵与矩阵的乘法：
  1.只有当左侧的矩阵的列数与右侧的矩阵的行数相等才能相乘
  2.矩阵相乘不遵守交换律
  | Ax Bx |  .  | Cx Dx |  =  | Ax * Cx + Bx * Cy, Ax * Dx + Bx * Dy |
  | Ay By |     | Cy Dy |     | Ay * Cx + By * Cy, Ay * Dx + By * Dy |
 
  | Ax Bx | .  | Cx | = | Ax * Cx + Bx * Cy |
  | Ay By |    | Cy |   | Ay * Cx + By * Cy |
 
 结果矩阵的维度 是 （n,m) n 是左侧矩阵的行数，m 是右侧矩阵的列数
 
 
 坐标系统：
 对我们比较重要的5个系统：
 局部空间 local space / object space
 世界空间 world space
 观察空间 view space / eye space / 摄像机
 剪裁空间 clip space
 屏幕空间 screen space
 
 为了从一个系统变换到另一个系统，这里需要几个矩阵 模型（model），观察（view），投影（projection）
 
 顶点坐标起始于局部空间，称为局部坐标 local coordinate
 local space -> [model matrix] -> world space -> [view matrix] -> view space -> [projection matrix] -> clip space -> viewport transform（视口变换过程） -> screen space
 在 clip space 坐标会被处理成-1.0到 1.0的范围内
 视口变换过程 将 -1.0到1.0范围内的坐标 变换到 glViewPort定义到坐标内
 最后变换出来的坐标将会送到光栅器，将其转换为片段。
 
 由投影矩阵 创建的观察箱 称为 平截头体 Frustum
 
 projection matrix 分为 正交投影矩阵 Orthographic 和 透视投影矩阵 Perspective
 
 //正交投影矩阵（主要用于二维渲染和一些建筑或工程的程序）
 glm::ortho(0.0f, 800.0f, 0.0f, 600.0f, 0.1f, 100.0f);
 前两个参数指定了平截头体的左右坐标，第三和第四参数指定了平截头体的底部和顶部。通过这四个参数我们定义了近平面和远平面的大小，然后第五和第六个参数则定义了近平面和远平面的距离
 
 
 //透视投影矩阵
 w分量：1.帮助移动，2.进行透视投影
 glm::mat4 proj = glm::perspective(glm::radians(45.0f), (float)width/(float)height, 0.1f, 100.0f);
https://learnopengl-cn.github.io/01%20Getting%20started/08%20Coordinate%20Systems/
 它的第一个参数定义了fov的值，它表示的是视野(Field of View)，并且设置了观察空间的大小。如果想要一个真实的观察效果，它的值通常设置为45.0f，但想要一个末日风格的结果你可以将其设置一个更大的值。第二个参数设置了宽高比，由视口的宽除以高所得。第三和第四个参数设置了平截头体的近和远平面。我们通常设置近距离为0.1f，而远距离设为100.0f。所有在近平面和远平面内且处于平截头体内的顶点都会被渲染。
 
 注：
    当你把透视矩阵的 near 值设置太大时（如10.0f），OpenGL会将靠近摄像机的坐标（在0.0f和10.0f之间）都裁剪掉，这会导致一个你在游戏中很熟悉的视觉效果：在太过靠近一个物体的时候你的视线会直接穿过去。
 
 
 把上面的组合到一起：
    Vclip = Mprojection ⋅ Mview ⋅ Mmodel ⋅ Vlocal （矩阵的运算时相反的）
    最后的顶点应该被赋值到顶点着色器到gl_Position OpenGL将会自动进行透视剔除法和剪裁
 
  */

