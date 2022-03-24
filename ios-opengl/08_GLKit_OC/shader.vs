attribute vec4 position;
attribute vec2 data;
varying lowp vec2 varyTextCoord;

uniform mat4 model;
uniform mat4 projection;

float xToPixel(float x) {
    float x_p = x / 0.05 + 23.05 / 0.05;
    return x_p;
}

float yToPixel(float y) {
//    float y_p = 1708.0 - (y / 0.05 + 73.8 / 0.05);
    float y_p = (y / 0.05 + 73.8 / 0.05);
    return y_p;
}

void main()
{
    varyTextCoord = data;
    vec2 new_p = vec2(xToPixel(position.x) + data.x / 0.05 * cos(data.y + position.z) ,yToPixel(position.y) + data.x / 0.05 * sin(data.y + position.z) );
    gl_PointSize = 3.0;
    gl_Position = projection * model * vec4(new_p.x, new_p.y, position.z, 1.0);
//   vertexColor = vec4(0.5,0.5,0.0,1.0);
}
