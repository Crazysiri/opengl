#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 Normal;
out vec3 FragPos;

void main()
{
    Normal = aNormal;
    //法线矩阵 mat3(transpose(inverse(model))) 最好计算完从cpu传进来
    //逆矩阵(Inverse Matrix)和转置矩阵(Transpose Matrix)
//    Normal = mat3(transpose(inverse(model))) * aNormal;
    FragPos = vec3(model * vec4(aPos,1.0));
    gl_Position = projection * view  * model * vec4(aPos,1.0);
}
