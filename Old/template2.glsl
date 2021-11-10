#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.14159265358979323846264

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//random and noise functions:
// Simplex 2D noise
//
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }
float snoise(vec2 v)
    {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
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
//
//Random noise
float random(float val)
{
    return fract( sin( (dot(vec2(val, val), vec2(12.9898,78.233)) ) * 43758.5453123 ) );
}
float random(vec2 pos)
{
    return fract( sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123 );
}
//


//Other Utils: 
vec2 rot2D(vec2 pos, vec2 around, float theta)
{
    return vec2(  cos(theta) * (pos.x - around.x) - sin(theta) * (pos.y - around.y) + around.x,
                sin(theta) * (pos.x - around.x) + cos(theta) * (pos.y - around.y) + around.y);
}
vec2 rotOrigin2D(vec2 pos, float theta)
{
    return vec2(  cos(theta) * (pos.x) - sin(theta) * (pos.y),
                sin(theta) * (pos.x) + cos(theta) * (pos.y));
}

vec3 Shader(vec3 col, vec2 uv)
{
    float d_line = min( abs(uv.y - 0.5), abs(uv.x - 0.5) );//distance to lines x = 0.5, y = 0.5
    d_line = 0.5 - d_line;
    uv = uv * sin(d_line);

    float d1 = length(uv); //distance to top left
    float d2 = distance(uv, vec2(1.0, 0.0)); //distance to top right
    float d3 = distance(uv, vec2(0.0, 1.0)); //distance to bottom left
    float d4 = distance(uv, vec2(1.0, 1.0)); //distance to bottom right

    float d = min(min(d1, d2), min(d3, d4));

    float r = d * 9.0 ;
    float g = d * 3.0 ;
    float b = d * 4.0 ;

    vec3 c = vec3(r, g, b);
    c = abs(sin(c) * 1.2 - cos(c) * 2.9);
    c.b = sin(cos(c.b * 8.0) * 5.0);
    c *= 0.6;
    //return vec3(c.r * 0.4, c.b, c.g);
    return vec3(d_line);
}
void main()
{
    vec2 pos = (gl_FragCoord.xy / min(u_resolution.x, u_resolution.y));
    vec2 mouse = (u_mouse.xy / u_resolution.x);
    
    vec3 col = Shader(vec3(0.0), pos);
    gl_FragColor = vec4(col, 1.0);
}