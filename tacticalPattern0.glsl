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

    #define BlurCircularMacro(v, tileSize, blurPow, func, blurResult) \
        const vec2 _corners[16] = vec2[16](								  \
            vec2(-1.0, -1.0),											  \
            vec2(-1.0, 0.0),											  \
            vec2(-1.0, 1.0),											  \
            vec2(-1.0, 2.0),											  \
            vec2(0.0, -1.0),											  \
            vec2(0.0, 0.0),												  \
            vec2(0.0, 1.0),												  \
            vec2(0.0, 2.0),												  \
            vec2(1.0, -1.0),											  \
            vec2(1.0, 0.0),												  \
            vec2(1.0, 1.0),												  \
            vec2(1.0, 2.0),												  \
            vec2(2.0, -1.0),											  \
            vec2(2.0, 0.0),												  \
            vec2(2.0, 1.0),												  \
            vec2(2.0, 2.0)												  \
        );								                                  \
        vec2 _vc = v * (1.0 / tileSize);								  \
        vec2 _vf = floor(_vc);											  \
        vec2 _vLocal = _vc - _vf;										  \
        float _wSum = 0.0;											      \
        blurResult = vec3(0.0);										    \
        for (int _i = 0; _i < 16; _i++){								  \
            float _td = 1.41421356237 - distance(_vLocal, _corners[_i]);  \
            if (_td > 0.0){												  \
                _td = pow(_td, blurPow);								  \
                _wSum += _td;											  \
                blurResult += func(_corners[_i] + _vf) * _td;			  \
            }															  \
    }blurResult /= _wSum;

    #define BlurSquareMacro(v, tileSize, blurPow, func, blurResult)	  \
        const vec2 _corners[16] = vec2[16](								  \
            vec2(-1.0, -1.0),											  \
            vec2(-1.0, 0.0),											  \
            vec2(-1.0, 1.0),											  \
            vec2(-1.0, 2.0),											  \
            vec2(0.0, -1.0),											  \
            vec2(0.0, 0.0),												  \
            vec2(0.0, 1.0),												  \
            vec2(0.0, 2.0),												  \
            vec2(1.0, -1.0),											  \
            vec2(1.0, 0.0),												  \
            vec2(1.0, 1.0),												  \
            vec2(1.0, 2.0),												  \
            vec2(2.0, -1.0),											  \
            vec2(2.0, 0.0),												  \
            vec2(2.0, 1.0),												  \
            vec2(2.0, 2.0)												  \
        );																  \
        vec2 _vc = v * (1.0 / tileSize);								  \
        vec2 _vf = floor(_vc);											  \
        vec2 _vLocal = _vc - _vf;										  \
        float _wSum = 0.0;												  \
        blurResult = vec3(0.0);											\
        for (int _i = 0; _i < 16; _i++){								  \
            vec2 _dif = abs(_vLocal - _corners[_i]);					  \
            float _td = 2.0 - max(_dif.x, _dif.y);						  \
            if (_td > 0.0){												  \
                _td = smoothstep(0.749 - blurPow * 0.1, 1.0, _td * 0.5);  \
                _wSum += _td;											  \
                blurResult += func(_corners[_i] + _vf) * _td;			  \
            }															  \
    }blurResult /= _wSum;
//DEFINES

//UTILITY METHODS
    //NOISE GEN
        //SIMPLEX
            // Simplex 2D noise
            float snoise(vec2 v)
			{
				vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
				vec2 i = floor(v + dot(v, C.yy));
				vec2 x0 = v - i + dot(i, C.xx);
				vec2 i1;
				i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
				vec4 x12 = vec4(x0.x, x0.y, x0.x, x0.y) + C.xxzz;
				x12.x -= i1.x;
				x12.y -= i1.y;

				i = mod(i, 289.0);
				//vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));

				vec3 p = i.y + vec3(0.0, i1.y, 1.0);
				p = mod(((p * 34.0) + 1.0) * p, 289.0) + i.x + vec3(0.0, i1.x, 1.0);
				p = mod(((p * 34.0) + 1.0) * p, 289.0);

				vec3 m = 0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw));
				m.x = max(m.x, 0.0);
				m.y = max(m.y, 0.0);
				m.z = max(m.z, 0.0);

				m = m * m;
				m = m * m;

				vec3 x = 2.0 * fract(p * C.www) - 1.0;
				vec3 h = abs(x) - 0.5;
				vec3 ox = floor(x + 0.5);
				vec3 a0 = x - ox;
				m = (m * (1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h)));
				vec3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				vec2 tv2 = a0.yz * x12.xz + h.yz * x12.yw;
				g.y = tv2.x;
				g.z = tv2.y;

				return 130.0 * dot(m, g);
			}
            float snoisePositive(vec2 v)
			{
				return snoise(v) * 0.5 + 0.5;
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

    //COLOR OP
        //linear interpolation between 4 colors
        vec3 ColorRampLinear(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b, float pos_c, vec3 col_c, float pos_d, vec3 col_d){
            if(n < pos_a)
                return col_a; 
            else if(n < pos_b)
            {
                n -= pos_a;
                n /= (pos_b - pos_a);
                return col_a * (1.0 - n) + col_b * n;
            }
            else if(n < pos_c)
            {
                n-= pos_b;
                n /= (pos_c - pos_b);
                return col_b * (1.0 - n) + col_c * n;
            }
            else if(n < pos_d)
            {
                n-= pos_c;
                n /= (pos_d - pos_c);
                return col_c * (1.0 - n) + col_d * n;
            }
            return col_d;
        }
        //constant interpolation between 4 colors
        vec3 ColorRampConstant(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b, float pos_c, vec3 col_c, vec3 col_d){
            if(n < pos_a)
                return col_a; 
            else if(n < pos_b)
                return col_b;
            else if(n < pos_c)
                return col_c;
            return col_d;
        }
        //linear interpolation between 3 colors
        vec3 ColorRampLinear(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b, float pos_c, vec3 col_c){
            if(n < pos_a)
                return col_a; 
            else if(n < pos_b)
            {
                n -= pos_a;
                n /= (pos_b - pos_a);
                return col_a * (1.0 - n) + col_b * n;
            }
            else if(n < pos_c)
            {
                n-= pos_b;
                n /= (pos_c - pos_b);
                return col_b * (1.0 - n) + col_c * n;
            }
            return col_c;
        }
        //constant interpolation between 3 colors
        vec3 ColorRampConstant(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b, vec3 col_c){
            if(n < pos_a)
                return col_a; 
            else if(n < pos_b)
                return col_b;
            return col_c;
        }
        //linear interpolation between 2 colors
        vec3 ColorRampLinear(float n, float pos_a, vec3 col_a, float pos_b, vec3 col_b){
            if(n < pos_a)
                return col_a; 
            else if(n < pos_b)
            {
                n -= pos_a;
                n /= (pos_b - pos_a);
                return col_a * (1.0 - n) + col_b * n;
            }
            return col_b;
        }
        //constant interpolation between 2 colors
        vec3 ColorRampConstant(float n, float pos_a, vec3 col_a, vec3 col_b){
            if(n < pos_a)
                return col_a; 
            return col_b;
        }
    //COLOR OP
//UTILITY METHODS

vec3 TacticalPattern0(vec2 v)
{
    vec3 col_a = vec3(0.229, 0.299, 0.186);
    vec3 col_b = vec3(0.535, 0.561, 0.355);
    vec3 col_c = vec3(0.2118, 0.0235, 0.149);
    vec3 col_d = vec3(0.2941, 0.0627, 0.1137);
 
    vec2 noisePos = v * 0.005;
    
    float n0, n1; //get 2 noise values
    float mult = 0.5, multSum = 0.0;
    vec2 tv2 = noisePos * 1.2; //vertical noise scale
    n0 = 0.0;
    //noise pass 1
    for(int i = 0; i < 8; i++)
    {
        n0 += snoisePositive(tv2) * mult;
        tv2 = tv2 * 3.8 + 2.3;
        multSum += mult;
        mult *= 0.8;
    }
    n0 /= multSum;
    //noise pass 2
    mult = 0.5, multSum = 0.0;
    tv2 = noisePos * 1.5 + 200.; //vertical noise scale
    n1 = 0.0;
    for(int i = 0; i < 7; i++)
    {
        n1 += snoisePositive(tv2) * mult;
        tv2 = tv2 * 5.2;
        multSum += mult;
        mult *= 0.8;
    }
    n1 /= multSum;
    //noises in n0, n1

    //base color
    vec3 col0 = ColorRampConstant(n0, 
        0.5, col_a, 
        col_b);
    //fine details
    vec3 col1 = ColorRampConstant(n1, 
        0.29, col_c, 
        0.4, vec3(0.0),
        0.7, vec3(0.0), 
        col_d);
    vec3 col = col0;
    if(col1.x > 0.0)
        col = col1;
    
    return col;
}
vec3 Shader(vec2 uv)
{
    vec3 blurRes;
    BlurSquareMacro(uv, 0.01, 0.4, TacticalPattern0, blurRes);

    return blurRes;
}