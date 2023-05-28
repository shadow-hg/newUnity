Shader "Unlit/PuTao"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("MainTexture", 2D) = "white" {}
        [NoScaleOffset]_NormalTex ("NormalTexture",2D) = "bump" {}
        [NoScaleOffset]_RMA("RMA_Texture",2D) = "white"{}

        _BaseColor("BaseColor",color) = (1,1,1,1)
        _SpecularColor("SpecularColor",color) = (1,1,1,1)

        _normalScale("NormalScale",float) = 1
        _roughness("Roughness",float) = 1
        _metallic("Metallic",float) = 1
        _ao("AO",float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.11/ShaderLibrary/Core.hlsl"
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.11/ShaderLibrary/Lighting.hlsl"
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.11/ShaderLibrary/Shadows.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 lightMap : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 wldNormal : TEXCOORD1;
                float4 wldTangent : TEXCOORD2;
                float4 wldBinTangent : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            TEXTURE2D(_RMA);
            SAMPLER(sampler_RMA);

            CBUFFER_START(UnityPerMaterial)
                half3 _BaseColor;
                half3 _SpecularColor;

                half _normalScale;
                half _roughness;
                half _metallic;
                half _ao;

            CBUFFER_END

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                float3 wldPos = TransformObjectToWorld(v.vertex);
                half3 wldNormal = TransformObjectToWorldNormal(v.normal);
                half3 wldTangent = TransformObjectToWorldDir(v.tangent);
                half3 wldBinTangent = cross(wldNormal, wldTangent) * v.tangent.w * unity_WorldTransformParams.w;

                o.uv = v.uv;
                o.wldNormal = float4(wldNormal, wldPos.x);
                o.wldTangent = float4(wldTangent, wldPos.y);
                o.wldBinTangent = float4(wldBinTangent, wldPos.z);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                half3 rma = SAMPLE_TEXTURE2D(_RMA, sampler_RMA, i.uv);
                half roughness = lerp(0,rma.r,_roughness);
                half material = lerp(0,rma.g,_metallic);
                half ao = lerp(0,rma.b,_ao);

                half3 Normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv));
                Normal.xy *= _normalScale;
                Normal.z = sqrt(1 - saturate(dot(Normal.xy, Normal.xy)));
                Normal = NormalizeNormalPerPixel(half3(dot(half3(i.wldTangent.x,i.wldBinTangent.x,i.wldNormal.x),Normal),dot(half3(i.wldTangent.y,i.wldBinTangent.y,i.wldNormal.y),Normal),dot(half3(i.wldTangent.z,i.wldBinTangent.z,i.wldNormal.z),Normal)));
                //return half4(Normal,1);

                Light LightInfo = GetMainLight();
                float3 wldPos = float3(i.wldNormal.w,i.wldTangent.w,i.wldBinTangent.w);
                half3 viewDir =normalize(_WorldSpaceCameraPos.xyz - wldPos.xyz);
                half3 halfV = normalize(LightInfo.direction.xyz + viewDir.xyz);
                
                half NdotL = saturate(dot(Normal,normalize(LightInfo.direction.xyz)));
                
                return NdotL.rrrr;

                return col;
            }
            ENDHLSL
        }
    }
}