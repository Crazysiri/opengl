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
#include "TextureCube.h"
#include "Camera.h"
#include "Mesh.h"
#include "AssimpModel.h"
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
    
    Shader robotShader("./robotShader.vs","./robotShader.fs");
    Model robotModel("./nanosuit_reflection/nanosuit.obj");
    
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

    

    
    float cubeVertices[] = {
            -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
             0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
             0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
             0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
            -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
            -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,

            -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
             0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
             0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
             0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
            -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
            -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,

            -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
            -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
            -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
            -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
            -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
            -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,

             0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
             0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
             0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
             0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
             0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
             0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,

            -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
             0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
             0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
             0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
            -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
            -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,

            -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
             0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
             0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
             0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
            -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
            -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
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

    unsigned int cubeVAO,cubeVBO;
    glGenVertexArrays(1,&cubeVAO);
    glGenBuffers(1,&cubeVBO);
    glBindVertexArray(cubeVAO);
    glBindBuffer(GL_ARRAY_BUFFER,cubeVBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(cubeVertices),&cubeVertices,GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,6 * sizeof(float),(void *)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,6 * sizeof(float),(void *)(3 * sizeof(float)));
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
    

    TextureN cubeTexture;
    cubeTexture.begin();
    cubeTexture.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    cubeTexture.setWrap2D(GL_REPEAT);
    cubeTexture.end("./marble.jpg");
    
    TextureN floorTexture;
    floorTexture.begin();
    floorTexture.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    floorTexture.setWrap2D(GL_REPEAT);
    floorTexture.end("./metal.png");
    
    shader.use();
    shader.setInt("skybox", 0);
    
    /*
     draw skybox
     */
    
    float skyboxVertices[] = {
        // positions
        -1.0f,  1.0f, -1.0f,
        -1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,

        -1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,

         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,

        -1.0f, -1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,

        -1.0f,  1.0f, -1.0f,
         1.0f,  1.0f, -1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f, -1.0f,

        -1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
         1.0f, -1.0f,  1.0f
    };
    
    Shader skyboxShader("./skyboxShader.vs","./skyboxShader.fs");
    
    vector<std::string> faces{
        "./right.jpg",
        "./left.jpg",
        "./bottom.jpg",
        "./top.jpg",
        "./front.jpg",
        "./back.jpg"
    };
    TextureCube cube;
    cube.begin();
    cube.setFilter(GL_LINEAR);
    cube.setWrap2D(GL_CLAMP_TO_EDGE);
    cube.end(faces);
    
    unsigned int skyVAO,skyVBO;
    glGenVertexArrays(1,&skyVAO);
    glGenBuffers(1,&skyVBO);
    glBindVertexArray(skyVAO);
    glBindBuffer(GL_ARRAY_BUFFER,skyVBO);
    glBufferData(GL_ARRAY_BUFFER,sizeof(skyboxVertices),&skyboxVertices,GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,3 * sizeof(float),(void *)0);
    glBindVertexArray(0);
    
    skyboxShader.use();
    skyboxShader.setInt("skybox", 0);
    
    /*
     end draw skybox
     */
    
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
        shader.setVec3("cameraPos", camera.Position);

        glActiveTexture(GL_TEXTURE0);

        //cube
        glBindVertexArray(cubeVAO);
        cubeTexture.use();
        model = glm::translate(model, glm::vec3(-1.0f,0.01f,-1.0f));
        shader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);
        model = glm::mat4(1.0f);
        model = glm::translate(model, glm::vec3(2.0f,0.01f,0.0f));
        shader.setMat4("model", model);
        glDrawArrays(GL_TRIANGLES,0,36);
        //floor
        glBindVertexArray(planeVAO);
        floorTexture.use();
        glm::mat4 m(1.0);
        shader.setMat4("model", m);
        glDrawArrays(GL_TRIANGLES,0,6);
        
        robotShader.use();
        robotShader.setMat4("projection", projection);
        robotShader.setMat4("view", view);
        model = glm::mat4(1.0f);
        model = glm::scale(model, glm::vec3(0.2f, 0.2f, 0.2f));    // it's a bit too big for our scene, so scale it down
        model = glm::rotate(model, glm::radians(180.0f), glm::vec3(1.0,0.0,0.0));
        model = glm::translate(model, glm::vec3(0.0f, -2.5f, 0.0f)); // translate it down so it's at the center of the scene

        robotShader.setMat4("model", model);
        robotModel.Draw(robotShader);

        glDepthMask(GL_FALSE); //禁止写入
        
        //绘制天空盒子start 绘制需要 GL_LEQUAL GL_LESS
        glDepthFunc(GL_LEQUAL);  // change depth function so depth test passes when values are equal to depth buffer's content
        skyboxShader.use();
        view = glm::mat4(glm::mat3(camera.GetViewMatrix())); // remove translation from the view matrix
        skyboxShader.setMat4("view", view);
        skyboxShader.setMat4("projection", projection);
        glBindVertexArray(skyVAO);
        cube.use();
        glDrawArrays(GL_TRIANGLES,0,36);
        glDepthFunc(GL_LESS); // set depth function back to default
        //绘制天空盒子end
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
 立方体贴图：
 在坐标系统小节中我们说过，透视除法是在顶点着色器运行之后执行的，将gl_Position的xyz坐标除以w分量。我们又从深度测试小节中知道，相除结果的z分量等于顶点的深度值。使用这些信息，我们可以将输出位置的z分量等于它的w分量，让z分量永远等于1.0，这样子的话，当透视除法执行之后，z分量会变为w / w = 1.0。
 void main()
 {
     TexCoords = aPos;
     vec4 pos = projection * view * vec4(aPos, 1.0);
     gl_Position = pos.xyww;
 }
 
 反射：
 vec3 I = normalize(Position - cameraPos); //观察向量
 vec3 R = reflect(I, normalize(Normal));
 FragColor = vec4(texture(skybox, R).rgb, 1.0);
 //法线矩阵
 Normal = mat3(transpose(inverse(model))) * aNormal;
 Position = vec3(model * vec4(aPos, 1.0));
 gl_Position = projection * view * model * vec4(aPos, 1.0);
 折射：
 float ratio = 1.00 / 1.52; //两个材质的折射率
 vec3 I = normalize(Position - cameraPos);
 vec3 R = refract(I, normalize(Normal), ratio); //折射向量
 FragColor = vec4(texture(skybox, R).rgb, 1.0);
 
 动态环境贴图：
 通过帧缓冲，为物体的6个不同角度创建场景的纹理，并在每个渲染迭代中将它们存储到一个立方体贴图中
*/

/*
 高级数据：
   
    如果将 glBufferData 中 data 设置为null，那么只会分配内存，不进行填充
    可以使用 glBufferSubData 填充特定区域
    缓冲目标，偏移量，数据大小 核 数据本身
    例如：glBufferSubData(GL_ARRAY_BUFFER, 24, sizeof(data), &data); // 范围： [24, 24 + sizeof(data)]
    
    还有另一种方法： glMapBuffer
        float data[] = {
          0.5f, 1.0f, -0.35f
          ...
        };
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        // 获取指针
        void *ptr = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
        // 复制数据到内存
        memcpy(ptr, data, sizeof(data));
        // 记得告诉OpenGL我们不再需要这个指针了
        glUnmapBuffer(GL_ARRAY_BUFFER);
    
   分批顶点属性：
    glBufferSubData
    使用这个函数可以把 数组顶点 法线 纹理数组分开
         float positions[] = { ... };
         float normals[] = { ... };
         float tex[] = { ... };
         // 填充缓冲
         glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(positions), &positions);
         glBufferSubData(GL_ARRAY_BUFFER, sizeof(positions), sizeof(normals), &normals);
         glBufferSubData(GL_ARRAY_BUFFER, sizeof(positions) + sizeof(normals), sizeof(tex), &tex);
 
         glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), 0);
         glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)(sizeof(positions)));
         glVertexAttribPointer(
           2, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)(sizeof(positions) + sizeof(normals)));
 
    复制缓冲：
        void glCopyBufferSubData(GLenum readtarget, GLenum writetarget, GLintptr readoffset,
        GLintptr writeoffset, GLsizeiptr size);
        如果读写两个不同缓冲都为顶点数组缓冲：可以这样
            GL_COPY_READ_BUFFER和GL_COPY_WRITE_BUFFER
        float vertexData[] = { ... };
        glBindBuffer(GL_COPY_READ_BUFFER, vbo1); //或者 glBindBuffer(GL_ARRAY_BUFFER, vbo1);
        glBindBuffer(GL_COPY_WRITE_BUFFER, vbo2);
        glCopyBufferSubData(GL_COPY_READ_BUFFER, GL_COPY_WRITE_BUFFER, 0, 0, sizeof(vertexData));
    
 */
