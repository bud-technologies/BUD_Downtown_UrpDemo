#ifndef STANDARD_PBRFORWARD_INCLUDE
#define STANDARD_PBRFORWARD_INCLUDE

#include "StandardPBRInput.hlsl"
#include "StandardPBRData.hlsl"

struct Attributes_PBR
{
	float4 positionOS   : POSITION;
	float3 normalOS     : NORMAL;

#if defined(_NORMAL_ON)
	float4 tangentOS    : TANGENT;
#endif

	float2 uv     		: TEXCOORD0;
	float4 lightmapUV   : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings_PBR
{
	float4 positionCS   : SV_POSITION;

#if defined(_REFLECTION_SCREEN)
	float4 uv           : TEXCOORD0; 	
#else
	float2 uv          : TEXCOORD0; 	
#endif

#if defined(_NORMAL_ON)
	half4 normalWS      : TEXCOORD1;
	half4 tangentWS     : TEXCOORD2;
	half4 bitangentWS   : TEXCOORD3;
#else
	half3 normalWS      : TEXCOORD1;
	half3 viewDirWS     : TEXCOORD2;
#endif

	float4 positionWS   : TEXCOORD4;

#ifdef _ADDITIONAL_LIGHTS_VERTEX
	half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
	half  fogFactor                 : TEXCOORD5;
#endif

// #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
	float4 shadowCoord              : TEXCOORD6;
// #endif
	
	DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
	UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////// Energy Compensation //////////




Varyings_PBR PBRVert(Attributes_PBR input)
{
	Varyings_PBR output = (Varyings_PBR)0;

	// Instance
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

	// Vertex
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
	output.positionWS.xyz = vertexInput.positionWS;
	output.positionCS = vertexInput.positionCS;

	// UV
	output.uv.xy = TRANSFORM_TEX( input.uv,_BaseMap);

	#if defined(_REFLECTION_SCREEN)
		float4 screenPos=ComputeScreenPos(output.positionCS);
		output.uv.zw=screenPos.xy;
		output.positionWS.w=screenPos.w;
	#endif

	// Direction
	// VertexNormalInputs normalInput;
	// normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	// half sign = input.tangentOS.w * GetOddNegativeScale();
	// output.tangentWS = half4(TransformObjectToWorldDir(input.tangentOS.xyz), sign);

	//----------
	// View
    half3 viewDirWS = (GetCameraPositionWS() - vertexInput.positionWS);

	// Normal
    #if defined(_NORMAL_ON)
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
        half sign = input.tangentOS.w * GetOddNegativeScale();
        output.tangentWS = half4(normalInput.tangentWS.xyz, viewDirWS.x);
        output.bitangentWS = half4(sign * cross(normalInput.normalWS.xyz, normalInput.tangentWS.xyz), viewDirWS.y);
        output.normalWS = half4(normalInput.normalWS.xyz, viewDirWS.z);
    #else
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
        output.normalWS = normalInput.normalWS;
        output.viewDirWS = viewDirWS;
    #endif
	//---------

	// output.normalWS = normalInput.normalWS;
	// output.viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;

	// Indirect light
	OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
	OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

	// VertexLight And Fog
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	#ifdef _ADDITIONAL_LIGHTS_VERTEX
		//half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
		half3 vertexLight = VertexLighting(output.positionWS, output.normalWS);
		output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
	#else
		output.fogFactor = fogFactor;
	#endif

	// shadow
	#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
		#if !defined(ENABLE_HQ_SHADOW) && !defined(ENABLE_HQ_AND_UNITY_SHADOW)
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				output.shadowCoord = GetShadowCoord(vertexInput);
			#endif
		#endif
	#endif

	return output;
}

//////// Fragment Function //////////

//void DetailLayer(float2 uv,inout half3 albedo,inout half3 normal,inout half smoothness)
//{
//	half4 detail_id = SAMPLE_TEXTURE2D(_Detail_ID, sampler_LinearRepeat, uv);
	
//	half3 detail_scale = half3(_DetailAlbedoScale_1,_DetailNormalScale_1,_DetailSmoothnessScale_1) * detail_id.r
//					   + half3(_DetailAlbedoScale_2,_DetailNormalScale_2,_DetailSmoothnessScale_2) * detail_id.g
//					   + half3(_DetailAlbedoScale_3,_DetailNormalScale_3,_DetailSmoothnessScale_3) * detail_id.b
//					   + half3(_DetailAlbedoScale_4,_DetailNormalScale_4,_DetailSmoothnessScale_4) * detail_id.a;

//	half4 detail_map1 = SAMPLE_TEXTURE2D(_DetailMap_1, sampler_LinearRepeat, uv * _DetailMap_Tilling_1.xx);
//	half4 detail_map2 = SAMPLE_TEXTURE2D(_DetailMap_2, sampler_LinearRepeat, uv * _DetailMap_Tilling_2.xx);
//	half4 detail_map3 = SAMPLE_TEXTURE2D(_DetailMap_3, sampler_LinearRepeat, uv * _DetailMap_Tilling_3.xx);
//	half4 detail_map4 = SAMPLE_TEXTURE2D(_DetailMap_4, sampler_LinearRepeat, uv * _DetailMap_Tilling_4.xx);

//	half4 final_detail = lerp( lerp( lerp( detail_map1 , detail_map2 , detail_id.g) , detail_map3 , detail_id.b) , detail_map4 , detail_id.a);

// 	half3 detail_normal = normalize(UnpackNormal(half4(final_detail.w, final_detail.y, 1, 1.0)));

//    half3 normal_adjust = NormalStrength(detail_normal, detail_scale.y);

//    half detail_smoothness = final_detail.z * 2 - 1;

//    albedo = Remap((final_detail.x * 2 - 1) * detail_scale.x, half2 (-1, 1), half2 (0, 1)) * albedo * 2 ;
//	albedo = saturate(albedo);
//    // albedo = lerp(_Albedo, (final_detail.x - 0.5)>0?1:-1, _Detail_Scale.x * abs(final_detail.x *2 - 1));
//    normal = normalize(NormalBlend(normal, normal_adjust));
//    smoothness = saturate(smoothness + detail_smoothness * detail_scale.z);
//}

void DetailLayer_new(float2 uv,inout half3 albedo,inout half3 normalTS,inout half smoothness)
{
	half4 detail_id = SAMPLE_TEXTURE2D(_Detail_ID, sampler_LinearRepeat, uv);
	
	half3 detail_scale = half3(_DetailAlbedoScale_1,_DetailNormalScale_1,_DetailSmoothnessScale_1) * detail_id.r
					   + half3(_DetailAlbedoScale_2,_DetailNormalScale_2,_DetailSmoothnessScale_2) * detail_id.g
					   + half3(_DetailAlbedoScale_3,_DetailNormalScale_3,_DetailSmoothnessScale_3) * detail_id.b
					   + half3(_DetailAlbedoScale_4,_DetailNormalScale_4,_DetailSmoothnessScale_4) * detail_id.a;

	half3 detail_color = _DetailAlbedoColor_1.rgb * detail_id.r
					   + _DetailAlbedoColor_2.rgb * detail_id.g
					   + _DetailAlbedoColor_3.rgb * detail_id.b
					   + _DetailAlbedoColor_4.rgb * detail_id.a;

	half4 detail_map1 = SAMPLE_TEXTURE2D(_DetailMap_1, sampler_LinearRepeat, uv * _DetailMap_Tilling_1.xx);
	half4 detail_map2 = SAMPLE_TEXTURE2D(_DetailMap_2, sampler_LinearRepeat, uv * _DetailMap_Tilling_2.xx);
	half4 detail_map3 = SAMPLE_TEXTURE2D(_DetailMap_3, sampler_LinearRepeat, uv * _DetailMap_Tilling_3.xx);
	half4 detail_map4 = SAMPLE_TEXTURE2D(_DetailMap_4, sampler_LinearRepeat, uv * _DetailMap_Tilling_4.xx);

	half4 final_detail = lerp( lerp( lerp( detail_map1 , detail_map2 , detail_id.g) , detail_map3 , detail_id.b) , detail_map4 , detail_id.a);

 	half3 detail_normal = normalize(UnpackNormal(half4(final_detail.w, final_detail.y, 1, 1.0)));

    half3 normal_adjust = NormalStrength(detail_normal, detail_scale.y);

    half detail_smoothness = final_detail.z * 2 - 1;

    albedo = Remap((final_detail.x * 2 - 1) * detail_scale.x, half2 (-1, 1), half2 (0, 1)) * albedo * 2  + detail_color;
	albedo = clamp(albedo, 0.05, 0.95);
    // albedo = lerp(_Albedo, (final_detail.x - 0.5)>0?1:-1, _Detail_Scale.x * abs(final_detail.x *2 - 1));

    normalTS = normalize(NormalBlend(normalTS, normal_adjust));
    smoothness = saturate(smoothness + detail_smoothness * detail_scale.z);
}

inline void InitSurfaceData(float2 uv,out SurfaceData_PBR outSurfaceData)
{
	outSurfaceData = (SurfaceData_PBR)0;

	// base map
	half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_LinearRepeat, uv);

	//alpha
	outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
	// outSurfaceData.shadowStrenght = outSurfaceData.alpha;
	outSurfaceData.shadowStrenght = 1;
#if _ALPHATEST_ON
	clip(outSurfaceData.alpha- _Cutoff);
#endif

	outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
	outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);

	//specGloss
	half4 specGloss = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_LinearRepeat, uv);
	outSurfaceData.metallic = specGloss.r * _Metallic;
	outSurfaceData.smoothness = specGloss.b * _Smoothness;

#if defined(AOCOLORSET_COLOR)
	outSurfaceData.occlusionColor = _OcclusionColor;
#elif defined(AOCOLORSET_COLORMAP)
	outSurfaceData.normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_LinearRepeat, uv);
	half3 occlusionColorMap = SAMPLE_TEXTURE2D(_OcclusionColorMap, sampler_LinearRepeat, uv).rgb;
	outSurfaceData.occlusionColor =_OcclusionColor*occlusionColorMap;
#endif

//ao
outSurfaceData.occlusion = LerpWhiteTo(specGloss.g, _OcclusionStrength);
#if defined(AOCOLORSET_COLOR) || defined(AOCOLORSET_COLORMAP)
	outSurfaceData.occlusionColor=lerp(outSurfaceData.occlusionColor,half3(1.0,1.0,1.0),outSurfaceData.occlusion);
	outSurfaceData.albedo.rgb=outSurfaceData.albedo.rgb*outSurfaceData.occlusionColor;
#endif

	//emission
#if defined(_EMISSION_ON)
		float4 emission_color = _EmissionColor;
		
	#if defined(_EMISSION_MAP)
		emission_color *= SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).r;
	#endif

		outSurfaceData.emission = emission_color.rgb;
#endif

	//clearcloat
#if defined(_CLEARCOAT_ON)
	half clearCoatMap = SAMPLE_TEXTURE2D(_ClearCoatMap,sampler_LinearRepeat,uv).r;
	outSurfaceData.clearCoatMask = _ClearCoatMask * clearCoatMap;
	outSurfaceData.clearCoatSmoothness = _ClearCoatSmoothness;
#endif

#if defined(_IRIDESCENCE_ON)
	outSurfaceData.iridescence.x = _Iridescence;

	#if defined(_IRIDESCENCE_MASK)
		outSurfaceData.iridescence.x *= SAMPLE_TEXTURE2D(_IridescenceMask, sampler_LinearRepeat, uv).r;
	#endif

	outSurfaceData.iridescence.y = _IridescenceThickness;
#endif
}

void InitInputData(Varyings_PBR input,inout SurfaceData_PBR surfaceData, out InputData_PBR inputData)
{
	inputData = (InputData_PBR)0;
	inputData.positionWS = input.positionWS.xyz;
	inputData.positionCS = input.positionCS;

#if defined(_REFLECTION_SCREEN)
	inputData.screenUV=input.uv.zw/input.positionWS.w;
#endif

	// Normal, View
#if defined(_NORMAL_ON)
	inputData.viewDirWS = normalize(half3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w));

	half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);

	half4 normalTex;

	#if defined(AOCOLORSET_COLORMAP)
		normalTex=surfaceData.normalTex;
	#else
		normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_LinearRepeat, input.uv);
	#endif

    half3 normalTS = UnpackNormalScale(normalTex,_BumpScale);

	#if defined(_CLEARCOAT_ON)	
		inputData.clearCoatNormalWS = normalize(mul(normalTS, TBN));
	#endif
    
	// Detail
#if defined(_DETAILMAP_ON)
	DetailLayer_new(input.uv,surfaceData.albedo,normalTS,surfaceData.smoothness);
	// DetailLayer(input.uv,surfaceData.albedo,normalTS,surfaceData.smoothness);
#endif

	inputData.normalWS = normalize(mul(normalTS,TBN));
	
	// Specular Occlusion
#if defined(_SPECULAROCCLUSION_ON)
	half3 bent_normal_data = UnpackNormalScale(SAMPLE_TEXTURE2D(_BentNormalMap,sampler_LinearRepeat,input.uv),_BentBumpScale);
	inputData.bentNormalWS = normalize(mul(bent_normal_data,TBN));
#endif

#else
    inputData.viewDirWS = normalize(input.viewDirWS);
    inputData.normalWS = normalize(input.normalWS);

	#if defined(_CLEARCOAT_ON)	
		inputData.clearCoatNormalWS = inputData.normalWS;
	#endif
#endif	// _NORMAL_ON

	// Normal Filter
#if defined(MODULATE_SMOOTHNESS)
	ModulateSmoothnessByNormal(surfaceData.smoothness, inputData.normalWS);
#endif
	
	// Clear Coat
#if defined(_CLEARCOAT_ON)	
	surfaceData.smoothness = lerp(surfaceData.smoothness,surfaceData.smoothness * _ClearCoatDownSmoothness,surfaceData.clearCoatMask);
	inputData.clearCoatNormalWS = lerp(inputData.clearCoatNormalWS,inputData.normalWS,_ClearCoat_Detail_Factor);
#endif

	// Shadow
#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
	#if defined(ENABLE_HQ_SHADOW) || defined(ENABLE_HQ_AND_UNITY_SHADOW) 
		inputData.shadowCoord.x = HighQualityRealtimeShadow(input.positionWS);
	#else
		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			inputData.shadowCoord = input.shadowCoord;
		#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
			inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
		#else
			inputData.shadowCoord = float4(0, 0, 0, 0);
		#endif

	#endif
#endif

	inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);

	// Addisional Light Vertex
#ifdef _ADDITIONAL_LIGHTS_VERTEX
	inputData.fogCoord = input.fogFactorAndVertexLight.x;
	inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
	inputData.fogCoord = input.fogFactor;
#endif

	// Indirect Light
	inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);

}

#endif	//STANDARD_PBRFORWARD_INCLUDE
