#ifndef FOG_LIB_INCLUDE
#define FOG_LIB_INCLUDE

//need #pragma multi_compile_fog

//vert output
#ifdef _ADDITIONAL_LIGHTS_VERTEX
	#define OUTPUT_FOG_VERTEX_LIGHT(index0) \
		half4 fogFactorAndVertexLight : TEXCOORD##index0;
#else
	#define OUTPUT_FOG_VERTEX_LIGHT(index0) \
		half  fogFactor : TEXCOORD##index0;
#endif

//vert fun
#ifdef _ADDITIONAL_LIGHTS_VERTEX
	#define VERT_FOG_VERTEX_LIGHT(output,positionCS,normalWS) \
		half fogFactor = ComputeFogFactor(positionCS.z);\
		half3 vertexLight = VertexLighting(positionWS, normalWS);\
		output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#else
	#define VERT_FOG_VERTEX_LIGHT(output,positionCS,normalWS) \
		half fogFactor = ComputeFogFactor(positionCS.z);\
		output.fogFactor = fogFactor;
#endif

//frag //FRAGMENT_GET_FOG_VERTEX_LIGHT(input,positionWS) input:vert output
#ifdef _ADDITIONAL_LIGHTS_VERTEX
	#define FRAGMENT_GET_FOG_VERTEX_LIGHT(input,positionWS) \
		half fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactorAndVertexLight.x); \
		half3 vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
	#define FRAGMENT_GET_FOG_VERTEX_LIGHT(input,positionWS) \
		half fogCoord = InitializeInputDataFog(float4(positionWS, 1.0), input.fogFactor); \
		half3 vertexLighting = half3(0,0,0);
#endif

//frag mix //FRAGMENT_FOG_MIX(inputColor,fogCoord)
#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
	#define FRAGMENT_FOG_MIX(inputColor,fogCoord) \
		half3 fogMixColor = MixFog(inputColor.rgb, fogCoord);
#else
	#define FRAGMENT_FOG_MIX(inputColor,fogCoord) \
		half3 fogMixColor = inputColor.rgb;
#endif

half3 MixFogColorPBR(half3 fragColor, half3 fogColor, half fogFactor)
{
	#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
		half fogIntensity = ComputeFogIntensity(fogFactor);
		fragColor = lerp(fogColor, fragColor, fogIntensity);
	#endif
    return fragColor;
}

#endif // FOG_LIB_INCLUDE















