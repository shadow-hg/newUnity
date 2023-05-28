Shader "Unlit/point"
{
    Properties
    {
        [HDR]_Color("Color",color) = (1,1,1,1)
        _R("R",range(0,0.3)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half3 _Color;
            half _R;

            half RR(float2 uv,half2 UVOffset)
            {
                uv += UVOffset;
                half sphere = distance(uv,0.5);
                sphere = step(sphere,_R);
                return sphere;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half mask = RR(i.uv,half2(0.5,0.5)) + RR(i.uv,half2(-0.5,0.5)) +
                    RR(i.uv,half2(0.5,-0.5)) + RR(i.uv,half2(-0.5,-0.5));

                clip(mask - 0.001);
                
                return half4(mask * _Color,1);
            }
            ENDHLSL
        }
    }
}
