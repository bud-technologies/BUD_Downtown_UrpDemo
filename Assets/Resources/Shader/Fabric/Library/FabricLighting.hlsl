#ifndef FABRIC_LIGHTING_INCLUDE
#define FABRIC_LIGHTING_INCLUDE

#include "FabricForward.hlsl"
#include "FabricFunction.hlsl"

struct BSDFData_Fabric
{
    half3 diffuseColor;
    half3 fresnel0;
    half  ambientOcclusion;
    half  specularOcclusion;
    half3 normalWS;
    half3 geomNormalWS;
    half  perceptualRoughness;
    half3 transmittance;
    half3 tangentWS;
    half3 bitangentWS;
    half  roughnessT;
    half  roughnessB;
    half  anisotropy;
};

struct PreLightData_Fabric
{
    half NdotV;        // Could be negative due to normal mapping, use ClampNdotV()
    half partLambdaV;

    // IBL
    half3 iblR;                     // Reflected specular direction, used for IBL in EvaluateBSDF_Env()
    half  iblPerceptualRoughness;

    half3 specularFGD;              // Store preintegrated BSDF for both specular and diffuse
    half  diffuseFGD;
};

PreLightData_Fabric GetPreLightData_Fabric(InputData_Fabric inputData, UnityTexture2D FGD, inout BSDFData_Fabric bsdfData)
{
    PreLightData_Fabric preLightData = (PreLightData_Fabric)0;

    half3 V = inputData.viewDirectionWS;
    half3 N = bsdfData.normalWS;
    preLightData.NdotV = dot(N, V);
    preLightData.iblPerceptualRoughness = bsdfData.perceptualRoughness;

    half NdotV = ClampNdotV(preLightData.NdotV);

    half reflectivity;// unused
    half3 iblN;
    
    // Reminder: This is a static if resolve at compile time
    #if defined(_SILK_ON) // Silk
    {
        GetPreIntegratedFGDGGXAndDisneyDiffuse(FGD, NdotV, preLightData.iblPerceptualRoughness, bsdfData.fresnel0, preLightData.specularFGD, preLightData.diffuseFGD, reflectivity);

        half TdotV = dot(bsdfData.tangentWS, V);
        half BdotV = dot(bsdfData.bitangentWS, V);

        preLightData.partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, NdotV, bsdfData.roughnessT, bsdfData.roughnessB);

        // perceptualRoughness is use as input and output here
        GetGGXAnisotropicModifiedNormalAndRoughness_SGame(bsdfData.bitangentWS, bsdfData.tangentWS, N, V, bsdfData.anisotropy, preLightData.iblPerceptualRoughness, iblN, preLightData.iblPerceptualRoughness);

    }
    #else //Cotton Wool
        preLightData.partLambdaV = 0.0;
        iblN = N;

        GetPreIntegratedFGDCharlieAndFabricLambert(FGD, NdotV, preLightData.iblPerceptualRoughness, bsdfData.fresnel0, preLightData.specularFGD, preLightData.diffuseFGD, reflectivity);
    #endif
    
    preLightData.iblR = reflect(-V, iblN);

    return preLightData;
}

real Fabric_DV_SmithJointGGXAniso(real TdotH, real BdotH, real NdotH, real NdotV,
                           real TdotL, real BdotL, real NdotL,
                           real roughnessT, real roughnessB, real partLambdaV)
{
    real a2 = roughnessT * roughnessB;
    real3 v = real3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
    real  s = dot(v, v);

    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * length(real3(roughnessT * TdotL, roughnessB * BdotL, NdotL));

    real2 D = real2(a2 * a2 * a2, s * s);  // Fraction without the multiplier (1/Pi)
    real2 G = real2(1, lambdaV + lambdaL); // Fraction without the multiplier (1/2)

    // This function is only used for direct lighting.
    // If roughness is 0, the probability of hitting a punctual or directional light is also 0.
    // Therefore, we return 0. The most efficient way to do it is with a max().
    return (INV_PI * 0.5) * (D.x * G.x) / (max(D.y * G.y, REAL_MIN)+0.0005);
}

// float3 diffR; // Diffuse  reflection   (T -> MS -> T, same sides)
// float3 specR; // Specular reflection   (R, RR, TRT, etc)
// float3 diffT; // Diffuse  transmission (rough T or TT, opposite sides)
// float3 specT; // Specular transmission (T, TT, TRRT, etc)

void FabricLighting(BSDFData_Fabric bsdfData , InputData_Fabric inputData, Light light, PreLightData_Fabric preLightData, out half3 diffuse, out half3 specular)
{

    half3 L = light.direction;
    half3 V = inputData.viewDirectionWS;
    half3 N = bsdfData.normalWS;

    half3 lightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
   
   // -----------------------
    half NdotV = preLightData.NdotV;
    half NdotL = dot(N, L);
    half clampedNdotV = ClampNdotV(NdotV);
    half clampedNdotL = saturate(NdotL);
    half flippedNdotL = ComputeWrappedDiffuseLighting(-NdotL, TRANSMISSION_WRAP_LIGHT);

    half LdotV, NdotH, LdotH, invLenLV;
    GetBSDFAngle(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

    half  diffTerm;
    half3 specTerm;

#if !defined(_SILK_ON)
    half D = D_Charlie_Unity(NdotH, bsdfData.roughnessT);

    // V_Charlie is expensive, use approx with V_Ashikhmin instead
    // float Vis = V_Charlie(NdotL, clampedNdotV, bsdfData.roughness);
    half Vis = V_Ashikhmin_Unity(NdotL, clampedNdotV);

    // Fabric are dieletric but we simulate forward scattering effect with colored specular (fuzz tint term)
    // We don't use Fresnel term for CharlieD
    half3 F = bsdfData.fresnel0;

    specTerm = F * Vis * D;

    // diffTerm = Fd_Fabric(bsdfData.roughnessT) ; // FabricLambert Orginal HDRP code
    diffTerm = FabricLambertNoPI(bsdfData.roughnessT) ; //hack : No INV_PI for URP to match the HDRP result
    
#else // MATERIALFEATUREFLAGS_FABRIC_SILK
    // For silk we just use a tinted anisotropy
    half3 H = (L + V) * invLenLV;

    // For anisotropy we must not saturate these values
    half TdotH = dot(bsdfData.tangentWS, H);
    half TdotL = dot(bsdfData.tangentWS, L);
    half BdotH = dot(bsdfData.bitangentWS, H);
    half BdotL = dot(bsdfData.bitangentWS, L);

    // TODO: Do comparison between this correct version and the one from isotropic and see if there is any visual difference
    // We use abs(NdotL) to handle the none case of double sided
    half DV = Fabric_DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, clampedNdotV, TdotL, BdotL, abs(NdotL),bsdfData.roughnessT, bsdfData.roughnessB, preLightData.partLambdaV);

    // Fabric are dieletric but we simulate forward scattering effect with colored specular (fuzz tint term)
    half3 F = F_Schlick(bsdfData.fresnel0, LdotH);

    specTerm = F * DV;

    // hack: we increase the specular for silk in URP to match HDRP result
    specTerm *= PI;
    
    // Use abs NdotL to evaluate diffuse term also for transmission
    // TODO: See with Evgenii about the clampedNdotV here. This is what we use before the refactor
    // but now maybe we want to revisit it for transmission

    // diffTerm = DisneyDiffuse(clampedNdotV, abs(NdotL), LdotV, bsdfData.perceptualRoughness); // Orginal HDRP code

    // Burt:We don't need DisneyDiffuse,Lambert is already enough for phone
    // diffTerm = DisneyDiffuseNoPI(clampedNdotV, abs(NdotL), LdotV, bsdfData.perceptualRoughness); //hack : No INV_PI for URP to match the HDRP result
    diffTerm = Fd_Lambert() * PI;

#endif
    
    // The compiler should optimize these. Can revisit later if necessary.
    float3 diffR = diffTerm * clampedNdotL;
    float3 diffT = diffTerm * flippedNdotL;

    // Probably worth branching here for perf reasons.
    // This branch will be optimized away if there's no transmission (as NdotL > 0 is tested in IsNonZeroBSDF())
    // And we hope the compile will move specTerm in the branch in case of transmission (TODO: verify as we fabric this may not be true as we already have branch above...)
    // specR = bsdfData.bitangentWS;
    float3 specR = 0;
    if (NdotL > 0)
    {
        specR = specTerm * clampedNdotL;
    }
    // -----------------------
    
    half3 transmittance = bsdfData.transmittance;

    // If transmittance or the CBSDF_SGame's transmission components are known to be 0,
    // the optimization pass of the compiler will remove all of the associated code.
    // However, this will take a lot more CPU time than doing the same thing using
    // the preprocessor.
    diffuse  = (diffR + diffT * transmittance) * lightColor * bsdfData.diffuseColor;
    specular = specR  * lightColor;
}

BSDFData_Fabric InitInitializeBSDFData_Fabric(SurfaceData_Fabric surfaceData, half3 bitangentWS, half3 transmittance)
{
    BSDFData_Fabric bsdfData = (BSDFData_Fabric)0;

    // IMPORTANT: All enable flags are statically know at compile time, so the compiler can do compile time optimization
    bsdfData.diffuseColor = surfaceData.baseColor;

    bsdfData.normalWS = surfaceData.normalWS;
    bsdfData.tangentWS  = surfaceData.tangentWS;
    bsdfData.bitangentWS = bitangentWS;
    bsdfData.geomNormalWS = surfaceData.geomNormalWS;

    bsdfData.specularOcclusion = surfaceData.specularOcclusion;
    bsdfData.ambientOcclusion = surfaceData.ambientOcclusion;

    bsdfData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness);
    
    #if !defined(_SILK_ON)
        bsdfData.anisotropy = 0;
    #else
        bsdfData.anisotropy = surfaceData.anisotropy;
    #endif

    bsdfData.transmittance = transmittance;

    // In forward everything is statically know and we could theorically cumulate all the material features. So the code reflect it.
    // However in practice we keep parity between deferred and forward, so we should constrain the various features.
    // The UI is in charge of setuping the constrain, not the code. So if users is forward only and want unleash power, it is easy to unleash by some UI change

    // After the fill material SSS data has operated, in the case of the fabric we force the value of the fresnel0 term
    bsdfData.fresnel0 = surfaceData.specularColor;

    // roughnessT and roughnessB are clamped, and are meant to be used with punctual and directional lights.
    // perceptualRoughness is not clamped, and is meant to be used for IBL.
    // perceptualRoughness can be modify by FillMaterialClearCoatData, so ConvertAnisotropyToClampRoughness must be call after
    ConvertAnisotropyToClampRoughness(bsdfData.perceptualRoughness, bsdfData.anisotropy, bsdfData.roughnessT, bsdfData.roughnessB);

    return bsdfData;
}

half4 LFragmentFabric(SurfaceData_Fabric fabricSurfaceData, InputData_Fabric inputData)
{
    BSDFData_Fabric bsdfData = InitInitializeBSDFData_Fabric(fabricSurfaceData, inputData.tangentToWorld[1].xyz, _Transmission_Tint.xyz);

    PreLightData_Fabric preLightData = GetPreLightData_Fabric(inputData, UnityBuildTexture2DStructNoScale(_preIntegratedFGD), bsdfData);

    #if !defined (LIGHTMAP_ON)
        half4 shadowMask = unity_ProbesOcclusion;
    #else
        half4 shadowMask = half4(1, 1, 1, 1);
    #endif

    Light mainLight = GetMainLight_Standard(inputData.positionWS,inputData.positionCS,inputData.shadowCoord,shadowMask);
    
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    // Direct Color
    half3 diffuse = 0, specular = 0;
    FabricLighting(bsdfData, inputData, mainLight, preLightData, diffuse, specular);
    specular=clamp(specular,0,20);
    half3 directColor = bsdfData.diffuseColor * diffuse + specular;

    // Additional Color
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
        half3 addDiffuse = 0, addSpecular = 0 ;
        FabricLighting(bsdfData, inputData, light, preLightData, addDiffuse, addSpecular);
        directColor += addDiffuse + addSpecular;
    }
#endif

    // Indirect Color
    half3 indirectDiffuse = 0, indirectSpecular = 0;
    EvaluateBSDF_Env(bsdfData.diffuseColor,inputData.bakedGI,preLightData.specularFGD,preLightData.iblR,preLightData.iblPerceptualRoughness,bsdfData.ambientOcclusion,
                        fabricSurfaceData.specularOcclusion,indirectDiffuse,indirectSpecular);

    half3 indirectColor = indirectDiffuse + indirectSpecular;

    // Emission Color
    float3 emission = fabricSurfaceData.emission;
    
    half3 color = directColor + indirectColor + emission;

    return half4(color,fabricSurfaceData.alpha);
}

float4 FabricFragment(Varyings_Fabric input, half facing : VFACE):SV_TARGET
{
    SurfaceData_Fabric fabricSurfaceData = InitializeSurfaceData_Fabric(input.uv, 0 /* emission */);

    InputData_Fabric inputData = InitializeInputData_Fabric(input, max(facing,0),fabricSurfaceData);

    half4 color = LFragmentFabric(fabricSurfaceData,inputData);
     color.rgb = MixFogColorPBR(color.rgb,  unity_FogColor.rgb, inputData.fogCoord);
    return color;
}

#endif  //FABRIC_LIGHTING_INCLUDE
