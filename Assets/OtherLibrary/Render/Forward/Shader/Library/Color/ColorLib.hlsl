#ifndef COLOR_LIB_INCLUDE
#define COLOR_LIB_INCLUDE

half3 ACESToneMapping(half3 color, float adapted_lum)
{
    const float A = 2.51f;
    const float B = 0.03f;
    const float C = 2.43f;
    const float D = 0.59f;
    const float E = 0.14f;
    color *= adapted_lum;
    return saturate((color * (A * color + B)) / (color * (C * color + D) + E));
}

#endif // COLOR_LIB_INCLUDE















