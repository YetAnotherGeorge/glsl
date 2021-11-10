#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PLOT_RES 10.0

// Hue to RGB function from Fabrice's shadertoyunofficial blog:
#define hue2rgb(hue) 0.6 + 0.6 * cos(6.3 * hue + vec3(0.0, 23.0, 21.0))

float sdLine(in vec2 p, in vec2 a, in vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

vec2 Bezier(in vec2 a, in vec2 b, in vec2 c, in vec2 d, in float t) {
    float tInv = 1.0 - t;
    return a * tInv * tInv * tInv +
           b * 3.0 * t * tInv * tInv +
           c * 3.0 * tInv * t * t +
           d * t * t * t;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * u_resolution.xy) / u_resolution.y * 4.0;
    float unit = 8.0 / u_resolution.y;
    vec3 color = vec3(0.0);

    float t1 = 0.5 * u_time, t2 = u_time, t3 = 1.25 * u_time;
    float c1 = cos(t1), s1 = sin(t1);
    float c2 = cos(t2), s2 = sin(t2);
    float c3 = cos(t3), s3 = sin(t3);

    vec2 a = vec2(c1 * 3.0, s2 * 2.0);
    vec2 b = vec2(s3 * 3.0, c2 * 2.0);
    vec2 c = vec2(c3 * 3.0, s2 * 2.0);
    vec2 d = vec2(c2 * 3.0, s1 * 2.0);

    vec2 prevPos = a;
    float tStep = 1.0 / PLOT_RES;
    const float stop  =  1.0;
    for (float t= 0.0; t < stop; t += 0.1) {
        vec2 curPos = Bezier(a, b, c, d, t);
        color = mix(color, hue2rgb(t + u_time), smoothstep(unit, 0.0, sdLine(uv, prevPos, curPos)));
        prevPos = curPos;
    }

    fragColor = vec4(color, 1.0);
}