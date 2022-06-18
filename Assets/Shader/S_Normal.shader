 Shader "Study/PBR/Normal_01"
{
    Properties{
        _MainTex("MainTex",2D) = "White"{}
        _NormalTex("NormalTex",2D) = "Blue"{}
        _Color("Color",color) = (1,1,1,1)
        _NormalScale("NormalScale",float) = 1
        }
    Subshader{
        
        Pass{
            Tags{"RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry"}    
            ZTest Less
            ZWrite on
            Cull back
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.6/ShaderLibrary/Core.hlsl"
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.6/ShaderLibrary/Lighting.hlsl"

            struct a2v
            {
                float4 vertex : POSITION ;
                float3 normal : NORMAL ;
                float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0 ;
                float3 vertColor : COLOR ;
            };

            struct v2f
            {
                float4 pos : SV_POSITION ;
                float4 uv0 : TEXCOORD0 ;
                float4 OTW0 : TEXCOORD1 ;
                float4 OTW1 : TEXCOORD2 ;
                float4 OTW2 : TEXCOORD3 ;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            
            CBUFFER_START(PerUnityMaterial)
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            half4 _Color;
            float _NormalScale;
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o = (v2f)0;
                o.pos = TransformObjectToHClip(v.vertex);
                float3 wldNormal = TransformObjectToWorldNormal(v.normal);
                float3 wldTangent = TransformObjectToWorldDir(v.tangent);
                float3 wldPos = TransformObjectToWorld(v.vertex);
                
                float3 binTangent = cross(wldNormal.xyz,wldTangent.xyz) * v.tangent.w;

                o.OTW0 = float4(wldTangent.x,binTangent.x,wldNormal.x,wldPos.x);
                o.OTW1 = float4(wldTangent.y,binTangent.y,wldNormal.y,wldPos.y);
                o.OTW2 = float4(wldTangent.z,binTangent.z,wldNormal.z,wldPos.z);
                
                o.uv0.xy = TRANSFORM_TEX(v.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw,_MainTex);
                o.uv0.zw = TRANSFORM_TEX(v.uv0.xy * _NormalTex_ST.xy + _NormalTex_ST.zw,_NormalTex);
                
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float3 tangentNormal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv0.zw));
                float3x3 MartixNormal = float3x3(i.OTW0.x,i.OTW1.x,i.OTW2.x,
                                                i.OTW0.y,i.OTW1.y,i.OTW2.y,
                                                i.OTW0.z,i.OTW1.z,i.OTW2.z);
                
                //float3 wldNormalTex = normalize(float3(dot(i.OTW0.xyz,tangentNormal),dot(i.OTW1.xyz,tangentNormal),dot(i.OTW2.xyz,tangentNormal)));
                tangentNormal.xy *= _NormalScale;
                tangentNormal.z =sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal)));
                float3 wldNormalTex = normalize(mul(tangentNormal,MartixNormal));

                Light mainLight = GetMainLight();
                
                float NdotL = saturate(dot(wldNormalTex.xyz,normalize(mainLight.direction)));
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv0);
                half3 finallColor = NdotL * mainTex;
                return half4(finallColor,1);
            }
            
            
            ENDHLSL

            }
    }
}
