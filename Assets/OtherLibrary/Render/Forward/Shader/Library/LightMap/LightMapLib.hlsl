#ifndef LIGHTMAP_LIB_INCLUDE
#define LIGHTMAP_LIB_INCLUDE

#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
#endif

//vert input
#define INPUT_ATTRIBUTES_LIGHTMAP  \
	float4 lightmapUV : TEXCOORD1; \
	float4 staticLightmapUV : TEXCOORD2;

//vert output // OUTPUT_VARYINGS_LIGHTMAP(index0)

#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
    #define OUTPUT_VARYINGS_LIGHTMAP(index0) \
        float4 lightmapUV: TEXCOORD##index0;
#else
    #if defined(LIGHTMAP_ON)
        #if defined(DYNAMICLIGHTMAP_ON)
            #define OUTPUT_VARYINGS_LIGHTMAP(index0) \
                float4 lightmapUV: TEXCOORD##index0;
        #else
            #define OUTPUT_VARYINGS_LIGHTMAP(index0) \
                float2 lightmapUV: TEXCOORD##index0;
        #endif
    #else
        #if defined(DYNAMICLIGHTMAP_ON)
            #define OUTPUT_VARYINGS_LIGHTMAP(index0) \
                float2 lightmapUV: TEXCOORD##index0;
        #else
            #define OUTPUT_VARYINGS_LIGHTMAP(index0) \
                float3 sh: TEXCOORD##index0;
        #endif
    #endif
#endif

//vert // LIGHTMAP_VERT(input,output) //input:顶点数据
#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
    #define LIGHTMAP_VERT(input,output) \
        output.lightmapUV.zw = input.uv0.xy; \
        output.lightmapUV.xy = input.uv0.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#else
    #if defined(LIGHTMAP_ON)
        #if defined(DYNAMICLIGHTMAP_ON)
            #define LIGHTMAP_VERT(input,output) \
                float2 staticLightmapUV; \
                OUTPUT_LIGHTMAP_UV(input.uv1, unity_LightmapST, staticLightmapUV); \
                output.lightmapUV.xy=staticLightmapUV; \
                output.lightmapUV.zw = input.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
        #else
            #define LIGHTMAP_VERT(input,output) \
                float2 staticLightmapUV; \
                OUTPUT_LIGHTMAP_UV(input.uv1, unity_LightmapST, staticLightmapUV); \
                output.lightmapUV.xy=staticLightmapUV;
        #endif
    #else
        #if defined(DYNAMICLIGHTMAP_ON)
            #define LIGHTMAP_VERT(input,output) \
                output.lightmapUV.xy = input.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
        #else
            #define LIGHTMAP_VERT(input,output) \
                OUTPUT_SH(output.normalWS.xyz, output.sh);
        #endif
    #endif
#endif

//frag GI //GET_BACK_GI(input,normalWS)  //input:顶点阶段输出数据
#if defined(LIGHTMAP_ON)
    #if defined(DYNAMICLIGHTMAP_ON)
        #define GET_BACK_GI(input,normalWS) \
            half3 bakedGI = SampleLightmap(input.lightmapUV.xy, input.lightmapUV.zw, normalWS);
    #else
        #define GET_BACK_GI(input,normalWS) \
            half3 bakedGI = SampleLightmap(input.lightmapUV.xy, 0, normalWS);
    #endif
#else
    #if defined(DYNAMICLIGHTMAP_ON)
        #define GET_BACK_GI(input,normalWS) \
            half3 bakedGI =  SampleLightmap(0, input.lightmapUV.xy, normalWS);
    #else
        #if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
            #define GET_BACK_GI(input,normalWS) \
                float3 TRSH = SampleSH(normalWS.xyz); \
                //float3 TRSH = 0; \
                half3 bakedGI = SampleSHPixel(TRSH, normalWS);
        #else
            #define GET_BACK_GI(input,normalWS) \
                half3 bakedGI = SampleSHPixel(input.sh, normalWS);
        #endif
    #endif
#endif

#endif // LIGHTMAP_LIB_INCLUDE















