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
		//PERLIN FLOW
			//PERLIN FLOW SUPPORT FUNCTIONS
				float lerp(float t, float a, float b) {
					return a + t * (b - a);
				}
				#define pfgv 0.81649658
				float gradientDot(int index, float sinTheta, float cosTheta, float x, float y, float z) {
					const vec3 gradientUBase[16] = vec3[16](
						vec3( 1.0,  0.0,  1.0), vec3( 0.0,  1.0,  1.0),
						vec3(-1.0,  0.0,  1.0), vec3( 0.0, -1.0,  1.0),
						vec3( 1.0,  0.0, -1.0), vec3( 0.0,  1.0, -1.0),
						vec3(-1.0,  0.0, -1.0), vec3( 0.0, -1.0, -1.0),
						vec3(pfgv, pfgv, pfgv), vec3(-pfgv, pfgv, -pfgv),
						vec3(-pfgv, -pfgv, pfgv), vec3(pfgv, -pfgv, -pfgv),
						vec3(-pfgv, pfgv, pfgv), vec3(pfgv, -pfgv, pfgv),
						vec3(pfgv, -pfgv, -pfgv), vec3(-pfgv, pfgv, -pfgv)
					);

					const vec3 gradientVBase[16] = vec3[16](
						vec3(-pfgv, pfgv, pfgv), vec3(-pfgv, -pfgv, pfgv),
						vec3(pfgv, -pfgv, pfgv), vec3(pfgv, pfgv, pfgv),
						vec3(-pfgv, -pfgv, -pfgv), vec3(pfgv, -pfgv, -pfgv),
						vec3(pfgv, pfgv, -pfgv), vec3(-pfgv, pfgv, -pfgv),
						vec3( 1.0, -1.0,  0.0), vec3( 1.0,  1.0,  0.0),
						vec3(-1.0,  1.0,  0.0), vec3(-1.0, -1.0,  0.0),
						vec3( 1.0,  0.0,  1.0), vec3(-1.0,  0.0,  1.0), 
						vec3( 0.0,  1.0, -1.0), vec3( 0.0, -1.0, -1.0)
					);

					int safeIndex = index % 16;
					vec3 gradientU = gradientUBase[safeIndex];
					vec3 gradientV = gradientVBase[safeIndex];
					vec3 gradient = cosTheta * gradientU + sinTheta * gradientV;
					vec3 value = vec3(x, y, z);
					return dot(gradient, value);
				}
			//PERLIN FLOW SUPPORT FUNCTIONS

			// Returned values are in the [0, 1] range.
			float perlinFlowNoise3D(vec3 position, float flow) {
				const int perm[512] = int[512](
					151,160,137,91,90,15,
					131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
					190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
					88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
					77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
					102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
					135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
					5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
					223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
					129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
					251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
					49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
					138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
					151,160,137,91,90,15,
					131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
					190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
					88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
					77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
					102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
					135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
					5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
					223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
					129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
					251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
					49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
					138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
				);
				// Gradient component that leads to a vec3 of length sqrt(2).
				// float pfgv = sqrt(2)/sqrt(3);
				float x = position[0];
				float y = position[1];
				float z = position[2];
				
				int ix = int(floor(x));
				int iy = int(floor(y));
				int iz = int(floor(z));
				
				float fx = x - float(ix);
				float fy = y - float(iy);
				float fz = z - float(iz);
				
				ix = ix & 255;
				iy = iy & 255;
				iz = iz & 255;
				
				float i = fx * fx * fx* (fx * (fx * 6.0 - 15.0) + 10.0);
				float j = fy * fy * fy* (fy * (fy * 6.0 - 15.0) + 10.0);
				float k = fz * fz * fz* (fz * (fz * 6.0 - 15.0) + 10.0);
				
				int A = perm[ix    ] + iy, AA = perm[A] + iz, AB = perm[A + 1] + iz;
				int B = perm[ix + 1] + iy, BA = perm[B] + iz, BB = perm[B + 1] + iz;
				
				// Sine and cosine for the gradient rotation angle
				float angle = M_PI * 2.0 * flow;
				float sinTheta = sin(angle);
				float cosTheta = cos(angle);

				float noiseValue = 
					lerp(k, lerp(j, lerp(i, gradientDot(perm[AA    ], sinTheta, cosTheta, fx      , fy      , fz      ),
											gradientDot(perm[BA    ], sinTheta, cosTheta, fx - 1.0, fy      , fz      )),
									lerp(i, gradientDot(perm[AB    ], sinTheta, cosTheta, fx      , fy - 1.0, fz      ),
											gradientDot(perm[BB    ], sinTheta, cosTheta, fx - 1.0, fy - 1.0, fz      ))),
							lerp(j, lerp(i, gradientDot(perm[AA + 1], sinTheta, cosTheta, fx      , fy      , fz - 1.0),
											gradientDot(perm[BA + 1], sinTheta, cosTheta, fx - 1.0, fy      , fz - 1.0)),
									lerp(i, gradientDot(perm[AB + 1], sinTheta, cosTheta, fx      , fy - 1.0, fz - 1.0),
											gradientDot(perm[BB + 1], sinTheta, cosTheta, fx - 1.0, fy - 1.0, fz - 1.0))));
				
				// Scale to the [0, 1] range.
				return 0.5 * noiseValue + 0.5;
			}
			vec3 perlinFlowNoise3DGradient(vec3 position, float flow, float delta) {
				vec3 result = vec3(
					perlinFlowNoise3D(position + vec3(delta, 0.0, 0.0), flow) - 
					perlinFlowNoise3D(position - vec3(delta, 0.0, 0.0), flow),
					perlinFlowNoise3D(position + vec3(0.0, delta, 0.0), flow) - 
					perlinFlowNoise3D(position - vec3(0.0, delta, 0.0), flow),
					perlinFlowNoise3D(position + vec3(0.0, 0.0, delta), flow) - 
					perlinFlowNoise3D(position - vec3(0.0, 0.0, delta), flow)
				);
				result /= (2.0 * delta);
				return result;
			}
			// 3D Fractal Perlin flow noise implementation.
			// Returned values are in the [-1, 1] range.
			//WARNING: SLOW
			//float v = fractalPerlinFlowNoise3D(
			//		/*position		*/ pos * 33.,
			//		/*flow			*/ u_time * 0.1,
			//		/*lacunarity	*/ 4.0,
			//		/*flowRate		*/ 1.0,
			//		/*gain			*/1.0,
			//		/*advect		*/ 1.0,
			//		/*octaveCount	*/ 5
			//	);
			float fractalPerlinFlowNoise3D( vec3 position, float flow, float lacunarity, float flowRate, float gain, float advect, int octaveCount) {
				float noiseValue = 0.0;
				float flowValue = flow;
				float amplitude = 1.0;
				float advectionAmount = advect;
				for (int octave = 0; octave < octaveCount; ++octave) {
					float noiseOctave = amplitude * (perlinFlowNoise3D(position, flowValue) - 0.5);
					noiseValue += noiseOctave;

					if (advectionAmount != 0.0) {
						position -= advectionAmount * noiseOctave * perlinFlowNoise3DGradient(position, flow, 0.01);
					}
					position *= lacunarity;
					flowValue *= flowRate;
					amplitude *= gain;
					advectionAmount *= advect;
				}
				return noiseValue;
			}
		//PERLIN FLOW
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

#define _SOITER 16
float SnoiseOctaves(vec2 pos, float divBy, vec2 posMult, vec2 posAdd)
{
    float dinv = 1.0 / divBy;
    float n = 0.0, mult = 0.5, total = 0.0;
    for(int i = 0; i < _SOITER; i++)
    {
        n += (snoisePositive(pos) * mult);
        pos.x *= posMult.x + posAdd.x;
        pos.y *= posMult.y + posAdd.y;

        total += mult;
        mult *= dinv;
    }
    return n / total;
}
vec3 Shader(vec2 uv)
{
    float n = SnoiseOctaves(uv * 1. + 200.0 + vec2(u_time * 0.02, -u_time * 0.02), 1.45, vec2(1.5), vec2(.1));
    vec3 col = vec3(sin(u_time), cos(u_time), 0.0);
    if(n < 0.4)
        return col;
    n = (n - 0.4) * 1.6666666666;
    n *= 8.0;

    n = 1.0 / n;

    return ColorRampLinear(n, 0.26, vec3(0.0, 0.0, 0.0),
        0.4, vec3(sin(u_time * .5), cos(u_time), 0.0706),
        0.6, vec3(0.3882, 0.3843, 0.3804),
        0.9, col);
}