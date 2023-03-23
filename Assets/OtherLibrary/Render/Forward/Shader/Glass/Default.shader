//全息
Shader "NewRender/Glass/Default"
{	
	Properties
	{

		[KeywordEnum(Off,Color,AlphaTest,ColorAlphaTest)] _BASEMAP("BaseMap类型",Int) = 0
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		_BaseMap ("Base Texture", 2D) = "white" {}
		[HDR]_BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

		[MaterialToggle(_NORMAL_ON)] _NormalOn  ("Normal开启", float) = 0
		[NoScaleOffset][Normal]_BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Range(0.0, 3.0)) = 1.0

		//Refract
		[KeywordEnum(Off,Unity,Custom_2d,Custom_Cube)] _REFRACT("折射类型",Int) = 1
		[MaterialToggle(_CHANNELSPLITTING_ON)] _ChannelSplittingOn  ("通道拆分", float) = 0
		_ChannelSplittingScale("Channel Splitting Scale 通道拆分", Range(0,1)) = 0.03
		_RefractMap ("RefractMap 折射纹理 2D", 2D) = "black" {}
		_RefractCubeMap("RefractMap 折射纹理 Cube", Cube) = "black" {}
		_Refractive("Refractive 折射率", Range(0,1)) = 0.642
		_RefractScale("Refract Scale 折射强度", Range(0,1)) = 1
		_RefractColor("Refract Color", Color) = (1,1,1,1)

		//Reflect
		[KeywordEnum(Off,Light,HalfLight)] _FRESNEL("Fresnel Light 效果",Int) = 2
		_FresnelScale("Fresnel Scale", Range(0,10)) = 1
		_FresnelPower("Fresnel Power", Range(0.001,10)) = 4
		_FresnelAdd("Fresnel Add", Range(0,1)) = 0.021
		_ReflectColor("Reflect Color", Color) = (1,1,1,1)
		_ReflectScale("Reflect Scale", Range(0,5)) = 2.88
		[KeywordEnum(Off,Unity,Custom)] _REFLECT_CUBE("Cube类型",Int) = 1
		_ReflectMap("Reflect Map", Cube) = "white" {}

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}

		HLSLINCLUDE

		#include "../Library/Common/CommonFunction.hlsl"

		CBUFFER_START(UnityPerMaterial)

			half4 _BaseColor;
			float4 _BaseMap_ST;
			float4 _BumpMap_ST;
			half _RefractScale;
			half _Refractive;
			half _BumpScale;
			half _NormalOn;
			half _FresnelScale;
			half _FresnelPower;
			half _FRESNEL;
			half _REFLECT_CUBE;
			half4 _ReflectColor;
			half _ReflectScale;
			half4 _RefractColor;
			half _FresnelAdd;
			half _REFRACT;
			half _BaseMapOn;
			half _AlphaTestOn;
			half _Cutoff;
			half _ChannelSplittingOn;
			half _ChannelSplittingScale;
			half _Cull;

		CBUFFER_END

		ENDHLSL

		Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit"}

            ZWrite Off
            Cull Front
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex GlassVert
            #pragma fragment GlassFrag
            #pragma multi_compile_instancing 

			struct Attributes_Glass
			{
				float4 positionOS   : POSITION;
			};

			struct Varyings_Glass
			{
				float4 positionCS   : SV_POSITION;
			};

			Varyings_Glass GlassVert(Attributes_Glass input){
				Varyings_Glass output = (Varyings_Glass)0;

				// Vertex
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

				return output;
			}

			half4 GlassFrag(Varyings_Glass input) : SV_Target
			{
				return half4(0,0,0,1);
			}

            ENDHLSL
        }

		Pass
		{
			Tags {"LightMode"="UniversalForward"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM
			#pragma vertex GlassVert
			#pragma fragment GlassFrag
			#pragma multi_compile_instancing 
            #pragma multi_compile_fog
			#pragma shader_feature_local _ _BASEMAP_COLOR _BASEMAP_ALPHATEST _BASEMAP_COLORALPHATEST
			#pragma shader_feature_local _NORMAL_ON
			#pragma shader_feature_local _CHANNELSPLITTING_ON
			#pragma shader_feature_local _ _FRESNEL_LIGHT _FRESNEL_HALFLIGHT
			#pragma shader_feature_local _ _REFLECT_CUBE_UNITY _REFLECT_CUBE_CUSTOM
			#pragma shader_feature_local _ _REFRACT_UNITY _REFRACT_CUSTOM_2D _REFRACT_CUSTOM_CUBE

			SAMPLER(sampler_ScreenTextures_linear_clamp);
			SAMPLER(sampler_ScreenTextures_linear_repeat);

			#if defined(_CAMERADEPTHTEXTURE_ON)
				TEXTURE2D_X(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
			#endif

			#if defined(_BASEMAP_COLOR) || defined(_BASEMAP_ALPHATEST) || defined(_BASEMAP_COLORALPHATEST)
				TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			#endif

			TEXTURE2D_X(_BumpMap); SAMPLER(sampler_BumpMap);

			#if defined(_REFRACT_CUSTOM_CUBE)
				TEXTURECUBE(_RefractCubeMap);
			#endif

			#if defined(_REFRACT_CUSTOM_2D)
				TEXTURE2D_X(_RefractMap);
			#endif

			#if defined(_REFRACT_UNITY)
				TEXTURE2D_X(_CameraOpaqueTexture);
			#endif

			#if defined(_REFLECT_CUBE_CUSTOM)
				TEXTURECUBE(_ReflectMap);
			#endif

			struct Attributes_Glass
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float4 tangentOS : TANGENT;
				float2 uv     		: TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Glass
			{
				float4 positionCS   : SV_POSITION;
				float2 uv           : TEXCOORD0; 	

				float4 screenUV		: TEXCOORD1;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half  fogFactor : TEXCOORD2;
				#endif

				#if defined(_NORMAL_ON)
					float4 normalWS : TEXCOORD3;
					float4 tangentWS : TEXCOORD4;
					float4 bitangentWS : TEXCOORD5;
				#else
					float3 positionWS : TEXCOORD3;
					float3 normalWS : TEXCOORD4;
				#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Glass GlassVert(Attributes_Glass input){
				Varyings_Glass output = (Varyings_Glass)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

				#if defined(_NORMAL_ON)
					real sign = real(input.tangentOS.w) * GetOddNegativeScale(); 
					output.normalWS =half4( TransformObjectToWorldNormal(input.normalOS) , positionWS.x); 
					output.tangentWS =half4(real3(TransformObjectToWorldDir(input.tangentOS.xyz)),positionWS.y) ; 
					output.bitangentWS = half4(real3(cross(output.normalWS.xyz, float3(output.tangentWS.xyz))) * sign,positionWS.z);
				#else
					output.normalWS = TransformObjectToWorldNormal(input.normalOS);
					output.positionWS = positionWS;
				#endif

				// UV
				output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;

				float4 projPos = ComputeScreenPos (output.positionCS);
				output.screenUV = projPos;

				// Fog
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					half fogFactor = ComputeFogFactor(output.positionCS.z); 
					output.fogFactor = fogFactor;
				#endif

				return output;
			}

			half4 GlassFrag(Varyings_Glass input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half4 baseMapTex = half4(0,0,0,1);
				#if defined(_BASEMAP_COLOR) || defined(_BASEMAP_ALPHATEST) || defined(_BASEMAP_COLORALPHATEST)
				    float2 baseMapUV = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw;
					baseMapTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseMapUV)*_BaseColor;
					#if defined(_BASEMAP_ALPHATEST) || defined(_BASEMAP_COLORALPHATEST)
						clip(baseMapTex.a-_Cutoff);
					#endif
				#endif

				//
				#if defined(_NORMAL_ON)
					float3 positionWS = float3(input.normalWS.w,input.tangentWS.w,input.bitangentWS.w); 
				#else
					float3 positionWS = input.positionWS;
				#endif

				half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);

				float3 normalWS;
				#if defined(_NORMAL_ON)
					float2 normalTexUV = input.uv.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
					half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap,  normalTexUV);
					float3 normalTS = UnpackNormalScale(normalTex,_BumpScale);
					normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
				#else
					normalWS = NormalizeNormalPerPixel(input.normalWS);
				#endif

				//Fresnel
				float NDotV = dot( normalWS, viewDirWS );
				float fresnel = pow(abs(1.0 - NDotV), _FresnelPower);
				#if defined(_FRESNEL_LIGHT) || defined(_FRESNEL_HALFLIGHT)
					Light mainLight = GetMainLight();
					half3 lightDirection = mainLight.direction;
					half3 lightColor = mainLight.color;
					half lightDistanceAtten = mainLight.distanceAttenuation;
					half lightShadowAtten = mainLight.shadowAttenuation;
					float NDotL = dot(normalWS,lightDirection);
					#if defined(_FRESNEL_HALFLIGHT)
						NDotL=NDotL*0.5+0.5;
					#endif
					NDotL = saturate(NDotL);
					fresnel = fresnel*NDotL;
				#endif
				fresnel = saturate(fresnel);
				fresnel = _FresnelAdd + fresnel*_FresnelScale;

				half3 fresnelColor = _ReflectScale*_ReflectColor.rgb*fresnel;
				float3 reflectVector = reflect(-viewDirWS,normalWS);
				#if defined(_REFLECT_CUBE_UNITY)
					half4 encodedIrradiance = SAMPLE_TEXTURECUBE(unity_SpecCube0, samplerunity_SpecCube0, reflectVector);
					#if !defined(UNITY_USE_NATIVE_HDR)
						encodedIrradiance.rgb = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
					#endif
					fresnelColor = fresnelColor.rgb*encodedIrradiance.rgb;
				#elif defined(_REFLECT_CUBE_CUSTOM)
					half4 reflectionColor = SAMPLE_TEXTURECUBE(_ReflectMap, sampler_ScreenTextures_linear_clamp, reflectVector);
					#if !defined(UNITY_USE_NATIVE_HDR)
						reflectionColor.rgb = DecodeHDREnvironment(reflectionColor, unity_SpecCube0_HDR);
					#endif
					fresnelColor = fresnelColor.rgb*reflectionColor.rgb;
				#endif

				half4 opaqueTex = half4(0,0,0,1);

				// #if defined(_REFRACT_UNITY) || defined(_REFRACT_CUSTOM_2D)
				// 	#if defined(_CHANNELSPLITTING_ON)
				// 		float3 refractVectorR = refract(-viewDirWS,normalWS,_Refractive);
				// 		float DotRV_R = dot(-viewDirWS,refractVectorR);
				// 		DotRV_R=saturate(1.0-DotRV_R);
				// 		float3 refractVectorG = refract(-viewDirWS,normalWS,_Refractive+_Refractive*_ChannelSplittingScale);
				// 		float DotRV_G = dot(-viewDirWS,refractVectorG);
				// 		DotRV_G=saturate(1.0-DotRV_G);
				// 		float3 refractVectorB = refract(-viewDirWS,normalWS,_Refractive-_Refractive*_ChannelSplittingScale);
				// 		float DotRV_B = dot(-viewDirWS,refractVectorB);
				// 		DotRV_B=saturate(1.0-DotRV_B);
				// 		float3 refractVectorViewR = TransformWorldToViewDir(refractVectorR);
				// 		float3 refractVectorViewG = TransformWorldToViewDir(refractVectorG);
				// 		float3 refractVectorViewB = TransformWorldToViewDir(refractVectorB);
				// 		float2 screenUV=input.screenUV.xy/input.screenUV.w;
				// 		float dis = length(screenUV-float2(0.5,0.5));
				// 		dis = saturate(1.0-smoothstep(0,0.5,dis));
				// 		float2 opaqueUV_R = screenUV+dis*refractVectorViewR.xy*DotRV_R*_RefractScale;
				// 		float2 opaqueUV_G = screenUV+dis*refractVectorViewG.xy*DotRV_G*_RefractScale;
				// 		float2 opaqueUV_B = screenUV+dis*refractVectorViewB.xy*DotRV_B*_RefractScale;
				// 		#if defined(_REFRACT_UNITY)
				// 			half opaqueTex_R = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_ScreenTextures_linear_repeat, opaqueUV_R).r;
				// 			half opaqueTex_G = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_ScreenTextures_linear_repeat, opaqueUV_G).g;
				// 			half opaqueTex_B = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_ScreenTextures_linear_repeat, opaqueUV_B).b;
				// 			opaqueTex.rgb=half3(opaqueTex_R,opaqueTex_G,opaqueTex_B);
				// 		#elif defined(_REFRACT_CUSTOM_2D)
				// 			half opaqueTex_R = SAMPLE_TEXTURE2D(_RefractMap, sampler_ScreenTextures_linear_repeat, opaqueUV_R).r;
				// 			half opaqueTex_G = SAMPLE_TEXTURE2D(_RefractMap, sampler_ScreenTextures_linear_repeat, opaqueUV_G).g;
				// 			half opaqueTex_B = SAMPLE_TEXTURE2D(_RefractMap, sampler_ScreenTextures_linear_repeat, opaqueUV_B).b;
				// 			opaqueTex.rgb=half3(opaqueTex_R,opaqueTex_G,opaqueTex_B);
				// 		#endif
				// 	#else
				// 		float3 refractVector = refract(-viewDirWS,normalWS,_Refractive);
				// 		float DotRV = dot(-viewDirWS,refractVector);
				// 		DotRV=saturate(1.0-DotRV);
				// 		float3 refractVectorView = TransformWorldToViewDir(refractVector);
				// 		float2 screenUV=input.screenUV.xy/input.screenUV.w;
				// 		float2 opaqueUV = screenUV;
				// 		float dis = length(screenUV-float2(0.5,0.5));
				// 		dis = saturate(1.0-smoothstep(0,0.5,dis));
				// 		opaqueUV=opaqueUV+dis*refractVectorView.xy*DotRV*_RefractScale;
				// 		#if defined(_REFRACT_UNITY)
				// 			opaqueTex = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_ScreenTextures_linear_repeat, opaqueUV);
				// 		#elif defined(_REFRACT_CUSTOM_2D)
				// 			opaqueTex = SAMPLE_TEXTURE2D(_RefractMap, sampler_ScreenTextures_linear_repeat, opaqueUV);
				// 		#endif
				// 	#endif
				// #elif defined(_REFRACT_CUSTOM_CUBE)
				// 	#if defined(_CHANNELSPLITTING_ON)
				// 		float3 refractVectorR = refract(-viewDirWS,normalWS,_Refractive);
				// 		float3 refractVectorG = refract(-viewDirWS,normalWS,_Refractive+_Refractive*_ChannelSplittingScale);
				// 		float3 refractVectorB = refract(-viewDirWS,normalWS,_Refractive-_Refractive*_ChannelSplittingScale);
				// 		//
				// 		half4 refractColorR = SAMPLE_TEXTURECUBE(_RefractCubeMap, sampler_ScreenTextures_linear_clamp, refractVectorR);
				// 		#if !defined(UNITY_USE_NATIVE_HDR)
				// 			refractColorR.rgb = DecodeHDREnvironment(refractColorR, unity_SpecCube0_HDR);
				// 		#endif
				// 		half4 refractColorG = SAMPLE_TEXTURECUBE(_RefractCubeMap, sampler_ScreenTextures_linear_clamp, refractVectorG);
				// 		#if !defined(UNITY_USE_NATIVE_HDR)
				// 			refractColorG.rgb = DecodeHDREnvironment(refractColorG, unity_SpecCube0_HDR);
				// 		#endif
				// 		half4 refractColorB = SAMPLE_TEXTURECUBE(_RefractCubeMap, sampler_ScreenTextures_linear_clamp, refractVectorB);
				// 		#if !defined(UNITY_USE_NATIVE_HDR)
				// 			refractColorB.rgb = DecodeHDREnvironment(refractColorB, unity_SpecCube0_HDR);
				// 		#endif
				// 		opaqueTex.rgb = half3(refractColorR.r,refractColorG.g,refractColorB.b);
				// 	#else
				// 		float3 refractVector = refract(-viewDirWS,normalWS,_Refractive);
				// 		half4 refractColor = SAMPLE_TEXTURECUBE(_RefractCubeMap, sampler_ScreenTextures_linear_clamp, refractVector);
				// 		#if !defined(UNITY_USE_NATIVE_HDR)
				// 			refractColor.rgb = DecodeHDREnvironment(refractColor, unity_SpecCube0_HDR);
				// 		#endif
				// 		opaqueTex.rgb = refractColor.rgb;
				// 	#endif
				// #endif
				// opaqueTex= opaqueTex*_RefractColor;

				half4 finishColor = opaqueTex;
				finishColor.a = 1.0 * _BaseColor.a;
				finishColor.rgb = 	finishColor.rgb+fresnelColor;

				#if defined(_BASEMAP_COLOR) || defined(_BASEMAP_COLORALPHATEST)
					finishColor.rgb = lerp(finishColor.rgb,baseMapTex.rgb, baseMapTex.a);
				#endif

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
					float fogFactor=input.fogFactor;
					half fogIntensity = ComputeFogIntensity(fogFactor);
					finishColor.rgb = lerp(unity_FogColor.rgb, finishColor.rgb , fogIntensity);
				#endif

				return finishColor;

			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.GlassShaderGUI"
}
