#ifndef FABRIC_FORWARD_INCLUDE
#define FABRIC_FORWARD_INCLUDE

#include "FabricInput.hlsl"


struct Attributes_Fabric
{
	float4 positionOS   : POSITION;
	float3 normalOS     : NORMAL;

	float4 tangentOS    : TANGENT;

	float2 uv     		: TEXCOORD0;
	float4 lightmapUV   : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings_Fabric
{
	float4 positionCS               : SV_POSITION;
	float2 uv                       : TEXCOORD0; 	
	float3 positionWS               : TEXCOORD1;

	half3 normalWS                 	: TEXCOORD2;

	half4 tangentWS                	: TEXCOORD3;    // xyz: tangent, w: sign

	half3 viewDirWS                	: TEXCOORD4;

#ifdef _ADDITIONAL_LIGHTS_VERTEX
	float4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
	float  fogFactor                 : TEXCOORD5;
#endif

// #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
	float4 shadowCoord              : TEXCOORD6;
// #endif
	
	DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct SurfaceData_Fabric
{
    half3 baseColor;
    half3 specularColor;
    
    half metallic;  // ?
    half anisotropy;
    half perceptualSmoothness;
    
    half3 normalWS;
    half3 geomNormalWS;
    half3 tangentWS;

    half3 subsurfaceMask;
    
    half ambientOcclusion;
    half specularOcclusion;
    
    half3 emission;

    half alpha;
};

struct InputData_Fabric
{
    float3  positionWS;
    float4  positionCS;
    
    half3   normalWS;
    half3   viewDirectionWS;

    half3   bakedGI;

    float4  shadowCoord;
    half4   shadowMask;

    half3x3 tangentToWorld;

    half    fogCoord;

#ifdef _ADDITIONAL_LIGHTS_VERTEX
	half3   vertexLighting;
#endif
};


Varyings_Fabric FabricVert(Attributes_Fabric input)
{
	Varyings_Fabric output = (Varyings_Fabric)0;

	// Instance
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);

	// Vertex
	VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
	output.positionWS = vertexInput.positionWS;
	output.positionCS = vertexInput.positionCS;

	// UV
	output.uv = input.uv;

	// Direction
	VertexNormalInputs normalInput;
	normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	float sign = input.tangentOS.w * GetOddNegativeScale();
	output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), sign);

	output.normalWS = normalInput.normalWS;
	output.viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;;

	// Indirect light
	OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
	OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

	// VertexLight And Fog
	float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	#ifdef _ADDITIONAL_LIGHTS_VERTEX
		vertexLight = VertexLighting(output.positionWS, output.normalWS);
		output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);
	#else
		output.fogFactor = fogFactor;
	#endif

	// shadow
	#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
		#if !defined(ENABLE_HQ_SHADOW) && !defined(ENABLE_HQ_AND_UNITY_SHADOW)
			output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
		#endif
	#endif

	return output;
}

SurfaceData_Fabric InitializeSurfaceData_Fabric(half2 uv, half3 emission)
{
    SurfaceData_Fabric surfaceData = (SurfaceData_Fabric)0;

    float4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv) * _BaseColor;

    half3 mask_map = SAMPLE_TEXTURE2D(_MetallicGlossMap,sampler_MetallicGlossMap,uv).rgb;
    half metallic = _Metallic * mask_map.r;
    half smoothness = mask_map.b*_Smoothness;
    half occlusion = lerp(1,mask_map.g,_OcclusionStrength);

#if defined(_FUZZMAP_ON)
    half fuzz_map = SAMPLE_TEXTURE2D(_FuzzMap,sampler_FuzzMap, uv * _FuzzMapUVScale).r;
    albedoAlpha.rgb = saturate(lerp(0,fuzz_map,_FuzzStrength).xxx + albedoAlpha.rgb) * occlusion;
#endif

    // Origin
    // surfaceData.baseColor = albedoAlpha.rgb;
    // surfaceData.specularColor = _SpecColor.rgb;
    // surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
    
    // Change To Metallic
    surfaceData.metallic = metallic;
    surfaceData.specularColor = lerp(kDieletricSpec.rrr,  albedoAlpha.rgb, surfaceData.metallic);
    surfaceData.specularColor = lerp(surfaceData.specularColor,  _SpecColor.rgb, _SpecTintStrength);
    surfaceData.baseColor =  lerp(albedoAlpha.rgb,  kDieletricSpec.rgb, surfaceData.metallic);
    
    surfaceData.alpha = albedoAlpha.a;

#if _ALPHATEST_ON
	clip(surfaceData.alpha - _Cutoff);
#endif

    surfaceData.specularOcclusion    = occlusion;
    surfaceData.perceptualSmoothness = smoothness;
    surfaceData.ambientOcclusion     = occlusion;
    surfaceData.anisotropy           = _Anisotropy;
    surfaceData.emission             = emission;

    #if !defined(_SILK_ON)
        surfaceData.perceptualSmoothness =  lerp(0.0, 0.6, smoothness);
    #else
        // Initialize the normal to something non-zero to avoid div-zero warnings for anisotropy.
        surfaceData.normalWS = float3(0, 1, 0);
    #endif
    
    #if defined(_ENABLE_GEOMETRIC_SPECULAR_AA) && !defined(SHADER_STAGE_RAY_TRACING)
        surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.tangentToWorld[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
    #endif

    return surfaceData;
}

void SG_ThreadMapDetail(float2 thread_uv, float threadAOStrength, float threadNormalStrength, float threadSmoothnessStrength, 
                        inout float3 normal, inout float smoothness, inout float ao)
{
    float4 threadMap = SAMPLE_TEXTURE2D(_ThreadMap, sampler_ThreadMap, thread_uv);

    float3 threadNormal = normalize(UnpackNormal(float4(threadMap.a, threadMap.g, 1, 1)));
    threadNormal = float3(threadNormal.rg * threadNormalStrength, lerp(1, threadNormal.b, saturate(threadNormalStrength)));

    float smoothness_adjus = Remap(threadMap.b, float2 (0, 1), float2 (-1, 1));
    smoothness_adjus = lerp(0,smoothness_adjus,threadSmoothnessStrength);
    
    normal = normalize(NormalBlend(threadNormal, normal));
    smoothness = saturate(smoothness + smoothness_adjus);
    // ao = min(ao, lerp(1, threadMap.r, threadAOStrength));
    ao = Remap((threadMap.x * 2 - 1) * threadAOStrength, float2 (-1, 1), float2 (0, 1)) * ao * 2 ;
}

InputData_Fabric InitializeInputData_Fabric(Varyings_Fabric input,half FaceSign,inout SurfaceData_Fabric surfaceData)
{
    InputData_Fabric inputData = (InputData_Fabric)0;
    inputData.positionWS = input.positionWS;

    half sgn = input.tangentWS.w;      // should be either +1 or -1
    half3 bitangentWS = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);

    inputData.tangentToWorld = half3x3(input.tangentWS.xyz, bitangentWS, input.normalWS.xyz);

    float4 normal_map = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,input.uv);
    float3 normalTS = UnpackNormal(normal_map);
    normalTS.xy *= _BumpScale;
    normalTS = normalize(normalTS);

#if defined(_THREADMAP_ON)
    SG_ThreadMapDetail(input.uv * _ThreadTilling,_ThreadAOStrength * 2,_ThreadNormalStrength,_ThreadSmoothnessScale,normalTS ,surfaceData.perceptualSmoothness,surfaceData.ambientOcclusion);
#endif

    inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld); // default Tangent Space
        
    if(FaceSign == 0)
        inputData.normalWS = -inputData.normalWS;

    inputData.normalWS = normalize(inputData.normalWS);
    inputData.viewDirectionWS = SafeNormalize(input.viewDirWS);

    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);

    #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
        #if defined(ENABLE_HQ_SHADOW) || defined(ENABLE_HQ_AND_UNITY_SHADOW) 
            inputData.shadowCoord.x = HighQualityRealtimeShadow(input.positionWS);
        #else
            inputData.shadowCoord = input.shadowCoord;
        #endif
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = input.fogFactorAndVertexLight.x;
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    #else
        inputData.fogCoord = input.fogFactor;
    #endif

    // SurfaceData Part
    surfaceData.normalWS = inputData.normalWS;
    surfaceData.geomNormalWS = inputData.tangentToWorld[2];
    surfaceData.tangentWS = input.tangentWS.xyz;

    return inputData;
}

#endif	//FABRIC_FORWARD_INCLUDE
