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
            LOD 100

            Cull [_Cull]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Core.hlsl"

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
            half4 _MainTex_ST;
            half4 _NormalTex_ST;
            half4 _RMATex_ST;
            half4 _CubeMap_ST;
            half4 _Color;
            half4 _SpecularColor;
            half _NormalScale;
            half _Roughness;
            half _Metallic;
            half _AO;

            CBUFFER_END

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;

                float3 wldPos = normalize(TransformObjectToWorld(v.vertex));
                float3 wldNormal = TransformObjectToWorldNormal(v.normal);
                float3 wldTangent = TransformObjectToWorldDir(v.tangent);

                float3 binWldTangent = cross(wldNormal,wldTangent) * v.tangent.w;

                o.T2W0 = float4(wldTangent,wldPos.x);
                o.T2W1 = float4(binWldTangent,wldPos.y);
                o.T2W2 = float4(wldNormal,wldPos.z);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //Sampler base texture
                half4 diffuseTex = tex2D(_MainTex, i.uv);
                clip(diffuseTex.a - 0.001);
                half4 RMATex = tex2D(_RMATex,i.uv);
                half roughness = saturate(RMATex.r * _Roughness);
                half metallic = saturate(RMATex.g * _Metallic);
                half ao = saturate(RMATex.b * _AO);
                half3 wldPos = normalize(half3(i.T2W0.w,i.T2W1.w,i.T2W2.w));

                //Sampler normal texture
                half3 normalTex = UnpackNormal(tex2D(_NormalTex,i.uv));
                normalTex.xy *= _NormalScale;
                normalTex.z = sqrt(1-saturate(dot(normalTex.xy,normalTex.xy)));
                normalTex = half3(dot(float3(i.T2W0.x,i.T2W1.x,i.T2W2.x),normalTex),dot(float3(i.T2W0.y,i.T2W1.y,i.T2W2.y),normalTex),dot(float3(i.T2W0.z,i.T2W1.z,i.T2W2.z),normalTex));

                half viewDir = normalize(-_WorldSpaceCameraPos - wldPos);
                half HalfV = normalize(_MainLightPosition + viewDir);
                half NdotL = max(saturate(dot(normalTex,_MainLightPosition)),0.1 ) ;
                half NdotV = max(dot(normalTex,viewDir),0);
                half ref = reflect(-viewDir,normalTex);

                half3 finallColor = diffuseTex * NdotL;

                return half4(finallColor,1);
            }
            ENDHLSL
        }
    }
}