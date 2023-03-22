//全息
Shader "NewRender/Particle/ParticleHolographic"
{	
	Properties
	{
		[Header(Blend Mode)]
		[HideInInspector]_BlendOp("__blendop", Float) = 0.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("混合层1 ，one one 是ADD", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("混合层2 ，SrcAlpha    OneMinusSrcAlpha 是alphaBlend", int) = 1
		[Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式 : Off是双面显示，否则一般用 Back", int) = 2
		[Header(ZTest Mode)]
        [Enum(LEqual, 4, Always, 8)]_ZAlways("层级显示：LEqual默认层级，Always永远在最上层", int) = 4

		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor][HDR] _BaseColor("RGB:颜色 A:透明度", Color) = (0,0,0,1)
		_BaseMapUVSpeed("Base Map UVSpeed", vector) = (1, 1, 0, 0)
		_BaseMapUVSpeedParticalLerp("Base Map UVSpeed Partical Lerp", Range(0,1.0)) = 0

		[KeywordEnum(Off,On,RgbNotAlpha,RNotAlpha,GNotAlpha,BNotAlpha)] _MaskEnable("遮罩WrapMode",Int) = 0
		_MaskTex("遮罩贴图 MaskTex", 2D) = "white" {}
		_MaskTexUVSpeed("Mask Tex UVSpeed", vector) = (1, 1, 0, 0)

		[MaterialToggle(_CAMERADEPTHTEXTURE_ON)] _CameraDepthTextureOn  ("深度采样", float) = 0
		_DepthFadeIndensity("Depth Fade Soft Strength", Range(0,10)) = 1

		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_FresnelScale("Fresnel Scale", Range(0,10)) = 1.66
		_FresnelPower("Fresnel Power", Range(0.001,10)) = 1.78
		[KeywordEnum(Default,Noise,NoiseMask)] _Holographic("类型",Int) = 0
		[Toggle(_HOLOGRAPHIC_INVERT_ON)] _HolographicInvert("Holographic Invert", Float) = 0
		[KeywordEnum(WorldPos,Object,Screen)] _HOLOGRAPHIC_UV("UV类型",Int) = 0

		[KeywordEnum(Off,Default,Random)] _HOLOGRAPHIC_VERTEXANIM("顶点动画类型",Int) = 0

		_Noise("Noise", 2D) = "white" {}
		_NoiseVertexUVTilling("Noise Vertex UVTilling", vector) = (2,2,0,0)
		_NoiseScale("Noise Scale", Range(0,3)) = 1.54

		//
		_NoiseVertexRandomTex("Noise Vertex Random Tex", 2D) = "white" {}
		_NoiseVertexUVSpeed("Noise Vertex UVSpeed", vector) = (0,0.1,0,0)
		_NoiseVertexFlickerFresnelLerp("Noise Vertex Flicker Fresnel Lerp 闪烁菲尼尔缩放", Range(0,1)) = 0.3
		_NoiseVertexFlickerScale("Noise Vertex Flicker Scale 闪烁缩放", Range(0,1)) = 0.005
		_NoiseVertexFlickerTimeInterval("Noise Vertex Flicker Time Interval 闪烁时间间隔 秒", float) = 3
		_NoiseVertexFlickerTimeRange("Noise Vertex Flicker Time Range 闪烁时间区域", Range(0,1)) = 0.1
		_NoiseVertexFlickerTimeCount("Noise Vertex Flicker Time Count 闪烁次数", int) = 3
		_NoiseVertexFlickerTriggerScale("Noise Vertex Flicker Trigger Scale 闪烁触发缩放", Range(0,1)) = 0.051
		
		//
		_HolographicMaskTexture("Holographic Mask 全息遮罩", 2D) = "white" {}
		_MaskScale("Mask Scale", Range(0,3)) = 1.782
		_NoiseMaskScale("Noise Scale", Range(0,1)) = 0.071
		_HolographicMaskNoiseTiling("Holographic Mask Tiling", Float) = 4

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline" "IsEmissive" = "true"}
		BlendOp[_BlendOp]
		Blend[_SrcBlend][_DstBlend]
		Cull[_Cull]
		ZTest[_ZAlways]
        ZWrite Off

		ColorMask RGB
		Lighting Off 
		Fog { Mode Off }
		
		LOD 100

		Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit"}

            ZWrite On
            Cull Front
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex ParticleVert
            #pragma fragment ParticleFrag
            #pragma multi_compile_instancing 

			#include "../Library/Common/CommonFunction.hlsl"

			struct Attributes_Particle
			{
				float4 positionOS   : POSITION;
			};

			struct Varyings_Particle
			{
				float4 positionCS   : SV_POSITION;
			};

			Varyings_Particle ParticleVert(Attributes_Particle input){
				Varyings_Particle output = (Varyings_Particle)0;

				// Vertex
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

				return output;
			}

			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{

				return half4(0,0,0,1);
			}

            ENDHLSL
        }
		
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
			#pragma multi_compile _ _HOLOGRAPHIC_INVERT_ON
			#pragma multi_compile _HOLOGRAPHIC_UV_WORLDPOS _HOLOGRAPHIC_UV_OBJECT _HOLOGRAPHIC_UV_SCREEN
			#pragma multi_compile _ _HOLOGRAPHIC_VERTEXANIM_DEFAULT _HOLOGRAPHIC_VERTEXANIM_RANDOM
			#pragma multi_compile _HOLOGRAPHIC_DEFAULT _HOLOGRAPHIC_NOISE _HOLOGRAPHIC_NOISEMASK

			#if defined(_CAMERADEPTHTEXTURE_ON) || defined(_HOLOGRAPHIC_UV_SCREEN)
				#define VARYINGS_SCREEN_POS_UV
			#endif

			#include "../Library/Common/CommonFunction.hlsl"

			CBUFFER_START(UnityPerMaterial)

				half4 _BaseColor;
				float4 _BaseMap_ST;
				float4 _MaskTex_ST;
				float4 _BaseMapUVSpeed;
				float4 _MaskTexUVSpeed;
				float _CameraDepthTextureOn;
				half _DepthFadeIndensity;
				half _BaseMapUVSpeedParticalLerp;
				//
				half4 _EmissionColor;
				half _FresnelScale;
				half _FresnelPower;
				half _NoiseScale;
				half _HolographicInvert;
				half _HolographicMaskNoiseTiling;
				float4 _Noise_ST;
				//
				float4 _NoiseVertexUVTilling;
				float4 _NoiseVertexUVSpeed;
				float _NoiseVertexFlickerTimeInterval;
				float _NoiseVertexFlickerTimeRange;
				float _NoiseVertexFlickerTimeCount;
				float _NoiseVertexFlickerScale;
				float _NoiseVertexFlickerTriggerScale;
				half _NoiseVertexFlickerFresnelLerp;
				half _NoiseMaskScale;
				half _MaskScale;
				half _HOLOGRAPHIC_VERTEXANIM;
				half _HOLOGRAPHIC_UV;

			CBUFFER_END

			TEXTURE2D_X(_HolographicMaskTexture); SAMPLER(sampler_HolographicMaskTexture);
			TEXTURE2D_X(_Noise); SAMPLER(sampler_Noise);
			TEXTURE2D_X(_NoiseVertexRandomTex); SAMPLER(sampler_NoiseVertexRandomTex);

			#if defined(_CAMERADEPTHTEXTURE_ON)
				TEXTURE2D_X(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
			#endif

				TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
				TEXTURE2D_X(_MaskTex); SAMPLER(sampler_MaskTex);
			#endif

			struct Attributes_Particle
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float4 tangentOS : TANGENT;
				float4 color : COLOR;
				float4 uv     		: TEXCOORD0;//zw粒子控制
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

				#if defined(_HOLOGRAPHIC_UV_SCREEN)
					float3 animData : TEXCOORD1; 	
				#else
					float2 animData : TEXCOORD1; 	
				#endif

				float4 color : COLOR;

				#if defined(VARYINGS_SCREEN_POS_UV)
					float4 screenUV		: TEXCOORD2;
				#endif

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					#if defined(_HOLOGRAPHIC_NOISEMASK)
						half4 fogNormalOS : TEXCOORD3;
					#else
						half  fogFactor : TEXCOORD3;
					#endif
				#else
					#if defined(_HOLOGRAPHIC_NOISEMASK)
						half3 fogNormalOS : TEXCOORD3;
					#endif
				#endif

				float4 normalWS : TEXCOORD4;
				float4 tangentWS : TEXCOORD5;
				float4 bitangentWS : TEXCOORD6;

				#if defined(_HOLOGRAPHIC_NOISEMASK)
					float3 positionOS : TEXCOORD7;
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

				output.animData.xy = input.uv.zw;

				#if defined(_HOLOGRAPHIC_UV_SCREEN)
					output.animData.z = length(_WorldSpaceCameraPos.xyz-TransformObjectToWorld(half3(0,0,0)))/100.0;
				#endif

				float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

				//Holographic
				#if defined(_HOLOGRAPHIC_VERTEXANIM_DEFAULT) || defined(_HOLOGRAPHIC_VERTEXANIM_RANDOM)
					
					#if defined(_HOLOGRAPHIC_VERTEXANIM_RANDOM)
						//Random
						float2 pannerRandomUV = float2(_Time.y,_Time.y)*2  +  positionWS.xz*0.1;
						float randomValue = SAMPLE_TEXTURE2D_LOD( _NoiseVertexRandomTex, sampler_NoiseVertexRandomTex,pannerRandomUV,0).r;
						randomValue=saturate(randomValue+0.1);
					#endif

					float2 pannerUV = _Time.y * _NoiseVertexUVSpeed.xy +  positionWS.xy * _NoiseVertexUVTilling.xy;
					half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);

					float NDotV = dot(output.normalWS.xyz, viewDirWS);
					float fresnel = _FresnelScale * pow( abs(1.0 - NDotV), _FresnelPower );
					#ifdef _HOLOGRAPHIC_INVERT_ON
						fresnel = clamp( 1.0 - fresnel, 0.0 , 1.0 );
					#endif

					float flickerTime = _Time.y%_NoiseVertexFlickerTimeInterval;

					float lerpPos = flickerTime/_NoiseVertexFlickerTimeInterval;

					flickerTime = float(_NoiseVertexFlickerTimeCount*6.31852)/(_NoiseVertexFlickerTimeRange*_NoiseVertexFlickerTimeInterval);

					#if defined(_HOLOGRAPHIC_VERTEXANIM_RANDOM)
						float sinValue = sin(flickerTime+randomValue*6.31852);
					#else
						float sinValue = sin(flickerTime);
					#endif

					float lerpValueMin = 1.0 - _NoiseVertexFlickerTimeRange;
					float lerpValue = saturate((lerpPos-lerpValueMin)/_NoiseVertexFlickerTimeRange);
					sinValue = sinValue*(1.0-lerpValue)*step(0.001,lerpValue)*_NoiseVertexFlickerTriggerScale;
					
					float3 vertexOffset = SAMPLE_TEXTURE2D_LOD( _Noise, sampler_Noise,pannerUV,0).xyz*_NoiseScale;
					vertexOffset = (lerp(1.0,fresnel,_NoiseVertexFlickerFresnelLerp)*vertexOffset.xyz *(_NoiseVertexFlickerScale+sinValue)).rgb;
					
					#if defined(_HOLOGRAPHIC_VERTEXANIM_RANDOM)
					    vertexOffset = vertexOffset*randomValue;
					#endif
					input.positionOS.xyz +=  vertexOffset;

				#endif

				// Vertex
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.color=input.color;

				positionWS = TransformObjectToWorld(input.positionOS.xyz);
				real sign = real(input.tangentOS.w) * GetOddNegativeScale(); 
				output.normalWS =half4( TransformObjectToWorldNormal(input.normalOS) , positionWS.x); 
				output.tangentWS =half4(real3(TransformObjectToWorldDir(input.tangentOS.xyz)),positionWS.y) ; 
				output.bitangentWS = half4(real3(cross(output.normalWS.xyz, float3(output.tangentWS.xyz))) * sign,positionWS.z);

				// UV
				#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
					output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;
					output.uv.zw = input.uv.xy*_MaskTex_ST.xy+_MaskTex_ST.zw;
				#else
					output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;
				#endif

				#if defined(VARYINGS_SCREEN_POS_UV)
					float4 projPos = ComputeScreenPos (output.positionCS);
					output.screenUV.xyz=projPos.xyz/projPos.w;
					output.screenUV.w=projPos.w;
				#endif

				#if defined(_HOLOGRAPHIC_NOISEMASK)
					output.positionOS = input.positionOS;
				#endif

				// Fog
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half fogFactor = ComputeFogFactor(output.positionCS.z); 
					#if defined(_HOLOGRAPHIC_NOISEMASK)
						output.fogNormalOS.w = fogFactor;
						output.fogNormalOS.xyz = input.normalOS;
					#else
						output.fogFactor = fogFactor;
					#endif
				#else
					#if defined(_HOLOGRAPHIC_NOISEMASK)
						output.fogNormalOS = input.normalOS;
					#endif
				#endif

				return output;
			}


			half4 ParticleFrag(Varyings_Particle input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				float3 positionWS = float3(input.normalWS.w,input.tangentWS.w,input.bitangentWS.w); 
				half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
				float3 normalWS = TransformTangentToWorld(float3(0,0,1), half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
				normalWS = NormalizeNormalPerPixel(normalWS);
				half3 emissionColor = _EmissionColor.rgb;

				//Holographic
				float NDotV = dot( normalWS, viewDirWS ) ;

				float fresnel = _FresnelScale * pow(abs(1.0 - NDotV), _FresnelPower);
				#ifdef _HOLOGRAPHIC_INVERT_ON
					fresnel = clamp( 1.0 - fresnel, 0.0 , 1.0 );
				#endif

				float holographicAlpha=1;

				#if defined(_HOLOGRAPHIC_DEFAULT)
					holographicAlpha = fresnel;
					holographicAlpha = clamp(holographicAlpha,0,2);
				#elif defined(_HOLOGRAPHIC_NOISE)
				    #if defined(_HOLOGRAPHIC_UV_WORLDPOS)
						float2 nosiePannerUV = _Time.y * _NoiseVertexUVSpeed.xy +  positionWS.xy * _NoiseVertexUVTilling.xy;
					#elif defined(_HOLOGRAPHIC_UV_OBJECT)
						float2 nosiePannerUV = _Time.y * _NoiseVertexUVSpeed.xy +  input.uv.xy * _NoiseVertexUVTilling.xy;
					#elif defined(_HOLOGRAPHIC_UV_SCREEN)
						float dis = input.animData.z;
						float s = lerp(1.0,100.0,dis);
						float2 nosiePannerUV = _Time.y * _NoiseVertexUVSpeed.xy +  input.screenUV.xy * _NoiseVertexUVTilling.xy*s;
					#endif
					float4 offsetColor = SAMPLE_TEXTURE2D( _Noise,sampler_Noise, nosiePannerUV ) * fresnel;
					holographicAlpha = offsetColor.r;
					holographicAlpha = clamp(holographicAlpha,0,1);
				#elif defined(_HOLOGRAPHIC_NOISEMASK)
					half3 normalOS = input.fogNormalOS.xyz;
					normalOS = abs(normalOS);
					float3 positionOS = input.positionOS*_HolographicMaskNoiseTiling;

					float2 uvNoise = input.uv.xy * _NoiseVertexUVTilling.xy + _NoiseVertexUVTilling.zw;
					half4 noiseTex = SAMPLE_TEXTURE2D(_Noise, sampler_Noise, uvNoise)* _NoiseMaskScale;

					float2 pannerNoise =  _Time.y * float2( 0.03,0.05 ) + positionOS.yz;
					half4 holographicTex = SAMPLE_TEXTURE2D(_HolographicMaskTexture, sampler_HolographicMaskTexture, pannerNoise+noiseTex.rg);
					half4 holographicColor = lerp(0,holographicTex,normalOS.x);
					//
					float2 pannerHolographic=  _Time.y * float2( 0.05,0.07 ) + positionOS.xz;
					half4 holographicTexB = SAMPLE_TEXTURE2D(_HolographicMaskTexture, sampler_HolographicMaskTexture, pannerHolographic+noiseTex.rg);
					half4 holographicColorB = lerp(holographicColor,holographicTexB,normalOS.y);
					//
					float2 pannerHolographicC =  _Time.y * float2( 0.05,0.06 ) + positionOS.xy;
					half4 holographicTexC = SAMPLE_TEXTURE2D(_HolographicMaskTexture, sampler_HolographicMaskTexture, pannerHolographicC+noiseTex.rg);
					half4 holographicColorC = lerp(holographicColorB,holographicTexC,normalOS.z);
					//
					holographicAlpha = holographicColorC.r * fresnel*_MaskScale;
					holographicAlpha = clamp(holographicAlpha,0,2);
				#endif

				float2 baseMapUV =lerp(input.uv.xy+_BaseMapUVSpeed.xy*_Time.y, input.uv.xy+input.animData.xy,_BaseMapUVSpeedParticalLerp);
				half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseMapUV);
				half4 finishColor=color*_BaseColor*input.color;

				finishColor.a=finishColor.a*holographicAlpha;
				finishColor.rgb = finishColor.rgb+emissionColor*holographicAlpha;

				#if defined(_CAMERADEPTHTEXTURE_ON)
					float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(input.screenUV.xy)).r;
					float sceneZ = (unity_OrthoParams.w == 0) ? LinearEyeDepth(rawDepth, _ZBufferParams) : LinearDepthToEyeDepth(rawDepth);
					float thisZ = LinearEyeDepth(input.screenUV.z, _ZBufferParams);
					float depthInterval=abs(sceneZ-thisZ)*_DepthFadeIndensity;
					depthInterval=clamp(depthInterval,0,1.0);
					finishColor.a=finishColor.a*depthInterval;
				#endif

				#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
					float2 maskUV = input.uv.zw+_MaskTexUVSpeed.xy*_Time.y;
					half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, maskUV);
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

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					float fogFactor=1.0;
					#if defined(_HOLOGRAPHIC_NOISEMASK)
						fogFactor = input.fogNormalOS.w;
					#else
						fogFactor = input.fogFactor;
					#endif
					half fogIntensity = ComputeFogIntensity(fogFactor);
					finishColor.rgb = lerp(unity_FogColor.rgb, finishColor.rgb , fogIntensity);
				#endif

				return finishColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ParticleHolographicShaderGUI"
}
