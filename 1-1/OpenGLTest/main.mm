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
//#include <glad/glad.h>
using namespace std;

const char *vertexShaderSource = "#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "out vec4 vertexColor; \n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "   vertexColor = vec4(0.5,0.5,0.0,1.0);\n"
    "}\0";

const char *fragmentShaderSource = "#version 330 core\n"
    "out vec4 FragColor;\n"
    "in vec4 vertexColor;"
    "uniform vec4 ourColor;\n"
    "void main()\n"
    "{\n"
    "   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n" //正常模式
//    "   FragColor = vertexColor;\n" //从顶点着色器传入的颜色
//    "   FragColor = ourColor;\n" //采用uniform 从程序传入颜色 uniform 用来 从cpu 传入 gpu 的变量 它是全局的

    "}\n\0";
// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;
void processInput(GLFWwindow *window);

void framebuffer_size_callback(GLFWwindow* window, int width, int height);

void indices(int program,GLFWwindow *window);
void twoTriangles(int shaderProgram,GLFWwindow *window);

int main(int argc, char * argv[]) {
    
//    complierGLSL();
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
    int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader,1,&vertexShaderSource,NULL);
    glCompileShader(vertexShader);
    int success;
    char infoLog[512];
    glGetShaderiv(vertexShader,GL_COMPILE_STATUS,&success);
    if (!success) {
        glGetShaderInfoLog(vertexShader,512,NULL,infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
    }
    
    int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader,1,&fragmentShaderSource,NULL);
    glCompileShader(fragmentShader);
    
    glGetShaderiv(fragmentShader,GL_COMPILE_STATUS,&success);
    if (!success) {
        glad_glGetShaderInfoLog(fragmentShader,512,NULL,infoLog);
        std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
    }
    
    int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram,vertexShader);
    glAttachShader(shaderProgram,fragmentShader);
    glLinkProgram(shaderProgram);
    
    glGetProgramiv(shaderProgram,GL_LINK_STATUS,&success);
    if (!success) {
        glad_glGetShaderInfoLog(shaderProgram,512,NULL,infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    //查询有多少个包含4分量的顶点属性可用
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;

//    indices(shaderProgram,window);
    twoTriangles(shaderProgram,window);

    return 0;
}

void twoTriangles(int shaderProgram,GLFWwindow *window) {
    float first[] = {
        -0.9f,-0.5f,0.0f,
        -0.0f,-0.5f,0.0f,
        -0.45f,0.5f,0.0f
    };
    float second[] = {
        -0.0f,-0.5f,0.0f,
        0.9f,-0.5f,0.0f,
        0.45f,0.5f,0.0f
    };
    
    unsigned int VBOs[2],VAOs[2];
    glGenVertexArrays(2,VAOs);
    glGenBuffers(2,VBOs);
    
    glBindVertexArray(VAOs[0]);
    glBindBuffer(GL_ARRAY_BUFFER,VBOs[0]);
    glBufferData(GL_ARRAY_BUFFER,sizeof(first),first,GL_STATIC_DRAW);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,3 * sizeof(float),(void*)0);
    glEnableVertexAttribArray(0);
    
    glBindVertexArray(VAOs[1]);
    glBindBuffer(GL_ARRAY_BUFFER,VBOs[1]);
    glBufferData(GL_ARRAY_BUFFER,sizeof(second),second,GL_STATIC_DRAW);
    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,3 * sizeof(float),(void*)0);
    glEnableVertexAttribArray(0);
    
    while (!glfwWindowShouldClose(window)) {
        
        processInput(window);
        
        glClearColor(0.2f,0.3f,0.3f,1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glUseProgram(shaderProgram);
        
        glBindVertexArray(VAOs[0]);
        glDrawArrays(GL_TRIANGLES,0,3);
        
        glBindVertexArray(VAOs[1]);
        glDrawArrays(GL_TRIANGLES,0,3);
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    
    glDeleteVertexArrays(2,VAOs);
    glDeleteBuffers(2,VBOs);
    glDeleteProgram(shaderProgram);
    
    glfwTerminate();
}


void indices(int shaderProgram,GLFWwindow *window) {
        float vertices[] = {
            0.5f, 0.5f, 0.0f,   // 右上角
            0.5f, -0.5f, 0.0f,  // 右下角
            -0.5f, -0.5f, 0.0f, // 左下角
            -0.5f, 0.5f, 0.0f   // 左上角
        };
        
        unsigned int VBO,VAO;
        glGenVertexArrays(1,&VAO);
        glGenBuffers(1,&VBO);
        
        glBindVertexArray(VAO);
        
        glBindBuffer(GL_ARRAY_BUFFER,VBO);
        /*
         第四个参数指定了我们希望显卡如何管理给定的数据。它有三种形式：
         GL_STATIC_DRAW ：数据不会或几乎不会改变。
         GL_DYNAMIC_DRAW：数据会被改变很多。
         GL_STREAM_DRAW ：数据每次绘制时都会改变。
         */
        glBufferData(GL_ARRAY_BUFFER,sizeof(vertices),vertices,GL_STATIC_DRAW);
        
        /*如何解释顶点数组
         第一个参数指定我们要配置的顶点属性。还记得我们在顶点着色器中使用layout(location = 0)定义了position顶点属性的位置值(Location)吗？它可以把顶点属性的位置值设置为0。因为我们希望把数据传递到这一个顶点属性中，所以这里我们传入0。
         第二个参数指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
         第三个参数指定数据的类型，这里是GL_FLOAT(GLSL中vec*都是由浮点数值组成的)。
         下个参数定义我们是否希望数据被标准化(Normalize)。如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。我们把它设置为GL_FALSE。
         第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔。由于下个组位置数据在3个float之后，我们把步长设置为3 * sizeof(float)。要注意的是由于我们知道这个数组是紧密排列的（在两个顶点属性之间没有空隙）我们也可以设置为0来让OpenGL决定具体步长是多少（只有当数值是紧密排列时才可用）。一旦我们有更多的顶点属性，我们就必须更小心地定义每个顶点属性之间的间隔，我们在后面会看到更多的例子（译注: 这个参数的意思简单说就是从这个属性第二次出现的地方到整个数组0位置之间有多少字节）。
         最后一个参数的类型是void*，所以需要我们进行这个奇怪的强制类型转换。它表示位置数据在缓冲中起始位置的偏移量(Offset)。由于位置数据在数组的开头，所以这里是0。我们会在后面详细解释这个参数。
         */
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,3 * sizeof(float),(void *)0);
        glEnableVertexAttribArray(0);
        
        unsigned int indices[] = {
                0,1,3,
                1,2,3
        };
        
        unsigned int EBO;
        glGenBuffers(1,&EBO);
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,sizeof(indices),indices,GL_STATIC_DRAW);

        
        glBindBuffer(GL_ARRAY_BUFFER,0);
    //    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
        glBindVertexArray(0);
        
        while (!glfwWindowShouldClose(window)) {
            processInput(window);
            
            glClearColor(0.2f,0.3f,0.3f,1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            
            glUseProgram(shaderProgram);
            glBindVertexArray(VAO);
    //        glDrawArrays(GL_TRIANGLES,0,6);
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

            glfwSwapBuffers(window);
            glfwPollEvents();
        }
        
        glDeleteVertexArrays(1,&VAO);
        glDeleteBuffers(1,&VBO);
        glDeleteProgram(shaderProgram);
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
