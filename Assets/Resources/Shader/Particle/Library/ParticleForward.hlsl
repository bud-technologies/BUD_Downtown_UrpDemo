#ifndef PARTICLE_FORWARD_INCLUDE
#define PARTICLE_FORWARD_INCLUDE

#include "ParticleInput.hlsl"

struct Attributes_Particle
{
	float4 positionOS   : POSITION;
	float3 normalOS     : NORMAL;
	float4 color : COLOR;
	float4 uv     		: TEXCOORD0; //zw MainTex特效uv
	float4 animData     		: TEXCOORD1; //zw MaskTex特效uv
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings_Particle
{
	float4 positionCS   : SV_POSITION;
	#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
		float4 uv           : TEXCOORD0; 	
	#else
		float2 uv           : TEXCOORD0; 	
	#endif
	float4 color : COLOR;

	half3 normalWS      : TEXCOORD1;

#if defined(VARYINGS_VIEWDIR_WS)
	half3 viewDirWS     : TEXCOORD2;
#endif

#if defined(VARYINGS_SCREEN_POS_UV)
	float3 screenUV		: TEXCOORD3;
#endif

#if defined(VARYINGS_DISSOLVE_UV)
	float2 uv1           : TEXCOORD4; 	
#endif

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    half  fogFactor : TEXCOORD5;
#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

Varyings_Particle ParticleVert(Attributes_Particle input){
	Varyings_Particle output = (Varyings_Particle)0;

	// Instance
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

	// UV
	#if defined(_MASKENABLE_ON)	|| defined(_MASKENABLE_RGBNOTALPHA) || defined(_MASKENABLE_RNOTALPHA) || defined(_MASKENABLE_GNOTALPHA) || defined(_MASKENABLE_BNOTALPHA)
		output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw+input.uv.zw;
		output.uv.zw = input.uv.xy*_MaskTex_ST.xy+_MaskTex_ST.zw+input.animData.zw;
	#else
		output.uv.xy = input.uv.xy*_BaseMap_ST.xy+_BaseMap_ST.zw+input.uv.zw;
	#endif

	#if defined(VARYINGS_DISSOLVE_UV)	
		output.uv1.xy = input.uv.xy*_DissolveTex_ST.xy+_DissolveTex_ST.zw+input.uv.zw;
	#endif

#if defined(VARYINGS_VIEWDIR_WS)
    float3 positionWS=TransformObjectToWorld(input.positionOS.xyz);
	output.positionCS=TransformWorldToHClip(positionWS);
	// View
    half3 viewDirWS = (GetCameraPositionWS() - positionWS);
	output.viewDirWS = viewDirWS;
#else
	output.positionCS=TransformObjectToHClip(input.positionOS.xyz);
#endif

#if defined(VARYINGS_SCREEN_POS_UV)
	float4 projPos = ComputeScreenPos (output.positionCS);
	output.screenUV=projPos.xyz/projPos.w;
#endif

	// Normal
	output.normalWS = TransformObjectToWorldNormal(input.normalOS);

	// Fog
#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
#endif
	//Color
	output.color = input.color;
	
	return output;
}

#endif	//PARTICLE_FORWARD_INCLUDE
