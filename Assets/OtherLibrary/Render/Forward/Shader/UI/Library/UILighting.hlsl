#ifndef UI_LIGHTING_INCLUDE
#define UI_LIGHTING_INCLUDE

#include "UIForward.hlsl"

half4 UIFrag(Varyings_UI input) : SV_Target
{
    //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
    //The incoming alpha could have numerical instability, which makes it very sensible to
    //HDR color transparency blend, when it blends with the world's texture.
    const half alphaPrecision = half(0xff);
    const half invAlphaPrecision = half(1.0/alphaPrecision);
    input.color.a = round(input.color.a * alphaPrecision)*invAlphaPrecision;

    half4 color = input.color * ( SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) + _TextureSampleAdd);
    //return  color*color.a;
    #ifdef UNITY_UI_CLIP_RECT
        half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(input.mask.xy)) * input.mask.zw);
        color.a *= m.x * m.y;
    #endif

    #ifdef UNITY_UI_ALPHACLIP
        clip (color.a - 0.001);
    #endif

    #ifdef _UI_LINEAR_TO_SRGB
        color.rgb = LinearToSRGB(color.rgb);
    #endif

    color.rgb *= color.a;

    return color;
}

#endif  //UI_LIGHTING_INCLUDE
