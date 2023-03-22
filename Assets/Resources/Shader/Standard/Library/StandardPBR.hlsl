#ifndef STANDARD_INCLUDE
#define STANDARD_INCLUDE

#include "StandardPBRData.hlsl"
#include "../../Library/Common/CommonFunction.hlsl"
#include "../../Library/Common/Light.hlsl"
#include "../../Library/Common/GlobalIllumination.hlsl"
//#include "../../Library/Common/Fog.hlsl"
#include "../../Library/Fog/FogLib.hlsl"

TEXTURE2D(_EnergyLUT);

float3 AverageFresnel(float3 r, float3 g) {
    return float3(0.087237.xxx) + 0.0230685 * g - 0.0864902 * g * g + 0.0774594 * g * g * g
           + 0.782654 * r - 0.136432 * r * r + 0.278708 * r * r * r
           + 0.19744  * g * r + 0.0360605 * g * g * r - 0.2586 * g * r * r;
}

float3 MultiScatterBRDF(half3 albedo,half roughness, half3 N,half3 V,half3 L) {

    half NdotL = saturate(dot(N,L));
    half NdotV = saturate(dot(N,V));

    half E_avg = SAMPLE_TEXTURE2D(_EnergyLUT , sampler_LinearClamp, float2(0, roughness)).x;
    half E_o   = SAMPLE_TEXTURE2D(_EnergyLUT , sampler_LinearClamp, float2(NdotL, roughness)).y;
    half E_i   = SAMPLE_TEXTURE2D(_EnergyLUT , sampler_LinearClamp, float2(NdotV, roughness)).y;

    // copper
    float3 edgetint = float3(0.827, 0.792, 0.678);
    float3 F_avg = AverageFresnel(albedo, edgetint);
    
    float3 fms = (float3(1.0.xxx) - E_o) * (float3(1.0.xxx) - E_i) / (PI * (float3(1.0.xxx) - E_avg));
    float3 F_add = F_avg * E_avg / (float3(1.0.xxx) - F_avg * (float3(1.0.xxx) - E_avg));

    // return fms;
    return F_add * fms;
}

void InitInitializeBRDFData(InputData_PBR inputData,inout SurfaceData_PBR surfaceData,out BRDFData_PBR brdfData) {

    brdfData = (BRDFData_PBR)0;

    // Unity Handle
    brdfData.perceptualRoughness = 1 - surfaceData.smoothness;
    brdfData.roughness = max(brdfData.perceptualRoughness* brdfData.perceptualRoughness, M_HALF_MIN_SQRT);
    brdfData.roughness2 = max(brdfData.roughness * brdfData.roughness, M_HALF_MIN);

    // Filament Handle
    //brdfData.perceptualRoughness = clamp(1 - surfaceData.smoothness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
    //brdfData.roughness = brdfData.perceptualRoughness * brdfData.perceptualRoughness;
    //brdfData.roughness2 = brdfData.roughness * brdfData.roughness;

    brdfData.normalizationTerm = brdfData.roughness * 4.0h + 2.0h;
    brdfData.roughness2MinusOne = brdfData.roughness2 - 1.0h;

    // Specular Occlusion
    #if defined(_SPECULAROCCLUSION_ON)
        half3 reflectVector = reflect(-inputData.viewDirWS, inputData.normalWS);
        // Base signal depends on occlusion and dot product between reflection and bent normal vector
        half occlusionAmount = max(0, dot(reflectVector, inputData.bentNormalWS));
        half reflOcclusion = surfaceData.occlusion - (1 - occlusionAmount);
        // Scale with roughness. This is what "sharpens" glossy reflections
        reflOcclusion = saturate(reflOcclusion / brdfData.perceptualRoughness);
        // Fade between roughness-modulated occlusion and "regular" occlusion based on surface roughness
        // This is done because the roughness-modulated signal doesn't represent rough surfaces very well
        reflOcclusion = lerp(reflOcclusion, lerp(occlusionAmount, 1, surfaceData.occlusion), brdfData.perceptualRoughness);
        // Scale by color and return
        half so_factor = max(lerp(1, reflOcclusion, _SpecularOcclusionStrength),0);

        surfaceData.albedo = lerp(1,pow(so_factor,_Smoothness * 2),surfaceData.metallic * surfaceData.metallic) * surfaceData.albedo;
        surfaceData.metallic = pow(so_factor,0.5) * surfaceData.metallic;
    #endif

    half oneMinusDielectricSpec = kDieletricSpec.a;
    half oneMinusReflectivity = oneMinusDielectricSpec - surfaceData.metallic * oneMinusDielectricSpec;

    brdfData.diffuse = surfaceData.albedo * oneMinusReflectivity;
    brdfData.specular = lerp(kDieletricSpec.rgb, max(0, surfaceData.albedo), surfaceData.metallic);

    // Iridescence
    #if defined(_IRIDESCENCE_ON)
        half NdotV = saturate(dot(inputData.normalWS, inputData.viewDirWS));
        half topIor = lerp(1.0f, 1.5f, surfaceData.clearCoatMask);
        half viewAngle = lerp(NdotV,sqrt(1.0 + Sq(1.0 / topIor) * (Sq(dot(inputData.normalWS, inputData.viewDirWS)) - 1.0)),surfaceData.clearCoatMask);
    
        half3 Iridescence = EvalIridescence(topIor, viewAngle, surfaceData.iridescence.y, brdfData.specular);
        brdfData.specular = lerp(brdfData.specular,Iridescence,surfaceData.iridescence.x);
    #endif


    #if defined(_CLEARCOAT_ON)
        // Unity Handle
        brdfData.clearCoatPerceptualRoughness = 1 - surfaceData.clearCoatSmoothness;
        brdfData.clearCoatRoughness = max(brdfData.clearCoatPerceptualRoughness * brdfData.clearCoatPerceptualRoughness, HALF_MIN_SQRT);
        brdfData.clearCoatRoughness2 = max(brdfData.clearCoatRoughness * brdfData.clearCoatRoughness, HALF_MIN);
    
        // Filament Handle
        // brdfData.clearCoatPerceptualRoughness = clamp(1 - surfaceData.clearCoatSmoothness, MIN_PERCEPTUAL_ROUGHNESS, 1.0);
        // brdfData.clearCoatRoughness = brdfData.clearCoatPerceptualRoughness * brdfData.clearCoatPerceptualRoughness;
        // brdfData.clearCoatRoughness2 = brdfData.clearCoatRoughness * brdfData.clearCoatRoughness;
    
        brdfData.clearCoatNormalizationTerm = brdfData.clearCoatRoughness * 4.0h + 2.0h;  
        brdfData.clearCoatRoughness2MinusOne = brdfData.clearCoatRoughness2 - 1.0h;
    #endif

    // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
        float4 shadowMask = brdfData.shadowMask;
    #elif !defined (LIGHTMAP_ON)
        float4 shadowMask = unity_ProbesOcclusion;
    #else
        float4 shadowMask = float4(1, 1, 1, 1);
    #endif
    brdfData.shadowMask = shadowMask;
}


half3 GI(BRDFData_PBR brdfData, InputData_PBR inputData, SurfaceData_PBR surfaceData)
{
    half3 reflectVector = reflect(-inputData.viewDirWS, inputData.normalWS);
    half NdotV = saturate(dot(inputData.normalWS, inputData.viewDirWS));

    #if defined(_REFLECTION_SCREEN)
        //����
        half mip = PerceptualRoughnessToMipmapLevel( brdfData.roughness);
        half4 reflectionScreenTex = SAMPLE_TEXTURE2D(_ReflectionScreenTex,sampler_ReflectionScreenTex, inputData.screenUV);
        reflectionScreenTex=lerp(reflectionScreenTex,0,mip/6.0);
        half3 reflectionGI = reflectionScreenTex.rgb * surfaceData.occlusion;
        half3 c = (inputData.bakedGI *brdfData.diffuse + reflectionGI);
    #else
        half3 gi=SpecularIBL(reflectVector,inputData.positionWS, brdfData.roughness,brdfData.specular,NdotV);
        half3 c = (inputData.bakedGI * brdfData.diffuse + gi);
    #endif


    // clearCoat
    #if defined(_CLEARCOAT_ON)

        half NoV_ClearCoat = saturate(abs(dot(inputData.clearCoatNormalWS, inputData.viewDirWS)) + 1e-5);
        half3 reflectVector_ClearCoat = reflect(-inputData.viewDirWS, inputData.clearCoatNormalWS);
        // Custom Indirect Clear Coat Cube Map
        ClearCloatIllumination(_ClearCoatCubeMap,brdfData.clearCoatRoughness,surfaceData.clearCoatMask,inputData.positionWS,NoV_ClearCoat,reflectVector_ClearCoat,
                                    surfaceData.specular,surfaceData.occlusion,c);
    #endif

    return c * surfaceData.occlusion;
}

half3 StandardPhysicallyBased(SurfaceData_PBR surfaceData,BRDFData_PBR brdfData, Light light, InputData_PBR inputData)
{
    half shadowAttenuation = light.shadowAttenuation;
    shadowAttenuation = lerp(1, shadowAttenuation,surfaceData.shadowStrenght);

    half NdotV = saturate(dot(inputData.normalWS,inputData.viewDirWS));

    half NdotL = saturate(dot(inputData.normalWS,light.direction));

    half3 radiance = light.color * (light.distanceAttenuation * shadowAttenuation * NdotL);
    // EnergyCompensation
    half3 energyCompensation = MultiScatterBRDF(surfaceData.albedo,brdfData.roughness,inputData.normalWS,inputData.viewDirWS,light.direction);

    half3 Distort_L = light.direction;

    #if defined(_CLEARCOAT_ON)
        Distort_L = normalize(light.direction + (light.direction - inputData.viewDirWS) * surfaceData.clearCoatMask);
    #endif

    half3 spec=brdfData.specular * (BRDFSpecular(inputData.normalWS, Distort_L, inputData.viewDirWS,brdfData.roughness2MinusOne,brdfData.roughness2,brdfData.normalizationTerm) + energyCompensation);
    half3 brdf = brdfData.diffuse + spec;

    // clearCoat
    #if defined(_CLEARCOAT_ON)
        // half NoV_ClearCoat = saturate(abs(dot(inputData.clearCoatNormalWS, inputData.viewDirWS)) + 1e-5);
        half3 clearCoatLighting = kDieletricSpec.r * BRDFSpecular(inputData.clearCoatNormalWS,light.direction, inputData.viewDirWS,brdfData.clearCoatRoughness2MinusOne,brdfData.clearCoatRoughness2,brdfData.clearCoatNormalizationTerm);
        half coatFresnel = kDieletricSpec.x + kDieletricSpec.a * Pow4(1.0 - NdotV);
        brdf =  brdf * (1.0 - surfaceData.clearCoatMask * coatFresnel) + clearCoatLighting * surfaceData.clearCoatMask;
    #endif

    brdf=clamp(brdf,0,16);
    return brdf * radiance;
}

half4 StandardFragmentPBR(InputData_PBR inputData, SurfaceData_PBR surfaceData)
{
    BRDFData_PBR brdfData;
    InitInitializeBRDFData(inputData,surfaceData, brdfData);

    Light mainLight = GetMainLight_Standard(inputData.positionWS,inputData.positionCS,inputData.shadowCoord,brdfData.shadowMask);

    #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
        inputData.bakedGI = SubtractDirectMainLightFromLightmap(mainLight, inputData.normalWS, inputData.bakedGI);
    #endif

    // Indirect Color
    half3 color = GI(brdfData, inputData,surfaceData);

    // Direct Color
    color += StandardPhysicallyBased(surfaceData,brdfData,mainLight, inputData);

    // Additional Color
    #ifdef _ADDITIONAL_LIGHTS
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS, brdfData.shadowMask);
            color += StandardPhysicallyBased(surfaceData,brdfData,light, inputData);
        }
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        color += inputData.vertexLighting * brdfData.diffuse;
    #endif

    #if defined(_EMISSION_ON)
        color += surfaceData.emission;
    #endif

    return half4(color, surfaceData.alpha);
}

#endif	//STANDARD_INCLUDE
