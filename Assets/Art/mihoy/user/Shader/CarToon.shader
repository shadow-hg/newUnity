Shader "Unlit/CarToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ReMap("RemapTex",2D) = "white" {}
        _aa ("aa",Range(0,1)) = 0.1
        _ShadowRange("ShadowRange",Range(0,1)) = 0.5
        _LightColor("LightColor",color) = (1,1,1,1)
        _ShadowColor("ShadowColor",color) = (1,1,1,1)
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
                float3 WldPos : TEXCOORD1;
                float3 WldNormal : TEXCOORD2; 
            };
            
            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
            TEXTURE2D(_ReMap);SAMPLER(sampler_ReMap);
            half _aa;
            half _ShadowRange;
            half3 _LightColor;
            half3 _ShadowColor;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv.xy;

                o.WldPos = normalize(mul(UNITY_MATRIX_M,v.vertex).xyz);
                o.WldNormal = normalize(mul(UNITY_MATRIX_M,v.normal).xyz);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy);

                half NdotL = saturate(dot(i.WldNormal,_MainLightPosition.xyz));
                
                //return NdotL;
                half3 remap = SAMPLE_TEXTURE2D(_ReMap,sampler_ReMap,half2(smoothstep(0,0.5,NdotL),_aa));
                col.rgb *= remap;
                
                half stepNdotL = step(_ShadowRange,NdotL);
                //col.rgb *= lerp(_ShadowColor,_LightColor,stepNdotL) * _MainLightColor.rgb;
                
                return half4(col.rgb,1);
            }
            ENDHLSL
        }
    }
}
