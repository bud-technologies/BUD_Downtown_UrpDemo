#ifndef FABRIC_INPUT_INCLUDE
#define FABRIC_INPUT_INCLUDE

#include "../../Library/Common/CommonFunction.hlsl"
#include "../../Library/Surface/ShadingModel.hlsl"
#include "../../Library/Common/GlobalIllumination.hlsl"
#include "../../Library/Normal/NormalLib.hlsl"
#include "../../Library/Common/Light.hlsl"
#include "../../Library/Fog/FogLib.hlsl"

CBUFFER_START(UnityPerMaterial)

	// transparent
	float _Cutoff;

	float _Anisotropy;

	float4 _BaseMap_ST;
	float4 _BaseColor;
	float4 _SpecColor;
	half _SpecTintStrength;
	float4 _Transmission_Tint;

	float _Metallic;
	float _Smoothness;
	float _OcclusionStrength;

	float _BumpScale;

	float _ThreadAOStrength;
	float _ThreadNormalStrength;
	float _ThreadSmoothnessScale;
	float _ThreadTilling;

	float _FuzzMapUVScale;
	float _FuzzStrength;

	float4 _preIntegratedFGD_TexelSize;

	// shadow
	//��Ӱ��ɫ Ŀǰ���ⲿ�ű��趨 UpdateShadowPlane.cs
	float4 _ShadowColor;
	//��Ӱƽ��ĸ߶� Ŀǰ���ⲿ�ű��趨 UpdateShadowPlane.cs
	float _ShadowHeight;
	//XZƽ���ƫ��
	float _ShadowOffsetX;
	float _ShadowOffsetZ;

	//ģ�͸߶� ���ⲿ�ű��趨 UpdateShadowPlane.cs
	float _MeshHight;
	//ģ��λ�� ���ⲿ�ű��趨 UpdateShadowPlane.cs
	float4 _WorldPos;
	//Ӱ��͸����
	float _AlphaVal;

	int _Silk;

	float3 _ProGameOutDir;
	float _ShadowStr=1;



CBUFFER_END

TEXTURE2D(_preIntegratedFGD);
SAMPLER(sampler_preIntegratedFGD);

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);

TEXTURE2D(_MetallicGlossMap);
SAMPLER(sampler_MetallicGlossMap);

TEXTURE2D(_ThreadMap);
SAMPLER(sampler_ThreadMap);

TEXTURE2D(_FuzzMap);
SAMPLER(sampler_FuzzMap);

#endif	//FABRIC_INPUT_INCLUDE
