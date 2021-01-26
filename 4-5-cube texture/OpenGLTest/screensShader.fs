#version 330 core
out vec4 FragColor;
in vec2 TexCoords;

uniform sampler2D screenTexture;

const float offset = 1.0 / 300.0f;

void main()
{
    //正常
    FragColor = texture(screenTexture, TexCoords);
    //反相
//    FragColor = vec4(vec3(1.0 - texture(screenTexture, TexCoords)), 1.0);

    //灰度
//    FragColor = texture(screenTexture,TexCoords);
//    float average = (FragColor.r + FragColor.g + FragColor.b) / 3.0;
//    FragColor = vec4(average,average,average,1.0);
    
//    FragColor = texture(screenTexture, TexCoords);
//    //人眼会对绿色更加敏感一些，而对蓝色不那么敏感，所以为了获取物理上更精确的效果，我们需要使用加权的(Weighted)通道
//    float average = 0.2126 * FragColor.r + 0.7152 * FragColor.g + 0.0722 * FragColor.b;
//    FragColor = vec4(average, average, average, 1.0);
    
    //核效果
    /*
     核 Kernel 或 卷积矩阵 convolution matrix
     它的中心为当前的像素，它会用它的核值乘以周围的像素值，并将结果相加变成一个值
     在网上找到的大部分核将所有的权重加起来之后都应该会等于1，如果它们加起来不等于1，这就意味着最终的纹理颜色将会比原纹理值更亮或者更暗了。
     ｜ 2   2   2 ｜
     ｜ 2  -15  2 ｜
     ｜ 2   2   2 ｜
     */
    
//    vec2 offsets[9] =
//    vec2[](
//           vec2(-offset,offset),
//           vec2(0.0f,offset),
//           vec2(offset,offset),
//           vec2(-offset,0.0f),
//           vec2(0.0,0.0),
//           vec2(offset,0.0),
//           vec2(-offset,-offset),
//           vec2(0.0f,-offset),
//           vec2(offset,-offset)
//
//                             );
    //锐化
//    float kernel[9] = float[](
//                              -1,-1,-1,
//                              -1,9,-1,
//                              -1,-1,-1
//                              );
//    float kernel[9] = float[](
//                              1.0 / 16,2.0 / 16,1.0 / 16,
//                              2.0 / 16,4.0 / 16,2.0 / 16,
//                              1.0 / 16,2.0 / 16,1.0 / 16
//                              );
//        float kernel[9] = float[](
//                                  1,1,1,
//                                  1,-8,1,
//                                  1,1,1
//                                  );
//    vec3 sampleTex[9];
//    for (int i = 0; i < 9; i++) {
//        sampleTex[i] = vec3(texture(screenTexture,TexCoords.st + offsets[i]));
//    }
//    vec3 col = vec3(0.0);
//    for (int i = 0; i < 9; i++) {
//        col += sampleTex[i] * kernel[i];
//    }
//
//    FragColor = vec4(col,1.0);
}
