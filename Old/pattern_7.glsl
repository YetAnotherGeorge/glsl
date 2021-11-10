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
float Random(float val)
    {
    return fract( sin( (dot(vec2(val, val), vec2(12.9898,78.233)) ) * 43758.5453123 ) );
    }
float Random(vec2 pos)
    {
    return fract( sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123 );
    }
//

//Distance functions:
float Dist(vec2 a, vec2 b)
    {
    vec2 dist = a - b;
    return sqrt(dot(dist, dist));
    }
float Length(vec2 a)
    {
    return sqrt(dot(a, a));
    }
float DistLine2D(vec2 p, vec2 p0, vec2 p1)
    {
    vec2 line_dir = p0 - p1;
    return abs( dot(p0 - p, normalize(vec2(line_dir[1], -line_dir[0]))) );
    }
float DistLineSegment2D(vec2 p, vec2 p0, vec2 p1)
    {
    vec2 dir_p = p - p0;
    vec2 dir = p1 - p0;
    float t = clamp(dot(dir_p, dir) / dot(dir, dir), 0.0, 1.0);
    return length(dir_p - dir * t);
    }
//

//Other Utils: 
vec2 Rot2D(vec2 pos, vec2 around, float theta)
    {
    return vec2(  cos(theta) * (pos.x - around.x) - sin(theta) * (pos.y - around.y) + around.x,
                    sin(theta) * (pos.x - around.x) + cos(theta) * (pos.y - around.y) + around.y);
    }
vec2 RotOrigin2D(vec2 pos, float theta)
    {
    return vec2(  cos(theta) * (pos.x) - sin(theta) * (pos.y),
                    sin(theta) * (pos.x) + cos(theta) * (pos.y));
    }
float Step(float x, float Step, float Gradient)
    {
    x *= Step;
    return floor(x) + pow(fract(x), Gradient);
    }
//max value reached is Step * Cycle
float StepCyclic(float x, float Step, float Cycle, float Gradient)
    {
    float t = fract(x / Cycle) * Cycle;
    if(t > Cycle / 2.0)
        t = Cycle - t;
    t *= Step;
    return floor(t) + pow(fract(t), Gradient);
    }
//

//Coordinate Systems:
//radius is found at polar[0], angle is found at polar[1]
vec2 ToPolar(vec2 cartesian)
    {
    vec2 pc = vec2(length(cartesian), atan(cartesian.y, cartesian.x));
    if(cartesian.y < 0.0)
    {
        pc.y = pc.y + 2.0 * M_PI;
    }
    return pc;
    }
vec2 ToPolar(vec2 cartesian, float angle_mult)
    {
    vec2 pc = vec2(length(cartesian), atan(cartesian.y, cartesian.x));
    if(cartesian.y < 0.0)
    {
        pc.y = pc.y + 2.0 * M_PI;
    }
    pc.y *= angle_mult;
    return pc;
    }
vec2 ToPolarS0(vec2 cartesian)
    {
    vec2 pc = vec2(length(cartesian), atan(cartesian.y, cartesian.x));
    return pc;
    }
vec2 ToPolarS1(vec2 cartesian)
    {
    vec2 pc = vec2(length(cartesian), atan(cartesian.x, cartesian.y));
    return pc;
    }
//radius is found at polar[0], angle is found at polar[1]
vec2 ToCartesian(vec2 polar)
    {
    return vec2(cos(polar.y) * polar.x, sin(polar.y) * polar.x);
    }
//


#define GLOBALSCALE 6.0
#define LINE_WIDTH 6.0  //the larger it is the smaller the line

float GetDist(vec2 pos, vec2 mouse)
{
    vec2 pos_scaled = pos * 0.5;
    float d_edge = max(abs(pos_scaled.x), abs(pos_scaled.y));
    if(d_edge > 1.0)
        return 0.0;
    pos_scaled.y -= 1.0;
    pos_scaled.x += 1.0;

    pos_scaled *= 0.5;
    pos_scaled *= 70.0;

    float i = floor(pos_scaled.x);
    float j = floor(pos_scaled.y);
    return sin(sin((i * j) + u_time * i * 0.05) + 0.5 * u_time);
}
void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    vec2 mouse = (u_mouse.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    
    float d = GetDist(pos, mouse);
    gl_FragColor = vec4(vec3(d), 1.0);
}