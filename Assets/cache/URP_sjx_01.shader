// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "URP_sjx_01"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Tiling("Tiling", Float) = 10
		_Min("Min", Float) = 0
		_max("max", Float) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Anchor("Anchor", Vector) = (0.2,0.2,0,0)
		_Rotator("Rotator", Float) = 2.79
		[Toggle(_ZHONGXIN_ON)] _zhongxin("zhongxin", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		
		[Toggle]_UseScaleXZ("使用ScaleXZ保持Tiling",int) = 0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 2.0
		
		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#pragma multi_compile _ _USESCALEXZ_ON

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS_SPRITEUNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#pragma multi_compile_local __ _ZHONGXIN_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float2 _Anchor;
			float _Min;
			float _max;
			float _Tiling;
			float _Rotator;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float4 _RendererColor;

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(_USESCALEXZ_ON)
				//获取XZ轴缩放
				half4 ScaleX = half4(1,0,0,0);
				half4 ScaleZ = half4(0,0,1,0);
				ScaleX = mul(UNITY_MATRIX_M,ScaleX);
				ScaleZ = mul(UNITY_MATRIX_M,ScaleZ);
				ScaleX.w = length(ScaleX);
				ScaleZ.w = length(ScaleZ);
				#endif
				
				float2 uv_MainTex = IN.texCoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 texCoord121 = IN.texCoord0.xy  + float2( 0,0 );
				float2 temp_cast_0 = (0.5).xx;
				float2 temp_output_119_0 = ( texCoord121 - temp_cast_0 );
				float2 temp_cast_1 = (0.5).xx;
				float2 break122 = temp_output_119_0;
				float2 appendResult131 = (float2(( 1.0 - length( temp_output_119_0 ) ) , (( atan2( break122.x , break122.y ) / PI )*0.5 + 0.5)));
				float2 texCoord1 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult3 = (float2(texCoord1.x , ( 1.0 - texCoord1.y )));
				float2 break4 = appendResult3;
				
				#if defined(_USESCALEXZ_ON)
				break4 *= half2(ScaleX.w,ScaleZ.w);
				#endif
				
				float2 appendResult89 = (float2(( break4.x * 0.5 ) , break4.y));
				float2 P6 = appendResult89;
				float2 break17 = ( _Tiling * P6 );
				float InTwo13 = fmod( floor( ( (P6).y * _Tiling ) ) , 2.0 );
				float2 appendResult19 = (float2(( break17.x + ( InTwo13 * 0.5 ) ) , break17.y));
				float2 P220 = appendResult19;
				float2 Pindex62 = floor( P220 );
				float2 temp_output_22_0 = frac( P220 );
				float temp_output_23_0 = (temp_output_22_0).x;
				float2 appendResult27 = (float2(abs( ( 0.5 - temp_output_23_0 ) ) , (temp_output_22_0).y));
				float2 P328 = appendResult27;
				float2 break31 = P328;
				float temp_output_37_0 = ( ( break31.x * 2.0 ) + break31.y );
				float temp_output_40_0 = step( 1.0 , temp_output_37_0 );
				float Sign35 = sign( ( temp_output_23_0 - 0.5 ) );
				float Inone41 = ( 1.0 - InTwo13 );
				float2 appendResult56 = (float2(( ( temp_output_40_0 * ( Sign35 / 2.0 ) ) + ( Inone41 / 2.0 ) ) , 0.0));
				float2 pindex260 = appendResult56;
				float cos76 = cos( _Rotator );
				float sin76 = sin( _Rotator );
				float2 rotator76 = mul( ( ( Pindex62 + pindex260 ) / float2( 9,9 ) ) - _Anchor , float2x2( cos76 , -sin76 , sin76 , cos76 )) + _Anchor;
				#ifdef _ZHONGXIN_ON
				float2 staticSwitch132 = rotator76;
				#else
				float2 staticSwitch132 = appendResult131;
				#endif
				float smoothstepResult83 = smoothstep( _Min , _max , staticSwitch132.x);
				float W163 = max( temp_output_37_0 , ( 1.0 - ( break31.y * 1.5 ) ) );
				float2 break45 = ( float2( 0.5,1 ) - P328 );
				float W261 = max( ( ( break45.x * 2.0 ) + break45.y ) , ( 1.0 - ( break45.y * 1.5 ) ) );
				float lerpResult73 = lerp( ( 1.0 - W163 ) , ( 1.0 - W261 ) , temp_output_40_0);
				float Trianglebase77 = lerpResult73;
				
				float4 Color = ( tex2D( _MainTex, uv_MainTex ) * step( smoothstepResult83 , saturate( Trianglebase77 ) ) );

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif

				Color *= IN.color;

				return Color;
			}

			ENDHLSL
		}
	}
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
7;6;1920;1013;1660.025;363.5219;1.734027;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-3868.812,-1179.804;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;2;-3580.509,-1046.026;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;-3309.237,-1155.059;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;4;-3044.937,-1154.559;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2710.067,-1304.773;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-2467.811,-1096.504;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-2219.763,-1196.484;Inherit;True;P;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-3771.711,-783.8915;Inherit;True;6;P;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3863.778,-514.6456;Inherit;False;Property;_Tiling;Tiling;0;0;Create;True;0;0;0;False;0;False;10;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;90;-3479.1,-808.9124;Inherit;True;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3187.774,-775.9868;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;11;-2988.363,-775.9288;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;12;-2772.563,-781.1289;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2495.79,-780.4025;Inherit;True;InTwo;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-3485.056,-532.3517;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-3361.589,-266.903;Inherit;True;13;InTwo;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-3253.563,-530.2292;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-3091.189,-263.0032;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-2896.19,-549.0026;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2636.189,-533.403;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-2399.59,-538.6027;Inherit;True;P2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-3738.549,38.19666;Inherit;True;20;P2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;22;-3491.917,216.092;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-3286.917,214.092;Inherit;True;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-2979.917,414.0917;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;26;-3283.917,415.0917;Inherit;True;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;25;-2698.917,400.0918;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-2442.917,427.0917;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-2202.051,422.4938;Inherit;True;P3;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-2012.698,-1090.747;Inherit;True;28;P3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;31;-1760.667,-1087.718;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-2980.917,182.0919;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;33;-2700.917,185.0919;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1482.567,-1145.118;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2440.917,183.0919;Inherit;True;Sign;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1235.466,-1079.919;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-2231.89,-777.8025;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-2088.691,-875.0024;Inherit;False;Inone;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-657.1616,-311.0059;Inherit;True;35;Sign;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;36;-2163.079,-559.8464;Inherit;True;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;0.5,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;40;-971.5637,-1103.318;Inherit;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;42;-507.3767,-755.0284;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-1861.219,-554.0413;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;43;-259.7698,-309.6111;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-666.2246,-69.08508;Inherit;True;41;Inone;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-1618.855,-551.1392;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;49;-268.8337,-67.69031;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-12.11084,-524.3409;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;-1957.947,221.6879;Inherit;False;1992.074;651.2941;中心扩散;12;127;120;119;122;123;125;129;124;126;130;131;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;121;-1859.963,354.2483;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1306.398,-306.6109;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1801.245,554.7466;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1483.768,-826.4186;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;314.7073,-432.3155;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;560.8972,-363.6555;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1301.032,-570.0047;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;749.7454,-422.5548;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;119;-1618.446,356.3062;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;59;-3490.917,-8.908049;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-991.9636,-555.238;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-1213.367,-827.7186;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;55;-990.0227,-308.0626;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;122;-1359.245,508.7466;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;58;-733.1477,-557.6795;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;57;-972.8667,-823.8183;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;989.5723,-426.7377;Inherit;True;pindex2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;134;-1443.404,909.9382;Inherit;False;1415.645;769.3777;左下右上方向;7;66;64;70;72;75;74;76;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-3294.917,-14.90805;Inherit;True;Pindex;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ATan2OpNode;123;-1135.377,508.0108;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-519.5247,-562.1901;Inherit;True;W2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;125;-1138.922,687.4823;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-737.5618,-827.7184;Inherit;True;W1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-1212.704,1230.06;Inherit;True;60;pindex2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1198.227,974.2384;Inherit;True;62;Pindex;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-913.2205,1072.973;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-745.6153,756.9823;Inherit;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;124;-931.9434,512.7658;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-406.8127,-839.6008;Inherit;True;63;W1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;129;-982.7272,287.7161;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-392.7798,-1117.886;Inherit;True;61;W2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;69;-367.3867,-910.0215;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;75;-563.6201,1304.397;Inherit;False;Property;_Anchor;Anchor;4;0;Create;True;0;0;0;False;0;False;0.2,0.2;0.01,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;130;-632.2346,288.2318;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;68;-193.6196,-787.0267;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-546.938,1434.179;Float;False;Property;_Rotator;Rotator;5;0;Create;True;0;0;0;False;0;False;2.79;2.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;126;-528.2446,532.7466;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;71;-171.7146,-1117.886;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;74;-632.9492,1071.842;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;9,9;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;76;-303.7593,1071.705;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;73;87.67139,-950.2108;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;131;-205.7009,289.7597;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;132;66.18997,816.9466;Inherit;False;Property;_zhongxin;zhongxin;6;0;Create;True;0;0;0;False;0;False;1;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;647.8794,-949.6867;Inherit;True;Trianglebase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;492.933,670.5801;Inherit;False;77;Trianglebase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;471.8079,947.7869;Inherit;False;Property;_max;max;2;0;Create;True;0;0;0;False;0;False;1;-2.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;79;273.6644,820.7073;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;81;467.3316,773.3975;Inherit;False;Property;_Min;Min;1;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;82;697.3641,676.1118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;83;616.4468,821.7493;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;852.262,462.3443;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;0;False;0;False;-1;5e2b85270357b8a42b390fa82810466b;5f368dbeab7ad0f4d8ae462f7729dbbc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;85;854.0215,745.8766;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;414.6492,-867.1141;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;1208.372,467.8852;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1535.777,468.4914;Float;False;True;-1;2;ASEMaterialInspector;0;13;URP_sjx;cf964e524c8e69742b1d21fbe2ebcc4a;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;3;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;2;0;1;2
WireConnection;3;0;1;1
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;89;0;5;0
WireConnection;89;1;4;1
WireConnection;6;0;89;0
WireConnection;90;0;7;0
WireConnection;10;0;90;0
WireConnection;10;1;8;0
WireConnection;11;0;10;0
WireConnection;12;0;11;0
WireConnection;13;0;12;0
WireConnection;14;0;8;0
WireConnection;14;1;7;0
WireConnection;17;0;14;0
WireConnection;16;0;15;0
WireConnection;18;0;17;0
WireConnection;18;1;16;0
WireConnection;19;0;18;0
WireConnection;19;1;17;1
WireConnection;20;0;19;0
WireConnection;22;0;21;0
WireConnection;23;0;22;0
WireConnection;24;1;23;0
WireConnection;26;0;22;0
WireConnection;25;0;24;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;28;0;27;0
WireConnection;31;0;29;0
WireConnection;30;0;23;0
WireConnection;33;0;30;0
WireConnection;32;0;31;0
WireConnection;35;0;33;0
WireConnection;37;0;32;0
WireConnection;37;1;31;1
WireConnection;34;0;13;0
WireConnection;41;0;34;0
WireConnection;40;1;37;0
WireConnection;42;0;40;0
WireConnection;38;0;36;0
WireConnection;38;1;29;0
WireConnection;43;0;39;0
WireConnection;45;0;38;0
WireConnection;49;0;44;0
WireConnection;48;0;42;0
WireConnection;48;1;43;0
WireConnection;47;0;45;1
WireConnection;50;0;31;1
WireConnection;54;0;48;0
WireConnection;54;1;49;0
WireConnection;46;0;45;0
WireConnection;56;0;54;0
WireConnection;56;1;51;0
WireConnection;119;0;121;0
WireConnection;119;1;120;0
WireConnection;59;0;21;0
WireConnection;52;0;46;0
WireConnection;52;1;45;1
WireConnection;53;0;50;0
WireConnection;55;0;47;0
WireConnection;122;0;119;0
WireConnection;58;0;52;0
WireConnection;58;1;55;0
WireConnection;57;0;37;0
WireConnection;57;1;53;0
WireConnection;60;0;56;0
WireConnection;62;0;59;0
WireConnection;123;0;122;0
WireConnection;123;1;122;1
WireConnection;61;0;58;0
WireConnection;63;0;57;0
WireConnection;70;0;64;0
WireConnection;70;1;66;0
WireConnection;124;0;123;0
WireConnection;124;1;125;0
WireConnection;129;0;119;0
WireConnection;69;0;40;0
WireConnection;130;0;129;0
WireConnection;68;0;65;0
WireConnection;126;0;124;0
WireConnection;126;1;127;0
WireConnection;126;2;127;0
WireConnection;71;0;67;0
WireConnection;74;0;70;0
WireConnection;76;0;74;0
WireConnection;76;1;75;0
WireConnection;76;2;72;0
WireConnection;73;0;68;0
WireConnection;73;1;71;0
WireConnection;73;2;69;0
WireConnection;131;0;130;0
WireConnection;131;1;126;0
WireConnection;132;1;131;0
WireConnection;132;0;76;0
WireConnection;77;0;73;0
WireConnection;79;0;132;0
WireConnection;82;0;78;0
WireConnection;83;0;79;0
WireConnection;83;1;81;0
WireConnection;83;2;80;0
WireConnection;85;0;83;0
WireConnection;85;1;82;0
WireConnection;87;0;73;0
WireConnection;86;0;84;0
WireConnection;86;1;85;0
WireConnection;0;1;86;0
ASEEND*/
//CHKSM=04407BB4B1955AC49E9CA6A72A843D1C8A584940