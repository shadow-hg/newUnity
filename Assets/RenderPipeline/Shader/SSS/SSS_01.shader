Shader "Unlit/SSS01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Lut ("SSSLut", 2D) = "black" {}
        _Curve ("Curve", 2D) = "white" {}
        _aa("aa",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.11/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wldNormal : TEXCOORD1;
                float3 wldPos : TEXCOORD2;
            };

            half _aa;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            TEXTURE2D(_Lut);SAMPLER(sampler_Lut);
            TEXTURE2D(_Curve);SAMPLER(sampler_Curve);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.wldPos = TransformObjectToWorld(v.vertex);
                o.wldNormal = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);
                half3 wldNormal = NormalizeNormalPerPixel(i.wldNormal);
                half3 wldLightDir = normalize(_MainLightPosition.xyz);
                half3 wldPos = normalize(i.wldPos.xyz);
                half nDotL = (dot(wldNormal,wldLightDir)) * 0.5 + 0.5;
                float halfR =pow(SAMPLE_TEXTURE2D(_Curve,sampler_Curve,i.uv).r , _aa);
                half2 lutUV = float2(nDotL,halfR);

                half3 diffuse = SAMPLE_TEXTURE2D(_Lut,sampler_Lut,lutUV);
                
                return half4(diffuse,1);
            }
            ENDHLSL
        }
    }
}
