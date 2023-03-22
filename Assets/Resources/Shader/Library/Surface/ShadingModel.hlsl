#ifndef SHADING_MOEDEL_INCLUDE
#define SHADING_MOEDEL_INCLUDE
            
#include "BRDF.hlsl"

half BRDFSpecular(half3 N, half3 L, half3 V,half roughness2MinusOne,half roughness2,half normalizationTerm)
{
    float3 H = SafeNormalize(float3(L) + float3(V));

    half NoV = saturate(dot(N, V));
    half NoL = dot(N, L);
    float NoH = saturate(dot(N, H));
    float LoH = saturate(dot(L, H));
    float LoH2 = LoH * LoH;

    half specularTerm = GGX_Unity(NoH,LoH2,roughness2,roughness2MinusOne,normalizationTerm);
   
    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specularTerm = specularTerm - M_HALF_MIN;
        specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    // specularTerm = clamp(specularTerm, 0, 8);

    return specularTerm;
}

//SecondLobeRoughnessDerivation 0-1 
//SpecularLobeInterpolation 0-1
half BRDFSpecularWithTwoLobes
(
    half3 N, half3 L, half3 V,
    half SecondLobeRoughnessDerivation,half SpecularLobeInterpolation,
    half roughness,half roughness2MinusOne,half roughness2,half normalizationTerm
)
{
    float3 H = SafeNormalize(float3(L) + float3(V));

    float NoH = saturate(dot(N, H));
    float LoH = saturate(dot(L, H));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.

    float secondRoughness = roughness * (1 + SecondLobeRoughnessDerivation);
    float secondRoughness2MinusOne = secondRoughness * secondRoughness - 1;

    float d = NoH * NoH * roughness2MinusOne + 1.00001f;
    float d2 = NoH * NoH * secondRoughness2MinusOne + 1.00001f;

    half normalizationTerm2 = secondRoughness * 4.0 + 2.0;

    half LoH2 = LoH * LoH;
    half specularTerm1 = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);
    half specularTerm2 = (secondRoughness * secondRoughness) / ((d2 * d2) * max(0.1h, LoH2) * normalizationTerm2);

    //half specularTerm = lerp(specularTerm1, specularTerm2, SpecularLobeInterpolation);
    half specularTerm = specularTerm2+ specularTerm1* SpecularLobeInterpolation;

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specularTerm = specularTerm - HALF_MIN;
        specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    specularTerm = clamp(specularTerm, 0, 8);

    return specularTerm;
}

float3 ClearCoatGGX( float ClearCoat,float Roughness, float3 N,float3 V, float3 L,out float3 EnergyLoss)
{
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N,H));
    float NoV = saturate(abs(dot(N,V)) + 1e-5);
    float NoL = saturate(dot(N,L));
    float VoH = saturate(dot(V,H));

    float a2 = Pow4( Roughness );
    
    // Generalized microfacet specular
    float D = D_GGX_UE4( a2, NoH );
    float Vis = Vis_SmithJointApprox( a2, NoV, NoL );
    float3 F = F_Schlick_UE4( float3(0.04,0.04,0.04), VoH ) * ClearCoat;
    EnergyLoss = F;

    return (D * Vis) * F;
}


#endif // SHADING_MOEDEL_INCLUDE