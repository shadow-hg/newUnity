Shader "Custom/PBR" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold ("Threshold", Range(0,1)) = 0.5
        _GridSize ("Grid Size", Range(1,100)) = 10
    }
    SubShader {
        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Core.hlsl"
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 WldNormal : TEXCOORD1;
                float3 WldPos : TEXCOORD2;
            };
            
            sampler2D _MainTex;
            
            
            v2f vert (appdata v) {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.WldNormal = TransformObjectToWorldNormal(v.normal);
                o.WldPos = TransformObjectToWorld(v.vertex);
                return o;
            }
            
            half4 frag (v2f i) : SV_Target {

                float3 WldLightDir = _MainLightPosition.xyz;
                float3 WldView = normalize(_WorldSpaceCameraPos - i.WldPos) ;
                float3 HalfV = normalize(WldLightDir + WldView);
                float NdotH =1- saturate(dot(normalize(i.WldNormal),HalfV));

                return half4(NdotH.rrrr);
            }
            ENDHLSL
        }
    }
}