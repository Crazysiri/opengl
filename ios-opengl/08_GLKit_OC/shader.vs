attribute vec4 position;
attribute vec2 data;
varying lowp vec2 varyTextCoord;
void main()
{
    varyTextCoord = data;
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
//   vertexColor = vec4(0.5,0.5,0.0,1.0);
}
