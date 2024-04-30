Shader "UltraEffects/Dither"
{
    Properties
    {
        // Main texture
        _MainTex ("Texture", 2D) = "white" {}
        // The noise texture
		_NoiseTex1("Noise Texture1", 2D) = "white" {}
        _NoiseTex2("Noise Texture2", 2D) = "white" {}
		_ColorRampTex("Color Ramp", 2D) = "white" {}

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


            float EaseInOutSine(float t) {
                //return 0.5 * (1 - cos(t * 3.1415926535897932384626433832795));
            }


            // Fragment shader function
            float4 frag (v2f i) : SV_Target
            {
                // Calculate the color using sampler2D and texture coordinate
                // Base texture color
                float3 col = tex2D(_MainTex, i.uv).xyz;
                // Luminance according to human eye 
				float lum = dot(col, float3(0.299f, 0.587f, 0.114f));

                // calculate the new UV with noise on it, by texture pixle's width and height
				float2 noiseUV1 = i.uv * _NoiseTex1_TexelSize.xy * _MainTex_TexelSize.zw;
                float2 noiseUV2 = i.uv * _NoiseTex2_TexelSize.xy * _MainTex_TexelSize.zw;

				noiseUV1 += float2(_XOffset, _YOffset);
                noiseUV2 += float2(_XOffset, _YOffset);

                // Calculate the color of the modified texture with the noise uv coordinates
				float3 threshold1 = tex2D(_NoiseTex1, noiseUV1);
                float3 threshold2 = tex2D(_NoiseTex2, noiseUV2);

				float thresholdLum1 = dot(threshold1, float3(0.299f, 0.587f, 0.114f));
                float thresholdLum2 = dot(threshold2, float3(0.299f, 0.587f, 0.114f));

                // lum: The original color without noise
                // threshold: the color of the noise
                // Compared to the noise color, if the color is more like black, then the value close to 0, and if white, close it 1
				float rampVal1 = lum < thresholdLum1 ? thresholdLum1 - lum : 1.0f;
                float rampVal2 = lum < thresholdLum2 ? thresholdLum2 - lum : 1.0f;

                // 0.5 - a horizontal ramp
				float3 rgb1 = tex2D(_ColorRampTex, float2(rampVal1, 0.5f));
                float3 rgb2 = tex2D(_ColorRampTex, float2(rampVal2, 0.5f));

                //float blend = 1.0 - exp(-10.0 * _Blend);
                //float easedBlend = EaseInOutSine(_Blend);
                return lerp(float4(rgb1, 1.0f), float4(rgb2, 1.0f), _Blend);
            }
            ENDCG
        }
    }
}
