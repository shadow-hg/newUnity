Shader "Unlit/conv"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _xx ("xx",int) = 0
        _yy ("yy",float) = 0
        _pow("pow",float) = 1
        _aa ("aa",float) = 0
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

            #include "Library/PackageCache/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _MainTex_TexelSize;
            int _xx;
            half _yy;
            half _pow;
            half _aa;

            half sobel(v2f i,int xx)
            {
                const half Gx[9] = {-1,-2,-1,
                                     0, 0, 0,
                                     1, 2, 1 };
                const half Gy[9] = {-1, 0, 1,
                                    -2, 0, 2,
                                    -1, 0, 1 };
                half texcolor = 0;
                half edgeX = 0;
                half edgeY = 0;
                for(int j = 0; j < xx; j++)
                {
                    //int j = xx;
                    half4 color = tex2D(_MainTex,i.uv[j]);
                    color = 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;

                    edgeX += color * Gx[j];
                    edgeY += color * Gy[j];
                }

                half edge = 1 - sqrt(pow(edgeX,2) + pow(edgeY,2));
                //half edge = 1 - abs(edgeX) - abs(edgeY);
                edge = 1- edge;
                
                edge = max(0,pow(edge,_pow));
                edge = edge < _aa ? 0:edge;
                edge = 1- edge;
                return edge;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv[0] = v.uv + _MainTex_TexelSize * half2(-1, -1) * _yy;
                o.uv[1] = v.uv + _MainTex_TexelSize * half2(0, -1)* _yy;
                o.uv[2] = v.uv + _MainTex_TexelSize * half2(1,  -1)* _yy;
                o.uv[3] = v.uv + _MainTex_TexelSize * half2(-1, 0)* _yy;
                o.uv[4] = v.uv + _MainTex_TexelSize * half2(0, 0)* _yy;
                o.uv[5] = v.uv + _MainTex_TexelSize * half2(1, 0)* _yy;
                o.uv[6] = v.uv + _MainTex_TexelSize * half2(-1,1)* _yy;
                o.uv[7] = v.uv + _MainTex_TexelSize * half2(0,  1)* _yy;
                o.uv[8] = v.uv + _MainTex_TexelSize * half2(1,  1)* _yy;
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return sobel(i,_xx);
            }
            ENDHLSL
        }
    }
}
