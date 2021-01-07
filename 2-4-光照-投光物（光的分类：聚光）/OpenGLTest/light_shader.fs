#version 330 core

struct Material {
    sampler2D diffuse; //漫反射贴图 
    sampler2D specular; //镜面光照
    float shininess; //反光度 32 64
};

//光对环境光，漫反射，镜面的不同影响
struct Light {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    //点光源需要的衰减常数值
    float constant; //常数
    float linear; //1次项
    float quadratic; //2次项
};

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;

out vec4 FragColor;

uniform Light light;
uniform Material material;

//uniform vec3 lightPos;
uniform vec3 viewPos;//观察者坐标
void main()
{
    //   //1.计算光源和片段位置之间的方向向量
    vec3 lightDir = normalize(light.position - FragPos);
    
    float theta = dot(lightDir,normalize(-light.direction));
    
    float epsilon   = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
    
    
        //-----环境光-----
    //    vec3 ambient = material.ambient * light.ambient;
        vec3 ambient = light.ambient * texture(material.diffuse,TexCoords).rgb;

        //-----漫反射-----
        //法线单位向量
        vec3 norm = normalize(Normal);
        //1.光源的方向
    //    vec3 lightDir = normalize(-light.direction);
        //2.计算光源对当前片段实际的散发射影响（点乘算角度）
        //大于90度灰变成负数 ，负数是没有意义的
        float diff = max(dot(norm,lightDir),0.0);
        //3.角度余弦值 乘 光的颜色 得到漫反射分量
    //    vec3 diffuse = light.diffuse * (diff * material.diffuse);
        vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse,TexCoords));
        //4.根据环境光和漫反射分量 * 物体的颜色 得到反射光（其实就是看到的颜色）
        //向量中每个分量各自相乘 详见 1-3 纹理+变换
        
        //-----镜面光-----
        //1.视线方向向量
        vec3 viewDir = normalize(viewPos - FragPos);
        //2.对应的沿着法线轴的反射向量
        //reflect 第一个向量是 从光源指向片段的所以取反，第二个向量要求是一个法向量
        vec3 reflectDir = reflect(-lightDir,norm);
        //3.先计算视线方向和反射方向的点乘，然后取32次幂（高光的反光度（Shininess））
        float spec = pow(max(dot(viewDir,reflectDir),0.0),material.shininess);
        vec3 specular = light.specular * spec * vec3(texture(material.specular,TexCoords));
        
        //attenuation
        float dis = length(light.position - FragPos);
        float attenuation = 1.0 / (light.constant + light.linear * dis + light.quadratic * (dis * dis));
        diffuse *= attenuation * intensity;
        specular *= attenuation * intensity;
        //----计算结果-----
        vec3 result = ambient  + diffuse + specular ;
        
        FragColor = vec4(result,1.0);
}
