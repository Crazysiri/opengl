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

void draw(unsigned int framebuffer,int texture,Shader &screenShader,Shader &shader,GLFWwindow *window);
unsigned int getTexture();
unsigned int getBuffer(unsigned int texture);

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
//    glDepthFunc(GL_ALWAYS); // always pass the depth test (same effect as glDisable(GL_DEPTH_TEST))
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_STENCIL_TEST);
    //面剔除
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK); //剔除正向面
    glFrontFace(GL_CCW);

    
//    glStencilMask(0x00); //禁止写入
//    glStencilMask(0xff); //允许写入

    Shader shader("./shader.vs","./shader.fs");
    Shader screenShader("./screensShader.vs","./screensShader.fs");

    //查询有多少个包含4分量的顶点属性可用
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

//    string path = "./models/nanosuit/nanosuit.obj";
//    Model ourModel(path.c_str());
    unsigned int texture = getTexture();
    unsigned int buffer = getBuffer(texture);
    draw(buffer, texture, screenShader, shader, window);

    return 0;
}

unsigned int getTexture() {
    unsigned int texture;
    glGenTextures(1,&texture);
    glBindTexture(GL_TEXTURE_2D,texture);
    
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,SCR_WIDTH,SCR_HEIGHT,0,GL_RGB,GL_UNSIGNED_BYTE,NULL);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D,0);
    return texture;
}

unsigned int getBuffer(unsigned int texture) {

    unsigned int fbo;
    glGenFramebuffers(1,&fbo);
    glBindFramebuffer(GL_FRAMEBUFFER,fbo);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture,0);
    
    unsigned int rbo;
    glGenRenderbuffers(1,&rbo);
    glBindRenderbuffer(GL_RENDERBUFFER,rbo);
    glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH24_STENCIL8,SCR_WIDTH,SCR_HEIGHT);
    glBindRenderbuffer(GL_RENDERBUFFER,0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_STENCIL_ATTACHMENT,GL_RENDERBUFFER,rbo);
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE)
    {
        if (status == GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT) {
            
        } else if (status == GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT) {
            
        } else if (status == GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER) {
            
        } else if (status == GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER) {
            
        } else if (status == GL_FRAMEBUFFER_UNSUPPORTED) {
            
        }
        
        std::cout << "ERROR::FRAMEBUFFER:: Framebuffer is not complete!" << std::endl;
    }
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    return fbo;
}

void draw(unsigned int framebuffer,int texture,Shader &screenShader,Shader &shader,GLFWwindow *window) {
    
    float quadVertices[] = {
        // positions   // texCoords
        -1.0f,  1.0f,  0.0f, 1.0f,
        -1.0f, -1.0f,  0.0f, 0.0f,
         1.0f, -1.0f,  1.0f, 0.0f,

        -1.0f,  1.0f,  0.0f, 1.0f,
         1.0f, -1.0f,  1.0f, 0.0f,
         1.0f,  1.0f,  1.0f, 1.0f
    };
    unsigned int VAO,VBO;
    glGenVertexArrays(1,&VAO);
    glBindVertexArray(VAO);
    glGenBuffers(1,&VBO);
    glBindBuffer(GL_ARRAY_BUFFER,VBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(quadVertices),&quadVertices,GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,2,GL_FLOAT,GL_FALSE,4 * sizeof(float),(void *)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,4 * sizeof(float),(void *)(2 * sizeof(float)));

    
    screenShader.use();
    screenShader.setInt("screenTexture", 0);

    

    
    float cubeVertices[] = { //逆时针定义的
        // Back face
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, // Bottom-left
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f, // bottom-right
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, // bottom-left
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
        // Front face
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f, // top-right
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f, // top-right
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f, // top-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
        // Left face
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-right
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-left
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-left
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-right
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-right
        // Right face
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-left
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-right
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // bottom-right
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // top-left
         0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-left
        // Bottom face
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // top-right
         0.5f, -0.5f, -0.5f,  1.0f, 1.0f, // top-left
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-left
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f, // bottom-left
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f, // bottom-right
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f, // top-right
        // Top face
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, // top-right
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f, // bottom-right
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f, // top-left
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f  // bottom-left
    };

    float planeVertices[] = {
        // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
         5.0f, 0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, 0.5f,  5.0f,  0.0f, 0.0f,
        -5.0f, 0.5f, -5.0f,  0.0f, 2.0f,

         5.0f, 0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, 0.5f, -5.0f,  0.0f, 2.0f,
         5.0f, 0.5f, -5.0f,  2.0f, 2.0f
    };
    
    float transparentVertices[] = {
        // positions         // texture Coords (swapped y coordinates because texture is flipped upside down)
        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        0.0f, -0.5f,  0.0f,  0.0f,  1.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,

        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,
        1.0f,  0.5f,  0.0f,  1.0f,  0.0f
    };
    
    vector<glm::vec3> vegetation;
    vegetation.push_back(glm::vec3(-1.5f,0.0f,-0.48f));
    vegetation.push_back(glm::vec3(1.5f,0.0f,0.51f));
    vegetation.push_back(glm::vec3(0.0f,0.0f,0.7f));
    vegetation.push_back(glm::vec3(-0.3f,0.0f,-2.3f));
    vegetation.push_back(glm::vec3(0.5f,0.0f,-0.6f));

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
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,5 * sizeof(float),(void *)(3 * sizeof(float)));
    glBindVertexArray(0);
    
    unsigned int grassVAO,grassVBO;
    glGenVertexArrays(1,&grassVAO);
    glGenBuffers(1,&grassVBO);
    glBindVertexArray(grassVAO);
    glBindBuffer(GL_ARRAY_BUFFER,grassVBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(transparentVertices),&transparentVertices,GL_STATIC_DRAW);
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
    
    TextureN grassTexture;
    unsigned int grassTextureId = grassTexture.begin();
    grassTexture.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    grassTexture.setWrap2D(GL_CLAMP_TO_EDGE);
    grassTexture.end("./window.png");
    
    shader.use();
    shader.setInt("texture1", 0);
    
    while (!glfwWindowShouldClose(window)) {
        
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        processInput(window);
        
        glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);
        glEnable(GL_DEPTH_TEST);
        
                
        glClearColor(0.1f,0.1f,0.1f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/SCR_HEIGHT , 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glm::mat4 model = glm::mat4(1.0);
        shader.use();
        shader.setMat4("projection", projection);
        shader.setMat4("view", view);
        
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
        //floor
        glBindVertexArray(planeVAO);
        glBindTexture(GL_TEXTURE_2D,floorTextureId);
        glm::mat4 m(1.0);
        shader.setMat4("model", m);
        glDrawArrays(GL_TRIANGLES,0,6);
        glBindVertexArray(0);

        glDepthMask(GL_FALSE); //禁止写入
        glBindVertexArray(grassVBO);
        glBindTexture(GL_TEXTURE_2D,grassTextureId);
        for (unsigned int i = 0; i < vegetation.size(); i++)
         {
             model = glm::mat4(1.0f);
             model = glm::translate(model, vegetation[i]);
             shader.setMat4("model", model);
             glDrawArrays(GL_TRIANGLES, 0, 6);
         }
        glDepthMask(GL_TRUE); //禁止写入
        
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glDisable(GL_DEPTH_TEST);
        glClearColor(1.0f,1.0f,1.0f,1.0f); //为什么这里会无效？还是说被texture 覆盖了
        glClear(GL_COLOR_BUFFER_BIT);

        screenShader.use();
        glBindVertexArray(VAO);
        glBindTexture(GL_TEXTURE_2D, texture);    // use the color attachment texture as the texture of the quad plane
        glDrawArrays(GL_TRIANGLES, 0, 6);

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
 帧缓冲：
    unsigned int fbo;
    glGenFramebuffers(1,&fbo);
    glBindFramebuffer(GL_FRAMEBUFFER,fbo);
    //检查framebuffer完整性
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE) {
    
    }
 
    //激活
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    glDeleteFramebuffers(1,&fbo);
 
    //纹理附件
    * 当把一个纹理附加到帧缓冲的时候，所有的渲染指令将会写入到这个纹理中，就想它是一个普通的颜色/深度或模板缓冲一样。使用纹理的优点是，所有渲染操作的结果将会被储存在一个纹理图像中，我们之后可以在着色器中很方便地使用它。
    unsigned int texture;
    glGenTextures(1,&texture);
    glBindTexture(GL_TEXTURE_2D,texture);
    
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,800,600,0,GL_RGB,GL_UNSIGNED_BYTE,NULL);
 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_FILTER,GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D,0); //释放掉

     *上面这个纹理和普通纹理主要区别：
         1.维度设置成屏幕的大小（800，600）
         2.纹理的data传了null，仅仅分配内存并没有填充
 
    //将纹理附件添加到缓冲区
    glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture,0);
        arget：帧缓冲的目标（绘制、读取或者两者皆有）
        attachment：我们想要附加的附件类型。当前我们正在附加一个颜色附件。注意最后的0意味着我们可以附加多个颜色附件。我们将在之后的教程中提到。
        textarget：你希望附加的纹理类型
        texture：要附加的纹理本身
        level：多级渐远纹理的级别。我们将它保留为0。

        //将一个深度和模版缓冲附加到缓冲上的例子
        glTexImage2D(
          GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, 800, 600, 0,
          GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, NULL
        );

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, texture, 0);

 
    一个完整的buffer需要下面：
        附加至少一个缓冲（颜色、深度或模板缓冲）。
        至少有一个颜色附件(Attachment)。
        所有的附件都必须是完整的（保留了内存）。
        每个缓冲都应该有相同的样本数。
 
    我们的帧缓冲不是默认缓冲，渲染指定将不会对窗口的视觉输出有任何影响，出于这个原因，渲染到一个不同的帧缓冲被叫做离屏渲染 off-screen rendering
    * 要保证所有的渲染操作都在主窗口有视觉效果，我们需要再次激活默认帧缓冲，将它绑定到0 ： glBindFramebuffer(GL_FRAMEBUFFER, 0);
    * 记得要解绑帧缓冲，保证我们不会不小心渲染到错误的帧缓冲上。：glBindFramebuffer(GL_FRAMEBUFFER, 0);
    * 如果你忽略了深度缓冲，那么所有的深度测试操作将不再工作，因为当前绑定的帧缓冲中不存在深度缓冲。
  */

/*
 渲染缓冲对象附件：
    为离屏渲染到帧缓冲优化过
    通常只写到
    比较适合深度和模版（因为不怎么关心读只关心测试）
    
    unsigned int rbo;
    glGenRenderbuffers(1,&rbo);
    //绑定这个渲染缓冲，让之后所有的渲染缓冲操作影响当前rbo
    glBindRenderbuffer(GL_RENDERBUFFER,rbo);
    //创建
    glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH24_STENCIL8,800,600);
    //附加这个渲染缓冲对象
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_STENCIL_ATTACHMENT,GL_RENDERBUFFER,rbo);
    glBindRenderbuffer(GL_RENDERBUFFER,0);

    通常不需要读取数据用 渲染缓冲对象。
 */


/*
 个人理解帧缓冲：
    3d - 自建framebuffer - 2d texture - 切换主framebuffer（自建framebuffer无法渲染到屏幕也称离屏渲染） - 把 2d texture 绘制上去
 */
