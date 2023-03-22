Shader "URPGroups/GamePossEffect/PossEffect"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
		    //后处理效果一般都是这几个状态
			LOD 100
			ZTest Always 
			Cull Off 
			ZWrite Off

			Pass
			{
				Name "PossEffect"

				HLSLPROGRAM

				#pragma vertex vert_blur
				#pragma fragment frag_blur
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				
				//高斯模糊开关
				#pragma multi_compile _ _GASBLUR_ON
				//颜色模式开关  _COLORGRAY_ON:去色 _COLORMULTIPLY_ON:相乘 _COLORADD_ON:相加
				#pragma multi_compile _ _COLORGRAY_ON _COLORMULTIPLY_ON _COLORADD_ON


				CBUFFER_START(UnityPerMaterial)

				TEXTURE2D(_MainTex);
				SAMPLER(sampler_MainTex);

				float4 _MainTex_ST;
				float4 _MainTex_TexelSize;
				float4 _Offsets;
				half4 _MultiplyColor;
				half4 _AddColor;

				CBUFFER_END

				struct ver_blur {
					float4 positionOS : POSITION;
					float2 uv : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f_blur {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					#ifdef _GASBLUR_ON
						float4 uv01 : TEXCOORD1;
						float4 uv23 : TEXCOORD2;
						float4 uv45 : TEXCOORD3;
					#endif
					UNITY_VERTEX_OUTPUT_STEREO
				};

				v2f_blur vert_blur(ver_blur v)
				{
					v2f_blur o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.pos = TransformObjectToHClip(v.positionOS.xyz);
					o.uv = v.uv;
					#ifdef _GASBLUR_ON
						_Offsets *= _MainTex_TexelSize.xyxy;
						o.uv01 = v.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1);
						o.uv23 = v.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
						o.uv45 = v.uv.xyxy + _Offsets.xyxy * float4(1, 1, -1, -1) * 3.0;
					#endif
					return o;
				}

				half4 frag_blur(v2f_blur i) : SV_Target
				{
					half4 color = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv);
					#ifdef _COLORMULTIPLY_ON
						color = color * _MultiplyColor;
					#endif
					#ifdef _COLORADD_ON
						color = color + _AddColor;
					#endif
					#ifdef _COLORGRAY_ON
						float gray = dot(color.rgb, half3(0.22, 0.707, 0.071));
						color.rgb = half3(gray, gray, gray);
					#endif
					#ifdef _GASBLUR_ON
						//将像素本身以及像素左右（或者上下，取决于vertex shader传进来的uv坐标）像素值的加权平均
						color = 0.4 * color;
						color += 0.15 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv01.xy);
						color += 0.15 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv01.zw);
						color += 0.10 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv23.xy);
						color += 0.10 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv23.zw);
						color += 0.05 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv45.xy);
						color += 0.05 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv45.zw);
					#endif
					return color;
				}

				ENDHLSL
			}

	}
	//后处理效果一般不给fallback，如果不支持，不显示后处理即可
}