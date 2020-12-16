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
//#include <glad/glad.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

using namespace std;

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;
void processInput(GLFWwindow *window);

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
    
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "failed to initialize glad" << std::endl;
        return -1;
    }
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    
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
    float vertices[] = {
//      ---- 位置 -----    ----- 颜色 -----    -- 纹理坐标 --
        0.5f,0.5f,0.0f, 1.0f,0.0f,0.0f, 2.0f,2.0f, //右上
        0.5f,-0.5f,0.0f, 0.0f,1.0f,0.0f, 2.0f,0.0f, //右下
        -0.5f,-0.5f,0.0f, 0.0f,0.0f,1.0f, 0.0f,0.0f, //左下
        -0.5f,0.5f,0.0f, 1.0f,1.0f,1.0f, 0.0f,2.0f //左上
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
        
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)0);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)(6 * sizeof(float)));
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


    while (!glfwWindowShouldClose(window)) {
        
        processInput(window);
        
        glClearColor(0.2f,0.3f,0.3f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D,texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D,texture2);
        
        shader.use();
        
        glm::mat4 trans(1.0f);
        //这里实际的变换顺序是相反的：是先旋转 再移动
        trans = glm::translate(trans, glm::vec3(0.5,-0.5,0.0));
        trans = glm::rotate(trans, (float)glfwGetTime(), glm::vec3(0.0f,0.0f,1.0f));
        glUniformMatrix4fv(glGetUniformLocation(shader.ID,"transform"),1,GL_FALSE,glm::value_ptr(trans));

        
        glBindVertexArray(VAOs[0]);
//        glDrawArrays(GL_TRIANGLES,0,3);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        
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

 乘法：
    在glsl中可能存在：vec3 * vec3这样的形式：
    vec3(1.0,1.0,1.0) * vec3(0.0,1.0,0.0) = vec3(0.0,1.0,0.0)
    反射光 = 自然光 * 绿色光 = 绿色光
    element wise multiplication
 
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
 
 
  */

