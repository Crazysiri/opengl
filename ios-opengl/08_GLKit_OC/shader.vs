attribute vec4 position;
attribute vec2 data;
varying lowp vec2 varyTextCoord;

uniform mat4 model;
uniform mat4 projection;

uniform vec2 resolution;
uniform vec2 map;

float xToPixel(float x) {
    float x_p = x / resolution.x + map.x / resolution.y;
    return x_p;
}

float yToPixel(float y) {
//    float y_p = 1708.0 - (y / 0.05 + 73.8 / 0.05);
    float y_p = (y / resolution.x + map.y / resolution.y);
    return y_p;
}

void main()
{
    varyTextCoord = data;
    vec2 new_p = vec2(xToPixel(position.x) + data.x / 0.05 * cos( (position.z + data.y)) ,yToPixel(position.y) + data.x / 0.05 * sin( ( position.z + data.y) ) );
    gl_PointSize = 3.0;
    gl_Position = projection * model * vec4(new_p.x, new_p.y, 0.0, 1.0);
//   vertexColor = vec4(0.5,0.5,0.0,1.0);
}
