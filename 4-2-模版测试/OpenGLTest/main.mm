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
#include "Mesh.h"
//#include "AssimpModel.h"
//#include <glad/glad.h>

Camera camera(glm::vec3(0.0,-1.0,8.0f));

using namespace std;

// settings
const unsigned int SCR_WIDTH = 800.0;
const unsigned int SCR_HEIGHT = 600.0;
void processInput(GLFWwindow *window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void scroll_callback(GLFWwindow *window,double xoffset,double yoffset);

float lastX = (float)SCR_WIDTH  / 2.0;
float lastY = (float)SCR_HEIGHT / 2.0;
bool firstMouse = true;

// timing
float deltaTime = 0.0f;
float lastFrame = 0.0f;

void draw(Shader &borderShader,Shader &shader,GLFWwindow *window);

int main(int argc, char * argv[]) {
    
//    Assimp::Importer importer;
//    const aiScene *scene = importer.ReadFile("", aiProcess_Triangulate);

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
    
//    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    
//    glfwSetCursorPosCallback(window, mouse_callback);
    
    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "failed to initialize glad" << std::endl;
        return -1;
    }
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
//    glDepthFunc(GL_ALWAYS); // always pass the depth test (same effect as glDisable(GL_DEPTH_TEST))

//    glStencilMask(0x00); //禁止写入
//    glStencilMask(0xff); //允许写入
    Shader shader("./shader.vs","./shader.fs");
    Shader borderShader("./ShaderSingleColor.vs","./ShaderSingleColor.fs");

    //查询有多少个包含4分量的顶点属性可用
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

//    string path = "./models/nanosuit/nanosuit.obj";
//    Model ourModel(path.c_str());

    draw(borderShader,shader,window);

    return 0;
}
void draw(Shader &borderShader,Shader &shader,GLFWwindow *window) {
    
    float cubeVertices[] = {
        // positions          // texture Coords
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
    float planeVertices[] = {
        // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
         5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f,  5.0f,  0.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,

         5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
         5.0f, -0.5f, -5.0f,  2.0f, 2.0f
    };
    
    unsigned int cubeVAO,cubeVBO;
    glGenVertexArrays(1,&cubeVAO);
    glGenBuffers(1,&cubeVBO);
    glBindVertexArray(cubeVAO);
    glBindBuffer(GL_ARRAY_BUFFER,cubeVBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(cubeVertices),&cubeVertices,GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void *)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void *)(3 * sizeof(float)));
    glBindVertexArray(0);
    
    unsigned int planeVAO,planeVBO;
    glGenVertexArrays(1,&planeVAO);
    glGenBuffers(1,&planeVBO);
    glBindVertexArray(planeVAO);
    glBindBuffer(GL_ARRAY_BUFFER,planeVBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(planeVertices),&planeVertices,GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void *)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void *)(3 * sizeof(float)));
    glBindVertexArray(0);
    

    TextureN cubeTexture;
    unsigned int cubeTextureId = cubeTexture.begin();
    cubeTexture.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    cubeTexture.setWrap2D(GL_REPEAT);
    cubeTexture.end("./marble.jpg");
    
    TextureN floorTexture;
    unsigned int floorTextureId = floorTexture.begin();
    floorTexture.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    floorTexture.setWrap2D(GL_REPEAT);
    floorTexture.end("./metal.png");
    
    shader.use();
    shader.setInt("texture1", 0);
    
    while (!glfwWindowShouldClose(window)) {
        
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        processInput(window);
                
        glClearColor(0.1f,0.1f,0.1f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/SCR_HEIGHT , 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glm::mat4 model = glm::mat4(1.0);
        shader.setMat4("projection", projection);
        shader.setMat4("view", view);
        
        borderShader.use();
        borderShader.setMat4("projection", projection);
        borderShader.setMat4("view", view);
        
//        glStencilMask(0x00);
        
        shader.use();
        //floor
        glBindVertexArray(planeVAO);
        glBindTexture(GL_TEXTURE_2D,floorTextureId);
        glm::mat4 m(1.0);
        shader.setMat4("model", m);
        glDrawArrays(GL_TRIANGLES,0,6);
        glBindVertexArray(0);
        
        //1.在绘制（需要添加轮廓的）物体之前，将模板函数设置为GL_ALWAYS，每当物体的片段被渲染时，将模板缓冲更新为1。
        glStencilFunc(GL_ALWAYS,1,0xff);
        glStencilMask(0xff);
        //cube
        glBindVertexArray(cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D,cubeTextureId);
        model = glm::translate(model, glm::vec3(-1.0f,0.01f,-1.0f));
        shader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);
        model = glm::mat4(1.0f);
        model = glm::translate(model, glm::vec3(2.0f,0.01f,0.0f));
        shader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);

        //3.禁用模板写入以及深度测试。(不等于1才绘制）
        glStencilFunc(GL_NOTEQUAL,1,0xff);
        glStencilMask(0x00);
        glDisable(GL_DEPTH_TEST);
        borderShader.use();
        float scale = 1.1;
        glBindVertexArray(cubeVAO);
        glBindTexture(GL_TEXTURE_2D,cubeTextureId);
        model = glm::mat4(1.0f);
        model = glm::translate(model, glm::vec3(-1.0f,0.01f,-1.0f));
        model = glm::scale(model, glm::vec3(scale, scale, scale));
        borderShader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);
        model = glm::mat4(1.0f);
        model = glm::translate(model, glm::vec3(2.0f,0.01f,0.0f));
        model = glm::scale(model, glm::vec3(scale, scale, scale));
        borderShader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);
        glBindVertexArray(0);
        glStencilMask(0xff);
        glStencilFunc(GL_ALWAYS, 0, 0xFF);
        glEnable(GL_DEPTH_TEST);
        shader.use(); //这里加上这一句为了保证所有物体都随着鼠标动（不加不知道为什么上面绘制的不动。。。）

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    

    glfwTerminate();
}


void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.ProcessKeyboard(FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.ProcessKeyboard(BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.ProcessKeyboard(LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.ProcessKeyboard(RIGHT, deltaTime);
}


void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // reversed since y-coordinates go from bottom to top

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
 深度测试：
    它会以16，24或32位float形式存储。大部分系统中默认是24位
    深度测试默认关闭，当启用时，opengl 会将一个片段的深度值与深度缓冲对比，测试通过深度缓冲会更新该值，失败抛弃该片段。
    深度缓冲是在片段着色器运行之后（以及模版测试运行之后）在屏幕空间中运行。
    屏幕空间坐标与通过opengl的glviewport所定义的视口密切相关，并且可以直接使用glsl内建变量gl_fragCoord（0，0）位于左下角？（查看一下mac ios相关坐标系）
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //进行深度测试并丢弃相应片段，但不希望更新深度缓冲
    glDepthMask(GL_FALSE); //禁止写入
    glDepthFunc(GL_LESS); //默认GL_LESS GL_ALWAYS ..

    深度值精度：
        Fdepth = (z - near) / (far - near);
        这个线形方程 将z变换到 0.0-1.0之间

        在实践中几乎不会用线性深度缓冲，即在z值很小的时候有很大的精度
        Fdepth = (1/z - 1/near) / (1/far - 1/near);
        在1.0-2.0之间的值会变换到 1.0-0.5之间
    深度冲突：
        Z-fighting
        由于精度不足导致 两个z 一样，例如箱子和地板同一高度 即共面，深度测试没办法决定该显示哪一个
    防止深度冲突：
        1.不要把物体靠的太近
        2.尽可能将平面设置远一些
        3.使用高精度的深度缓冲
 模版测试：
    有自己的缓冲，叫模版缓冲
    每个模版值是8位的，所以每个像素/片段一共能有256种不同的模板值
    使用步骤：
        启用模板缓冲的写入。
        渲染物体，更新模板缓冲的内容。
        禁用模板缓冲的写入。
        渲染（其它）物体，这次根据模板缓冲的内容丢弃特定的片段。
 
     //和下面设置的掩码进行 and 运算
     glStencilMask(0x00); //禁止写入
     glStencilMask(0xff); //允许写入
 glStencilFunc(GLenum func, GLint ref, GLuint mask)一共包含三个参数：
 func：设置模板测试函数(Stencil Test Function)。这个测试函数将会应用到已储存的模板值上和glStencilFunc函数的ref值上。可用的选项有：GL_NEVER、GL_LESS、GL_LEQUAL、GL_GREATER、GL_GEQUAL、GL_EQUAL、GL_NOTEQUAL和GL_ALWAYS。它们的语义和深度缓冲的函数类似。
 ref：设置了模板测试的参考值(Reference Value)。模板缓冲的内容将会与这个值进行比较。
 mask：设置一个掩码，它将会与参考值和储存的模板值在测试比较它们之前进行与(AND)运算。初始情况下所有位都为1。

 glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass)一共包含三个选项，我们能够设定每个选项应该采取的行为：
 sfail：模板测试失败时采取的行为。
 dpfail：模板测试通过，但深度测试失败时采取的行为。
 dppass：模板测试和深度测试都通过时采取的行为。
 
     GL_KEEP    保持当前储存的模板值
     GL_ZERO    将模板值设置为0
     GL_REPLACE    将模板值设置为glStencilFunc函数设置的ref值
     GL_INCR    如果模板值小于最大值则将模板值加1
     GL_INCR_WRAP    与GL_INCR一样，但如果模板值超过了最大值则归零
     GL_DECR    如果模板值大于最小值则将模板值减1
     GL_DECR_WRAP    与GL_DECR一样，但如果模板值小于0则将其设置为最大值
     GL_INVERT    按位翻转当前的模板缓冲值

    轮廓的步骤如下：

    1.在绘制（需要添加轮廓的）物体之前，将模板函数设置为GL_ALWAYS，每当物体的片段被渲染时，将模板缓冲更新为1。
    2.渲染物体。
    3.禁用模板写入以及深度测试。
    4.将每个物体缩放一点点。
    5.使用一个不同的片段着色器，输出一个单独的（边框）颜色。
    6.再次绘制物体，但只在它们片段的模板值不等于1时才绘制。
    7.再次启用模板写入和深度测试。
 
 */
