
Shader "NewRender/Standard/PBRUber"
{
    Properties
    {
        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [NoScaleOffset][MainTexture] _BaseMap("颜色贴图", 2D) = "white" {}
        [MainColor] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

        [NoScaleOffset][Normal]_BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Range(0.0, 10)) = 1.0
        [NoScaleOffset][Normal]_BentNormalMap("Bent法线贴图",2D) = "bump" {}
        _BentBumpScale("法线强度", Range(0.0, 10)) = 1.0

        // 换遮罩
        [NoScaleOffset]_MetallicGlossMap("RGB: 金属度 AO 光滑度", 2D) = "white" {}
        _Metallic("金属度", Range(0.0, 1.0)) = 0.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0
        _SpecularOcclusionStrength("高光AO强度", Range(0, 1)) = 0

        [KeywordEnum(Off,Color,ColorMap)] AOCOLORSET("AO颜色",Int) = 0
        _OcclusionColor("AO颜色", Color) = (1,1,1,1)
        _OcclusionColorMap("AO颜色贴图", 2D) = "white" {}

        [HideInInspector]_EnergyLUT("_EnergyLUT", 2D) = "black" {}

        [MaterialToggle(_EMISSION_ON)] _Emission  ("Emission", float) = 0
        [NoScaleOffset]_EmissionMap("自发光遮罩", 2D) = "white" {}
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

        [MaterialToggle(_CLEARCOAT_ON)] _ClearCoat("ClearCoat", Float) = 0.0
        _ClearCoatMap("清漆遮罩(透明度)", 2D) = "white" {}
        _ClearCoatCubeMap("清漆反射球", Cube) = "white" {}
        _ClearCoatMask("清漆透明度", Range( 0 , 1)) = 0.8
        _ClearCoatSmoothness("清漆光滑度", Range( 0 , 1)) = 0.8
        _ClearCoatDownSmoothness("清漆底层光滑度", Range( 0 , 1)) = 0.8
        _ClearCoat_Detail_Factor("清漆 Detail 强度",Range(0 , 1))= 0

        [MaterialToggle(_DETAILMAP_ON)]_UseDetailMap("细节开启", Float) = 0
        [NoScaleOffset]_Detail_ID("细节 ID", 2D) = "white" {}

        [Space(15)]
        [IntRange]_Detail_Layer("细节层数",Range(1,4)) = 1
        
        [NoScaleOffset]_DetailMap_1("细节贴图1", 2D) = "linearGrey" {}
        _DetailMap_Tilling_1("_DetailMap_Tilling_1",Range( 1 , 200))= 60
        _DetailAlbedoScale_1("Albedo 强度", Range(0, 1)) = 0.8
        _DetailAlbedoColor_1("Albedo 颜色",Color) = (0,0,0,1)
        _DetailNormalScale_1("法线强度", Range(0, 1)) = 0.8
        _DetailSmoothnessScale_1("光滑度", Range(0, 1)) = 0.8
        [Space(15)]
        _DetailMap_2("细节贴图2", 2D) = "linearGrey" {}
        _DetailMap_Tilling_2("_DetailMap_Tilling_2",Range( 1 , 200))= 60
        _DetailAlbedoScale_2("Albedo 强度", Range(0, 1)) = 0.8
        _DetailAlbedoColor_2("Albedo 颜色",Color) = (0,0,0,1)
        _DetailNormalScale_2("法线强度", Range(0, 1)) = 0.8
        _DetailSmoothnessScale_2("光滑度", Range(0, 1)) = 0.8
        [Space(15)]
        _DetailMap_3("细节贴图3", 2D) = "linearGrey" {}
        _DetailMap_Tilling_3("_DetailMap_Tilling_3",Range( 1 , 200))= 60
        _DetailAlbedoScale_3("Albedo 强度", Range(0, 1)) = 0.8
        _DetailAlbedoColor_3("Albedo 颜色",Color) = (0,0,0,1)
        _DetailNormalScale_3("法线强度", Range(0, 1)) = 0.8
        _DetailSmoothnessScale_3("光滑度", Range(0, 1)) = 0.8
        [Space(15)]
        _DetailMap_4("细节贴图4", 2D) = "linearGrey" {}
        _DetailMap_Tilling_4("_DetailMap_Tilling_4",Range( 1 , 200))= 60
        _DetailAlbedoScale_4("Albedo 强度", Range(0, 1)) = 0.8
        _DetailAlbedoColor_4("Albedo 颜色",Color) = (0,0,0,1)
        _DetailNormalScale_4("法线强度", Range(0, 1)) = 0.8
        _DetailSmoothnessScale_4("光滑度", Range(0, 1)) = 0.8

        [MaterialToggle(_IRIDESCENCE_ON)] _UseIridescence  ("镭射开启", float) = 0
        _IridescenceMask("镭射遮罩", 2D) = "white" {}
        _Iridescence("镭射强度",Range(0, 1)) = 0
        _IridescenceThickness("镭射厚度",Range(0, 1)) = 0

        [MaterialToggle(_REFLECTION_SCREEN)] _UseReflectionScreen  ("镜面开启", float) = 0

        [KeywordEnum(Off,Shadow,And_Unity_Shadow)] ENABLE_HQ("ShadowType",Int) = 0

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        //平面阴影
        _ShadowColor("Shadow Color", Color) = (0.83,0.89,0.97,0.25)
        _ShadowHeight("Shadow Height", float) = 0
        _ShadowOffsetX("Shadow Offset X", float) = 0.0
        _ShadowOffsetZ("Shadow Offset Y", float) = 0.0

        [HideInInspector]_MeshHight("_MeshHight", float) = 0.0
	    [HideInInspector]_WorldPos("_WorldPos", vector) = (0,0,0,0)

        _ProGameOutDir("ProGameOutDir", vector) = (-1.04, 1.9, 1.61,0)
        [HideInInspector]_PlantShadowOpen("PlantShadowOpen", float) = 1

        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "UniversalForward"
            Tags{"LightMode" = "UniversalForward"}

            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]

            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _ ENABLE_HQ_SHADOW ENABLE_HQ_AND_UNITY_SHADOW
            #pragma multi_compile _ _REFLECTION_SCREEN //镜面
            #pragma shader_feature_local _ AOCOLORSET_COLOR AOCOLORSET_COLORMAP

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #define _SHADOWS_SOFT

            #pragma multi_compile_fog

            // #pragma multi_compile_instancing
            #pragma multi_compile _ LIGHTMAP_ON
            // #define MODULATE_SMOOTHNESS

            // Material Shader Feature
            #pragma shader_feature _NORMAL_ON
            #pragma shader_feature _SPECULAROCCLUSION_ON
            #pragma shader_feature _EMISSION_ON
            #pragma shader_feature _EMISSION_MAP
            #pragma shader_feature _CLEARCOAT_ON 
            #pragma shader_feature _CLEARCOATCUBEMAP_ON 
            #pragma shader_feature _DETAILMAP_ON
            #pragma shader_feature _IRIDESCENCE_ON
            #pragma shader_feature _IRIDESCENCE_MASK


            #pragma vertex PBRVert
            #pragma fragment PBRFragment
            
            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Surface/ShadingModel.hlsl"
            #include "Library/StandardPBRLighting.hlsl"

            ENDHLSL
        }

        UsePass "NewRender/Standard/BasePBR/ShadowBeforePost"
        UsePass "NewRender/Standard/BasePBR/DepthOnly"
        UsePass "NewRender/Standard/BasePBR/ShadowCaster"
        // UsePass "NewRender/Standard/BasePBR/Meta"
        // UsePass "Universal Render Pipeline/Lit/DepthNormals"

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.StandardShaderGUI"
}
