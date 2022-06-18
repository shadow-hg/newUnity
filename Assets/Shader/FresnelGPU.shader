Shader "Test/Fresnel"
{
    Properties
    {
        _FresnelPow ("菲涅尔强度",float) = 1
        _FresnelColor("菲涅尔颜色",COLOR) = (1,1,1,1)
        _vec3("Vec3",vector) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "Library/PackageCache/com.unity.render-pipelines.universal@12.1.6/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
                float3 normalDir : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            sampler2D _MainTex;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _FresnelColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _FresnelPow)
                UNITY_DEFINE_INSTANCED_PROP(float3,_vec3)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v,o);
                o.vertex = TransformObjectToHClip(v.vertex);
                
                o.normalDir = TransformObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                float FresnelPow = UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelPow);
                float4 FresnelColor = UNITY_ACCESS_INSTANCED_PROP(Props,_FresnelColor);
                //float3 vec3 = UNITY_ACCESS_INSTANCED_PROP(Props,_vec3);
                
                i.normalDir = normalize(i.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //return float4(normalize(_WorldSpaceCameraPos),1);
                
                float dotValue = pow(1 - saturate(dot(i.normalDir,viewDir)),FresnelPow);
                //return float4(dotValue.x,0,0,1);
                
                float4 resultColor = FresnelColor;
                resultColor.rgb *=dotValue;
                return resultColor;
            }
            ENDHLSL
        }
    }
}

