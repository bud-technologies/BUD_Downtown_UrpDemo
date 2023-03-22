
Shader "NewRender/Cloud/ModelCloud"
{	
	Properties
	{
		_SkyColor("Sky", Color) = (0.8537736,1,0.9959381,1)
		_EquatorColor("Equator", Color) = (0.2432805,0.5996913,0.7264151,1)
		_GroundColor("Ground", Color) = (0.04610179,0.1565422,0.2641509,1)

		_GIScale("GI Scale", Range(0,1)) = 0.2
		_LambertScale("Lambert Scale", Range(0,1)) = 0.5
		_ScatteringPow("Scattering Pow", Range(0.1,50)) = 21
		_ScatteringScale("_Scattering Scale", Range(0,5)) = 1.5

		[MaterialToggle(_GROUNDPLANISH_ON)] _GroundPlanishOn  ("Ground Planish On", float) = 0
		_GroundPlanishOffset("Ground Planish Offset", float) = 0
		_GroundPlanishScaleStenghtH("Ground Planish Scale Stenght H", Range(0,10)) = 0
		_GroundPlanishScaleStenghtV("Ground Planish Scale Stenght V", Range(0.1,100)) = 10
		_GroundPlanishStenght("Ground Planish Stenght", Range(0,1)) = 0
		_GroundNormalPlanishStenght("Ground Normal Planish Stenght", Range(0,10)) = 1

		[MaterialToggle(_PLANT_ANIM_ON)] _TreeAnimOn  ("Tree Anim On", float) = 0
        _PosOffsetRange("Pos Offset Range", vector) = (-0.5,0.5,0,0)
        _AnimSpeed("Anim Speed XY", vector) = (20,40,20,0)
        _NoiseFrequency("Noise Frequency", Range(0.0, 2.0)) = 1
        _AnimStrength("Anim Strength", Range(0.0, 2.0)) = 0.261
		_WindData("Wind Data xyz:方向 w:强度", vector) = (0,0,0,0)

		[MaterialToggle(_SPHERE_NORMAL_ON)] _SphereNormalOn  ("Sphere Normal On", float) = 0
		_SphereNormalScale  ("Sphere Normal Scale", Range(0,2)) = 0.5

		[MaterialToggle(_FURMAP_ON)] _FurOn  ("Fur On", float) = 0
		//边缘虚化 作为外套虚边，需要开启半透
		_FurMap ("Fur Map", 2D) = "white" {}
		_FurMapScale  ("FurMap Scale", Range(0,2)) = 1
		_FurMapStep  ("FurMap Step", Range(0,1)) = 0

		//
		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)

		// Blending state
		[HideInInspector] _Surface("__surface", Float) = 0.0
		[HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
	}
	
	SubShader
	{
        Tags {
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

		BlendOp[_BlendOp]
        Blend[_SrcBlend][_DstBlend]
		Cull[_Cull]
        ZWrite[_ZWrite]

		HLSLINCLUDE

		#include "../Library/Common/CommonFunction.hlsl"

		CBUFFER_START(UnityPerMaterial)
			float4 _FurMap_ST;
			half3 _SkyColor;
			half3 _EquatorColor;
			half3 _GroundColor;
			half _ScatteringPow;
			half _ScatteringScale;
			half _LambertScale;
			half4 _PosOffsetRange;
			half4 _AnimSpeed;
			half _NoiseFrequency;
			half _AnimStrength;

			half _GroundPlanishStenght;
			half _GroundNormalPlanishStenght;
			half _SphereNormalScale;
			half _GroundPlanishOffset;
			half _GroundPlanishScaleStenghtH;
			half _GroundPlanishScaleStenghtV;

			half _FurMapScale;
			half _FurMapStep;
			half4 _WindData;
			half _GIScale;
		CBUFFER_END

		#if defined(_FURMAP_ON)
			TEXTURE2D_X(_FurMap);
		#endif

		ENDHLSL
		
		Pass
		{
			Tags {"LightMode"="UniversalForward"}

			HLSLPROGRAM
			#pragma vertex CloudVert
			#pragma fragment CloudFrag
			#pragma multi_compile_instancing 
            #pragma multi_compile_fog
			#pragma shader_feature _ _PLANT_ANIM_ON
			#pragma shader_feature _ _SPHERE_NORMAL_ON
			#pragma shader_feature _ _GROUNDPLANISH_ON
			#pragma shader_feature _ _FURMAP_ON

			struct Attributes_Cloud
			{
				float4 positionOS   : POSITION;
				float3 normalOS      : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Cloud
			{
				float4 positionCS   : SV_POSITION;
				#if defined(_FURMAP_ON)
					float4 screenUV		: TEXCOORD0;
				#endif
				float3 normalWS      : TEXCOORD1;
				half3 viewDirWS     : TEXCOORD2;
				float3 positionWS: TEXCOORD3;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float snoise_sin(float3 v)
			{
				float par=v.x+v.y*0.3+v.z;
				float sinValue = sin(par);
				float cosValue = cos(par*2);
				float res=(sinValue+cosValue)*0.5;
				return res;
			}

			Varyings_Cloud CloudVert(Attributes_Cloud input){
				Varyings_Cloud output = (Varyings_Cloud)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				#if defined(_SPHERE_NORMAL_ON)
					input.normalOS= normalize(input.normalOS+normalize(input.positionOS.xyz)*_SphereNormalScale);
				#endif

				#if defined(_GROUNDPLANISH_ON)
					float h=_GroundPlanishOffset-input.positionOS.y;
					input.positionOS.xz=lerp(input.positionOS.xz+_GroundPlanishScaleStenghtH*input.positionOS.xz,input.positionOS.xz,saturate(abs(h)/_GroundPlanishScaleStenghtV));
					input.positionOS.y=lerp(input.positionOS.y+_GroundPlanishScaleStenghtH*input.positionOS.y,input.positionOS.y,saturate(abs(h)/_GroundPlanishScaleStenghtV));
					float stepValue=step(0,h);
					float offset=lerp(0,max(0,h)*_GroundPlanishStenght,stepValue);
					input.positionOS.y=input.positionOS.y+offset;
					float3 hNormal =normalize(input.normalOS+float3(0,-1.0,0)*_GroundPlanishStenght*_GroundNormalPlanishStenght);
					input.normalOS=lerp(input.normalOS,hNormal,stepValue);
				#endif

				#if defined(_PLANT_ANIM_ON)
					float3 positonWS = TransformObjectToWorld(input.positionOS.xyz);
					float3 animSpeed = normalize(_AnimSpeed.xyz);
					float worldPos = snoise_sin( (positonWS + animSpeed * _Time.y)*_NoiseFrequency );
					worldPos=(worldPos+1.0)*(_PosOffsetRange.y-_PosOffsetRange.x)+_PosOffsetRange.x;
					float x=worldPos*animSpeed.x;
					float y=worldPos*animSpeed.y;
					float z=worldPos*animSpeed.z;
					#if defined(SHADER_STAGE_RAY_TRACING)
						float3 localOffset = mul(WorldToObject3x4(), float4(x,y,z, 0)).xyz;
					#else
						float3 localOffset = mul(GetWorldToObjectMatrix(), float4(x,y,z, 0)).xyz;
					#endif
					float3 posOffset=float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
										 length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
										 length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))*localOffset*_AnimStrength;
					input.positionOS.xyz += posOffset;
				#endif

				//
				output.positionWS.xyz=TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS=TransformWorldToHClip(output.positionWS.xyz);
				output.viewDirWS = GetCameraPositionWS() - output.positionWS.xyz;
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.normalWS.xy=output.normalWS.xy + (sin(_Time.y)*0.1).xx; 
				output.normalWS=normalize(output.normalWS);

				#if defined(_FURMAP_ON)
					float4 projPos = ComputeScreenPos (output.positionCS);
					output.screenUV = projPos.xyzw;
				#endif

				// Indirect light
				OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
				OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

				return output;
			}

			void Remap_float3(float3 In, float2 InMinMax, float2 OutMinMax, out float3 Out)
			{
				Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			void Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
			{
				Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

		    half3 SampleSH_half(half3 normalWS)
			{
				real4 SHCoefficients[7];
				SHCoefficients[0] = unity_SHAr;
				SHCoefficients[1] = unity_SHAg;
				SHCoefficients[2] = unity_SHAb;
				SHCoefficients[3] = unity_SHBr;
				SHCoefficients[4] = unity_SHBg;
				SHCoefficients[5] = unity_SHBb;
				SHCoefficients[6] = unity_SHC;
				return max(half3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
			}

			half4 CloudFrag(Varyings_Cloud input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				half4 finishColor=half4(0,0,0,1);

				float3 viewDirWS = normalize(input.viewDirWS);
				float3 normalWS = normalize(input.normalWS);
				float3 absolutePositionWS=GetAbsolutePositionWS(input.positionWS);

				//
				half3 lightDirection;
				half3 lightColor;
				half lightDistanceAtten;
				half lightShadowAtten;
				#if SHADOWS_SCREEN
					half4 clipPos = TransformWorldToHClip(absolutePositionWS);
					half4 shadowCoord = ComputeScreenPos(clipPos);
				#else
					half4 shadowCoord = TransformWorldToShadowCoord(absolutePositionWS);
				#endif
				half3 bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, normalWS);
				float bakedGIStrength=(bakedGI.r+bakedGI.g+bakedGI.b)*0.33333333;
				Light mainLight = GetMainLight(shadowCoord);
				float lightStrength=(mainLight.color.r+mainLight.color.g+mainLight.color.b)*0.33333333;
				lightDirection = mainLight.direction;
				lightColor = mainLight.color;
				lightDistanceAtten = mainLight.distanceAttenuation;
				lightShadowAtten = mainLight.shadowAttenuation;
				//
				float3 hDir=-(normalWS*0.5 + lightDirection);
				//
				float VDotH=dot(viewDirWS,hDir);
				VDotH=pow(abs(VDotH),_ScatteringPow);
				VDotH=saturate(dot(abs(VDotH),_ScatteringScale));
				half3 VDotHColor=VDotH*lightColor;

				//
				float NDotL=saturate(dot(normalWS,lightDirection));
				half3 difColor=lightColor*lightDistanceAtten*lightShadowAtten*NDotL*_LambertScale;
				//
				float fresnelEffect = pow((1.0 - saturate(dot(normalize(normalWS), normalize(viewDirWS)))), _ScatteringPow);
				half3 fresnelEffectColor=fresnelEffect*lightColor;
				half3 difColorRamap;
				Remap_float3(difColor, float2(-1,1), float2(0,1), difColorRamap);
				difColorRamap=pow(abs(difColorRamap),4.78);
				fresnelEffectColor=fresnelEffectColor*difColorRamap;
				//
				difColor=difColor+fresnelEffectColor+VDotHColor;
				//
				finishColor.rgb=difColor;
				//
				float NDotUp=dot(normalWS,float3(0.0,1.0,0.0));
				Remap_float(NDotUp,float2(-1,1), float2(0,1),NDotUp);
				float centerNDotUp=NDotUp*(1.0-NDotUp);
				Remap_float(centerNDotUp,float2(-1,1), float2(-1,2.01),centerNDotUp);
				centerNDotUp=1.0-centerNDotUp;
				half3 colorNDotUp=lerp(_GroundColor,_SkyColor,NDotUp);
				colorNDotUp=lerp(_EquatorColor,colorNDotUp,centerNDotUp);
				colorNDotUp=colorNDotUp*saturate(bakedGIStrength+lightStrength);
				//
				half3 ambientColor = SampleSH_half(normalWS);
				//
				finishColor.rgb=finishColor.rgb+colorNDotUp+ambientColor*_GIScale;

				#if defined(_FURMAP_ON)
				    float2 furUV =  input.screenUV.xy/input.screenUV.w;
					furUV=furUV*_FurMap_ST.xy+_FurMap_ST.zw;
					half4 furTex=SAMPLE_TEXTURE2D(_FurMap,sampler_LinearRepeat,furUV);
					float furAlpha=smoothstep(_FurMapStep,1.0,furTex.r);
					finishColor.a=furAlpha*_FurMapScale;
				#else
					finishColor.a=1.0;
				#endif

				return finishColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ModelCloundShaderGUI"
}
