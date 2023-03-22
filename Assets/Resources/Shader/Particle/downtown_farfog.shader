
//替换 "bud/downtown/bud_downtown_farfog" ,需要确认后续此shader是否还需要
Shader "NewRender/Particle/downtown_farfog"
{	
	Properties
	{
		_FogMask("FogMask", 2D) = "white" {}
		_FogTex("FogTex", 2D) = "white" {}
		_FogColor("FogColor", Color) = (1,1,1,0)
		_FLowSpeed("FLowSpeed", Range( 0 , 0.1)) = 0.1
		_FogTex2("FogTex2", 2D) = "white" {}
		_FogTex3("FogTex3", 2D) = "white" {}
		_FogIntensity("FogIntensity", Range( 0 , 15)) = 0
		_TimeOffset("TimeOffset", Range( 0 , 1)) = 0
		//

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}
		BlendOp[_BlendOp]
		Blend[_SrcBlend][_DestBlend]
		Cull[_Cull]
		ZTest[_ZAlways]
        ZWrite Off

		ColorMask RGB
		Lighting Off 
		Fog { Mode Off }
		
		LOD 100
		
		Pass
		{
			Tags {"LightMode"="UniversalForward"}
			HLSLPROGRAM
			#pragma vertex ParticleVert
			#pragma fragment ParticleFrag
			#pragma multi_compile_instancing 
            #pragma multi_compile_fog

			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				half _TimeOffset;
				half _FogIntensity;
				half3 _FogColor;
				half _FLowSpeed;
				float4 _FogTex3_ST;
				float4 _FogMask_ST;

			CBUFFER_END

			TEXTURE2D_X(_FogMask); SAMPLER(sampler_FogMask);
			TEXTURE2D_X(_FogTex); SAMPLER(sampler_FogTex);
			TEXTURE2D_X(_FogTex2); SAMPLER(sampler_FogTex2);
			TEXTURE2D_X(_FogTex3); SAMPLER(sampler_FogTex3);

			struct Attributes_Particle
			{
				float4 positionOS   : POSITION;
				float2 uv     		: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Particle
			{
				float4 positionCS   : SV_POSITION;
				float2 uv           : TEXCOORD0; 	
				float3 viewDirObject   : TEXCOORD1;
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half  fogFactor : TEXCOORD5;
				#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Particle ParticleVert(Attributes_Particle input){
				Varyings_Particle output = (Varyings_Particle)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				// Vertex
				output.positionCS = TransformObjectToHClip (input.positionOS.xyz);
				float3 localSpaceCameraPos = TransformWorldToObject(_WorldSpaceCameraPos.xyz);
				output.viewDirObject=normalize(localSpaceCameraPos-input.positionOS.xyz);

				// UV
				output.uv=input.uv;

				// Fog
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					output.fogFactor = ComputeFogFactor(output.positionCS.z); 
				#endif

				return output;
			}

			half3 ACESTonemap( half3 linearcolor )
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				return 
				saturate((linearcolor*(a*linearcolor+b))/(linearcolor*(c*linearcolor+d)+e));
			}

			half Ex( inout half In0, half FarFogClip, half CtF, half F1, half F2 )
			{
				float c =1.0 - saturate( (1.0 - In0) * 0.01*FarFogClip);
				float d =1.0 - saturate( In0 * 0.01*FarFogClip);
				In0=pow(min(c,d)*F2+F1,CtF);
				return In0;
			}

			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half fLowSpeed = ( _Time.y * _FLowSpeed + _TimeOffset );
				half2 uvOffsetA = half2(fLowSpeed * 0.75 , 0.32);
				float2 uvA = input.uv.xy * float2( 0.45,0.29 ) + uvOffsetA;
				half2 uvOffsetB = (half2(( ( fLowSpeed * 1.35 ) + -0.4 ) , 0.29));
				float2 uvB = input.uv.xy * float2( 0.58,0.32 ) + uvOffsetB;
				float2 uv_FogTex3 = input.uv.xy * _FogTex3_ST.xy + _FogTex3_ST.zw;
				float2 uv_FogMask = input.uv.xy * _FogMask_ST.xy + _FogMask_ST.zw;
				float maxValue=max( SAMPLE_TEXTURE2D( _FogTex, sampler_FogTex, uvA ).r , SAMPLE_TEXTURE2D( _FogTex2, sampler_FogTex2, uvB ).r ) ;
				half alpha = clamp( ( ( 1.0 - pow( abs( 1.0 - maxValue * SAMPLE_TEXTURE2D( _FogTex3, sampler_FogTex3, uv_FogTex3 ).r ) , _FogIntensity ) ) * SAMPLE_TEXTURE2D( _FogMask, sampler_FogMask, uv_FogMask ).r ) , 0.0 , 1.0 );

				half4 finishColor=half4(0,0,0,alpha);
				finishColor.rgb=_FogColor.rgb;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half fogIntensity = ComputeFogIntensity(input.fogFactor);
					finishColor.rgb = lerp(unity_FogColor.rgb, finishColor.rgb , fogIntensity);
				#endif

				return finishColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ParticleShaderGUI"
}
