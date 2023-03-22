
Shader "NewRender/Particle/Default"
{	
	Properties
	{
		[Header(Blend Mode)]
		[HideInInspector]_BlendOp("__blendop", Float) = 0.0
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("混合层1 ，one one 是ADD", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DestBlend("混合层2 ，SrcAlpha    OneMinusSrcAlpha 是alphaBlend", int) = 1
		[Header(Cull Mode)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式 : Off是双面显示，否则一般用 Back", int) = 1
		[Header(ZTest Mode)]
        [Enum(LEqual, 4, Always, 8)]_ZAlways("层级显示：LEqual默认层级，Always永远在最上层", int) = 4
		[HideInInspector] _ZWrite("__zw", Float) = 1.0

		[MainTexture]_BaseMap ("Particle Texture", 2D) = "white" {}
		[MainColor][HDR] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

		[KeywordEnum(Off,On,RgbNotAlpha,RNotAlpha,GNotAlpha,BNotAlpha)] _MaskEnable("遮罩WrapMode",Int) = 0
		_MaskTex("遮罩贴图 MaskTex", 2D) = "white" {}

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "RenderPipeline" = "UniversalPipeline"}
		BlendOp[_BlendOp]
		Blend[_SrcBlend][_DestBlend]
		Cull[_Cull]
		ZTest[_ZAlways]
        ZWrite[_ZWrite]

		ColorMask RGB
		Lighting Off 
		Fog { Mode Off }
		
		LOD 100
		
		Pass
		{
			Tags {"LightMode"="UniversalForward"}
			HLSLPROGRAM
			#pragma vertex ParticleVert
			#pragma fragment ParticleFrag
			#pragma multi_compile_instancing 
            #pragma multi_compile_fog
			#pragma multi_compile _ _MASKENABLE_ON _MASKENABLE_RGBNOTALPHA _MASKENABLE_RNOTALPHA _MASKENABLE_GNOTALPHA _MASKENABLE_BNOTALPHA
			//#pragma multi_compile _ _DISSOLVE_ON
			#include "Library/ParticleLighting.hlsl"

			ENDHLSL
		}
	}

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "NewRenderShaderGUI.ParticleShaderGUI"
}
