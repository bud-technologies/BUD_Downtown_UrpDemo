#ifndef NEWRENDER_SHADOW_INCLUDE
#define NEWRENDER_SHADOW_INCLUDE

//vert output //OUTPUT_SHADOW_COORD(index0)
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    #define OUTPUT_SHADOW_COORD(index0) \
        float4 shadowCoord: TEXCOORD##index0;
#else
    #define OUTPUT_SHADOW_COORD(index0)
#endif

//vert VERT_SHADOW_COORD(output,positionCS,positionWS)
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    #if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
        #define VERT_SHADOW_COORD(output,positionCS,positionWS) \
            output.shadowCoord =  ComputeScreenPos(positionCS);
    #else
        #define VERT_SHADOW_COORD(output,positionCS,positionWS) \
            output.shadowCoord =  TransformWorldToShadowCoord(positionWS);
    #endif
#else
    #define VERT_SHADOW_COORD(output,positionCS,positionWS)
#endif

//frag FRAGMENT_GET_SHADOW_COORD(input) // input:vert output
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    #define FRAGMENT_GET_SHADOW_COORD(input,positionWS) \
        float4 shadowCoord = input.shadowCoord; \
        half4 shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    #define FRAGMENT_GET_SHADOW_COORD(input,positionWS) \
        float4 shadowCoord = TransformWorldToShadowCoord(positionWS); \
        half4 shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#else
    #define FRAGMENT_GET_SHADOW_COORD(input,positionWS) \
        float4 shadowCoord = float4(0, 0, 0, 0); \
        half4 shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
#endif

#endif // NEWRENDER_SHADOW_INCLUDE