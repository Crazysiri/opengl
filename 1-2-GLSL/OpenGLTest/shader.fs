#version 330 core
out vec4 FragColor;
in vec4 vertexColor;
//    "uniform vec4 ourColor;\n"
in vec3 ourColor;
in vec4 point;

void main()
{
//    "   FragColor = vec4(0.0f, 0.6f, 0.2f, 1.0f);\n" //正常模式
//    "   FragColor = vertexColor;\n" //从顶点着色器传入的颜色
//    "   FragColor = ourColor;\n" //采用uniform 从程序传入颜色 uniform 用来 从cpu 传入 gpu 的变量 它是全局的
//    FragColor = vec4(ourColor,1.0);
    FragColor = vec4(point,1.0);
}
