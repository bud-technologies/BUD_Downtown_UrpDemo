//可以在移动端使用
//低端设备不开启深度的时候 顶点颜色r通道绘制深度 ,靠岸越浅r通道越黑
Shader "NewRender/Water/BudWater" {
	Properties{
		[MaterialToggle(_CAMERADEPTHTEXTURE_ON)] _CameraDepthTextureOn("深度采样", float) = 1.0
		_DistortionScale("Distortion Scale", Range(0, 1)) = 0.35
		[MaterialToggle(_OPAQUETEXTURE_ON)] _OpaqueTextureOn("颜色采样", float) = 1.0

		_HighlightsColor("Highlights Color", Color) = (0.2666667,0.8289316,0.9254902,1)
		_ShadeColor("Shade Color", Color) = (0.07320217,0.2178987,0.4433962,1)
		_PerspectiveIntensity("Alpha Strength 透视强度", Range(0.1,50)) = 20
		_MaxDepthSet("可见深度", Range(0,50)) = 9
		_WaveSpeed("Wave Speed", Range(0, 2)) = 0.415
		_WaveNoiseScale("Wave Noise Scale", Range(0, 1)) = 0.1
		_UVTilling("UV Tilling", Range(0, 2)) = 0.4
		_UVSpeed("UV Speed", Range(0, 2)) = 0.1
		_BlendDistance("Blend Distance", Range(200, 1500)) = 500

		//light
		_LightSamplingMap("SamplingMap Map", 2D) = "black" {}
		_SpecularPow("Specular Pow", Range(0, 10)) = 2
		_SpecularScale("Specular Scale", Range(0, 20)) = 0.15
		_LightScale("Light Scale", Range(0, 10)) = 1

		//
		_FresnelBias("Fresnel Bias", Range(0, 0.2)) = 0
		_FresnelScale("Fresnel Scale", Range(0, 5)) = 1
		_FresnelPower("Fresnel Power", Range(0.01, 10)) = 5

		//
		[MaterialToggle(_SCATTERING_ON)] _ScatteringOn("散射", float) = 1.0
		_ScatteringLightScale("Scattering Light Scale", Range(0, 3)) = 1
		_ScatteringLightPow("Scattering Light Pow", Range(1, 20)) = 1
		_ScatteringScale("Scattering Scale", Range(0, 3)) = 1
		_ScatteringPow("Scattering Pow", Range(1, 3)) = 3
		_ScatteringColor("Scattering Color", Color) = (1,1,1,1)

		//
		[KeywordEnum(Off,WaveMap)] _WATER_WAVE_HEIGHT("Wave变化",Int) = 1
		_WaveHeightMap("Wave Height Map", 2D) = "gray" {}
		_WaveHeightMapScale("缩放", Range(0,10)) = 0.1
		_WaveHeightNormalScale("法线强度", Range(0, 2)) = 0.1

		//
		[MaterialToggle(_WATER_FOAM_ON)] _WaterFoamOn("泡沫", float) = 1.0
		_FoamMap("Foam Map", 2D) = "black" {}
		_FoamStep("Foam Step", Range(0, 50)) = 20
		_FoamAdd("Foam Add", Range(0, 10)) = 3.83
		_WaveHeightMapFoamScale("Wave Height Map Foam Scale", Range(0, 1)) = 0.15

		//
		[MaterialToggle(_REFLECTION_SCREEN)] _ReflectScreenOn("镜面开启", float) = 0
		//
		[KeywordEnum(off,Unity,Custom)] _REFLECT_CUBE("Reflect",Int) = 1.0
		_ReflectMap("Reflect Map", Cube) = "white" {}
		_ReflectMapMipLevel("MipMap", Range(0, 4)) = 1
		_ReflectRatio("Reflect Ratio", Range(0, 1)) = 1
		_ReflectScale("Reflect Scale", Range(0, 10)) = 1
		_ReflectReplace("Reflect Replace", Range(0, 1)) = 0
		_ReflectReplaceScale("Reflect Replace Scale", Range(0, 1)) = 1

		[HideInInspector] _Cull("__cull", Float) = 0.0
		[HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0
		[HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
		[HideInInspector] _MainTex("_MainTex", 2D) = "white" {}

	}

	SubShader{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent-100" "RenderPipeline" = "UniversalPipeline" }

		Blend SrcAlpha OneMinusSrcAlpha
		Cull[_Cull]

		Pass {
			Name "WaterShading"
			Tags{"LightMode" = "UniversalForward"}

			HLSLPROGRAM
			#pragma vertex WaterVertex
			#pragma fragment WaterFragment
			#pragma prefer_hlslcc gles
			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma shader_feature _ _WATER_WAVE_HEIGHT_WAVEMAP
			#pragma shader_feature _ _REFLECT_CUBE_UNITY _REFLECT_CUBE_CUSTOM
			#pragma shader_feature _ _REFLECTION_SCREEN
			#pragma multi_compile _ _CAMERADEPTHTEXTURE_ON
			#pragma shader_feature _ _OPAQUETEXTURE_ON
			#pragma shader_feature _ _SCATTERING_ON 
			#pragma shader_feature _ _WATER_FOAM_ON

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Library/Normal/NormalLib.hlsl"
			#include "../Library/Noise/NoiseLib.hlsl"

			CBUFFER_START(UnityPerMaterial)
				half _SpecularPow;
				half _SpecularScale;
				half _WaveHeightMapScale;
				half _MaxDepthSet;
				half _CameraDepthTextureOn;
				half _FoamStep;
				half _WaveHeightMapFoamScale;
				half _FoamAdd;
				half3 _HighlightsColor;
				half3 _ShadeColor;
				half _OpaqueTextureOn;
				half _PerspectiveIntensity;
				half _WaveHeightNormalScale;
				half _WaveSpeed;
				half _ReflectMapMipLevel;
				half _ScatteringLightScale;
				half _ScatteringLightPow;
				half _ScatteringScale;
				half _ScatteringPow;
				half3 _ScatteringColor;
				half _UVTilling;
				half _UVSpeed;
				half _FresnelBias;
				half _FresnelScale;
				half _FresnelPower;
				half _ReflectRatio;
				half _ReflectScale;
				half _LightScale;
				half _WaterFoamOn;
				half _ReflectReplace;
				half _BlendDistance;
				half _ReflectReplaceScale;
				half _WaveNoiseScale;
				half _DistortionScale;
			CBUFFER_END

			TEXTURE2D(_LightSamplingMap);
			TEXTURE2D(_WaveHeightMap);SAMPLER(sampler_WaveHeightMap);
			SAMPLER(sampler_ScreenTextures_linear_clamp);
			TEXTURE2D(_CameraDepthTexture);
			TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);
			TEXTURE2D(_FoamMap); SAMPLER(sampler_FoamMap);

			#if defined(_REFLECT_CUBE_CUSTOM)
				TEXTURECUBE(_ReflectMap);
				SAMPLER(sampler_ReflectMap);
			#endif

			#if defined(_REFLECTION_SCREEN)
				TEXTURE2D_X(_ReflectionScreenTex);
			#endif

			const static half3 foamColors[128] = {
				half3(0,0,0),half3(0,0,0.01686274),half3(0,0,0.03372549),half3(0,0,0.05058823),half3(0,0,0.06745098),half3(0,0,0.08431371),half3(0,0,0.104549),half3(0,0,0.1214118),
				half3(0,0,0.141647),half3(0,0,0.1618823),half3(0,0,0.1821176),half3(0,0,0.2023529),half3(0,0,0.2225882),half3(0,0,0.2461961),half3(0,0,0.2664314),half3(0,0,0.2900392),
				half3(0,0,0.3102745),half3(0,0,0.3338823),half3(0,0,0.3541176),half3(0,0,0.3777255),half3(0,0,0.4013333),half3(0,0,0.4215686),half3(0,0,0.4451765),half3(0,0,0.4687843),
				half3(0,0,0.4923921),half3(0,0,0.5126274),half3(0,0,0.5362353),half3(0,0,0.5564705),half3(0,0,0.5800784),half3(0,0.006745098,0.6003137),half3(0,0.01686274,0.6239215),
				half3(0,0.03035294,0.6441568),half3(0,0.04047059,0.6643921),half3(0,0.05396078,0.6846274),half3(0,0.06745098,0.7048627),half3(0,0.08094117,0.725098),half3(0,0.09443136,0.7453333),
				half3(0,0.1079216,0.7655686),half3(0,0.1214118,0.7824313),half3(0,0.1382745,0.799294),half3(0,0.1517647,0.8161567),half3(0,0.1686274,0.8330195),half3(0,0.1821176,0.8498822),
				half3(0,0.1989804,0.8599999),half3(0,0.2124706,0.8532548),half3(0,0.2293333,0.8397646),half3(0,0.2461961,0.8296469),half3(0,0.2630588,0.8195293),half3(0,0.276549,0.8094116),
				half3(0,0.2934117,0.7959215),half3(0,0.3102745,0.7858039),half3(0,0.3271372,0.7723137),half3(0,0.344,0.762196),half3(0,0.3608627,0.7487058),half3(0,0.3777255,0.7352156),
				half3(0,0.3945882,0.7217254),half3(0,0.4114509,0.7082352),half3(0,0.4283137,0.6981176),half3(0,0.4451765,0.6846274),half3(0,0.4620392,0.6711372),half3(0,0.4789019,0.6542745),
				half3(0,0.4957647,0.6407843),half3(0,0.5126274,0.6272941),half3(0,0.5294902,0.6138039),half3(0,0.5463529,0.6003137),half3(0,0.5632156,0.5868235),half3(0,0.5800784,0.5699607),
				half3(0,0.5969411,0.5564705),half3(0,0.6104313,0.5429804),half3(0,0.6272941,0.5261176),half3(0,0.6441568,0.5126274),half3(0,0.6610196,0.4957647),half3(0,0.6745097,0.4822745),
				half3(0.01011765,0.6913725,0.4687843),half3(0.02360784,0.7048627,0.4519216),half3(0.03372549,0.7217254,0.4384314),half3(0.04721568,0.7352156,0.4215686),half3(0.06070588,0.7487058,0.4080784),
				half3(0.07419607,0.762196,0.3945882),half3(0.08768626,0.7756862,0.3777255),half3(0.1011765,0.7891764,0.3642353),half3(0.1180392,0.8026665,0.3473725),
				half3(0.1315294,0.8161567,0.3338823),half3(0.1450196,0.8296469,0.3203921),half3(0.1618823,0.8397646,0.3035294),half3(0.1753725,0.8566273,0.2900392),
				half3(0.1922353,0.8566273,0.276549),half3(0.209098,0.8498822,0.2596863),half3(0.2259608,0.8431371,0.2461961),half3(0.239451,0.8330195,0.2327059),
				half3(0.2563137,0.8229018,0.2192157),half3(0.2731765,0.8161567,0.2057255),half3(0.2900392,0.8060391,0.1922353),half3(0.3069019,0.7959215,0.1787451),
				half3(0.3237647,0.7858039,0.1652549),half3(0.3406274,0.7756862,0.1517647),half3(0.3574902,0.7655686,0.1382745),half3(0.3743529,0.7554509,0.1247843),
				half3(0.3912157,0.7453333,0.1112941),half3(0.4080784,0.7352156,0.1011765),half3(0.4249411,0.725098,0.08768626),half3(0.4451765,0.7149803,0.07419607),
				half3(0.4620392,0.7014901,0.06407843),half3(0.4789019,0.6913725,0.05058823),half3(0.4957647,0.6812548,0.04047059),half3(0.5126274,0.6677647,0.03035294),
				half3(0.5294902,0.657647,0.02023529),half3(0.5463529,0.6475294,0.01011765),half3(0.5632156,0.6340392,0),half3(0.5800784,0.6239215,0),half3(0.5969411,0.6138039,0),
				half3(0.6138039,0.6003137,0),half3(0.6306666,0.590196,0),half3(0.6441568,0.5800784,0),half3(0.6610196,0.5699607,0),half3(0.6778823,0.5564705,0),half3(0.6913725,0.5463529,0),
				half3(0.7082352,0.5362353,0),half3(0.7217254,0.5261176,0),half3(0.7385882,0.516,0),half3(0.7520784,0.5058823,0),half3(0.7655686,0.4957647,0),half3(0.7790588,0.485647,0),
				half3(0.792549,0.4755294,0),half3(0.8060391,0.4687843,0),half3(0.8195293,0.4586666,0),half3(0.8330195,0.4519216,0),half3(0.8431371,0.4418039,0)
			};

			struct Attributes_Water
			{
				float4	positionOS : POSITION;
				float2	uv : TEXCOORD0;
				half4 color:COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Water
			{
				float4	positionCS	: SV_POSITION;
				half4 	normalWS	: NORMAL;
				half4 color	:COLOR;
				float4	uv	: TEXCOORD0;
				float4	positionWS	: TEXCOORD1;
				float3 	viewDirWS	: TEXCOORD2;
				float4	waterData	: TEXCOORD3;
				half4	shadowCoord	: TEXCOORD4;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half  fogFactor : TEXCOORD5;
				#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Water WaterVertex(Attributes_Water input)
			{
				Varyings_Water output = (Varyings_Water)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				output.color = input.color;
				float time = _Time.y * _WaveSpeed;
				output.positionWS.xyz = TransformObjectToWorld(input.positionOS.xyz);
				output.normalWS.w = TransformObjectToWorld(float3(0,0,0)).y;
				output.normalWS.xyz = float3(0, 1, 0);
				//
				float noseY = noise_sin_cos((output.positionWS.xyz * 0.5) + time) * _WaveNoiseScale;
				output.uv.xy = output.positionWS.xz * _UVTilling - time.xx * _UVSpeed + noseY * 0.2;
				output.uv.zw = output.positionWS.xz * _UVTilling * 0.25 + time * _UVSpeed * 0.5 + noseY * 0.1;
				float averageWaveHeight = 1;
				float offsetY = 0;
				#if defined(_WATER_WAVE_HEIGHT_WAVEMAP)
					half2 waveHeightMap1 = SAMPLE_TEXTURE2D_LOD(_WaveHeightMap, sampler_WaveHeightMap, output.uv.zw, 2).xy * 2.0 - 1.0;
					half2 waveHeightMap2 = SAMPLE_TEXTURE2D_LOD(_WaveHeightMap, sampler_WaveHeightMap, output.uv.xy, 2).xy * 2.0 - 1.0;
					half2 waveHeightMapRes = (waveHeightMap1 + waveHeightMap2 * 0.5);
					averageWaveHeight = _WaveHeightMapScale * 1.5;
					offsetY = -_WaveHeightMapScale * (waveHeightMapRes.x + waveHeightMapRes.y);
					output.positionWS.y += offsetY;
					output.normalWS.xyz += half3(waveHeightMapRes.x, 0, waveHeightMapRes.y) * _WaveHeightNormalScale;
				#endif
				output.positionCS = TransformWorldToHClip(output.positionWS.xyz);
				output.shadowCoord = ComputeScreenPos(output.positionCS);
				output.viewDirWS = SafeNormalize(_WorldSpaceCameraPos - output.positionWS.xyz);

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					output.fogFactor = ComputeFogFactor(output.positionCS.z);
				#endif
				float3 viewPos = TransformWorldToView(output.positionWS.xyz);
				output.waterData.x = length(viewPos / viewPos.z);
				output.waterData.y = length(GetCameraPositionWS().xyz - output.positionWS.xyz);
				offsetY=clamp(offsetY,-averageWaveHeight,averageWaveHeight);
				output.waterData.z = offsetY / averageWaveHeight * 0.5 + 0.5;
				output.waterData.w = 5;
				half distanceBlend = saturate(abs(length((_WorldSpaceCameraPos.xz - output.positionWS.xz) * 1.0/_BlendDistance)) - 0.25);
				output.normalWS.xyz = lerp(output.normalWS.xyz, half3(0, 1, 0), distanceBlend);
				output.positionWS.w = distanceBlend;

				return output;
			}

			half4 WaterFragment(Varyings_Water input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				half3 screenUV = input.shadowCoord.xyz / input.shadowCoord.w;
				#if defined(_CAMERADEPTHTEXTURE_ON)
					float depthTex = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_ScreenTextures_linear_clamp, screenUV.xy).r;
				#else
					#if UNITY_REVERSED_Z
						float depthTex = 1.0 - input.color.r;
					#else
						float depthTex = input.color.r;
					#endif
				#endif//
				half distanceBlend = input.positionWS.w;
				float dis = LinearEyeDepth(depthTex, _ZBufferParams);
				float interval = dis * input.waterData.x - input.waterData.y;
				float waterMaxVisibility = _MaxDepthSet;
				half depthMulti = 1.0 / waterMaxVisibility;
				float depthLerp = saturate(interval * depthMulti);//
				half4 waveHeightMapTex1 = SAMPLE_TEXTURE2D(_WaveHeightMap, sampler_WaveHeightMap, input.uv.zw);
				half2 detailBump1 = waveHeightMapTex1.xy * 2 - 1;
				half4 waveHeightMapTex2 = SAMPLE_TEXTURE2D(_WaveHeightMap, sampler_WaveHeightMap, input.uv.xy);
				half2 detailBump2 = waveHeightMapTex2.xy * 2 - 1;
				half2 detailBump = (detailBump1 + detailBump2 * 0.5) * saturate(interval * 0.25 + 0.25);
				input.normalWS.xyz += half3(detailBump.x, 0, detailBump.y) * _WaveHeightNormalScale;
				input.normalWS.xyz = normalize(input.normalWS.xyz);//
				input.normalWS.xyz=lerp(input.normalWS.xyz,normalize(input.normalWS.xyz+half3(0,1.0,0)),distanceBlend);
				//
				Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS.xyz));
				half3 mainLightColor = mainLight.color * _LightScale;
				half shadow = 1;
				half3 GI = SampleSH(input.normalWS.xyz);//
				#if defined(_SCATTERING_ON)
					half3 directLighting = pow(saturate(dot(mainLight.direction, input.normalWS.xyz)), _ScatteringLightPow) * mainLightColor * _ScatteringLightScale;
					float VDotInL = saturate(dot(input.viewDirWS, -mainLight.direction));
					VDotInL = pow(abs(VDotInL), _ScatteringPow)*saturate(input.waterData.z);
					directLighting += VDotInL * 5 * mainLightColor;
					half3 scatteringIntensity = directLighting * shadow + GI;//
					scatteringIntensity = scatteringIntensity * _ScatteringScale;
					scatteringIntensity=clamp(scatteringIntensity,0,5.0);
					scatteringIntensity = scatteringIntensity  * _ScatteringColor;
				#else
					half3 scatteringIntensity = half3(0,0,0);
				#endif
				#if defined(_WATER_FOAM_ON)
					half3 foamMap = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap, input.uv.zw).rgb;
					half depthEdge = saturate(interval * _FoamStep);
					half waveFoam = saturate(input.waterData.z * 0.5 - _WaveHeightMapFoamScale);
					half depthAdd = saturate(1 - interval * _FoamAdd) * 0.5;
					half edgeFoam = saturate((1 - interval * 0.5 - 0.25) + depthAdd) * depthEdge;
					half foamBlendMask = saturate(max(waveFoam, edgeFoam));
					half3 foamBlend = foamColors[foamBlendMask * 128].rgb;
					half foamMask = saturate(length(foamMap * foamBlend) * 1.5 - 0.1);
					half3 foam = foamMask.xxx * (mainLight.shadowAttenuation * mainLightColor + GI);//
				#endif
				float3 halfDir = SafeNormalize(mainLight.direction + float3(input.viewDirWS));
				float NoH = saturate(dot(float3(input.normalWS.xyz), halfDir));
				NoH = pow(NoH, _SpecularPow);
				half LDotH = saturate(dot(mainLight.direction, halfDir));
				float speTex= SAMPLE_TEXTURE2D_LOD(_LightSamplingMap, sampler_ScreenTextures_linear_clamp, float2(NoH,LDotH*LDotH),0).r;
				float speTex2=speTex*speTex;
				float speTex4=speTex2*speTex2;
				half speRes = speTex4 * _SpecularScale*30000.0;
				#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
					speRes = speRes - HALF_MIN;
					speRes = clamp(speRes, 0.0, 20.0);
				#else
					speRes = clamp(speRes, 0.0, 20.0);
				#endif
				half3 spec = speRes * shadow * mainLightColor*_SpecularScale;
				scatteringIntensity = scatteringIntensity * lerp(_HighlightsColor,_ShadeColor, depthLerp);//
				half3 reflection = 0;
				#if _REFLECT_CUBE_CUSTOM 
					half3 reflectVector = reflect(-input.viewDirWS, input.normalWS.xyz);
					half4 reflectionColor = SAMPLE_TEXTURECUBE_LOD(_ReflectMap, sampler_ReflectMap, reflectVector,lerp(_ReflectMapMipLevel,5, distanceBlend));
					#if !defined(UNITY_USE_NATIVE_HDR)
						reflection.rgb = DecodeHDREnvironment(reflectionColor, unity_SpecCube0_HDR);
					#endif
					reflection = lerp(0, reflection, _ReflectRatio) * _ReflectScale;
				#elif _REFLECT_CUBE_UNITY
					half3 reflectVector = reflect(-input.viewDirWS, input.normalWS.xyz);
					#if !defined(_ENVIRONMENTREFLECTIONS_OFF)
						half3 irradiance;
						half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, lerp(_ReflectMapMipLevel,5,distanceBlend)));
						#if defined(UNITY_USE_NATIVE_HDR)
							irradiance = encodedIrradiance.rgb;
						#else
							irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
						#endif
						reflection = irradiance;
					#else
						reflection = _GlossyEnvironmentColor.rgb;
					#endif

					reflection = lerp(0, reflection, _ReflectRatio) * _ReflectScale;
				#elif _REFLECTION_SCREEN
					half2 reflectionUV = screenUV + input.normalWS.zx * half2(0.02, 0.15);
					reflection = SAMPLE_TEXTURE2D_LOD(_ReflectionScreenTex, sampler_LinearClamp, reflectionUV, lerp(_ReflectMapMipLevel, 5, distanceBlend));
					reflection = lerp(0, reflection, _ReflectRatio) * _ReflectScale;
				#endif//

				half fresnelTerm = _FresnelBias + _FresnelScale * saturate(pow(abs(1.0 - dot(input.normalWS.xyz, input.viewDirWS)), _FresnelPower));
				#if defined(_WATER_WAVE_HEIGHT_WAVEMAP)
					half2 distortionUV = _DistortionScale * float2(waveHeightMapTex1.a, waveHeightMapTex2.a) * saturate((interval) * 0.02)*0.3 + screenUV.xy;
				#else
					half2 distortionUV = saturate((interval) * 0.02) + screenUV.xy;
				#endif
				half3 refraction = 0;
				half alpha = 1.0;
				#if defined(_OPAQUETEXTURE_ON)
					alpha = saturate(_PerspectiveIntensity * 1.5 * depthLerp);
					half3 output = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, distortionUV, interval * 0.25).rgb;
					half3 rampColor = lerp(_HighlightsColor, _ShadeColor, depthLerp);
					refraction = output * rampColor;
					refraction = lerp(output, refraction, saturate(_PerspectiveIntensity * 0.5 * depthLerp));
				#else
					alpha = saturate(_PerspectiveIntensity * depthLerp);
					refraction = lerp(_HighlightsColor, _ShadeColor, depthLerp);
				#endif//
				#if defined(_WATER_FOAM_ON)
					spec=spec*(1.0-foamMask)*(1.0-edgeFoam)*depthEdge;
				#endif
				reflection=lerp(refraction,reflection,_ReflectReplaceScale);
				fresnelTerm=lerp(fresnelTerm,1.0,_ReflectReplace);
				#if defined(_WATER_FOAM_ON)
					half3 comp = lerp(lerp(refraction, reflection, fresnelTerm) + scatteringIntensity + spec, foam, foamMask);
				#else
					half3 comp = lerp(refraction, reflection, fresnelTerm) + scatteringIntensity + spec;
				#endif//
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half fogIntensity = ComputeFogIntensity(input.fogFactor);
					comp = lerp(unity_FogColor.rgb, comp, fogIntensity);
				#endif

				return half4(comp, alpha);

			}

			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.BudWaterShaderGUI"
}
