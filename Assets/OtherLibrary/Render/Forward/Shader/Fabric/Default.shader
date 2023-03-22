Shader "NewRender/Fabric/Default"
{
    Properties
    {
        [MainTexture]_BaseMap("Base Color Map", 2D) = "white" {}
        [MainColor]_BaseColor("BaseColor", Color) = (0.63, 0.58, 0.44, 1)

        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [MaterialToggle(_SILK_ON)] _Silk  ("Silk", int) = 0

        _SilkDefault("SilkDefault", float) = 0
        _WoolDefault("WoolDefault", float) = 0

        _Anisotropy("Anisotropy", Range(-1, 1)) = -0.65

        _SpecColor("SpecColor", Color) = (0.87, 0.8, 0.6117, 1)
        _SpecTintStrength("SpecTintStrength",Range(0, 1)) = 0

        _Transmission_Tint("Transmission Tint", Color) = (0, 0, 0, 0)
        
        [Normal][NoScaleOffset]_BumpMap("Bump Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Range(0, 4)) = 1

        [NoScaleOffset]_MetallicGlossMap("R: 金属度 G:AO B:光滑度 ", 2D) = "white" {}
        _Metallic("金属度", Range(0, 1)) = 0.2
        _Smoothness("光滑度", Range(0, 1)) = 0.2
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0

        [MaterialToggle(_THREADMAP_ON)]_UseThreadMap("细节开启", Float) = 1
        _ThreadMap("Thread Map", 2D) = "white" {}
        _ThreadTilling("Thread Tilling",Range( 1 , 200))= 100
        _ThreadAOStrength("Thread AO Strength", Range(0, 1)) = 0.5
        _ThreadNormalStrength("Thread Normal Strength", Range(0, 1)) = 0.5
        _ThreadSmoothnessScale("Thread Smoothness Scale", Range(0, 1)) = 0.5

        [MaterialToggle(_FUZZMAP_ON)]_Fuzz("绒毛", Float) = 0
        [NoScaleOffset]_FuzzMap("Fuzz Map", 2D) = "black" {}
        _FuzzMapUVScale("Fuzz Map UV Scale", Range( 1 , 50))= 15
        _FuzzStrength("Fuzz Strength", Range(0, 2)) = 1
        
        [HideInInspector][NoScaleOffset]_preIntegratedFGD("preIntegratedFGD", 2D) = "white" {}

        [KeywordEnum(Off,Shadow,And_Unity_Shadow)] ENABLE_HQ("ShadowType",Int) = 0

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 0.0
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
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque" 
        }

        Pass{
            
            Name "SGameFabric"
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
            #pragma multi_compile _ ENABLE_HQ_SHADOW ENABLE_HQ_AND_UNITY_SHADOW

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_instancing
            #define _SHADOWS_SOFT

            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #pragma multi_compile _ _SILK_ON
            #pragma shader_feature _THREADMAP_ON
            #pragma shader_feature _FUZZMAP_ON

            #pragma vertex FabricVert
            #pragma fragment FabricFragment

            #include "Library/FabricLighting.hlsl"

            ENDHLSL 
        }

        Pass //2
        {
            Name "ShadowBeforePost"
            Tags {"LightMode"="SGameShadowPass"}
            Stencil
            {
                Ref 0
                Comp equal
                Pass incrWrap
                Fail keep
                ZFail keep
            }
            
            Blend DstColor Zero
            ColorMask RGB
            ZWrite off
            
            HLSLPROGRAM
            #pragma vertex vertGameOut
            #pragma fragment frag

            #include "Library/FabricInput.hlsl"
            #include "../Library/Shadow/FlatShadow.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Library/FabricInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Library/FabricInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.FabricShaderGUI"
}
