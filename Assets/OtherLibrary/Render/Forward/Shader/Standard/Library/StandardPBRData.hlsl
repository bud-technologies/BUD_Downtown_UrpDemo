#ifndef STANDARD_PBRDATA_INCLUDE
#define STANDARD_PBRDATA_INCLUDE

struct SurfaceData_PBR
{
	half3 albedo;
	half3 specular;
	half  metallic;
	half  smoothness;
	half3 emission;
	half  occlusion;
	half  alpha;
	half  shadowStrenght;

// #if defined(_CLEARCOAT_ON)
	half  clearCoatMask;
	half  clearCoatSmoothness;
// #endif

	#if defined(_IRIDESCENCE_ON)
		half2 iridescence;	//x : mask ; y : thickness
	#endif

	//AO Color
	#if defined(AOCOLORSET_COLOR)
		half3 occlusionColor;
	#endif
	#if defined(AOCOLORSET_COLORMAP)
		half3 occlusionColor;
		#if defined(_NORMAL_ON)
			half4 normalTex;
		#endif
	#endif
};

struct InputData_PBR 
{
	float3  positionWS;
	float4  positionCS;

	half3  normalWS;
	half3  viewDirWS;
	half3	bentNormalWS;

	half    fogCoord;
	half3   bakedGI;

	float4   shadowMask;

// #if defined(_CLEARCOAT_ON)
	half3 clearCoatNormalWS;
// #endif

// #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
	half4  shadowCoord;
// #endif

	#ifdef _ADDITIONAL_LIGHTS_VERTEX
		half3   vertexLighting;
	#endif

	#if defined(_REFLECTION_SCREEN)
		float2 screenUV;
	#endif
};

struct BRDFData_PBR
{
    half3 albedo;
    half3 diffuse;
    half3 specular;
    half perceptualRoughness;
    half roughness;
    half roughness2;
    half normalizationTerm;     // roughness * 4.0 + 2.0
    half roughness2MinusOne;    // roughness^2 - 1.0

    #if defined(_CLEARCOAT_ON)
        half clearCoatPerceptualRoughness;
        half clearCoatRoughness;
        half clearCoatRoughness2;
        half clearCoatNormalizationTerm;     
        half clearCoatRoughness2MinusOne;   
    #endif

    float4 shadowMask;
};

#endif	//STANDARD_PBRDATA_INCLUDE
