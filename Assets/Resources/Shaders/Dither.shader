Shader "Custom/Dither"
{
    Properties
    {
        // Main texture
        _MainTex ("Texture", 2D) = "white" {}
        // The noise texture
		_NoiseTex1("Noise Texture1", 2D) = "white" {}
        _NoiseTex2("Noise Texture2", 2D) = "white" {}
		_ColorRampTex("Color Ramp", 2D) = "white" {}

        _BlendType ("_BlendType", Int) = 1

        // Control the blend value for transition
        _Blend("Blend", Range(0,1)) = 0
    }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always

        // Render channel
        Pass
        {
            // The start of HLSL
            CGPROGRAM
            // Define the function for the vertex shader and the fragment shader
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Define the data imported to the vertex shader
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Define the data from vertex shader to the fragment shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Vertex shader function
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Get value from dither effect
            sampler2D _MainTex;

			float4 _MainTex_TexelSize;

            // Get value from dither effect
			sampler2D _NoiseTex1;
            sampler2D _NoiseTex2;

            // The variable typically provides the size of a texture pixel of the noise texture
			float4 _NoiseTex1_TexelSize;
            float4 _NoiseTex2_TexelSize;

			sampler2D _ColorRampTex;

            // Get value from dither effect
			float _XOffset;
			float _YOffset;


            float _Blend;
            int _BlendType;


            float EaseInOutSine(float t) {
                return 0.5 * (1 - cos(t * 3.1415926535897932384626433832795));
            }

            float EaseInBounce(float x) {
                if (x < 1 / 2.75) {
                    return 7.5625 * x * x;
                } else if (x < 2 / 2.75) {
                    x -= 1.5 / 2.75;
                    return 7.5625 * x * x + 0.75;
                } else if (x < 2.5 / 2.75) {
                    x -= 2.25 / 2.75;
                    return 7.5625 * x * x + 0.9375;
                } else {
                    x -= 2.625 / 2.75;
                    return 7.5625 * x * x + 0.984375;
                }
            }

            float EaseInCircle(float x) {
				return 1 - sqrt(1 - x * x);
			}

            float2 edge(float2 uv, float2 delta)
            {
                float3 up = tex2D(_MainTex, uv + float2(0.0, 1.0) * delta);
                float3 down = tex2D(_MainTex, uv + float2(0.0, -1.0) * delta);
                float3 left = tex2D(_MainTex, uv + float2(1.0, 0.0) * delta);
                float3 right = tex2D(_MainTex, uv + float2(-1.0, 0.0) * delta);
                float3 centre = tex2D(_MainTex, uv);

                return float2(min(up.b, min(min(down.b, left.b), min(right.b, centre.b))),
                    max(max(distance(centre.rg, up.rg), distance(centre.rg, down.rg)),
                        max(distance(centre.rg, left.rg), distance(centre.rg, right.rg))));
            }

            // Fragment shader function
            // Fragment shader function
            float4 frag(v2f i) : SV_Target
            {
                // Calculate the base texture color
                float3 col = tex2D(_MainTex, i.uv).xyz;
                // Calculate luminance according to human perception
                float lum = dot(col, float3(0.299f, 0.587f, 0.114f));

                // Calculate edge data
                float2 edgeData = edge(i.uv, _MainTex_TexelSize.xy * 2.0f);

                // Enhance edges by adjusting luminance based on edge detection
                float enhancedLum = lum * (1.0f - clamp(edgeData.y * 10.0f, 0.0f, 1.0f));

                // Use noise textures to calculate threshold luminance
                float2 noiseUV1 = i.uv * _NoiseTex1_TexelSize.xy * _MainTex_TexelSize.zw + float2(_XOffset, _YOffset);
                float2 noiseUV2 = i.uv * _NoiseTex2_TexelSize.xy * _MainTex_TexelSize.zw + float2(_XOffset, _YOffset);

                float3 threshold1 = tex2D(_NoiseTex1, noiseUV1);
                float3 threshold2 = tex2D(_NoiseTex2, noiseUV2);

                float thresholdLum1 = dot(threshold1, float3(0.299f, 0.587f, 0.114f));
                float thresholdLum2 = dot(threshold2, float3(0.299f, 0.587f, 0.114f));

                // Determine the ramp values based on luminance and thresholds
                float rampVal1 = enhancedLum < thresholdLum1 ? thresholdLum1 - enhancedLum : 1.0f;
                float rampVal2 = enhancedLum < thresholdLum2 ? thresholdLum2 - enhancedLum : 1.0f;

                float3 rgb1 = tex2D(_ColorRampTex, float2(rampVal1, 0.5f));
                float3 rgb2 = tex2D(_ColorRampTex, float2(rampVal2, 0.5f));

                // Blend based on the selected easing function
                float blend = 0.0f;
                switch (_BlendType)
                {
                    case 1:
                        blend = EaseInOutSine(_Blend);
                        break;
                    case 2:
                        blend = EaseInCircle(_Blend);
                        break;
                    case 3:
                        blend = EaseInBounce(_Blend);
                        break;
                    default:
                        blend = _Blend;
                        break;
                }

                // Return the final color by blending the two color ramps based on edge detection
                return lerp(float4(rgb1, 1.0f), float4(rgb2, 1.0f), blend);
            }
            ENDCG
        }
    }
}
