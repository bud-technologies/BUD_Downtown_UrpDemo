#ifndef PARTICLE_LIGHTING_INCLUDE
#define PARTICLE_LIGHTING_INCLUDE

#include "ParticleForward.hlsl"

	half4 ParticleFrag(Varyings_Particle input) : SV_Target
	{
        UNITY_SETUP_INSTANCE_ID(input);

		half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);

        half4 finishColor=color*_BaseColor*input.color;

        #if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
		    half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uv.zw);
            half4 maskColor = mask;
        #endif

        #if defined(_MASKENABLE_RGBNOTALPHA)
            maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
            finishColor.a=finishColor.a*   maskColor.a;
        #elif defined(_MASKENABLE_RNOTALPHA)
            maskColor = half4(mask.r, mask.r, mask.r, mask.r);
            maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
            finishColor.a=finishColor.a*   maskColor.a;
        #elif defined(_MASKENABLE_GNOTALPHA)
            maskColor = half4(mask.g, mask.g, mask.g, mask.g);
            maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
            finishColor.a=finishColor.a*   maskColor.a;
        #elif defined(_MASKENABLE_BNOTALPHA)
            maskColor = half4(mask.b, mask.b, mask.b, mask.b);
            maskColor.a = dot(maskColor.rgb, half3(1, 1, 1)) / 1.732051;
            finishColor.a=finishColor.a*   maskColor.a;
        #endif

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
        half fogIntensity = ComputeFogIntensity(input.fogFactor);
	    finishColor.rgb = lerp(unity_FogColor.rgb, finishColor.rgb , fogIntensity);
#endif

		return finishColor;
	}

#endif	//PARTICLE_LIGHTING_INCLUDE
