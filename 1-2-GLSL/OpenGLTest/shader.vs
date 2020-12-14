#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
//    "out vec4 vertexColor; \n"
out vec3 ourColor;
out vec3 point;
uniform float offset;

void main()
{
    gl_Position = vec4(aPos.x + offset, -aPos.y, aPos.z, 1.0);
//    "   vertexColor = vec4(0.5,0.5,0.0,1.0);\n"
    ourColor = aColor;
    point = aPos;
}
