#version 300 es
    precision mediump float;
    uniform vec2 u_resolution;
    uniform vec2 u_mouse;
    uniform float u_time;
    out vec4 fragColor;

    vec3 Shader(vec2 uv);
    void main()
    { 
        //gl_FragCoord.xy / min(u_resolution.x, u_resolution.y) are the normalized uvs
        fragColor = vec4(Shader(gl_FragCoord.xy / min(u_resolution.x, u_resolution.y)), 1.0);
    }
//GLSL SPECIFIC

//MATH CONSTANTS
    #define M_PI 3.14159265358979323846264
//MATH CONSTANTS

//DEFINES
    #define SWAP(a, b, type){type _temp = a; a = b; b = _temp;}
    #define INVFLOAT(a) (1.0 / a)
//DEFINES

//UTILITY METHODS
    //NOISE GEN
        //SIMPLEX
            // Simplex 2D noise
            vec3 permute(vec3 x) {
                return mod(((x * 34.0) + 1.0) * x, 289.0); 
            }
            float snoise(vec2 v) {
                const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                    -0.577350269189626, 0.024390243902439);
                vec2 i  = floor(v + dot(v, C.yy) );
                vec2 x0 = v -   i + dot(i, C.xx);
                vec2 i1;
                i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
                vec4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod(i, 289.0);
                vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
                vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
                m = m*m;
                m = m*m;
                vec3 x = 2.0 * fract(p * C.www) - 1.0;
                vec3 h = abs(x) - 0.5;
                vec3 ox = floor(x + 0.5);
                vec3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
                vec3 g;
                g.x  = a0.x  * x0.x  + h.x  * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot(m, g);
            }
        //SIMPLEX
    //NOISE GEN

    //RANDOM GEN
        float random(float val){
            return fract( sin( (dot(vec2(val, val), vec2(12.9898,78.233)) ) * 43758.5453123 ) );
        }
        float random(vec2 pos){
            return fract( sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123 );
        }
    //RANDOM GEN
//UTILITY METHODS


vec3 Shader(vec2 uv)
{
    vec3 col = vec3(0.0);
    uv -= 0.59;
    uv *= 20.0;
    uv.y *= 0.7;
    float v = 15.1035;
#define iter 2
    for (int i = 0; i < iter; i++)
    {
        v *= 1.0 + cos(v * 0.3) * pow(v, 2.0);
        v = sin(v + uv.x + v * uv.y);
    }
    col.r = max(v, 0.0);

    for (int i = 0; i < iter; i++)
    {
        v *= 1.0 + cos(v * 3.) * pow(v, 2.0);
        v = sin(v + uv.x + v * uv.y);
    }
    col.g = max(v, 0.0);

    for (int i = 0; i < iter; i++)
    {
        v *= 1.0 + cos(v * 3.0) * pow(v, 2.0);
        v = sin(v + uv.x + v * uv.y);
    }
    col.b = max(v, 0.0);

    SWAP(col.r, col.b, float);
    return col ;
}