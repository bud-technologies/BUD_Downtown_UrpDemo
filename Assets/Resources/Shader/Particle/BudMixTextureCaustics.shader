//来自于bud升级
//Info:主纹理与次纹理混合，次纹理UV动画，根据次纹理指定通道明暗混合
Shader "NewRender/Particle/BudMixTextureCaustics"
{	
	Properties
	{
		[Header(Blend Mode)]
		[HideInInspector]_BlendOp("__blendop", Float) = 0.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("混合层1 ，one one 是ADD", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DestBlend("混合层2 ，SrcAlpha    OneMinusSrcAlpha 是alphaBlend", int) = 1
		[Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式 : Off是双面显示，否则一般用 Back", int) = 1
		[Header(ZTest Mode)]
        [Enum(LEqual, 4, Always, 8)]_ZAlways("层级显示：LEqual默认层级，Always永远在最上层", int) = 4
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		[MainTexture]_BaseMap ("Particle Texture", 2D) = "black" {}
		[MainColor][HDR]_BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)
		_BaseMapUVSpeed("Base Map UVSpeed", vector) = (0, 0, 0, 0)

		_MixFogColor("RGB:颜色", Color) = (1,1,1,1)
		_MixSmoothStep("Mix SmoothStep", vector) = (0, 1, 0, 0)
		[MaterialToggle(MIXTEXB_REVERSE)] MixReverse  ("MixReverse", float) = 0
		[KeywordEnum(RR,RG,RB,RA,GB,GA,BA,AA,RGB)] _Color_Channel("通道相乘",Int) = 0
		_MixTexA("MixTexA", 2D) = "black" {}
		[HDR]_MixTexAColor("Color", Color) = (1,1,1,1)
		_MixTexARatio("MixTexA Ratio", Range(0,1)) = 1.0
		_MixTexAUVSpeed("Mask Tex A UVSpeed", vector) = (1, 1, 0, 0)

		_MixTexB("MixTexB", 2D) = "black" {}
		[HDR]_MixTexBColor("Color", Color) = (1,1,1,1)
		_MixTexBRatio("MixTexB Ratio", Range(0,1)) = 1.0
		_MixTexBUVSpeed("Mask Tex B UVSpeed", vector) = (1, 1, 0, 0)


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
			#pragma shader_feature_local _COLOR_CHANNEL_RR _COLOR_CHANNEL_RG _COLOR_CHANNEL_RB _COLOR_CHANNEL_RA _COLOR_CHANNEL_GG _COLOR_CHANNEL_GB _COLOR_CHANNEL_GA _COLOR_CHANNEL_BB _COLOR_CHANNEL_BA _COLOR_CHANNEL_AA _COLOR_CHANNEL_RGB _COLOR_CHANNEL_RGBA
			#pragma shader_feature_local MIXTEXB_ON
			#pragma shader_feature_local MIXTEXB_REVERSE

			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				half4 _BaseColor;
				float4 _BaseMap_ST;
				float4 _BaseMapUVSpeed;

				half _Color_Channel;

				float4 _MixTexA_ST;
				half4 _MixTexAColor;
				float4 _MixTexAUVSpeed;
				half _MixTexARatio;

				float4 _MixTexB_ST;
				half4 _MixTexBColor;
				float4 _MixTexBUVSpeed;
				half _MixTexBRatio;

				half4 _MixSmoothStep;
				half MixReverse;

				half3 _MixFogColor;

			CBUFFER_END

			TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			TEXTURE2D_X(_MixTexA); SAMPLER(sampler_MixTexA);
			TEXTURE2D_X(_MixTexB); SAMPLER(sampler_MixTexB);


			struct Attributes_Particle
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float4 color : COLOR;
				float4 uv     		: TEXCOORD0;//zw粒子控制
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Particle
			{
				float4 positionCS   : SV_POSITION;
				float2 uv           : TEXCOORD0; 	
				float4 mixUv          : TEXCOORD1; 

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half  fogFactor : TEXCOORD3;
				#endif

				float4 color : COLOR;
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
				output.positionCS =  TransformObjectToHClip(input.positionOS.xyz);
				output.color=input.color;

				// UV
				output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw+_BaseMapUVSpeed.xy*_Time.y;
				output.mixUv.xy = input.uv.xy*_MixTexA_ST.xy+_MixTexA_ST.zw+_MixTexAUVSpeed.xy*_Time.y;
				output.mixUv.zw = input.uv.xy*_MixTexB_ST.xy+_MixTexB_ST.zw+_MixTexBUVSpeed.xy*_Time.y;

				// Fog
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					output.fogFactor = ComputeFogFactor(output.positionCS.z); 
				#endif

				return output;
			}

			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half4 baseMapTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy)*_BaseColor;
				half4 mixTexA = SAMPLE_TEXTURE2D(_MixTexA, sampler_MixTexA, input.mixUv.xy);
				#if defined(MIXTEXB_ON)
					half4 mixTexB = SAMPLE_TEXTURE2D(_MixTexB, sampler_MixTexB, input.mixUv.zw);
				#else
					half4 mixTexB = mixTexA;
				#endif
				half4 mixColor = mixTexA*_MixTexAColor*mixTexB*_MixTexBColor;

				#if defined(_COLOR_CHANNEL_RR)
					float mixSmoothStepChannel=lerp(1.0,mixTexA.r,_MixTexARatio) * lerp(1.0,mixTexB.r,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_RG)
					float mixSmoothStepChannel=lerp(1.0,mixTexA.r,_MixTexARatio)*lerp(1.0,mixTexB.g,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_RB) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.r,_MixTexARatio)*lerp(1.0,mixTexB.b,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_RA) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.r,_MixTexARatio)*lerp(1.0,mixTexB.a,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_GG) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.g,_MixTexARatio)*lerp(1.0,mixTexB.g,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_GB) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.g,_MixTexARatio)*lerp(1.0,mixTexB.b,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_GA) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.g,_MixTexARatio)*lerp(1.0,mixTexB.a,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_BB) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.b,_MixTexARatio)*lerp(1.0,mixTexB.b,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_BA)
					float mixSmoothStepChannel=lerp(1.0,mixTexA.b,_MixTexARatio)*lerp(1.0,mixTexB.a,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_AA) 
					float mixSmoothStepChannel=lerp(1.0,mixTexA.a,_MixTexARatio)*lerp(1.0,mixTexB.a,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_RGB) 
				    float rgbGrayA= dot(mixTexA.rgb, half3(1, 1, 1)) / 1.732051;
					#if defined(MIXTEXB_ON)
						float rgbGrayB = dot(mixTexB.rgb, half3(1, 1, 1)) / 1.732051;
					#else
						float rgbGrayB = rgbGrayA;
					#endif
					float mixSmoothStepChannel=lerp(1.0,rgbGrayA,_MixTexARatio) * lerp(1.0,rgbGrayB,_MixTexBRatio);
				#elif defined(_COLOR_CHANNEL_RGBA)
					float rgbGrayA= dot(mixTexA.rgb, half3(1, 1, 1)) / 1.732051;
					#if defined(MIXTEXB_ON)
						float rgbGrayB = dot(mixTexB.rgb, half3(1, 1, 1)) / 1.732051;
					#else
						float rgbGrayB = rgbGrayA;
					#endif
					float mixSmoothStepChannel=lerp(1.0,rgbGrayA * mixTexA.a,_MixTexARatio)  * lerp(1.0,rgbGrayB * mixTexB.a,_MixTexBRatio);
				#endif

				#if defined(MIXTEXB_REVERSE)
					mixSmoothStepChannel=1.0-mixSmoothStepChannel;
				#endif

				float mixSmoothStep=smoothstep(_MixSmoothStep.x,_MixSmoothStep.y,mixSmoothStepChannel);

				half4 finishColor = lerp(baseMapTex,mixColor,mixSmoothStep);
				finishColor.a=baseMapTex.a;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half fogIntensity = ComputeFogIntensity(input.fogFactor);
					finishColor.rgb = lerp(unity_FogColor.rgb*_MixFogColor, finishColor.rgb , fogIntensity);
				#endif

				return finishColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ParticleShaderGUI"
}
