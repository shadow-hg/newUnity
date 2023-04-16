Shader "Unlit/Saidao"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color",color) = (1,1,1,1)
        
        _Length("Length",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

        Pass
        {
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull back
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.7/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                uint id : SV_VertexID;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _Length;

            RWStructuredBuffer<float3> _VerticesBuffer;

            v2f vert (appdata v)
            {
                v2f o;

                //v.vertex.x += 0.5;
                v.vertex.x *= _Length ;
                v.vertex.x += 0.5;

                _VerticesBuffer[v.id] = v.vertex.xyz;
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);
                
                return col;
            }
            ENDHLSL
        }
    }
}
