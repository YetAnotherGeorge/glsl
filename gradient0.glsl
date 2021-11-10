//GLSL SPECIFIC
    #ifdef GL_ES
    precision mediump float;
    #endif
    uniform vec2 u_resolution;
    uniform vec2 u_mouse;
    uniform float u_time;
//GLSL SPECIFIC

//MATH CONSTANTS
    #define M_PI 3.14159265358979323846264
//MATH CONSTANTS

//DEFINES
    #define SWAP(a, b, type){type _temp = a; a = b; b = _temp;}
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
            float SnoisePositive(vec2 v){
                return snoise(v) * 0.5 + 0.5;
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

    float distLine2D(vec2 p, vec2 p0, vec2 p1){
        vec2 line_dir = p0 - p1;
        return abs( dot(p0 - p, normalize(vec2(line_dir[1], -line_dir[0]))) );
    }
    float distLineSegment2D(vec2 p, vec2 p0, vec2 p1){
        vec2 dir_p = p - p0;
        vec2 dir = p1 - p0;
        float t = clamp(dot(dir_p, dir) / dot(dir, dir), 0.0, 1.0);
        return length(dir_p - dir * t);
    }
    vec2 Rot2D(vec2 pos, vec2 around, float theta){
        return vec2(  cos(theta) * (pos.x - around.x) - sin(theta) * (pos.y - around.y) + around.x,
                        sin(theta) * (pos.x - around.x) + cos(theta) * (pos.y - around.y) + around.y);
    }
    vec2 RotOrigin2D(vec2 pos, float theta){
        return vec2(  cos(theta) * (pos.x) - sin(theta) * (pos.y),
                        sin(theta) * (pos.x) + cos(theta) * (pos.y));
    }
//UTILITY METHODS

vec3 Shader(vec2 uv);
void main()
{
    vec2 uv = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    gl_FragColor = vec4(Shader(uv), 1.0);
}

float NoiseLayered(vec2 pos)
{
    pos *= 0.5;
#define layers 7.
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

// v must be in the interval [0, 1]
// col_b is placed at 0.5
vec3 Mix3(float v, vec3 col_a, vec3 col_b, vec3 col_c)
{
    v *= 2.0;
    if (v < 1.0)
        return (1.0 - v) * col_a + v * col_b;
    v -= 1.0;
    return (1.0 - v) * col_b + v * col_c;
}
vec3 Shader(vec2 uv)
{
    uv.y += (u_time * .1);
    vec3 col_a = vec3(0.8157, 0.8275, 0.0667);
    vec3 col_b = vec3(0.8863, 0.0353, 0.149);
    vec3 col_c = vec3(0.3686, 0.1059, 0.8549);
    
    float n = NoiseLayered(vec2(uv.x * 0.1, uv.y * 9.0)) - 0.7;
    float t = min(max(0.0, uv.x + n), 1.0);
    vec3 gradient = Mix3(t, col_a, col_b, col_c);
    return gradient;
}