//来自于bud升级
//Info:主纹理有UV流动动画,开启深度采样会有边缘接触消隐效果,溶解贴图强度受到粒子系统UV1.z影响(减法)
//遮罩贴图UV 受粒子系统UV2.zw影响
Shader "NewRender/Particle/BudBaseUVMoveMaskDissolve"
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

		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor][HDR] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)
		_BaseMapUVSpeed("Base Map UVSpeed", vector) = (1, 1, 0, 0)

		[KeywordEnum(Off,On,RgbNotAlpha,RNotAlpha,GNotAlpha,BNotAlpha)] _MaskEnable("遮罩WrapMode",Int) = 0
		_MaskTex("遮罩贴图 MaskTex", 2D) = "white" {}

		[MaterialToggle(_CAMERADEPTHTEXTURE_ON)] _CameraDepthTextureOn  ("深度采样", float) = 0
		_DepthFadeIndensity("Depth Fade Soft Strength", Range(0,10)) = 1

		//溶解
		[MaterialToggle(_DISSOLVE_ON)] _DissolveOn  ("溶解开启", float) = 0
		_DissolveTex("Dissolve Tex", 2D) = "black" {}
		_DissolveOffset("Dissolve Offset", Range(-1,1)) = 0
		_DissolveSmoothStep("Dissolve Smooth Step", vector) = (0,1.0,0,0)

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
			#pragma multi_compile _ _MASKENABLE_ON _MASKENABLE_RGBNOTALPHA _MASKENABLE_RNOTALPHA _MASKENABLE_GNOTALPHA _MASKENABLE_BNOTALPHA
			#pragma multi_compile _ _CAMERADEPTHTEXTURE_ON
			#pragma multi_compile _ _DISSOLVE_ON

			#if defined(_CAMERADEPTHTEXTURE_ON)
				#define VARYINGS_SCREEN_POS_UV
			#endif
			#if defined(_DISSOLVE_ON)
				#define VARYINGS_DISSOLVE_UV
			#endif

			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				half4 _BaseColor;
				float4 _BaseMap_ST;
				float4 _MaskTex_ST;
				float4 _DissolveTex_ST;
				float4 _BaseMapUVSpeed;
				float _CameraDepthTextureOn;
				half _DepthFadeIndensity;
				half _DissolveOn;
				float _DissolveOffset;
				half2 _DissolveSmoothStep;
			CBUFFER_END

			#if defined(_CAMERADEPTHTEXTURE_ON)
				TEXTURE2D_X(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
			#endif

				TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
				TEXTURE2D_X(_MaskTex); SAMPLER(sampler_MaskTex);
			#endif
			#if defined(_DISSOLVE_ON)
				TEXTURE2D_X(_DissolveTex); SAMPLER(sampler_DissolveTex);
			#endif

			struct Attributes_Particle
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float4 color : COLOR;
				float3 uv     		: TEXCOORD0; //z 溶解动画
				float4 animData     		: TEXCOORD1; //zw MaskTex特效uv
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Particle
			{
				float4 positionCS   : SV_POSITION;
				#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
					float4 uv           : TEXCOORD0; 	
				#else
					float2 uv           : TEXCOORD0; 	
				#endif
				float4 color : COLOR;

				#if defined(VARYINGS_SCREEN_POS_UV)
					float3 screenUV		: TEXCOORD3;
				#endif

				#if defined(VARYINGS_DISSOLVE_UV)
					float3 uv1           : TEXCOORD4; 	
				#endif

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
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.color=input.color;

				// UV
				#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
					output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;
					output.uv.zw = input.uv.xy*_MaskTex_ST.xy+_MaskTex_ST.zw+input.animData.zw;
				#else
					output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;
				#endif

				#if defined(VARYINGS_DISSOLVE_UV)	
					output.uv1.xy = input.uv.xy*_DissolveTex_ST.xy+_DissolveTex_ST.zw;
					output.uv1.z=input.uv.z;
				#endif

				#if defined(VARYINGS_SCREEN_POS_UV)
					float4 projPos = ComputeScreenPos (output.positionCS);
					output.screenUV=projPos.xyz/projPos.w;
				#endif

					// Fog
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					output.fogFactor = ComputeFogFactor(output.positionCS.z); 
				#endif

				return output;
			}

			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				float2 baseMapUV = input.uv.xy+_BaseMapUVSpeed.xy*_Time.y;
				half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseMapUV);
				half4 finishColor=color*_BaseColor*input.color;

				#if defined(_CAMERADEPTHTEXTURE_ON)
					float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(input.screenUV.xy)).r;
					float sceneZ = (unity_OrthoParams.w == 0) ? LinearEyeDepth(rawDepth, _ZBufferParams) : LinearDepthToEyeDepth(rawDepth);
					float thisZ = LinearEyeDepth(input.screenUV.z, _ZBufferParams);
					float depthInterval=abs(sceneZ-thisZ)*_DepthFadeIndensity;
					depthInterval=clamp(depthInterval,0,1.0);
					finishColor.a=finishColor.a*depthInterval;
				#endif

				#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
					half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uv.zw);
					half4 maskColor = mask;
				#endif

				#if defined(_MASKENABLE_RGBNOTALPHA)
					maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
					finishColor.a=finishColor.a*   maskColor.a;
				#elif defined(_MASKENABLE_RNOTALPHA)
					maskColor = half4(mask.r, mask.r, mask.r, mask.r);
					maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
					finishColor.a=finishColor.a*   maskColor.a;
				#elif defined(_MASKENABLE_GNOTALPHA)
					maskColor = half4(mask.g, mask.g, mask.g, mask.g);
					maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
					finishColor.a=finishColor.a*   maskColor.a;
				#elif defined(_MASKENABLE_BNOTALPHA)
					maskColor = half4(mask.b, mask.b, mask.b, mask.b);
					maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
					finishColor.a=finishColor.a*   maskColor.a;
				#endif

				#if defined(_DISSOLVE_ON)
					half dissolveColor = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, input.uv1.xy).r;
					dissolveColor=dissolveColor+_DissolveOffset;
					dissolveColor=saturate(dissolveColor-input.uv1.z);
					dissolveColor =	smoothstep(_DissolveSmoothStep.x,_DissolveSmoothStep.y,dissolveColor);
					finishColor.a=finishColor.a*dissolveColor;
				#endif

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
