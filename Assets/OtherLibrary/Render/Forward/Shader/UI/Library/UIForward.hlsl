#ifndef UI_FORWARD_INCLUDE
#define UI_FORWARD_INCLUDE

#include "UIInput.hlsl"

struct Attributes_UI
{
	float4 positionOS   : POSITION;
	half4 color     : COLOR;
	float2 uv     		: TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings_UI
{
	float4 positionCS   : SV_POSITION;
	half4 color   : COLOR;
	float2 uv          : TEXCOORD0; 	
	float4 positionWS : TEXCOORD1;
	float4  mask : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//UI渲染一个像素闪烁HClip Pos处理
float4 PixelFlicker(float4 positionCS){
	#ifdef UNITY_HALF_TEXEL_OFFSET
		float hpcOX = -0.5;
		float hpcOY = 0.5;
	#else
		float hpcOX = 0;
		float hpcOY = 0;
	#endif  
	float hpcX = _ScreenParams.x * 0.5;
	float hpcY = _ScreenParams.y * 0.5;
	float pos = floor((positionCS.x / positionCS.w) * hpcX + 0.5f) + hpcOX;

	positionCS.x = pos / hpcX * positionCS.w;
	pos = floor((positionCS.y / positionCS.w) * hpcY + 0.5f) + hpcOY;
	positionCS.y = pos / hpcY * positionCS.w;
	return positionCS;
}

Varyings_UI UIVert(Attributes_UI v)
{
	Varyings_UI o;
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	float4 vPosition = TransformObjectToHClip(v.positionOS.xyz);
	o.positionWS = v.positionOS;
	o.positionCS = vPosition;

	//像素闪烁解决
	#ifdef _UI_PIXEL_FLICKER
		o.positionCS = PixelFlicker(o.positionCS);
	#endif 

	float2 pixelSize = vPosition.w;
	pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

	float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
	float2 maskUV = (v.positionOS.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
	o.uv = TRANSFORM_TEX(v.uv.xy, _MainTex);
	o.mask = float4(v.positionOS.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));
	o.color = v.color * _Color;
	return o;
}

#endif	//UI_FORWARD_INCLUDE
