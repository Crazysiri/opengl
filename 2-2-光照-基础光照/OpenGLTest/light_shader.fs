#version 330 core

in vec3 Normal;
in vec3 FragPos;

out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;
uniform vec3 viewPos;//观察者坐标
void main()
{
    float ambientStrength = 0.2;
    vec3 ambient = ambientStrength * lightColor;
//    vec3 result = ambient * objectColor;
    
    //法线单位向量
    vec3 norm = normalize(Normal);
    //1.计算光源和片段位置之间的方向向量
    vec3 lightDir = normalize(lightPos - FragPos);
    //2.计算光源对当前片段实际的散发射影响（点乘算角度）
    //大于90度灰变成负数 ，负数是没有意义的
    float diff = max(dot(norm,lightDir),0.0);
    //3.角度余弦值 乘 光的颜色 得到漫反射分量
    vec3 diffuse = diff * lightColor;
    //4.根据环境光和漫反射分量 * 物体的颜色 得到反射光（其实就是看到的颜色）
    //向量中每个分量各自相乘 详见 1-3 纹理+变换
//    vec3 result = (ambient + diffuse) * objectColor;
    
    //定义 镜面强度变量，如果设置成1.0 会得到一个非常亮的分量
    float specularStrength = 0.5f;
    //镜面光照
    //1.视线方向向量
    vec3 viewDir = normalize(viewPos - FragPos);
    //2.对应的沿着法线轴的反射向量
    //reflect 第一个向量是 从光源指向片段的所以取反，第二个向量要求是一个法向量
    vec3 reflectDir = reflect(-lightDir,norm);
    //3.先计算视线方向和反射方向的点乘，然后取32次幂（高光的反光度（Shininess））
    float spec = pow(max(dot(viewDir,reflectDir),0.0),64);
    vec3 specular = specularStrength * spec * lightColor;
    vec3 result = (ambient + diffuse + specular) * objectColor;
    
    FragColor = vec4(result,1.0);
}
