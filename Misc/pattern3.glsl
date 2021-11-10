#version 300 es
    precision mediump float;
    uniform vec2 u_resolution;
    uniform vec2 u_mouse;
    uniform float u_time;
    out vec4 fragColor;

    vec3 Shader(vec2 uv);
    void main()
    { 
        //gl_FragCoord.xy / min(u_resolution.x, u_resolution.y) are the normalized uvs
        fragColor = vec4(Shader(gl_FragCoord.xy / min(u_resolution.x, u_resolution.y)), 1.0);
    }
//GLSL SPECIFIC

//MATH CONSTANTS
    #define M_PI 3.14159265358979323846264
//MATH CONSTANTS

//DEFINES
    #define SWAP(a, b, type){type _temp = a; a = b; b = _temp;}
    #define INVFLOAT(a) (1.0 / (a))
    #define NORMALIZEUV(uv) ((uv) * 2.0 - 1.0)
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

    //2D TILING METHODS
        //tiles the plane in size sized tiles (coord space is [0, 1])
        //generates an unique id for every tile (Z x Z -> N)
        //returns (fract.xy, id in N)
        vec3 TileSquareId(vec2 v, float sizeInv)
        {
            v *= sizeInv;
            //random id
            int px = int(floor(v.x));
            int py = int(floor(v.y));

            int l = abs(px) + abs(py);
            int offset = ((l * (l-1)) << 1) + min(1, l);
            int id = offset + py + l;
            if(px < 0)
                id += (l << 1);

            float idf = float(id);

            return vec3(fract(v), idf);
        }
    //2D TILING METHODS

    //MASKS
        //add a border to a tile with coords in the [-1, 1] interval
        //power is useful for powers less than 1
        float MaskBorder(vec2 v, float l, float power)
        {
            v = abs(v);
            float dv = (v.y - l); //distance vertical
            float dh = (v.x - l); //distance horizontal
            if(dv < 0.0 && dh < 0.0)
                return 0.0;
            float md = 1.0 - l; //max dist
            float d =  (max(dv, dh) / md);
            return pow(d, power);
        }
        //add a border to a tile with coords in the [-1, 1] interval
        float MaskBorder(vec2 v, float l)
        {
            v = abs(v);
            float dv = (v.y - l); //distance vertical
            float dh = (v.x - l); //distance horizontal
            if(dv < 0.0 && dh < 0.0)
                return 0.0;
            float md = 1.0 - l; //max dist
            float d =  (max(dv, dh) / md);
            return d;
        }
    //MASKS
//UTILITY METHODS


// vec3 BlurShaderGenCol(vec2 v);
// //interpolates between 16 values of vec3 BlurShaderGenCol(vec2 v);
// vec3 BlurShader(vec2 uv, float tileSize, float blurPow)
// {
//     vec2 pos = uv * INVFLOAT(tileSize);

//     vec2 b = floor(pos) + vec2(0.5, 0.5); //base
//     vec2 corners[16];
//     int i = 0;
//     for(float x = -1.5; x < 1.6; x += 1.0)
//         for(float y = -1.5; y < 1.6; y += 1.0)
//             corners[i++] = vec2(b.x + x, b.y + y);

//     vec3 colSum = vec3(0.0);    float weightSum = 0.0;
//     for(int i = 0; i < 16; i++)
//     {
//         float d = 1.41421356237 - distance(pos, corners[i]); //sqrt(2)
//         if(d >= 0.0)
//         {
//             d = pow(d, blurPow);
//             colSum += BlurShaderGenCol(corners[i]) * d;
//             weightSum += d;
//         }
//     }
//     return colSum / weightSum;
// }
// vec3 BlurShaderGenCol(vec2 v)
// {
//     float r0 = random(v);
//     float r1 = random(v * 2.3 + r0);
//     float r2 = random(v * 6.643 + r1);
//     return vec3(r0, r1, r2);
// }





vec3 RandCol(vec2 v)
{
    float r0 = random(v);
    float r1 = random(r0 + v.x);
    float r2 = random(r1 + v.y);
    return vec3(r0, r1, r2);
}
vec3 BlurCircular(vec2 _v, float _tileSize, float _blurPow)
{
    _v *= INVFLOAT(_tileSize);
    vec2 _vf = floor(_v);     
    vec2 _vLocal = _v - _vf; //fract of v
    const vec2 _corners[16] = vec2[16](
        vec2(-1.0, -1.0),
        vec2(-1.0, 0.0),
        vec2(-1.0, 1.0),
        vec2(-1.0, 2.0),
        vec2(0.0, -1.0),
        vec2(0.0, 0.0),
        vec2(0.0, 1.0),
        vec2(0.0, 2.0),
        vec2(1.0, -1.0),
        vec2(1.0, 0.0),
        vec2(1.0, 1.0),
        vec2(1.0, 2.0),
        vec2(2.0, -1.0),
        vec2(2.0, 0.0),
        vec2(2.0, 1.0),
        vec2(2.0, 2.0)
    );

    //interpolate based on distances using a weighted sum
    float _wSum = 0.0;
    vec3 _wAvg = vec3(0.0);
    for (int _i = 0; _i < 16; _i++)
    {
        //distance in [1, 0] space:
        //max distance value is sqrt(2) / 2 if the normal distance formula is used
        //x / (sqrt(2) / 2) = x * sqrt(2) = x * 1.41421356237

        float _td = distance(_vLocal, _corners[_i]);//original dist to point
        _td = 1.0 - _td * 0.353553390593;           //td = td / (2 * sqrt(2)); point in [0, 1] space
        _td = pow(_td, _blurPow);

        _wSum += _td;
        _wAvg += RandCol( (_vf + _corners[_i]) * _tileSize) * _td;
    }
    return _wAvg / _wSum;
}
float DFunc0(vec2 v, vec2 corner)
{
    return distance(v, corner);
}
vec3 BlurSquare(vec2 _v, float _tileSize, float _blurPow)
{
    _v *= INVFLOAT(_tileSize);
    vec2 _vf = floor(_v);     
    vec2 _vLocal = _v - _vf; //fract of v
    const vec2 _corners[16] = vec2[16](
        vec2(-1.0, -1.0),
        vec2(-1.0, 0.0),
        vec2(-1.0, 1.0),
        vec2(-1.0, 2.0),
        vec2(0.0, -1.0),
        vec2(0.0, 0.0),
        vec2(0.0, 1.0),
        vec2(0.0, 2.0),
        vec2(1.0, -1.0),
        vec2(1.0, 0.0),
        vec2(1.0, 1.0),
        vec2(1.0, 2.0),
        vec2(2.0, -1.0),
        vec2(2.0, 0.0),
        vec2(2.0, 1.0),
        vec2(2.0, 2.0)
    );

    //interpolate based on distances using a weighted sum
    float _wSum = 0.0;
    vec3 _wAvg = vec3(0.0);
    for (int _i = 0; _i < 16; _i++)
    {
        //distance in [1, 0] space:
        //max distance value is sqrt(2) / 2 if the normal distance formula is used
        //x / (sqrt(2) / 2) = x * sqrt(2) = x * 1.41421356237

        float td = DFunc0(_vLocal, _corners[_i]);
        if(td < 2.)
        {
            td = td / 2.; //distance mapped to [0, 1] space
            td = smoothstep(0., 0.3, td);
            td = 1.0 - td;

            _wSum += td;
            _wAvg += RandCol(_vf + _corners[_i]) * td;
        }
    }
    return _wAvg / _wSum;
}
vec3 Shader(vec2 uv)
{
    return BlurSquare(uv, 0.1, 6.);
}




