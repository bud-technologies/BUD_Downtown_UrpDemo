
//镜子
Shader "NewRender/Mirror/Default" {
	Properties{
		[MainTexture]_BaseMap("Base Color Map", 2D) = "white" {}
        [MainColor]_BaseColor("BaseColor", Color) = (0.63, 0.58, 0.44, 1)
		_Proportion("Proportion 占比", Range(0.0, 1.0)) = 1
		//
		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}

	SubShader{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent-100" "RenderPipeline" = "UniversalPipeline" }

		Blend One Zero
		Cull[_Cull]

		Pass {

			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma prefer_hlslcc gles
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMap_ST;
				half4 _BaseColor;
				half _Proportion;
			CBUFFER_END

			TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
			TEXTURE2D_X(_ReflectionScreenTex); SAMPLER(sampler_ReflectionScreenTex);

			struct Attributes_Water
			{
				float4	positionOS : POSITION;
				float2	uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Water
			{
				float4	positionCS	: SV_POSITION;
				float2	uv	: TEXCOORD0;
				float4 screenUV : TEXCOORD1;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half  fogFactor : TEXCOORD5;
				#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Water Vertex(Attributes_Water input)
			{
				Varyings_Water output = (Varyings_Water)0;
				//
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.screenUV=ComputeScreenPos(output.positionCS);
				output.uv = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					output.fogFactor = ComputeFogFactor(output.positionCS.z);
				#endif

				return output;
			}

			half4 Fragment(Varyings_Water input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half4 baseMapTex = SAMPLE_DEPTH_TEXTURE(_BaseMap, sampler_BaseMap, input.uv.xy);
				half4 comp=baseMapTex;

				half3 screenUV = input.screenUV.xyz / input.screenUV.w;
				half4 reflection = SAMPLE_TEXTURE2D(_ReflectionScreenTex, sampler_ReflectionScreenTex, screenUV.xy);
				comp=lerp(comp,reflection,_Proportion);

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half fogIntensity = ComputeFogIntensity(input.fogFactor);
					comp.rgb = lerp(unity_FogColor.rgb, comp.rgb, fogIntensity);
				#endif

				return comp;

			}

			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	//CustomEditor "NewRenderShaderGUI.BudWaterShaderGUI"
}
