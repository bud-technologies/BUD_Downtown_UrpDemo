#ifndef COMMON_INPUT_INCLUDE
#define COMMON_INPUT_INCLUDE

// Unity Include
// #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl" 

// SGame Include
#include "../../Library/Math.hlsl"

//Background
//Geometry
//AlphaTest
//Transparent
//Overlay

SamplerState sampler_LinearClamp; //Filter	下拉选单	Linear、Point、Trilinear	定义采样的过滤模式。
SamplerState sampler_LinearRepeat; //Wrap	下拉选单	Repeat、Clamp、Mirror、MirrorOnce	定义采样的包裹模式。
#define L_PI 3.14159265359
#define L_PI_HALF 1.56079326759
#define L_PI2 6.28318530718

half Alpha(half albedoAlpha, half4 color, half cutoff)
{
   #if !defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A) && !defined(_GLOSSINESS_FROM_BASE_ALPHA)
       half alpha = albedoAlpha * color.a;
   #else
       half alpha = color.a;
   #endif

   #if defined(_ALPHATEST_ON)
       clip(alpha - cutoff);
   #endif
   return alpha;
}

half4 SampleAlbedoAlpha(half2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
{
   return SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_LinearClamp, uv);
}

half3 SampleNormal(half2 uv, half scale, TEXTURE2D_PARAM(normalMap, sampler_BumpMap))
{
   #ifdef _NORMAL_ON
       half4 n = SAMPLE_TEXTURE2D(normalMap, sampler_LinearClamp, uv);
       return UnpackNormalScale(n, scale);
   #else
       return half3(0.0h, 0.0h, 1.0h);
   #endif
}


#endif // COMMON_INPUT_INCLUDE