#ifndef PARTICLE_INPUT_INCLUDE
#define PARTICLE_INPUT_INCLUDE

#include "../../Library/Common/CommonFunction.hlsl"

	CBUFFER_START(UnityPerMaterial)

		half4 _BaseColor;
		float4 _BaseMap_ST;
		float4 _MaskTex_ST;
		float4 _DissolveTex_ST;
		float4 _BaseMapUVSpeed;
		float _CameraDepthTextureOn;
		half _DepthFadeIndensity;
		half _DissolveOn;

	CBUFFER_END

	TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
	TEXTURE2D_X(_MaskTex); SAMPLER(sampler_MaskTex);
#endif
#if defined(_DISSOLVE_ON)
	TEXTURE2D_X(_DissolveTex); SAMPLER(sampler_DissolveTex);
#endif
	
#endif	//PARTICLE_INPUT_INCLUDE
