precision highp float;
varying lowp vec2 varyTextCoord;
void main()
{
    gl_FragColor = vec4(0.9, 0.1, 0.1, 0.1);
    
    //    "   FragColor = vec4(0.0f, 0.6f, 0.2f, 1.0f);\n" //正常模式
    //    "   FragColor = vertexColor;\n" //从顶点着色器传入的颜色
    //    "   FragColor = ourColor;\n" //采用uniform 从程序传入颜色 uniform 用来 从cpu 传入 gpu 的变量 它是全局的

}
