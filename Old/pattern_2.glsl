#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.14159265358979323846264

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float Random(vec2 co)
    {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    }
float Random(float val)
    {
    return fract( sin( (dot(vec2(val, val), vec2(12.9898,78.233)) ) * 43758.5453123 ) );
    }
float Random2(vec2 pos)
    {
    return fract( sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123 );
    }
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
//end of template


#define GLOBALSCALE 70.4
#define CRAD 6.0
#define CDIST 15.0
#define CCOUNT 30.0
#define CSIZE_VARIATION_PERCENT 40.0
#define PAD 1.5
void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    vec2 mouse = (u_mouse.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    
    float d = 0.0;

    //grid
    vec2 tadd = vec2(sin(u_time / 2.0) * sin(u_time) + u_time, cos(u_time) + u_time);
    pos += tadd;
    vec2 fp = fract(pos / (CRAD * 2.0)) - vec2(0.5);
    vec2 id = floor(pos / (CRAD * 2.0));
    
    float cell_rand = Random2(id * 100.74);
    if(cell_rand > 0.4)
    {
        float move_rand = fract(cell_rand * 120.5423) * 0.4;
        float rad = 0.5 - move_rand; //between 0 and 0.5
        float move_angle = fract(move_rand * 432.213) * 2.0 * M_PI;


        float tf = Dist(fp, 
            vec2(cos(move_angle + u_time * 0.8) * move_rand, 
                sin(move_angle + u_time * 2.) * move_rand));
        if(tf < rad)
        {
            d = 1.0 - smoothstep(0.0, rad, tf);
        }
    }
    pos -= tadd;

    //moving dots:
    const float inc = 2.0 * M_PI / CCOUNT;
    for(float angle = 0.0; angle < 2.0 * M_PI; angle += inc)
    {
        float trx = PAD + (Random(angle + 2.0) - PAD) * CDIST;
        float try = PAD + (Random(angle + 4.43) - PAD) * CDIST;
        vec2 tcenter = vec2(cos(angle + u_time * 0.3) * trx, sin(angle + u_time * 0.7) * try);

        float trad = CRAD - CRAD * Random(angle) * (CSIZE_VARIATION_PERCENT / 100.0);
        float tf = Dist(tcenter, pos) / trad;  
        if(tf < 1.0)
        {
            d += 1.0 - smoothstep(0.0, 1.0, tf);
        }
    }

    vec3 col = vec3(0.1137, 0.0745, 0.0118) * d;
    float time_r = (sin(u_time * 2. + (pos.y * pos.x) * 0.1) + 1.0) / 1.7;
    float time_g = (sin(time_r + u_time) + 0.5) /2.0;
    float time_b = (cos(u_time * 0.8 + (pos.x * pos.y) * 0.01) + 1.0) / 2.0;
    col = vec3(time_r / 10.0, time_g , time_b / 2.0) * d + vec3(0.2, 0.2, 0.2) * d;
    if(d > 1.0)
    {
        float sub = 1.0 - smoothstep(0.0, 1.0, d - 1.0);
        float fac = (cos(sub) - 0.5) / 2.0;
        col *= 4.0 * fac;
        col += vec3(0.2353, 0.0, 0.3451) * (1.0 - fac) * 0.7;
        
    }
    gl_FragColor = vec4( min(abs(col), 1.0), 1.0);
}