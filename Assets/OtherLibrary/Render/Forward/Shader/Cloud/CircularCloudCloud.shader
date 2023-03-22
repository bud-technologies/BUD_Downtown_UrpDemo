
Shader "NewRender/Cloud/CircularCloud"
{	
	Properties
	{
		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor]_BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

		_FogHeight("Fog高度", Range(0,300)) = 100

		//
		_LightPow("Light Pow", Range(0.1, 10)) = 2
		_LightScale("Light Pow", Range(0, 1)) = 1
		_LightNegateRangOffset("Light Negate Range Offset", Range(0, 4)) = 0
		_LightNegateRangeLeftMin("Light Negate Range Left Min", Range(-1, 0)) = 0
		_LightNegateRangeLeftMax("Light Negate Range Left Max", Range(0, 1)) = 1
		_LightNegateRangeRightMin("Light Negate Range Right Min", Range(0, 4)) = 0
		_LightNegateRangeRightMax("Light Negate Range Right Max", Range(1, 4)) = 4
		[HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

		//
		_OcclusionMap("AO贴图", 2D) = "white" {}

		//
		[MaterialToggle(_GROUNDPLANISH_ON)] _GroundPlanishOn  ("Ground Planish On", float) = 0
		_GroundPlanishOffset("Ground Planish Offset", float) = 0
		_GroundPlanishScaleStenghtH("Ground Planish Scale Stenght H", Range(0,10)) = 0
		_GroundPlanishScaleStenghtV("Ground Planish Scale Stenght V", Range(0.1,100)) = 10
		_GroundPlanishStenght("Ground Planish Stenght", Range(0,1)) = 0
		_GroundNormalPlanishStenght("Ground Normal Planish Stenght", Range(0,10)) = 1

		//
		[MaterialToggle(_PLANT_ANIM_ON)] _TreeAnimOn  ("Tree Anim On", float) = 0
        _PosOffsetRange("Pos Offset Range", vector) = (-0.5,0.5,0,0)
        _AnimSpeed("Anim Speed XY", vector) = (20,40,20,0)
        _NoiseFrequency("Noise Frequency", Range(0.0, 2.0)) = 1
        _AnimStrength("Anim Strength", Range(0.0, 2.0)) = 0.261
		_WindData("Wind Data xyz:方向 w:强度", vector) = (0,0,0,0)

		// Blending state
		[HideInInspector] _Surface("__surface", Float) = 0.0
		[HideInInspector] _AlphaClip("__clip", Float) = 0.0
       
        [HideInInspector] _Cull("__cull", Float) = 2.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Tags { "Queue"="Transparent-100" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}

        Blend SrcAlpha OneMinusSrcAlpha
		Cull[_Cull]
        ZWrite[_ZWrite]

		HLSLINCLUDE

		#include "../Library/Common/CommonFunction.hlsl"
		#include "../Library/Light/LightLib.hlsl"
		#include "../Library/Normal/NormalLib.hlsl"

		CBUFFER_START(UnityPerMaterial)
			half4 _BaseColor;
			float4 _BaseMap_ST;
			half _LightPow;
			half _LightScale;
			half _LightNegateRangOffset;
			half _LightNegateRangeRightMin;
			half _LightNegateRangeRightMax;
			half _LightNegateRangeLeftMin;
			half _LightNegateRangeLeftMax;
			half3 _EmissionColor;
			half _FogHeight;

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

		CBUFFER_END

		TEXTURE2D_X(_BaseMap);
		TEXTURE2D_X(_OcclusionMap);

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
			#pragma shader_feature _ _GROUNDPLANISH_ON
			#pragma shader_feature _ _FURMAP_ON

			struct Attributes_Cloud
			{
				float4 positionOS   : POSITION;
				float3 normalOS      : NORMAL;
				float2 uv		: TEXCOORD0;
				float4 tangentOS : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Cloud
			{
				float4 positionCS   : SV_POSITION;
				#if defined(_FURMAP_ON)
					float4 screenUV		: TEXCOORD0;
				#endif
				float3 normalWS      : TEXCOORD1;
				float3 tangentWS : TEXCOORD2;
				float3 bitangentWS : TEXCOORD3;

				half3 viewDirWS     : TEXCOORD4;
				float3 positionWS: TEXCOORD5;
				float2 uv		: TEXCOORD6;

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half  fogFactor : TEXCOORD8;
				#endif

				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH,7);
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

			float2 RotatorAngle(float2 posXZ, float rotatorAngle) {
				half rCos = cos(rotatorAngle * 3.14159265359);
				half rSin = sin(rotatorAngle * 3.14159265359);
				half2 rPiv = half2(0, 0);
				float2 rotator = mul(float2x2(rCos, -rSin, rSin, rCos), (posXZ - rPiv));
				rotator = rotator;
				return rotator + rPiv;
			}

			Varyings_Cloud CloudVert(Attributes_Cloud input){
				Varyings_Cloud output = (Varyings_Cloud)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.uv.xy = TRANSFORM_TEX(input.uv,_BaseMap);

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

				output.normalWS=normalize(float3(-output.positionWS.x+GetCameraPositionWS().x,0,-output.positionWS.z+GetCameraPositionWS().z));

				half sign = input.tangentOS.w * GetOddNegativeScale();
				output.tangentWS.xyz = real3(TransformObjectToWorldDir(input.tangentOS.xyz));
				output.bitangentWS.xyz = half3(sign * cross(output.normalWS.xyz, output.tangentWS.xyz));

				#if defined(_FURMAP_ON)
					float4 projPos = ComputeScreenPos (output.positionCS);
					output.screenUV = projPos.xyzw;
				#endif

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					output.fogFactor = ComputeFogFactor(output.positionCS.z);
				#endif

				// Indirect light
				OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
				OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

				return output;
			}

			float3 Remap_float3(float3 In, float2 InMinMax, float2 OutMinMax)
			{
				return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			float Remap_float(float In, float2 InMinMax, float2 OutMinMax)
			{
				return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			half4 CloudFrag(Varyings_Cloud input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);

				half4 baseMapTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_LinearClamp, input.uv.xy);
				float alpha = baseMapTex.a;
				float3 colorRGToNormal = ColorRGToNormal(baseMapTex.r,baseMapTex.g);
				half3x3 TBN = transpose(half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS));
				float3 normalWS = normalize(mul(colorRGToNormal,TBN));
				float3 ambientNormalWS=lerp(input.normalWS,normalWS,0.5);
				half3 ambientColor = SampleSH(ambientNormalWS);
				half4 occlusionMapTex = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_LinearClamp, input.uv.xy);
				float ao=1.0-(1.0-occlusionMapTex.r)*0.5;
				ambientColor = ambientColor*ao;
				half3 lightDirection;
				half3 lightColor;
				half lightDistanceAtten;
				half lightShadowAtten;
				GetMainLight(input.positionWS, lightDirection, lightColor, lightDistanceAtten, lightShadowAtten);
				float NDotL = dot(normalWS,lightDirection);
				NDotL = NDotL*0.5+0.5;
				NDotL= saturate(pow(abs(NDotL),_LightPow));

				float VNegateNdotL = dot(-input.normalWS,lightDirection);
				VNegateNdotL = Remap_float(VNegateNdotL, float2(_LightNegateRangeLeftMin,_LightNegateRangeLeftMax), float2(_LightNegateRangeRightMin,_LightNegateRangeRightMax))+_LightNegateRangOffset;
				VNegateNdotL = clamp(VNegateNdotL,0,10)+0.5;
				float em=baseMapTex.r*baseMapTex.b*baseMapTex.g;
				half3 emissionColor = em*_EmissionColor;
				half3 lightRes = NDotL*VNegateNdotL*lightColor*_LightScale;
				half4 finishColor=half4(0,0,0,1);
				finishColor.rgb=ambientColor+lightRes+emissionColor;
				finishColor.a=alpha;
				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					half fogIntensity = ComputeFogIntensity(input.fogFactor);
					half3 fogFinishColor = lerp(unity_FogColor.rgb, finishColor.rgb, fogIntensity);
					float lerpValue = saturate(abs(input.positionWS.y)/_FogHeight) ;
					finishColor.rgb=lerp(fogFinishColor,finishColor.rgb,saturate(abs(input.positionWS.y)/_FogHeight));
				#endif

				return finishColor;
			}

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ModelCloundShaderGUI"
}
