 Shader "Custom/PBR"
{
    Properties
    {
        [Header(Textures)]
        _MainTex ("Texture", 2D) = "white" {}
        [Normal]_NormalTex("NormalTex",2D) = "blur"{}
        [Space(10)][Header(Base)]
        _Color("Color",color) = (1,1,1,1)
        _NormalScale("NormalScale",float) = 1.0
        
        _gg1("密度1",float) = 1.0
        _gg2("密度2",float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry"}
        Pass
        {
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
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 Mtx01: TEXCOORD1 ;
                float4 Mtx02: TEXCOORD2 ;
                float4 Mtx03: TEXCOORD3 ;
            };

            sampler2D _MainTex;
            sampler2D _NormalTex;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            half4 _Color;
            half _NormalScale;
            half _gg1 ;
            half _gg2 ;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv,_NormalTex);

                float3 WldPos = TransformObjectToWorld(v.vertex);
                float3 WldNormal = TransformObjectToWorldNormal(v.normal);
                float3 WldTangent = TransformWorldToObjectDir(v.tangent);
                float3 WldBinTangent = cross(WldNormal,WldTangent) * v.tangent.w;

                o.Mtx01 =normalize(float4(WldTangent.x,WldBinTangent.x,WldNormal.x,WldPos.x));
                o.Mtx02 = normalize(float4(WldTangent.y,WldBinTangent.y,WldNormal.y,WldPos.y));
                o.Mtx03 = normalize(float4(WldTangent.z,WldBinTangent.z,WldNormal.z,WldPos.z));
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);

                float3 normalTex = UnpackNormalScale(tex2D(_NormalTex,i.uv.zw),_NormalScale);
                normalTex.z = sqrt(1-saturate(dot(normalTex.xy,normalTex.xy)));

                float3 normal = float3(mul(i.Mtx01.xyz,normalTex),mul(i.Mtx02.xyz,normalTex),mul(i.Mtx03.xyz,normalTex));

                float NdotL = saturate(dot(normalize(_MainLightPosition.xyz),normal));
                
                //菲尼尔

                float ggg = pow(_gg1,2)/pow(_gg2,2) - 1 + pow(NdotL,2);
                
                float3 fresnel = ((pow(ggg-NdotL,2) / pow(ggg+NdotL,2))) * ((1+pow((NdotL*(ggg+NdotL)-1),2)/pow((NdotL*(ggg-NdotL)-1),2)));

                float3 diffuse = NdotL * _Color.rgb * col.rgb * _MainLightColor.rgb * fresnel;
                float alpha = _Color.a * col.a;
                
                return half4(diffuse,alpha);
            }
            ENDHLSL
        }
    }
}
