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


#define GLOBALSCALE 10.0
#define POINT_WIDTH 0.1
#define POINT_GAP 0.6
#define POINT_GRAD 0.3   
#define LINE_WIDTH 6.0  //the larger it is the smaller the line

//Cartesian Coordinate System
vec3 CartesianCoords(vec2 pos, float unit, float wp_main, float wp_grid)
    {
    vec3 cs = vec3(0.0, 0.0, 0.0);
    float d_x = abs(pos.y / GLOBALSCALE);
    float d_y = abs(pos.x / GLOBALSCALE);
    if(d_x < wp_main / 100.0)
    {
        cs.r += 1.0;
    }
    else if(d_y < wp_main / 100.0)
    {
        cs.g += 1.0;
    }
    else
    {
        vec2 cell = (fract(pos / unit) - 0.5) * 2.0;
        float d = max(abs(cell.x), abs(cell.y));
        d = smoothstep(1.0 - wp_grid / 100.0, 1.0, d);
        cs += d * 0.4;
    }
    return cs;
    }
//
float PlotPoint(vec2 pos, vec2 center)
    {
    float d = Dist(pos, center) / POINT_WIDTH;
    if(d < 1.0)
    {
        d = 1.0 - abs(0.5 - d) / 0.5;
        return smoothstep(POINT_GAP, POINT_GAP + POINT_GRAD, d);
    }
    return 0.0;
    }
vec3 Remap(float val, float interval)
    {
    //dist to 0., 1., 2.
    float a = abs(val);
    float b = abs(interval - val);
    float c = abs(interval * 2.0 - val);


    return vec3(b * b, a, c) * 0.7;
    }
//

//Complex numbers:
//z[0] = radius
//z[1] = angle
vec2 ComplexTrigMult(vec2 a, vec2 b)
    {
    return vec2(a.x * b.x, a.y * b.y);
    }
//
vec2 ComplexTrigDeg_ToCart(vec2 z)
    {
    float angle = z[1] * M_PI / 180.0;
    return vec2(z[0] * cos(angle), z[0] * sin(angle));
    }
//


float F2_0(vec2 n)
    {
    return sqrt(n.x * n.x + n.y * n.y);
    }
float F2_1(vec2 n, float waviness)  
    {
    return (cos(n.y * 1.) + sin(cos(n.x*n.y * 0.6) * waviness));
    }
float F2_2(vec2 n)
    {
    n.x += cos(n.y * n.y * 0.5);
    n.y += sin(n.x * 3.0);
    float d = sqrt(n.x * n.x + n.y * n.y);
    return d;
    }
float F2_3(vec2 n)
    {
    n.x += atan(n.y * 0.8);
    n.y += cos(n.x);

    float d = sqrt(n.x * n.x + n.y * n.y);
    return d;
    }

float Graph(vec2 pos)
{
    return F2_2(pos);
}
void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    vec2 mouse = (u_mouse.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    
    vec3 col = CartesianCoords(pos, 1.0, 0.2, 1.0);
    gl_FragColor = vec4(Remap(Graph(pos), 1.0), 1.0);
}