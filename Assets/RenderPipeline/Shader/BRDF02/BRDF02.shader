Shader "Unlit/PBRTest"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Diffuse Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalTex("Normal Texture",2D) = "bump"{}
        [NoScaleOffset]_RMATex("Roughness/Metallic/AO",2D) = "white"{}
        [NoScaleOffset]_CubeMap("CubeMap",cube) = "cube"{}
        [Header(________________________________________________________________________________________________)]
        [Space(8)]
        _Color("Color",color) = (1,1,1,1)
        _SpecularColor("SpecularColor/高光颜色",color) = (1,1,1,1)
        _NormalScale("NormalScale/法线强度",float) = 1.0
        _Roughness("Roughness/粗糙度",range(0,1)) = 1.0
        _Metallic("Metallic/金属度",range(0,1)) = 1.0
        _AO("AoStrength/环境光遮蔽强度",range(0,1)) = 1.0

        [Header(________________________________________________________________________________________________)]
        [Space(8)]
        [Space(8)]
        [Enum(off,0,front,1,back,2)]_Cull("Cull",int) = 2
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Opaque" "Queue" = "Geometry"
            }

            Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Core.hlsl"
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float4 T2W0 : TEXCOORD1;
                float4 T2W1 : TEXCOORD2;
                float4 T2W2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _NormalTex;
            sampler2D _RMATex;
            sampler2D _CubeMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            float4 _RMATex_ST;
            float4 _CubeMap_ST;
            float4 _Color;
            float4 _SpecularColor;
            float _NormalScale;
            float _Roughness;
            float _Metallic;
            float _AO;

            CBUFFER_END

            half3 BRDF_F(half3 F0,half LdotH)
            {
                half3 F1 = F0 + (1-F0) * pow(1-LdotH,5);
                
                return F1;
            }
            half BRDF_D_GGX(half roughness,half NdotH)
            {
                half roughness2 = roughness * roughness;
                half DGGX = roughness2 / (PI * pow(pow(NdotH,2) * (pow(roughness2,2) - 1) +1,2));
                return DGGX;
            }
            half BRDF_G(half roughness,half NdotV,half NdotL)
            {
                half k = pow(1+ roughness,2) / 8 ;
                half G1 = NdotV / lerp(NdotV ,1, k);
                half G2 = NdotL / lerp(NdotL ,1, k);
                
                return G1 * G2;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;

                float3 wldPos = TransformObjectToWorld(v.vertex);
                half3 wldNormal = TransformObjectToWorldNormal(v.normal);
                half3 wldTangent = TransformObjectToWorldDir(v.tangent);

                half3 binWldTangent = cross(wldNormal,wldTangent) * v.tangent.w*unity_WorldTransformParams.w;

                o.T2W0 = float4(wldTangent,wldPos.x);
                o.T2W1 = float4(binWldTangent,wldPos.y);
                o.T2W2 = float4(wldNormal,wldPos.z);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //Sampler base texture
                half4 diffuseTex = tex2D(_MainTex, i.uv);
                //clip(diffuseTex.a - 0.001);
                half4 RMATex = tex2D(_RMATex,i.uv);
                half smoothness = saturate(RMATex.r * _Roughness);
                half roughness = pow(1-smoothness,2);
                half metallic = saturate(RMATex.g * _Metallic);
                half ao = saturate(RMATex.b * _AO);
                float3 wldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);

                //Sampler normal texture
                half3 normalTex = UnpackNormal(tex2D(_NormalTex,i.uv));
                normalTex.xy *= _NormalScale;
                normalTex.z = sqrt(1-saturate(dot(normalTex.xy,normalTex.xy)));
                normalTex = float3(dot(float3(i.T2W0.x,i.T2W1.x,i.T2W2.x),normalTex),dot(float3(i.T2W0.y,i.T2W1.y,i.T2W2.y),normalTex),dot(float3(i.T2W0.z,i.T2W1.z,i.T2W2.z),normalTex));
                normalTex = NormalizeNormalPerPixel(normalTex);

                float3 viewDir = SafeNormalize(_WorldSpaceCameraPos - wldPos);
                float3 HalfV = normalize(viewDir + normalize(GetMainLight().direction) );
                half NdotL = max(dot(normalTex,normalize(_MainLightPosition.xyz)),0.000001);
                half NdotV = max(dot(normalTex,viewDir),0.000001);
                half NdotH=max(saturate(dot(HalfV,normalTex)),0.000001);
                half LdotH = max(dot(_MainLightPosition,HalfV),0.000001);
                float3 ref = reflect(-viewDir,normalTex);

                half D = BRDF_D_GGX(roughness,NdotH);
                half G = BRDF_G(roughness,NdotV,NdotL);
                half3 F0 = lerp(float3(0.04,0.04,0.04),diffuseTex,metallic);
                half3 F = BRDF_F(F0,LdotH);

                half3 finallColor =(1 - F) * (1-metallic) * diffuseTex * _MainLightColor * NdotL + ((D*F*G)/(4*NdotV*NdotL)) * _MainLightColor * NdotL * PI;
                finallColor *= ao;

                return half4(finallColor,1);
            }
            ENDHLSL
        }
    }
}