#ifndef STANDARD_PBRLIGHTING_INCLUDE
#define STANDARD_PBRLIGHTING_INCLUDE

#include "StandardPBRForward.hlsl"
#include "StandardPBR.hlsl"

half4 PBRFragment(Varyings_PBR input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

    SurfaceData_PBR surfaceData;

    InitSurfaceData(input.uv.xy, surfaceData);
    
    InputData_PBR inputData;
    InitInputData(input, surfaceData, inputData);


 //   float4 emission_color = _EmissionColor;
 //   //float yyyyy = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv).r;
		
	//#if defined(_EMISSION_MAP)
	//	emission_color *= SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv).r;
	//#endif
 //   return emission_color;


    half4 color = StandardFragmentPBR(inputData,surfaceData);
    
    color.rgb = MixFogColorPBR(color.rgb,  unity_FogColor.rgb, inputData.fogCoord);

    return color;
}

#endif  //STANDARD_PBRLIGHTING_INCLUDE
