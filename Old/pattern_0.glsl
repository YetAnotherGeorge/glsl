#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define GLOBALSCALE 500.0
#define LINE_PERCENT 80
#define LINE_THICKNESS 0.1
#define LINE_DISTANCE 1.0
#define LINE_WIDTH 0.4

float Random(float val)
    {
    return fract( sin( (dot(vec2(val, val), vec2(12.9898,78.233)) ) * 43758.5453123 ) );
    }
float Random(vec2 pos)
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
//


void main()
{
    vec2 pos = (gl_FragCoord.xy / u_resolution.x - vec2(0.5, 0.5 * u_resolution.y/u_resolution.x)) * GLOBALSCALE;
    //pos contains centered normalized coordinates
    float d = 200.0;

    vec2 fc = fract(pos / LINE_DISTANCE) - 0.5;
    float deltax = (Random(floor(pos.x / LINE_DISTANCE)) - 0.5) * (1.0 - LINE_WIDTH / LINE_DISTANCE);
    float dx = abs(fc.x + deltax);
    if(dx < LINE_WIDTH)
    {
        dx = dx / LINE_WIDTH;
        d = min(d, dx);
    }

    if(d < LINE_WIDTH)
    {
        d = 1.0 - smoothstep(0.2, 1.0, d / LINE_WIDTH);
        gl_FragColor = vec4(d, d, 0.0, 1.0);
        return;
    }
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}