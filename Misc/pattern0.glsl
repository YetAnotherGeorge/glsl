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
    #define INVFLOAT(a) (1.0 / (a))
//DEFINES

//UTILITY METHODS
    //NOISE GEN
        //SIMPLEX
            // Simplex 2D noise
            vec3 permute(vec3 x) {
                return mod(((x * 34.0) + 1.0) * x, 289.0); 
            }
            float Snoise(vec2 v) {
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
            float SnoisePositive(vec2 v){
                return 0.5 + 0.5 * Snoise(v);
            }
        //SIMPLEX
    //NOISE GEN

    //RANDOM GEN
        float random(float val)
        {
            return fract( sin(dot(vec2(val, val), vec2(12.9898, 78.233))) * 43758.5453);
        }
        float random(vec2 pos){
            return fract( sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123 );
        }
    //RANDOM GEN
//UTILITY METHODS

float NoiseLayered(vec2 pos)
{
    pos *= 0.5;
#define layers 8.
    float noise = 0.0, influence = 0.5, div_by = 0.0;
    for(float i = 1.0; i <= layers; i += 1.0)
    {
        noise += influence * SnoisePositive(pos);
        pos *= 1.99;
        div_by += influence;
        influence *= 0.5;
    }
    return noise / div_by;
}
//linear interpolation between 4 colors
vec3 ColorRamp(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b, float pos_c, vec3 col_c, float pos_d, vec3 col_d){
    if(n < pos_a)
        return col_a; 
    else if(n < pos_b)
    {
        n -= pos_a;
        n /= (pos_b - pos_a);
        return col_a * (1.0 - n) + col_b * n;
    }
    else if(n < pos_c)
    {
        n-= pos_b;
        n /= (pos_c - pos_b);
        return col_b * (1.0 - n) + col_c * n;
    }
    else if(n < pos_d)
    {
        n-= pos_c;
        n /= (pos_d - pos_c);
        return col_c * (1.0 - n) + col_d * n;
    }
    return col_d;
}
vec3 Shader(vec2 uv)
{
    float fpix = 0.014;
    float noiseScale = 2.4;
    
    vec2 grid = floor(uv * INVFLOAT(fpix)); //resolution
    float n = SnoisePositive(grid * noiseScale * fpix);


    // vec3 col_a = vec3(1.0, 0.0, 0.0);
    // vec3 col_b = vec3(0.102, 0.1098, 0.5922);
    // vec3 col_c = vec3(0.902, 0.0, 0.7804);
    // vec3 col_d = vec3(0.8941, 0.8863, 0.8353);

    uv.x += u_time * 0.2;
    vec3 col = ColorRamp(NoiseLayered(uv * 4.), 
        0.3,    vec3(0.902, 0.8667, 0.8275),
        0.6 + sin(u_time * 0.3) * 0.2,    vec3(0.102, 0.1098, 0.5922),
        0.85,    vec3(abs(sin(u_time * 0.1 + 0.1)), abs(sin(u_time * 0.05 + 0.6)), abs(sin(u_time * 0.1 + 2.0))),
        0.9,    vec3(0.8941, 0.8863, 0.8353)
    );
    return col;
}