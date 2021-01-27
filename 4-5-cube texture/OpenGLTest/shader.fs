#version 330 core
out vec4 FragColor;

in vec3 Normal;
in vec3 Position;

uniform samplerCube skybox;
uniform vec3 cameraPos;

void main()
{
    //方向向量
    vec3 I = normalize(Position - cameraPos);
    //反射
    vec3 R = reflect(I,normalize(Normal));
    FragColor = vec4(texture(skybox,R).rgb,1.0);
}
