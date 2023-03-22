#ifndef UI_INPUT_INCLUDE
#define UI_INPUT_INCLUDE

#include "../../Library/Common/CommonFunction.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _Color;
    float4 _MainTex_ST;
CBUFFER_END

float4 _ClipRect;
float _UIMaskSoftnessX;
float _UIMaskSoftnessY;
half4 _TextureSampleAdd;

TEXTURE2D_X(_MainTex);
SAMPLER(sampler_MainTex);

#endif	//STANDARD_PBRINPUT_INCLUDE
