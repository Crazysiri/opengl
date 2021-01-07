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

float cube_vertices[] = {
    // positions          // normals           // texture coords
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
     0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,

    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,

    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,

     0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,

    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
};


Camera camera(glm::vec3(0.0,0.0,8.0f));

using namespace std;

// settings
const unsigned int SCR_WIDTH = 800.0;
const unsigned int SCR_HEIGHT = 600.0;
void processInput(GLFWwindow *window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void framebuffer_size_callback(GLFWwindow* window, int width, int height);

void draw(Shader &light_shader,Shader &shader,GLFWwindow *window);

int main(int argc, char * argv[]) {

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
    
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "failed to initialize glad" << std::endl;
        return -1;
    }
    
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_DEPTH_TEST);

    
    Shader shader("./shader.vs","./shader.fs");
    Shader light_shader("./light_shader.vs","./light_shader.fs");
    //查询有多少个包含4分量的顶点属性可用
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

    draw(light_shader,shader,window);

    return 0;
}
void draw(Shader &light_shader,Shader &shader,GLFWwindow *window) {
    
    int nums = 1;
    
    unsigned int VBOs[nums],VAOs[nums];
    glGenVertexArrays(nums,VAOs);
    glGenBuffers(nums,VBOs);
            
    for (int i = 0; i < nums; i++) {
                
        glBindVertexArray(VAOs[i]);
        glBindBuffer(GL_ARRAY_BUFFER,VBOs[i]);
        glBufferData(GL_ARRAY_BUFFER,sizeof(cube_vertices),cube_vertices,GL_STATIC_DRAW);
                
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)0);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)(6 * sizeof(float)));
        glEnableVertexAttribArray(2);
    }
    
    Texture t;
    unsigned int texture_pointer = t.begin();
    t.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    t.setWrap2D(GL_REPEAT);
    t.end("./container2.png");

    Texture t_specular;
    unsigned int texture_s_pointer = t_specular.begin(GL_TEXTURE1);
    t_specular.setFilter(GL_LINEAR_MIPMAP_LINEAR);
    t_specular.setWrap2D(GL_REPEAT);
    t_specular.end("./container2_specular.png");
    
    unsigned int lightVAO;
    glGenVertexArrays(1,&lightVAO);
    glBindVertexArray(lightVAO);
    
    //这里只需要绑定已经创建的VBO即可，因为里面已经有了立方体的顶点
    glBindBuffer(GL_ARRAY_BUFFER,VBOs[0]);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,8 * sizeof(float),(void*)0);
    glEnableVertexAttribArray(0);
    
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

    
    glm::vec3 pointLightPositions[] = {
        glm::vec3( 0.7f,  0.2f,  2.0f),
        glm::vec3( 2.3f, -3.3f, -4.0f),
        glm::vec3(-4.0f,  2.0f, -12.0f),
        glm::vec3( 0.0f,  0.0f, -3.0f)
    };
    
    while (!glfwWindowShouldClose(window)) {
        
        processInput(window);
                
        glClearColor(0.1f,0.1f,0.1f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/SCR_HEIGHT , 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glm::mat4 model = glm::mat4(1.0);
        
        
        
        light_shader.use();
        //纹理需要代码1
        light_shader.setInt("material.diffuse", 0);
        light_shader.setInt("material.specular", 1);
        light_shader.setFloat("material.shininess", 64.0f);
        
        light_shader.setVec3("viewPos", camera.Position);
        
        
        light_shader.setVec3("dirLight.direction", -0.2f, -1.0f, -0.3f);
        light_shader.setVec3("dirLight.ambient", 0.05f, 0.05f, 0.05f);
        light_shader.setVec3("dirLight.diffuse", 0.4f, 0.4f, 0.4f);
        light_shader.setVec3("dirLight.specular", 0.5f, 0.5f, 0.5f);
        
        // point light 1
        light_shader.setVec3("pointLights[0].position", pointLightPositions[0]);
        light_shader.setVec3("pointLights[0].ambient", 0.05f, 0.05f, 0.05f);
        light_shader.setVec3("pointLights[0].diffuse", 0.8f, 0.8f, 0.8f);
        light_shader.setVec3("pointLights[0].specular", 1.0f, 1.0f, 1.0f);
        light_shader.setFloat("pointLights[0].constant", 1.0f);
        light_shader.setFloat("pointLights[0].linear", 0.09);
        light_shader.setFloat("pointLights[0].quadratic", 0.032);
        // point light 2
        light_shader.setVec3("pointLights[1].position", pointLightPositions[1]);
        light_shader.setVec3("pointLights[1].ambient", 0.05f, 0.05f, 0.05f);
        light_shader.setVec3("pointLights[1].diffuse", 0.8f, 0.8f, 0.8f);
        light_shader.setVec3("pointLights[1].specular", 1.0f, 1.0f, 1.0f);
        light_shader.setFloat("pointLights[1].constant", 1.0f);
        light_shader.setFloat("pointLights[1].linear", 0.09);
        light_shader.setFloat("pointLights[1].quadratic", 0.032);
        // point light 3
        light_shader.setVec3("pointLights[2].position", pointLightPositions[2]);
        light_shader.setVec3("pointLights[2].ambient", 0.05f, 0.05f, 0.05f);
        light_shader.setVec3("pointLights[2].diffuse", 0.8f, 0.8f, 0.8f);
        light_shader.setVec3("pointLights[2].specular", 1.0f, 1.0f, 1.0f);
        light_shader.setFloat("pointLights[2].constant", 1.0f);
        light_shader.setFloat("pointLights[2].linear", 0.09);
        light_shader.setFloat("pointLights[2].quadratic", 0.032);
        // point light 4
        light_shader.setVec3("pointLights[3].position", pointLightPositions[3]);
        light_shader.setVec3("pointLights[3].ambient", 0.05f, 0.05f, 0.05f);
        light_shader.setVec3("pointLights[3].diffuse", 0.8f, 0.8f, 0.8f);
        light_shader.setVec3("pointLights[3].specular", 1.0f, 1.0f, 1.0f);
        light_shader.setFloat("pointLights[3].constant", 1.0f);
        light_shader.setFloat("pointLights[3].linear", 0.09);
        light_shader.setFloat("pointLights[3].quadratic", 0.032);
        // spotLight
        light_shader.setVec3("spotLight.position", camera.Position);
        light_shader.setVec3("spotLight.direction", camera.Front);
        light_shader.setVec3("spotLight.ambient", 0.0f, 0.0f, 0.0f);
        light_shader.setVec3("spotLight.diffuse", 1.0f, 1.0f, 1.0f);
        light_shader.setVec3("spotLight.specular", 1.0f, 1.0f, 1.0f);
        light_shader.setFloat("spotLight.constant", 1.0f);
        light_shader.setFloat("spotLight.linear", 0.09);
        light_shader.setFloat("spotLight.quadratic", 0.032);
        light_shader.setFloat("spotLight.cutOff", glm::cos(glm::radians(12.5f)));
        light_shader.setFloat("spotLight.outerCutOff", glm::cos(glm::radians(15.0f)));
        
         
        light_shader.setMat4("view", view);
        light_shader.setMat4("projection", projection);
         
//        model = glm::mat4(1.0f);
//        model = glm::scale(model, glm::vec3(1.2f));
//        model = glm::rotate(model, glm::radians(20.0f), glm::vec3(0.0,1.0,0.0));
////        model = glm::rotate(model, glm::radians(10.0f), glm::vec3(1.0,0.0,0.0));
//
//        light_shader.setMat4("model", model);
        light_shader.setVec3("viewPos", camera.Position);//设置观察者位置（这里就是相机位置）

        //纹理需要代码2
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D,texture_pointer);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D,texture_s_pointer);
        
        glBindVertexArray(VAOs[0]);
        for(unsigned int i = 0; i < 10; i++)
        {
            glm::mat4 model(1.0f);
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * i;
            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
            light_shader.setMat4("model", model);

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        
        
        shader.use();
        glBindVertexArray(lightVAO);

        for (unsigned int i = 0; i < 4; i++)
        {
            shader.setMat4("view", view);
            shader.setMat4("projection", projection);
            model = glm::mat4(1.0f);
            model = glm::translate(model,pointLightPositions[i]); //lightPos
            model = glm::scale(model, glm::vec3(0.2f));
            shader.setMat4("model", model);
            glDrawArrays(GL_TRIANGLES, 0, 36);

        }


        

        



        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    
    glDeleteVertexArrays(nums,VAOs);
    glDeleteBuffers(nums,VBOs);
    glfwTerminate();
}


void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    
}


void mouse_callback(GLFWwindow* window, double xpos, double ypos) {

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
 冯氏光照模型：
 Phong lighting model
 组成：Ambient环境，Diffuse漫反射， 镜面Specular
 环境光照(Ambient Lighting)：即使在黑暗的情况下，世界上通常也仍然有一些光亮（月亮、远处的光），所以物体几乎永远不会是完全黑暗的。为了模拟这个，我们会使用一个环境光照常量，它永远会给物体一些颜色。
 漫反射光照(Diffuse Lighting)：模拟光源对物体的方向性影响(Directional Impact)。它是冯氏光照模型中视觉上最显著的分量。物体的某一部分越是正对着光源，它就会越亮。
 镜面光照(Specular Lighting)：模拟有光泽物体上面出现的亮点。镜面光照的颜色相比于物体的颜色会更倾向于光的颜色。
 
 环境光+漫反射光
 1.计算光源和片段之间的方向向量：
 即光源位置向量和片段位置向量之间的向量差
 lightPos - FragPos
 normalize() 转成单位向量
 vec3 lightDir = normalize(lightPos - FragPos);
 //2.计算光源对当前片段实际的散发射影响（点乘算角度）
 //大于90度灰变成负数 ，负数是没有意义的
 float diff = max(dot(norm,lightDir),0.0);
 //3.角度余弦值 乘 光的颜色 得到漫反射分量
 vec3 diffuse = diff * lightColor;
 //4.根据环境光和漫反射分量 * 物体的颜色 得到反射光（其实就是看到的颜色）
 //向量中每个分量各自相乘 详见 1-3 纹理+变换
 vec3 result = (ambient + diffuse) * objectColor;
 
 镜面光
 Specular Highlight
 和漫反射光照一样，镜面光照也是依据光的方向向量和物体的法向量来决定的，但是它也依赖于观察方向
 
 
 因为环境光颜色几乎在所有情况下都等于漫反射颜色，所以可以移除环境光颜色
 
 
 平行光（定向光）：
 处于无限远处，它和光源的位置是没有关系的，例如太阳
 点光源：
 它会朝着所有方向发光，但光线会随着距离逐渐衰减。例如灯泡 火把
 随着光线的传播距离的增长捉奸消减光的强度通常叫左衰减（attenuation）
 方式1:使用线性方程。但这样的线形方程通常会看起来比较假。
 在现实世界中，灯在近处通常会非常亮，但随着距离的增加光源的亮度一开始会下降非常快，但在远处时剩余的光强度就会下降的非常缓慢了。所以我们需要一个不同 公式来减少光的强度。
 Fatt=1.0 / (Kc + Kl * d + Kq * d*d)
  d*d 即d的二次方
 d代表片段光源的距离。
 Kc 常数项 一般为1.0，主要作用是保证分母用于不会比1小，否则在某些距离上它反而会增加强度
 Kl 一次项会与距离相乘，以线性的方式减少
 Kq 二次项会与距离的平方相乘，让光源以二次递减的方式减少强度。二次项在距离比较小的时候影响会小一些，当距离大的时候影响会很大
 Fatt 是衰减值
 
 聚光：
 https://learnopengl-cn.github.io/02%20Lighting/05%20Light%20casters
 spotlight，它只朝一个特定的方向而不是所有方向照射，例如手电筒
 聚光用一个世界空间位置，一个方向和一个切光角（cutoff angle）表示。切光角指定了聚光的半径（圆锥的半径）
 对于每个片段，需要计算是否位于聚光的切光方向之间（在圆锥内）
 LightDir : 从片段指向光源的向量
 SpotDir : 聚光所指向的方向
 Phi : 指定了聚光半径的切光角
 Theta：LightDir 和 SpotDir 夹角
 theta = dot(LightDir,normalize(-light.direction))
 if (theta > light.curOff) {
    光照计算
 }
 else {
    color = vec4(light.ambient * vec3(texture(material.diffuse,TexCoords)),1.0);
 }
 
 */
