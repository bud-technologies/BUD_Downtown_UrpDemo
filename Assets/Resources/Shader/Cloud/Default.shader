
Shader "NewRender/Cloud/Default"
{	
	Properties
	{

		[Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式 : Off是双面显示，否则一般用 Back", int) = 1
		[Header(ZTest Mode)]
        [Enum(LEqual, 4, Always, 8)]_ZAlways("层级显示：LEqual默认层级，Always永远在最上层", int) = 4
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor][HDR] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

		_ScaColorA("RGB:颜色 A:透明度", Color) = (1,1,1,1)
		_ScaColorB("RGB:颜色 A:透明度", Color) = (1,1,1,1)

		_Radius("半径", float) = 1000
		_FadeOut("淡出范围", Range(0,0.99)) = 0.7
		_FadeOutPow("Fade Out Pow", Range(0.1,10)) = 1

		[KeywordEnum(RR,RG,RB,RA,GB,GA,BA,AA,RGB)] _Color_Channel("通道相乘",Int) = 0
		_MixTexA("MixTexA", 2D) = "black" {}
		_MixTexARatio("MixTexA Ratio", Range(0,1)) = 1.0
		_MixTexAUVSpeed("Mix Tex A UVSpeed", vector) = (1, 1, 0, 0)
		_MixTexARange("Mix TexA Range", vector) = (-1, 1, 0, 0)

		_MixTexB("MixTexB", 2D) = "black" {}
		_MixTexBRatio("MixTexB Ratio", Range(0,1)) = 1.0
		_MixTexBUVSpeed("Mix Tex B UVSpeed", vector) = (1, 1, 0, 0)
		_MixTexBRange("Mix TexB Range", vector) = (0.424, 1, 0, 0)
		_Pow("abv" ,Float) = 1
		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)

	}
	
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent-10" "RenderPipeline" = "UniversalPipeline"}
		Blend SrcAlpha One
		Cull[_Cull]
		ZTest[_ZAlways]
        ZWrite Off

		LOD 100
		
		Pass
		{
			Tags {"LightMode"="UniversalForward"}
			HLSLPROGRAM
			#pragma vertex CloudVert
			#pragma fragment CloudFrag
			#pragma multi_compile_instancing 
            #pragma multi_compile_fog
			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				float _Pow;
				half4 _ScaColorA;
				half4 _ScaColorB;
				half4 _BaseColor;
				float4 _BaseMap_ST;
				half _FadeOut;
				half _FadeOutPow;
				half _Radius;
				half _Color_Channel;
				float4 _MixTexA_ST;
				float4 _MixTexAUVSpeed;
				half _MixTexARatio;
				half4 _MixTexARange;
				float4 _MixTexB_ST;
				float4 _MixTexBUVSpeed;
				half _MixTexBRatio;
				half4 _MixTexBRange;

			CBUFFER_END

			TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			TEXTURE2D_X(_MixTexA); SAMPLER(sampler_MixTexA);
			TEXTURE2D_X(_MixTexB); SAMPLER(sampler_MixTexB);

			struct Attributes_Cloud
			{
				float4 positionOS   : POSITION;
				float2 uv     		: TEXCOORD0;
				float3 normalOS      : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Cloud
			{
				float4 positionCS   : SV_POSITION;
				float4 uv           : TEXCOORD0; 	
				float3 normalWS      : TEXCOORD1;
				half3 viewDirWS     : TEXCOORD2;
				float3 positionWS: TEXCOORD3;
				float3 zeroPositionWS: TEXCOORD4;

				//#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
				//    half  fogFactor : TEXCOORD5;
				//#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Cloud CloudVert(Attributes_Cloud input){
				Varyings_Cloud output = (Varyings_Cloud)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				//
				output.positionWS.xyz=TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS=TransformWorldToHClip(output.positionWS.xyz);
				output.viewDirWS = GetCameraPositionWS() - output.positionWS.xyz;
				output.zeroPositionWS=TransformObjectToWorld(half3(0,0,0));

				// UV
				output.uv.xy = output.positionWS.xz *_MixTexA_ST.xy*0.001+_MixTexA_ST.zw+_MixTexAUVSpeed.xy*0.01*_Time.y;
				output.uv.zw = output.positionWS.xz*_MixTexB_ST.xy*0.001+_MixTexB_ST.zw+_MixTexBUVSpeed.xy*0.01*_Time.y;

				// Normal
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);

				// Fog
				//#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
				//    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
				//#endif

				return output;
			}

			half4 CloudFrag(Varyings_Cloud input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				//
				float disCam=length(GetCameraPositionWS()-input.positionWS.xyz);
				float ratioCam = disCam/(_ProjectionParams.z+0.01);
				float fadeStepCam=step(_FadeOut,ratioCam);
				float fadeAlphaCam=saturate(1.0-(ratioCam-_FadeOut)/(1.0-_FadeOut));
				fadeAlphaCam=pow(fadeAlphaCam,_FadeOutPow);
				float disCamAlpha=lerp(1.0,fadeAlphaCam,fadeStepCam);
				//
				float disPos=length(input.zeroPositionWS.xyz-input.positionWS.xyz);
				float ratioDis = disPos/(_Radius+0.01);
				float fadeStepDis=step(_FadeOut,ratioDis);
				float fadeAlphaDis=saturate(1.0-(ratioDis-_FadeOut)/(1.0-_FadeOut));
				fadeAlphaDis=pow(fadeAlphaDis,_FadeOutPow);
				float disDisAlpha=lerp(1.0,fadeAlphaDis,fadeStepDis);

				//
				half mixATex = SAMPLE_TEXTURE2D(_MixTexA, sampler_MixTexA, input.uv.xy).r;
				mixATex=smoothstep(_MixTexARange.x,_MixTexARange.y,mixATex);
				//_MixTexARange

				half mixBTex = SAMPLE_TEXTURE2D(_MixTexB, sampler_MixTexB, input.uv.zw).r;
				mixBTex=smoothstep(_MixTexBRange.x,_MixTexBRange.y,mixBTex);

				//
				float mixColor=(mixATex.r*mixBTex.r);

				float colorSmoothStep=smoothstep(0,0.5,mixColor);
				float colorStep=step(0.5,mixColor);
				float3 mixColor3=lerp(mixColor*lerp(_ScaColorA.rgb,_ScaColorB.rgb,colorSmoothStep),mixColor.rrr,colorStep);

				Light mainLight = GetMainLight();
				float NDotL=abs(dot(input.normalWS,mainLight.direction));
				//mixColor3=lerp(mixColor3,mixColor,NDotL);
				float VDotL=dot(-mainLight.direction,normalize(input.viewDirWS));
				VDotL=VDotL*0.5+0.5;

				mixColor3=lerp(mixColor,mixColor3,NDotL*VDotL);

				half4 finishColor=half4(0,0,0,1);

				finishColor.rgb=mixColor3;

				float alpha=disCamAlpha*disDisAlpha*finishColor.r;
				finishColor.a=alpha;
				finishColor.a = saturate(finishColor.a * _Pow);
				//#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
				//	half fogIntensity = ComputeFogIntensity(input.fogFactor);
				//	finishColor.rgb = lerp(unity_FogColor.rgb, finishColor.rgb , fogIntensity);
				//#endif

				return finishColor * _BaseColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	//CustomEditor "NewRenderShaderGUI.CloudShaderGUI"
}
