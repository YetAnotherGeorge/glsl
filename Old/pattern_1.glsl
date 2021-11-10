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

//Coordinate Systems:
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

//Distances to shapes:
float DGrid_0(vec2 p, float size)
    {
    vec2 fp = fract(p / size) - vec2(0.5, 0.5);
    //dist edge: 
    return min(abs(abs(fp.x) - 0.5), abs(abs(fp.y) - 0.5));
    }
float DGrid_1(vec2 p, float size)
    {
    vec2 fp = fract(p / size) - vec2(0.5, 0.5);
    //dist edge:
    float d_box = min(abs(abs(fp.x) - 0.5), abs(abs(fp.y) - 0.5));
    float d_diag = min(DistLine2D(fp, vec2(-0.5, 0.5), vec2(0.5, -0.5)),
        DistLine2D(fp, vec2(0.5, 0.5), vec2(-0.5, -0.5)));

    return min(d_box, d_diag);
    }
float DGrid_2(vec2 p, float size)
    {
    vec2 fp = fract(p / size) - vec2(0.5, 0.5);
    //dist edge:
    float d_box = min(abs(abs(fp.x) - 0.5), abs(abs(fp.y) - 0.5));

    //dist diag
    float d_diag = min(DistLine2D(fp, vec2(-0.5, 0.5), vec2(0.5, -0.5)),
        DistLine2D(fp, vec2(0.5, 0.5), vec2(-0.5, -0.5)));
    
    //place small circle in box
    float d_circle = abs(length(fp) - 0.25);
    return min(min(d_box, d_diag), d_circle);
    }
float DSwizzle(vec2 pos, float ray_count, float swizzle, float t)
    {
    vec2 polar = ToPolarS1(pos);
    polar.y += polar.x * swizzle + t;
    polar += snoise(pos * 0.5) * smoothstep(0.0, 3.0, length(pos) / 20.0);
    float r = 2.0 * M_PI / ray_count;
    float d_ray = abs(fract(polar.y / r) - 0.5) * polar.x;

    return d_ray;
    }
float DMovingDotGrid(vec2 pos, float block_size, float time)
    {
    float min_d = 100.0;
    vec2 scaled_pos = (pos + snoise(pos*0.34) * 0.2) / block_size + vec2(time * 0.5, -time * 0.2);
    vec2 fp = fract(scaled_pos) - vec2(0.5, 0.5);
    vec2 id = floor(scaled_pos);

    for(float i = -1.0; i <= 1.0; i++)
    {
        for(float j = -1.0; j <= 1.0; j++)
        {
            vec2 relative_id = vec2(id.x + i, id.y + j);
            vec2 n2 = vec2(Random(relative_id.x + relative_id.y), Random(relative_id.x * 0.45 + relative_id.y - 80.0));
            float move = 0.2 + 0.8 * n2.x;
            float move_angle = n2.y * 2.0 * M_PI;
            float rad = 0.1 + 0.3 * fract(n2.x + sin(n2.y) * 92.834);
            
            float local_time = time * (fract(n2.x * 6342.12) * 1.5 + 0.2);
            vec2 center = vec2(cos(move_angle + local_time) * move + i, sin(move_angle + local_time * 2.0) * move + j);

            float d_center = distance(fp, center) / rad;
            //turn circles into rings:
            float rv = Random(n2);
            if(rv > 0.8 && d_center < 1.0)
            {
                d_center = 1.0 - (1.0 - smoothstep(0.3, 1.0, d_center)) * sin(d_center * 20.0 * rv);
            }
            min_d = min(min_d, d_center);
        }
    }
   
    return min_d;
    }
//end of template

#define GLOBALSCALE 15.0
float GetD(vec2 pos, vec2 mouse)
{
    float d_swizzle = DSwizzle(pos, 15.0, 0.4, -u_time * 0.2) * smoothstep(0.2, 1.0, length(pos) * 0.9); //dist swizzle
    float d_grid = DMovingDotGrid(pos, 3.0, u_time * 0.5);
    d_grid = smoothstep(0.2, 1.0, d_grid);
    return min(d_grid, d_swizzle) + d_swizzle * d_grid * 0.5;
}
void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    vec2 mouse = (u_mouse.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    float width = 0.98;

    float d = GetD(pos, mouse) / width;
    vec3 col = vec3(0.0, 0.0, 0.0);
    d /= width;

    float t = u_time * 1.5;
    if(d < width / 2.0)
    {

        float t0 = (sin(t * 1.3) * cos(t * 1.5) + 2.0) / 4.0;
        float t1 = max(t0 - (cos(t + M_PI) + 1.0) / 2.0, 0.0);
        float t2 = max(1.0 - t1 - t0, 0.0);

        float t = smoothstep(0.0, 0.1, d);
        col =  t * (
                t0 * vec3(0.8784, 0.098, 0.098) + 
                t1 * vec3(0.0, 0.9529, 0.0471) +
                t2 * vec3(0.0667, 0.4275, 0.3804)) * abs(sin(pos.y * sin(pos.x)+u_time) / 0.3)+
                (1.0 - t) * (vec3(0.0941, 0.1176, 0.3333) * sin(pos.x));
    }
    else
    {
        d = 1.0 - smoothstep(0.2, 1.0, d / width);
        float t0 = (sin(t) + 1.0) * d;
        float t1 = (cos(t + M_PI) + 1.0) * d;
        float t2 = (sin(t * 0.7) + 1.0) * d;

        vec3 orange = vec3(0.2392, 0.0706, 0.5137); 
        vec3 green = vec3(0.2392, 0.5333, 0.0667);
        vec3 red = vec3(0.1176, 0.0431, 0.7804);
        vec3 white = vec3(1.0, 1.0, 1.0);
        col = d * white + (1.0 - d) * (t0 * orange + t1 * green + t2 * red);
    }
    gl_FragColor = vec4(col, 1.0);
}