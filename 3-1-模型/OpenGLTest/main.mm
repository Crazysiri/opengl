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
#include "AssimpModel.h"
//#include <glad/glad.h>

Camera camera(glm::vec3(0.0,-4.0,12.0f));

using namespace std;

// settings
const unsigned int SCR_WIDTH = 800.0;
const unsigned int SCR_HEIGHT = 600.0;
void processInput(GLFWwindow *window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void framebuffer_size_callback(GLFWwindow* window, int width, int height);

void draw(Model &model,Shader &shader,GLFWwindow *window);

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

    string path = "./models/nanosuit/nanosuit.obj";
    Model ourModel(path.c_str());

    draw(ourModel,shader,window);

    return 0;
}
void draw(Model &m,Shader &shader,GLFWwindow *window) {

    while (!glfwWindowShouldClose(window)) {
        
        processInput(window);
                
        glClearColor(0.1f,0.1f,0.1f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/SCR_HEIGHT , 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        glm::mat4 model = glm::mat4(1.0);
        
        shader.use();
        
        shader.setMat4("projection", projection);
        shader.setMat4("view", view);
        model = glm::translate(model, glm::vec3(0.0f, 0.0f, 0.0f)); // translate it down so it's at the center of the scene
        model = glm::scale(model, glm::vec3(0.5f, 0.5f, 0.5f));    // it's a bit too big for our scene, so scale it down
        model = glm::rotate(model, glm::radians(180.0f), glm::vec3(1.0f, 0.0f, 0.0f));
        model = glm::rotate(model, glm::radians(180.0f), glm::vec3(0.0f, 1.0f, 0.0f));

        shader.setMat4("model", model);
        
        
        m.Draw(shader);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    

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
