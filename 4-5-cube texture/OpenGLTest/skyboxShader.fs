#version 330 core
in vec3 textureDir;
out vec4 FragColor;

uniform samplerCube cubemap;

void main()
{
    //正常
    FragColor = texture(cubemap, textureDir);
}
