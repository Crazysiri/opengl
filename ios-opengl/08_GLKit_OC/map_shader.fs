precision highp float;
varying lowp vec2 varyTextCoord;
uniform sampler2D texture1;

void main()
{
//    vec2 newCoord1 = vec2(varyTextCoord.x,varyTextCoord.y);
    vec2 newCoord1 = vec2(varyTextCoord.x,varyTextCoord.y);
    gl_FragColor = texture2D(texture1, newCoord1);
    
//    gl_FragColor = vec4(0.0, 0.6, 0.2, 1.0);
    //    "   FragColor = vec4(0.0f, 0.6f, 0.2f, 1.0f);\n" //正常模式
    //    "   FragColor = vertexColor;\n" //从顶点着色器传入的颜色
    //    "   FragColor = ourColor;\n" //采用uniform 从程序传入颜色 uniform 用来 从cpu 传入 gpu 的变量 它是全局的

}
