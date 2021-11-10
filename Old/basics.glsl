#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//gradient: [0 - 100]
float Circle(vec2 pos, vec2 center, float rad, float gradient)
    {
    vec2 dist = pos - center;
    return 1.0 - smoothstep(rad * (1.0 - gradient / 100.0), rad, dot(dist, dist));    
    }
float Random(vec2 pos)
    {
    //fract( sin(pos.x * 12.9898 + pos.y * 70.233) * 43758.5453123 );
    //return fract(sin( dot(pos.xy, vec2(12.9898,78.233)) ) * 43758.5453123);
    return fract(sin( pos.x * pos.x+ pos.y ) );
    }
vec2 GridNorm(vec2 pos, float block_sz)
    {
    return vec2(fract(pos.x * block_sz), fract(pos.y * block_sz));
    }
vec2 GridCenter(vec2 pos, float block_sz)
    {
    float tf = block_sz / 2.0;
    return vec2(floor(pos.x / block_sz) + 0.5, floor(pos.y / block_sz) + 0.5) * block_sz;
    }
vec3 Pattern0(vec2 pos, float scale)
    {
    pos *= scale;
    vec3 color = vec3(0.2196, 0.8, 0.3922);

	vec2 grid_center = GridCenter(pos, 0.1);
    float d = Circle(pos, grid_center, 0.0001, 10.0);
    float n = Random(grid_center);
    
    color.r = n;
    color.b = n * n;
    return color;
    }
//test comment
void main()
{
	vec2 st = gl_FragCoord.xy/u_resolution.xy;
	gl_FragColor = vec4(Pattern0(st, 10.0), 1.0 );
}   