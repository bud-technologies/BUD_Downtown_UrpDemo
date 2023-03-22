#ifndef COMMON_POSITION_INCLUDE
#define COMMON_POSITION_INCLUDE

//frag //FRAGMENT_GET_WORLD_POSITION
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define FRAGMENT_GET_WORLD_POSITION(input) \
        float3 positionWS = float3(input.normalWS.w,input.tangentWS.w,input.bitangentWS.w);
#else
    #define FRAGMENT_GET_WORLD_POSITION(input) \
        float3 positionWS = input.positionWS;
#endif

#endif // COMMON_POSITION_INCLUDE