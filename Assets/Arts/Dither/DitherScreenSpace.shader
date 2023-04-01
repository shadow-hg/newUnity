Shader "Unlit/Dither"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _maskTilling("maskTilling",vector) = (1,1,1,1)
        _clip("clip",range(0,1)) = 0.00
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float4 ScreenPosUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _maskTilling;
            half _clip;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.ScreenPosUV = ComputeScreenPos(o.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                
                float2 screenUV =  i.ScreenPosUV.xy/i.ScreenPosUV.w;
                half4 col = tex2D(_MainTex, i.uv);

                float2 maskX = pow(sin(screenUV.xy * _maskTilling.xy + _maskTilling.zw),2);
                maskX.x = saturate(lerp(step(_clip,maskX.x),step(_clip,maskX.y),0.5));
                clip(maskX.x - 0.001);

                return col;
                //return half4(maskX,0,1);
            }
            ENDHLSL
        }
    }
}
