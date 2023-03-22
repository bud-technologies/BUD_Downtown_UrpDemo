#ifndef STANDARD_PBRINPUT_INCLUDE
#define STANDARD_PBRINPUT_INCLUDE

#include "../../Library/Common/CommonFunction.hlsl"
#include "../../Library/Common/CommonInput.hlsl"
#include "../../Library/Normal/NormalLib.hlsl"
#include "../../Library/Common/Light.hlsl"
#include "../../Library/Common/GlobalIllumination.hlsl"

CBUFFER_START(UnityPerMaterial)

	// transparent
	half _Cutoff;

	// PBR
	half4 _BaseColor;
	float4 _BaseMap_ST;

	half _BentBumpScale;
	half _BumpScale;
	half _Smoothness;
    half _Metallic;
    half _OcclusionStrength;
	half _SpecularOcclusionStrength;
	int AOCOLORSET;
	half3 _OcclusionColor;

	half4 _EmissionColor;

	// clear Cloat
	half _ClearCoatMask;
    half _ClearCoatSmoothness;
	half _ClearCoatDownSmoothness;
	float4 _ClearCoatCubeMap_HDR;
	half _ClearCoat_Detail_Factor;

	// detail
	float _DetailMap_Tilling_1;
	half _DetailAlbedoScale_1;
	half3 _DetailAlbedoColor_1;
	half _DetailNormalScale_1;
	half _DetailSmoothnessScale_1;

	float _DetailMap_Tilling_2;
	half _DetailAlbedoScale_2;
	half3 _DetailAlbedoColor_2;
	half _DetailNormalScale_2;
	half _DetailSmoothnessScale_2;

	float _DetailMap_Tilling_3;
	half _DetailAlbedoScale_3;
	half3 _DetailAlbedoColor_3;
	half _DetailNormalScale_3;
	half _DetailSmoothnessScale_3;

	float _DetailMap_Tilling_4;
	half _DetailAlbedoScale_4;
	half3 _DetailAlbedoColor_4;
	half _DetailNormalScale_4;
	half _DetailSmoothnessScale_4;

	// iridescence
	half _Iridescence;
    half _IridescenceThickness;

		//模型高度 由外部脚本设定 UpdateShadowPlane.cs
	float _MeshHight;
	//模型位置 由外部脚本设定 UpdateShadowPlane.cs
	float4 _WorldPos;
	//影子透明度
	half _AlphaVal;

	// shadow
	//阴影颜色 目前由外部脚本设定 UpdateShadowPlane.cs
	half4 _ShadowColor;
	//阴影平面的高度 目前由外部脚本设定 UpdateShadowPlane.cs
	float _ShadowHeight;
	//XZ平面的偏移
	float _ShadowOffsetX;
	float _ShadowOffsetZ;

	half3 _ProGameOutDir;
	half _ShadowStr=1;

CBUFFER_END

TEXTURE2D(_BaseMap);	SAMPLER(sampler_BaseMap);

TEXTURE2D(_BumpMap);
TEXTURE2D(_BentNormalMap);

TEXTURE2D(_MetallicGlossMap);
TEXTURE2D(_OcclusionColorMap);

TEXTURE2D_HALF(_EmissionMap);

TEXTURE2D_HALF(_ClearCoatMap);
TEXTURECUBE(_ClearCoatCubeMap);

TEXTURE2D_HALF(_IridescenceMask);

//detail
TEXTURE2D_HALF(_Detail_ID);
TEXTURE2D(_DetailMap_1);
TEXTURE2D(_DetailMap_2);
TEXTURE2D(_DetailMap_3);
TEXTURE2D(_DetailMap_4);

//镜面
TEXTURE2D_X(_ReflectionScreenTex);
SAMPLER(sampler_ReflectionScreenTex);

#endif	//STANDARD_PBRINPUT_INCLUDE
