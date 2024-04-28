Shader "UltraEffects/Dither"
{
    Properties
    {
        // Main texture
        _MainTex ("Texture", 2D) = "white" {}
        // The noise texture
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_ColorRampTex("Color Ramp", 2D) = "white" {}
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
			sampler2D _NoiseTex;

            // The variable typically provides the size of a texture pixel of the noise texture
			float4 _NoiseTex_TexelSize;

			sampler2D _ColorRampTex;

            // Get value from dither effect
			float _XOffset;
			float _YOffset;

            // Fragment shader function
            float4 frag (v2f i) : SV_Target
            {
                // Calculate the color using sampler2D and texture coordinate
                // Base texture color
                float3 col = tex2D(_MainTex, i.uv).xyz;
                // Luminance according to human eye 
				float lum = dot(col, float3(0.299f, 0.587f, 0.114f));

                // calculate the new UV with noise on it, by texture pixle's width and height
				float2 noiseUV = i.uv * _NoiseTex_TexelSize.xy * _MainTex_TexelSize.zw;

				noiseUV += float2(_XOffset, _YOffset);

                // Calculate the color of the modified texture with the noise uv coordinates
				float3 threshold = tex2D(_NoiseTex, noiseUV);
				float thresholdLum = dot(threshold, float3(0.299f, 0.587f, 0.114f));

                // lum: The original color without noise
                // threshold: the color of the noise
                // Compared to the noise color, if the color is more like black, then the value close to 0, and if white, close it 1
				float rampVal = lum < thresholdLum ? thresholdLum - lum : 1.0f;

                // 0.5 - a horizontal ramp
				float3 rgb = tex2D(_ColorRampTex, float2(rampVal, 0.5f));

				return float4(rgb, 1.0f);
            }
            ENDCG
        }
    }
}
