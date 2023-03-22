#ifndef COMMON_LIGHT_INCLUDE
#define COMMON_LIGHT_INCLUDE

#include "CommonInput.hlsl"

Light GetMainLight_Standard(float3 positionWS,float4 positionCS,float4 shadowCoord,float4 shadowMask)
{

#if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) && !defined(_RECEIVE_SHADOWS_OFF)
    #if defined(ENABLE_HQ_SHADOW)
        Light light = GetMainLight(float4(0,0,0,0), positionWS, shadowMask);

        #if defined(_RECEIVE_SHADOWS_OFF)
            light.shadowAttenuation = 1;
        #else
            light.shadowAttenuation = shadowCoord.x;
        #endif
        // Shadow
        return light;

    #elif defined(ENABLE_HQ_AND_UNITY_SHADOW)

        Light light = GetMainLight(shadowCoord.x);
        #if defined(_RECEIVE_SHADOWS_OFF)
            light.shadowAttenuation=1;
        #else
            light.shadowAttenuation = shadowCoord.x * light.shadowAttenuation;
        #endif
        // And_Unity_Shadow
        return light;
    #else
       
        // Off
        Light mainLight = GetMainLight(shadowCoord, positionWS,shadowMask);
        return mainLight;
    #endif
#else
    return GetMainLight();
#endif

}

#endif // COMMON_LIGHT_INCLUDE