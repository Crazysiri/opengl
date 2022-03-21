attribute vec4 position;
attribute vec2 data;
varying lowp vec2 varyTextCoord;

uniform mat4 model;
uniform mat4 projection;
void main()
{
    varyTextCoord = data;
    vec2 new_p = vec2(position.x + data.x * cos(data.y) ,position.y + data.x * sin(data.y) );
//    gl_PointSize = 100.0;
    gl_Position = projection * model * vec4(new_p.x, new_p.y, position.z, 1.0);
//   vertexColor = vec4(0.5,0.5,0.0,1.0);
}
