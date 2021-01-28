#version 330 core
out vec4 FragColor;

in BLOCK_NAME {
    vec2 TexCoords;
} vs_in;

uniform sampler2D texture1;

float near = 0.1;
float far  = 100.0;

float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // back to NDC 剪裁空间 [-1,1]
    return (2.0 * near * far) / (far + near - z * (far - near));
}

void main()
{
    if (gl_FragCoord.x < 400) {
        FragColor = texture(texture1, vs_in.TexCoords);
    } else {
        FragColor = vec4(1.0,0.0,0.0,1.0);
    }
//    float depth = LinearizeDepth(gl_FragCoord.z) / far;
//    FragColor = vec4(vec3(depth), 1.0);

}

/*
 gl_FragCoord x y是屏幕坐标 z是深度值
 
 gl_FrontFacing（只读变量） 正面或背面 （启用GL_FACE_CULL）
 
 gl_FragDepth 可以修改深度值
 
 */
