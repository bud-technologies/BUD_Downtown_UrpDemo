#ifndef BRDF_INCLUDE
#define BRDF_INCLUDE

#define MEDIUMP_FLT_MAX    65504.0
#define MEDIUMP_FLT_MIN    0.00006103515625
#define saturateMediump(x) min(x, MEDIUMP_FLT_MAX)

#ifndef kDieletricSpec
    #define kDieletricSpec  half4(0.04, 0.04, 0.04, 1.0 - 0.04)
#endif
#ifndef kSkinSpec
    #define kSkinSpec       half4(0.028, 0.028, 0.028, 1.0 - 0.028)
#endif
#ifndef kHairSpec
    #define kHairSpec       half4(0.046, 0.046, 0.046, 1.0 - 0.028)
#endif

#define M_HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats
#define M_HALF_MIN_SQRT 0.0078125  // 2^-7 == sqrt(HALF_MIN), useful for ensuring HALF_MIN after x^2

#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    // min roughness such that (MIN_PERCEPTUAL_ROUGHNESS^4) > 0 in fp16 (i.e. 2^(-14/4), rounded up)
    #define MIN_PERCEPTUAL_ROUGHNESS 0.089
    #define MIN_ROUGHNESS            0.007921
#else
    #define MIN_PERCEPTUAL_ROUGHNESS 0.045
    #define MIN_ROUGHNESS            0.002025
#endif

#include "../Math.hlsl"

//------------------------------------------------------------------------------
// Specular BRDF
//------------------------------------------------------------------------------

///////////////// Isotropy ///////////////////
half GGX_Unity(float NoH, half LoH2, half roughness2, half roughness2MinusOne, half normalizationTerm)
{    
    // Normal Distribution & Fersnel
    float d = NoH * NoH * roughness2MinusOne + 1.00001f;
    half specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);

    return specularTerm;
}

half D_GGX_Mobile(half Roughness, float NoH)
{
    // Walter et al. 2007, "Microfacet Models for Refraction through Rough Surfaces"
	float OneMinusNoHSqr = 1.0 - NoH * NoH; 
	half a = Roughness * Roughness;
	half n = NoH * a;
	half p = a / (OneMinusNoHSqr + n * n);
	half d = p * p;
	// clamp to avoid overlfow in a bright env
	return min(d, MEDIUMP_FLT_MAX);
}

// GGX / Trowbridge-Reitz
// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
float D_GGX_UE4( float a2, float NoH )
{
    float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
    return a2 / ( PI*d*d );					// 4 mul, 1 rcp
}

// Input roughness = percepturalRoughness ^ 2
half D_GGX_Fast(half roughness, half NoH, half3 N, half3 H) 
{
    half3 NxH = cross(N, H);
    half oneMinusNoHSquared = dot(NxH, NxH);
    half a = NoH * roughness;
    half k = roughness / (oneMinusNoHSquared + a * a);
    half d = k * k * (1.0 / PI);
    // return clamp(d, 0, 10);
    return saturateMediump(d);
}

// [Beckmann 1963, "The scattering of electromagnetic waves from rough surfaces"]
float D_Beckmann( float a2, float NoH )
{
	float NoH2 = NoH * NoH;
	return exp( (NoH2 - 1) / (a2 * NoH2) ) / ( PI * a2 * NoH2 * NoH2 );
}


//////////////////////// Anisotropy //////////////////////
float D_InvGGX( float a2, float NoH )
{
	float A = 4;
	float d = ( NoH - a2 * NoH ) * NoH + a2;
	return rcp( PI * (1 + A*a2) ) * ( 1 + 4 * a2*a2 / ( d*d ) );
}

float GGXAniso(float TOH, float BOH, float NOH, float roughT, float roughB)
{
     float f = TOH * TOH / (roughT * roughT) + BOH * BOH / (roughB * 
       roughB) + NOH * NOH;
      return 1.0 / (f * f * roughT * roughB);
}


//////////////////////// Fabric /////////////////////////
float D_Charlie_Unity(float NdotH, float roughness)
{
    float invR = rcp(roughness);
    float cos2h = NdotH * NdotH;
    float sin2h = 1.0 - cos2h;
    // Note: We have sin^2 so multiply by 0.5 to cancel it
    return (2.0 + invR) * PositivePow(sin2h, invR * 0.5) / 2.0 / PI;
}


// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointApprox( float a2, float NoV, float NoL )
{
    float a = sqrt(a2);
    float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
    float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
    return 0.5 * rcp( Vis_SmithV + Vis_SmithL );
}

half V_SmithGGXCorrelated_Fast(half roughness, half NoV, half NoL) 
{
    // Hammon 2017, "PBR Diffuse Lighting for GGX+Smith Microsurfaces"
    half v = 0.5 / lerp(2.0 * NoL * NoV, NoL + NoV, roughness);
    return saturateMediump(v);
}

// We use V_Ashikhmin instead of V_Charlie in practice for game due to the cost of V_Charlie
half V_Ashikhmin_Unity(half NdotL, half NdotV)
{
    // Use soft visibility term introduce in: Crafting a Next-Gen Material Pipeline for The Order : 1886
    return 1.0 / (4.0 * (NdotL + NdotV - NdotL * NdotV));
}


half3 F_Schlick_Fast(half3 f0, half VoH) 
{
    half f = Pow5(1.0 - VoH);
    return f + f0 * (1.0 - f);
}

half3 F_SchlickRoughness(half cosTheta, half3 F0, half roughness)
{
    return F0 + (max(1.0 - roughness, F0) - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}  

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float3 F_Schlick_UE4( float3 SpecularColor, float VoH )
{
    float Fc = Pow5( 1 - VoH );					// 1 sub, 3 mul
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
                
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate( 50.0 * SpecularColor.g ) * Fc + (1 - Fc) * SpecularColor;
                
}

float Fresnel_Dielectric(float3 Incoming, float3 Normal, float eta)
{
    // compute fresnel reflectance without explicitly computing
    // the refracted direction
    float c = abs(dot(Incoming, Normal));
    float g = eta * eta - 1.0 + c * c;

    if(g > 0.0)
    {
        g = sqrt(g);
        float A = (g - c) / (g + c);
        float B = (c * (g + c) - 1.0) / (c * (g - c) + 1.0);
        
        return 0.5 * A * A * (1.0 + B * B);
    }
    
    return 1.0; // TIR (no refracted component)
}


//------------------------------------------------------------------------------
// Diffuse BRDF
//------------------------------------------------------------------------------

half Fd_Lambert() {
    return 1.0 / PI;
}

float Fd_Burley(float roughness, float NoV, float NoL, float LoH) {
    // Burley 2012, "Physically-Based Shading at Disney"
    //float f90 = 0.5 + 2.0 * roughness * LoH * LoH;
    //float lightScatter = F_Schlick(1.0, f90, NoL);
    //float viewScatter  = F_Schlick(1.0, f90, NoV);
    //return lightScatter * viewScatter * (1.0 / PI);
    return 1;
}

half Fd_Fabric(half roughness)
{
    return lerp(1.0, 0.5, roughness) / PI;
}
//------------------------------------------------------------------------------
// Other BRDF
//------------------------------------------------------------------------------

half3 LightRim2(half3 N, half3 V, half4 rimColor)
{
    half NoV = saturate(dot(N, V));
    return pow(1.0 - NoV, 0.5) * rimColor.rgb * rimColor.a;
}


float3 EnvDFGLazarov( float3 specularColor, float gloss, float ndotv )
{
    float4 p0 = float4( 0.5745, 1.548, -0.02397, 1.301 );
    float4 p1 = float4( 0.5753, -0.2511, -0.02066, 0.4755 );
    float4 t = gloss * p0 + p1;
    float bias = saturate( t.x * min( t.y, exp2( -7.672 * ndotv ) ) + t.z );
    float delta = saturate( t.w );
    float scale = delta - bias;
    bias *= saturate( 50.0 * specularColor.y );
    return specularColor * scale + bias;
}

float2 Hammersley(uint i, float numSamples) 
{
    uint bits = i;
    bits = (bits << 16) | (bits >> 16);
    bits = ((bits & 0x55555555) << 1) | ((bits & 0xAAAAAAAA) >> 1);
    bits = ((bits & 0x33333333) << 2) | ((bits & 0xCCCCCCCC) >> 2);
    bits = ((bits & 0x0F0F0F0F) << 4) | ((bits & 0xF0F0F0F0) >> 4);
    bits = ((bits & 0x00FF00FF) << 8) | ((bits & 0xFF00FF00) >> 8);
    return float2(i / numSamples, bits / exp2(32));
}

float3 ImportanceSampleGGX(float2 Xi, float3 N, float roughness)
{
    float a = roughness*roughness;

    float phi = 2.0 * PI * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
    float sinTheta = sqrt(1.0 - cosTheta*cosTheta);

    // from spherical coordinates to cartesian coordinates
    float3 H;
    H.x = cos(phi) * sinTheta;
    H.y = sin(phi) * sinTheta;
    H.z = cosTheta;

    // from tangent-space floattor to world-space sample floattor
    float3 up        = abs(N.z) < 0.999 ? float3(0.0, 0.0, 1.0) : float3(1.0, 0.0, 0.0);
    float3 tangent   = normalize(cross(up, N));
    float3 bitangent = cross(N, tangent);

    float3 samplefloat = tangent * H.x + bitangent * H.y + N * H.z;
    return normalize(samplefloat);
}

#endif // BRDF_INCLUDE