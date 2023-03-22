
//指示标记
Shader "NewRender/Indicator/Default"
{
	Properties
	{
		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor][HDR]_BaseColor("Base Color", Color) = (0.5,0.5,0.5,1)

		_MapPow ("MapPow", Range(1, 10)) = 1
		_CutOff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		[KeywordEnum(Off,On)] _TimeAnim("时间动画",Int) = 0

		[HideInInspector]_MainTex ("MainTex (RGB)", 2D) = "white" {}
	}
		
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}
		ColorMask RGB
		Blend SrcAlpha One
		Cull Off 
		Lighting Off 
		ZWrite Off 
		Fog { Mode Off }

		HLSLINCLUDE

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

		CBUFFER_START(UnityPerMaterial)
			half _CutOff;
			half4 _BaseColor;
			float4 _BaseMap_ST;
			float _MapPow;
		CBUFFER_END

		TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);

		struct Attributes_Indicator {
			float4 positionOS : POSITION;
			float2 uv : TEXCOORD0;
			half4 color : COLOR0;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct Varyings_Indicator
		{
			float4 positionCS : SV_POSITION;
			float2 uv : TEXCOORD0;
			half4 color : TEXCOORD1;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		Varyings_Indicator IndicatorVert (Attributes_Indicator input)
		{
			Varyings_Indicator output=(Varyings_Indicator)0;

			// Instance
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_TRANSFER_INSTANCE_ID(input, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
			output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
			output.color = input.color*_BaseColor;
			return output;
		}

		half4 IndicatorFrag(Varyings_Indicator input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

			//
			half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
			#if defined(_TIMEANIM_ON)
				float mapPowTime = lerp(1.0,_MapPow,(sin(_Time.y*1.5)+1.0)*0.5);
			#else
				float mapPowTime = _MapPow;
			#endif
	
			color=pow(abs(color),mapPowTime);
	
			#if defined(_ALPHATEST_ON)
				if (color.a < _CutOff)
					discard;
			#endif
			color *= input.color;
			return color;
		}

		ENDHLSL

		Pass
		{
			Tags {"LightMode"="UniversalForward"}
			ZTest LEqual

			Stencil
			{
				Ref 0
				Comp equal
				Pass keep
				Fail keep
				ZFail keep
			}

			HLSLPROGRAM
			#pragma vertex IndicatorVert
			#pragma fragment IndicatorFrag
			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _TIMEANIM_ON

			ENDHLSL
		}

		Pass
		{
			Tags {"LightMode"="SrpDefaultUnlit"}
			ZTest GEqual

			Stencil
			{
				Ref 0
				Comp equal
				Pass keep
				Fail keep
				ZFail keep
			}

			HLSLPROGRAM
			#pragma vertex IndicatorVert
			#pragma fragment IndicatorFrag
			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _TIMEANIM_ON

			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"

}

