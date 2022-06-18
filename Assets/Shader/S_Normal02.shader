Shader "Study/PBR/Normal_02"
{
    Properties{
         _MainTex("MainTex/颜色贴图",2D) = "White"{}
        [Normal] _NormalTex("NormalTex/法线贴图",2D) = "White"{}
        _Color("Color",color) = (1,1,1,1)
        _NormalScale("NormalTex",range(0,2)) = 1
        _FresnelPow("FresnelPow",float) = 1
        _vec3("Vec3",vector) = (0,0,0,1)
        }
    SubShader{
        Pass{
            Name "Study_Normal"
            Tags{"RenderType" = "Opaque" "LightMode" = "UniversalForward" "RenderPipeline" = "UniversalRenderPipeline"}
            
            ZTest Less
            ZWrite on
            Cull back
            Lighting On
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.6/ShaderLibrary/Core.hlsl"
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.6/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            
            /*CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            half4 _Color;
            half _NormalScale;
            CBUFFER_END*/

            struct a2v
            {
                float4 vertex : POSITION ;
                float3 normal : NORMAL ;
                float4 tangent : TANGENT ;
                float2 uv0 : TEXCOORD0 ;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION ;
                float4 uv0 : TEXCOORD0 ;
                float4 WldNormal : NORMAL ;
                float4 WldTangent : Tangent ;
                float4 WldBinTangent : TEXCOORD1 ;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4,_MainTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _NormalTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4,_Color)
                UNITY_DEFINE_INSTANCED_PROP(float,_NormalScale)
                UNITY_DEFINE_INSTANCED_PROP(float,_FresnelPow)
                UNITY_DEFINE_INSTANCED_PROP(float3,_vec3)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(a2v v)
            {
                v2f o = (v2f)0;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v,o);

                float4 MainTex_ST = UNITY_ACCESS_INSTANCED_PROP(Props,_MainTex_ST);
                float4 NormalTex_ST = UNITY_ACCESS_INSTANCED_PROP(Props,_NormalTex_ST);
                
                o.pos = TransformObjectToHClip(v.vertex);

                o.uv0.xy = v.uv0 * MainTex_ST.xy +MainTex_ST.zw;
                o.uv0.zw = v.uv0 * NormalTex_ST.xy + NormalTex_ST.zw;

                o.WldNormal.xyz = normalize(TransformObjectToWorldNormal(v.normal));
                o.WldTangent.xyz = normalize(TransformObjectToWorldDir(v.tangent));
                o.WldBinTangent.xyz = cross(o.WldNormal.xyz,o.WldTangent.xyz) * v.tangent.w;
                float3 wldPos = normalize(TransformObjectToWorld(v.vertex));
                o.WldNormal.w = wldPos.x;
                o.WldTangent.w = wldPos.y;
                o.WldBinTangent.w = wldPos.z;

                

                return o;
            }
            half4 frag(v2f i) : SV_Target{

                UNITY_SETUP_INSTANCE_ID(i);
                
                float4 Color = UNITY_ACCESS_INSTANCED_PROP(Props,_Color);
                float NormalScale = UNITY_ACCESS_INSTANCED_PROP(Props,_NormalScale);
                float FresnelPow = UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelPow);
                float3 vec3 = UNITY_ACCESS_INSTANCED_PROP(Props,_vec3);
                vec3 = _WorldSpaceCameraPos.xyz;

                Light mainLight = GetMainLight();
                half4 finallColor  = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv0.xy) * Color * half4(mainLight.color.rgb,1);

                half3 NormalTex = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv0.zw),NormalScale);
                NormalTex.z = 1 - sqrt(saturate(dot(NormalTex.xy,NormalTex.xy)));

                NormalTex = mul(NormalTex,float3x3(i.WldTangent.xyz,i.WldBinTangent.xyz,i.WldNormal.xyz));
                
                float NdotL = saturate(dot(NormalTex,normalize(mainLight.direction)));
                
                float NdotV = pow(saturate(dot(normalize(NormalTex.xyz),normalize(vec3-float3(i.WldNormal.w,i.WldTangent.w,i.WldBinTangent.w)))),FresnelPow);

                finallColor *= NdotL;
                finallColor = lerp(NdotV,finallColor,FresnelPow);

                return float4(NdotV.xxx,1);
                
            }
            
            ENDHLSL
            
            }
        }    
}