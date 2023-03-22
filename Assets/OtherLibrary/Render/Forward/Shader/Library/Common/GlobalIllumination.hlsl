#ifndef GLOBAL_ILLUMINATION_INCLUDE
#define GLOBAL_ILLUMINATION_INCLUDE

#include "CommonInput.hlsl"

///////// Global Illumination //////////
float3 AOMultiBounce( float3 BaseColor, float AO )
{
    float3 a =  2.0404 * BaseColor - 0.3324;
    float3 b = -4.7951 * BaseColor + 0.6417;
    float3 c =  2.7552 * BaseColor + 0.6903;
    return max( AO, ( ( AO * a + b ) * AO + c ) * AO );
}

float GetSpecularOcclusion(float NoV, float RoughnessSq, float AO)
{
    return saturate( pow( abs(NoV + AO), RoughnessSq ) - 1 + AO );
}

inline half3 RotateDirection(half3 R, half degrees)
{
    float3 reflUVW = R;
    half theta = degrees * PI / 180.0f;
    half costha = cos(theta);
    half sintha = sin(theta);
    reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
    return reflUVW;
}

// Specular Occlusion
// http://media.steampowered.com/apps/valve/2015/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf
void ModulateSmoothnessByNormal(inout float smoothness, float3 normal)
{
    float3 normalWsDdx = ddx(normal);
    float3 normalWsDdy = ddy(normal);
    float geometricRoughnessFactor = pow(saturate(max(dot(normalWsDdx, normalWsDdx), dot(normalWsDdy, normalWsDdy))), 0.333f);
    smoothness = min(smoothness, 1.0f - geometricRoughnessFactor);
}

half GetReflectionOcclusion_float(float3 normalWS, float3 tangentWS, float3 bitangentWS, float3 viewDirectionWS, float3 normalTS,
float3 bentNormalTS, float smoothness, float specularOcclusionStrength, float occlusion)
{
    float3 bentNormalWS = TransformTangentToWorld(bentNormalTS, float3x3(tangentWS, bitangentWS, normalWS));
    float3 normal = TransformTangentToWorld(normalTS, float3x3(tangentWS, bitangentWS, normalWS));
    float3 reflectVector = reflect(-viewDirectionWS, normal);

    #ifdef MODULATE_SMOOTHNESS
        ModulateSmoothnessByNormal(smoothness, normalWS);
    #endif

    float perceptualRoughness = 1 - smoothness;

    // Base signal depends on occlusion and dot product between reflection and bent normal vector
    float occlusionAmount = max(0, dot(reflectVector, bentNormalWS));
    float reflOcclusion = occlusion - (1 - occlusionAmount);
    // Scale with roughness. This is what "sharpens" glossy reflections
    reflOcclusion = saturate(reflOcclusion / perceptualRoughness);
    // Fade between roughness-modulated occlusion and "regular" occlusion based on surface roughness
    // This is done because the roughness-modulated signal doesn't represent rough surfaces very well
    reflOcclusion = lerp(reflOcclusion, lerp(occlusionAmount, 1, occlusion), perceptualRoughness);
    // Scale by color and return
    return lerp(1, reflOcclusion, specularOcclusionStrength);
}


half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
    const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
    half4 r = Roughness * c0 + c1;
    half a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
    half2 AB = half2( -1.04, 1.04 ) * a004 + r.zw;

    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
    AB.y *= saturate( 50.0 * SpecularColor.g );

    return SpecularColor * AB.x + AB.y;
}

half3 SpecularIBL(float3 R,float3 WorldPos,float Roughness,float3 SpecularColor,float NoV)
{	
    half3 SpeucularLD = GlossyEnvironmentReflection(R,WorldPos,Roughness,1.0f);
    half3 SpecularDFG = EnvBRDFApprox(SpecularColor,Roughness,NoV);
    return SpeucularLD * SpecularDFG;
}


void ClearCloatIllumination(
    TextureCube _ClearCoatCubeMap,half clearCoatRoughness,half clearCoatMask,
    float3 positionWS,half NoV_ClearCoat,float3 reflectVector_ClearCoat,
    float3 surface_specular,float surface_occlusion,
    inout float3 clearcloat_color)
{

    float specularOcclusion = GetSpecularOcclusion(NoV_ClearCoat,Pow2(clearCoatRoughness),surface_occlusion) /* * inputData.shadowCoord*/;
    float3 specularAO = AOMultiBounce(surface_specular,specularOcclusion);

    // Custom Indirect Clear Coat Cube Map
    float3 irradiance;

    #ifdef _REFLECTION_PROBE_BLENDING
        irradiance = CalculateIrradianceFromReflectionProbes(reflectVector_ClearCoat, positionWS, clearCoatRoughness);
    #else
        #ifdef _REFLECTION_PROBE_BOX_PROJECTION
            reflectVector_ClearCoat = BoxProjectedCubemapDirection(reflectVector_ClearCoat, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        #endif // _REFLECTION_PROBE_BOX_PROJECTION

        float mip = PerceptualRoughnessToMipmapLevel(clearCoatRoughness);

        #if defined(_CLEARCOATCUBEMAP_ON)
            float4 encodedIrradiance = float4(SAMPLE_TEXTURECUBE_LOD(_ClearCoatCubeMap, sampler_LinearRepeat, reflectVector_ClearCoat, mip));
        #else
            float4 encodedIrradiance = float4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector_ClearCoat, mip));
        #endif

        #if defined(UNITY_USE_NATIVE_HDR)
            irradiance = encodedIrradiance.rgb;
        #else
            #if defined(_CLEARCOATCUBEMAP_ON)
                irradiance = DecodeHDREnvironment(encodedIrradiance, _ClearCoatCubeMap_HDR);
            #else
                irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
            #endif
        #endif // UNITY_USE_NATIVE_HDR
    #endif // _REFLECTION_PROBE_BLENDING
    
    float3 clearCoatLobe = irradiance * EnvBRDFApprox(kDieletricSpec.xyz,clearCoatRoughness,NoV_ClearCoat);
    float3 IndirectClearCoat = clearCoatLobe * clearCoatMask * specularAO;

    float coatFresnel = kDieletricSpec.x + kDieletricSpec.a * Pow4(1.0 - NoV_ClearCoat);
    clearcloat_color = clearcloat_color * (1.0 - coatFresnel * clearCoatMask) + IndirectClearCoat;

}


////////////////  Anisotropic image based lighting //////////////////////
// T is the fiber axis (hair strand direction, root to tip).
float3 ComputeViewFacingNormal_SGame(float3 V, float3 T)
{
    return Orthonormalize(V, T);
}

// Fake anisotropy by distorting the normal (non-negative anisotropy values only).
// The grain direction (e.g. hair or brush direction) is assumed to be orthogonal to N.
// Anisotropic ratio (0->no isotropic; 1->full anisotropy in tangent direction)
float3 GetAnisotropicModifiedNormal_SGame(float3 grainDir, float3 N, float3 V, float anisotropy)
{
    float3 grainNormal = ComputeViewFacingNormal(V, grainDir);
    return normalize(lerp(N, grainNormal, anisotropy));
}

// For GGX aniso and IBL we have done an empirical (eye balled) approximation compare to the reference.
// We use a single fetch, and we stretch the normal to use based on various criteria.
// result are far away from the reference but better than nothing
// Anisotropic ratio (0->no isotropic; 1->full anisotropy in tangent direction) - positive use bitangentWS - negative use tangentWS
// Note: returned iblPerceptualRoughness shouldn't be use for sampling FGD texture in a pre-integration
void GetGGXAnisotropicModifiedNormalAndRoughness_SGame(float3 bitangentWS, float3 tangentWS, float3 N, float3 V, float anisotropy, float perceptualRoughness, out float3 iblN, out float iblPerceptualRoughness)
{
    // For positive anisotropy values: tangent = highlight stretch (anisotropy) direction, bitangent = grain (brush) direction.
    float3 grainDirWS = (anisotropy >= 0.0) ? bitangentWS : tangentWS;
    // Reduce stretching depends on the perceptual roughness
    float stretch = abs(anisotropy) * saturate(1.5 * sqrt(perceptualRoughness));
    // NOTE: If we follow the theory we should use the modified normal for the different calculation implying a normal (like NdotV)
    // However modified normal is just a hack. The goal is just to stretch a cubemap, no accuracy here. Let's save performance instead.
    iblN = GetAnisotropicModifiedNormal(grainDirWS, N, V, stretch);
    iblPerceptualRoughness = perceptualRoughness * saturate(1.2 - abs(anisotropy));
}


/////////// BSDF //////////////////
void EvaluateBSDF_Env(half3 diffuseColor,half3 bakedGI,half3 specularFGD,half3 iblR,half iblPerceptualRoughness,half ambientOcclusion,half specularOcclusion, 
                      out half3 bakeDiffuseLighting, out half3 specularReflected)
{
    // Note: using influenceShapeType and projectionShapeType instead of (lightData|proxyData).shapeType allow to make compiler optimization in case the type is know (like for sky)
    half3 indirectSpecular = GlossyEnvironmentReflection(iblR, iblPerceptualRoughness, specularOcclusion);
    
    bakeDiffuseLighting = bakedGI * ambientOcclusion * diffuseColor;
    specularReflected = specularFGD * indirectSpecular;
}


#endif  // GLOBAL_ILLUMINATION_INCLUDE