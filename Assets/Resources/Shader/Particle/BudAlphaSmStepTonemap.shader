//来自于bud升级
//Info:主纹理提供颜色与透明度，由SmoothStep控制范围，颜色经过Tonemap处理
Shader "NewRender/Particle/BudAlphaSmStepTonemap"
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

		[MaterialToggle(_BASEMAPCOLOR_ON)] _BaseMapColorOn  ("混合basemap颜色", float) = 0
		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor]_BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)
		[KeywordEnum(RNotAlpha,GNotAlpha,BNotAlpha,RgbNotAlpha)] _MaskEnable("通道选择",Int) = 0
		_SmoothStepMax("颜色与透明区间", Range(0,1)) = 1
		[HDR]_LerpColorA("渐变色A", Color) = (1,1,1,1)
		[HDR]_LerpColorB("渐变色B", Color) = (1,1,1,1)
		[MaterialToggle(_ACESTONEMAP_ON)] _ACESToneMapOn  ("ACES开启", float) = 0

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
			#pragma shader_feature _ _BASEMAPCOLOR_ON
			#pragma shader_feature _ _ACESTONEMAP_ON
			#pragma shader_feature _MASKENABLE_RNOTALPHA _MASKENABLE_GNOTALPHA _MASKENABLE_BNOTALPHA _MASKENABLE_RGBNOTALPHA

			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				half4 _BaseColor;
				float4 _BaseMap_ST;
				half _SmoothStepMax;
				half4 _LerpColorA;
				half4 _LerpColorB;

			CBUFFER_END

			TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);

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

				// UV
				output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;

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

			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
				float channValue=baseTex.r;

				#if defined(_MASKENABLE_RGBNOTALPHA)
					channValue = dot(baseTex.rgb, half3(1, 1, 1)) / 1.732051;
				#elif defined(_MASKENABLE_RNOTALPHA)
					channValue=baseTex.r;
				#elif defined(_MASKENABLE_GNOTALPHA)
					channValue=baseTex.g;
				#elif defined(_MASKENABLE_BNOTALPHA)
					channValue=baseTex.b;
				#endif

				float smStepValue=smoothstep(0.0,_SmoothStepMax,channValue);

				#if defined(_BASEMAPCOLOR_ON)
					baseTex.rgb=baseTex.rgb*_BaseColor.rgb*lerp(_LerpColorA.rgb,_LerpColorB.rgb,smStepValue);
				#else
					baseTex.rgb=_BaseColor.rgb*lerp(_LerpColorA.rgb,_LerpColorB.rgb,smStepValue);
				#endif

				baseTex.a=smStepValue;
				//

				//

				#if defined(_ACESTONEMAP_ON)
					baseTex.rgb=ACESTonemap(baseTex.rgb);
				#endif

				half4 finishColor=baseTex;

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
