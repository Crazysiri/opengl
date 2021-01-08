#version 330 core

struct Material {
    sampler2D diffuse; //漫反射贴图 
    sampler2D specular; //镜面光照
    float shininess; //反光度 32 64
};

//定向光
struct DirLight {
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform DirLight dirLight;

vec3 CalcDirLight(DirLight light,vec3 normal,vec3 viewDir);


//点光源,点光源有位置没有明确方向，和衰减
struct PointLight {
    vec3 position;
    
    //衰减需要，常数项，一次项，二次项
    float constant;
    float linear;
    float quadratic;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

//lightingShader.setFloat("pointLights[0].constant", 1.0f);
#define NR_POINT_LIGHTS 4
uniform PointLight pointLights[NR_POINT_LIGHTS];

vec3 CalcPointLight(PointLight light,vec3 normal,vec3 fragPos,vec3 viewDir);



//聚光源,点光源有位置和明确的方向，例如手电筒
struct SpotLight {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    
    //衰减需要，常数项，一次项，二次项
    float constant;
    float linear;
    float quadratic;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform SpotLight spotLight;

vec3 CalcSpotLight(SpotLight light,vec3 normal,vec3 fragPos,vec3 viewDir);


uniform Material material;

uniform vec3 viewPos;//观察者坐标

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoords;


out vec4 FragColor;


void main()
{
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(viewPos - FragPos);
    
    //定向
    vec3 result = CalcDirLight(dirLight,norm,viewDir);
    //点
    for (int i = 0; i < NR_POINT_LIGHTS; i++) {
        result += CalcPointLight(pointLights[i],norm,FragPos,viewDir);
    }
    //聚光
    result += CalcSpotLight(spotLight,norm,FragPos,viewDir);

    FragColor = vec4(result, 1.0);
}




/*
    定向光：
    viewDir : 视线方向向量     vec3 viewDir = normalize(viewPos - FragPos);
    normal: 法线
 */
vec3 CalcDirLight(DirLight light,vec3 normal,vec3 viewDir) {
    vec3 lightDir = normalize(-light.direction);
    
    //漫反射
    float diff = max(dot(normal,lightDir),0.0); //点乘计算漫反射的角度 对于光强度的影响
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse,TexCoords));
    //镜面
    //reflect 第一个向量是 从光源指向片段的所以取反，第二个向量要求是一个法向量
    vec3 reflectDir = reflect(-lightDir,normal);
    //先计算视线方向和反射方向的点乘，然后取32次幂（高光的反光度（Shininess））
    float spec = pow(max(dot(viewDir,reflectDir),0.0),material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular,TexCoords));
    
    //环境
    vec3 ambient = light.ambient * vec3(texture(material.diffuse,TexCoords));
    
    return ambient + diffuse + specular;
}


vec3 CalcPointLight(PointLight light,vec3 normal,vec3 fragPos,vec3 viewDir) {
    //计算光源和片段位置之间的方向向量
    vec3 lightDir = normalize(light.position - fragPos);
    
    //环境光
    vec3 ambient = light.ambient * vec3(texture(material.diffuse,TexCoords));
    
    //漫反射
    float diff = max(dot(normal,lightDir),0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse,TexCoords));
    
    //镜面
    vec3 reflectDir = reflect(-lightDir,normal);
    float spec = pow(max(dot(viewDir,reflectDir),0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular,TexCoords));
    
    //点光源衰减
    float dis = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * dis + light.quadratic * dis * dis);
    
    
    return ambient * attenuation + diffuse * attenuation + specular * attenuation;
}


vec3 CalcSpotLight(SpotLight light,vec3 normal,vec3 fragPos,vec3 viewDir) {
    
    
    //计算光源和片段位置之间的方向向量
    vec3 lightDir = normalize(light.position - fragPos);
    
    float theta = dot(lightDir,normalize(-light.direction));
    float epsilon = light.cutOff - light.outerCutOff;
    //注意我们使用了clamp函数，它把第一个参数约束(Clamp)在了0.0到1.0之间。这保证强度值不会在[0, 1]区间之外。
    float intensity = clamp((theta - light.outerCutOff) / epsilon , 0.0 ,1.0);

    
    //环境光
    vec3 ambient = light.ambient * vec3(texture(material.diffuse,TexCoords));
    
    //漫反射
    float diff = max(dot(normal,lightDir),0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse,TexCoords));
    
    //镜面
    vec3 reflectDir = reflect(-lightDir,normal);
    float spec = pow(max(dot(viewDir,reflectDir),0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular,TexCoords));
    
    //点光源衰减
    float dis = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * dis + light.quadratic * dis * dis);
    
    
    return ambient * attenuation + diffuse * attenuation * intensity + specular * attenuation * intensity;
}
