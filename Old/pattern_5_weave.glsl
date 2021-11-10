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
            if(rv > 0.95 && d_center < 1.0)
            {
                d_center = 1.0 - (1.0 - smoothstep(0.3, 1.0, d_center)) * sin(d_center * 20.0 * rv);
            }
            min_d = min(min_d, d_center);
        }
    }
   
    return min_d;
    }
//----swizzled star:
#define MAX_LINE_COUNT 22.0
#define SWIZZLE 0.05
#define CUT_PADDING 0.2    //in both sides
#define CUT_GAP 3.0        //the bigger it is the larger the gap
#define CUT_CHANCE 0.7
#define PARSE_LEN 1.5
#define PARSE_ITERATIONS 6.0
float DStar(vec2 pos)
    {
    vec2 polar = ToPolar(pos);
    polar.y = mod(polar.y + u_time * 0.1 - pow(polar.x, 1.55) * SWIZZLE, 2.0 * M_PI); //swizzle

    //iterations
    float tf = PARSE_LEN * PARSE_ITERATIONS;
    if(polar.x > tf + PARSE_LEN)
        return polar.x;
    
    float start_x = floor(polar.x / PARSE_LEN) * PARSE_LEN, end_x = start_x + PARSE_LEN;

    //polar.y: [0, 2 * M_PI]
    float sector = (2.0 * M_PI) / MAX_LINE_COUNT;
    float angle_start = floor(polar.y / sector) * sector;
    float angle_mid = angle_start + sector / 2.0;

    //padding iteration
    if(polar.x > tf)
    {
        vec2 pos2 = ToCartesian(polar);
        return distance(pos2, ToCartesian(vec2(start_x, angle_mid)));
    }

    float line_id = Random(angle_mid);

    if(line_id < CUT_CHANCE || polar.x < PARSE_LEN)
    {
        float tmax = 1.0 - CUT_PADDING * 2.0;

        //get normalized cut positions
        float cut_a = Random(start_x * line_id * 132.4) * tmax;
        tmax -= cut_a;
        cut_a += CUT_PADDING;
        float cut_b = 1.0 - Random(start_x * line_id + 152.4) * tmax / CUT_GAP - CUT_PADDING;
        //turn normalized cut pos into actual coords
        cut_a = start_x + PARSE_LEN * cut_a;
        cut_b = start_x + PARSE_LEN * cut_b;

        if(cut_a <= polar.x && polar.x <= cut_b)
        {
            //get distance to circle
            vec2 circle_a = ToCartesian(vec2(cut_a, angle_mid));
            vec2 circle_b = ToCartesian(vec2(cut_b, angle_mid));
            vec2 pos2 = ToCartesian(polar);
            float d = min(distance(pos2, circle_a), distance(pos2, circle_b));
            return d;
        }
        
    }
    float d = abs(angle_mid - polar.y) * polar.x;
    return d;
    }
float DSpiral_0(vec2 pos)
    {
    vec2 polar = ToPolar(pos);
    float d = abs(snoise(polar * 0.2));
    return min(d, abs(pos.y) * 0.6);
    }
float DSpiral_1(vec2 pos)
    {
    return min((DSpiral_0(pos) * 0.6 + (snoise(pos * 0.1) + 1.0) * 0.6) * 0.5, 1.0);
    }
//spiral end

//fabric:
#define WEAVE_WIDTH 0.5
#define WEAVE_GRADIENT 0.9
#define WEAVE_LAYERS 1.
#define SEED 1.3
vec3 WeaveTwill(vec2 pos)
    {
    vec2 id = floor(pos);
    float hgrad = (sin(((pos.x + 0.5) * 0.5 + id.y / 2.0) * M_PI) + 1.0) / 2.0;
    float vgrad = (sin(((pos.y - 2.0) * 0.5 + id.x / 2.0) * M_PI) + 1.0) / 2.0;
    return vec3(mod(floor((id.x + id.y) / 2.0), 2.0), hgrad, vgrad);
    }
float DWeave(vec2 pos)
    {
    vec2 local = (fract(pos) - 0.5) * 2.0;
    vec3 col = vec3(0.0);

    float d_horizontal = abs(local.y / WEAVE_WIDTH);
    float c_horizontal = 0.0;
    float d_vertical = abs(local.x / WEAVE_WIDTH);
    float c_vertical = 0.0;
    vec3 weave_data = WeaveTwill(pos);

    if(d_horizontal < 1.0)
        c_horizontal += weave_data[1] * (1.0 - smoothstep(1.0 - WEAVE_GRADIENT, 1.0, d_horizontal));
    if(d_vertical < 1.0)
        c_vertical+= weave_data[2] * (1.0 - smoothstep(1.0 - WEAVE_GRADIENT, 1.0, d_vertical));

    if(d_horizontal < 1.0 && d_vertical < 1.0)
    {
        float type = weave_data[0];
        if(type == 0.0)
            c_vertical = 0.0;
        else
            c_horizontal = 0.0;
    }
    return max(c_horizontal, c_vertical);
    }
vec3 ColWeave(vec2 pos, vec3 col_a, vec3 col_b)
    {
    vec2 local = (fract(pos) - 0.5) * 2.0;

    float d_horizontal = abs(local.y / WEAVE_WIDTH) * (0.5 + Random(floor(pos.y) * 0.8));
    float c_horizontal = 0.0;
    float d_vertical = abs(local.x / WEAVE_WIDTH) * (0.5 + Random(floor(pos.x) * 0.8));;
    float c_vertical = 0.0;
    vec3 weave_data = WeaveTwill(pos);

    if(d_horizontal < 1.0)
        c_horizontal += weave_data[1] * (1.0 - smoothstep(1.0 - WEAVE_GRADIENT, 1.0, d_horizontal));
    if(d_vertical < 1.0)
        c_vertical+= weave_data[2] * (1.0 - smoothstep(1.0 - WEAVE_GRADIENT, 1.0, d_vertical));

    if(d_horizontal < 1.0 && d_vertical < 1.0)
    {
        float type = weave_data[0];
        if(type == 0.0)
            c_vertical = 0.0;
        else
            c_horizontal = 0.0;
    }
    if(c_horizontal > c_vertical)
        return c_horizontal * col_a;
    return c_vertical * col_b;
    }
//fabric end
//end of template

#define GLOBALSCALE 20.0

float Time()
{
    float s = StepCyclic(u_time, 0.5, 30.0, 0.8) / 2.;
    return s;
}


void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    vec2 mouse = (u_mouse.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    
    vec3 col = vec3(0.0);
    vec3 col_a = vec3(0.1725, 0.5843, 0.3333), col_b = vec3(1.0);
    for(float i = 0.0; i < WEAVE_LAYERS; i++)
    {
        col = max(col, ColWeave(RotOrigin2D(pos, Random(i) * M_PI * 2.0 + SEED), col_a, col_b));
    }
    gl_FragColor = vec4(col, 1.0);
}