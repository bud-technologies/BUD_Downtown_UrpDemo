
Shader "NewRender/Standard/BasePBR"
{
    Properties
    {
        [MainTexture] _BaseMap("颜色贴图", 2D) = "white" {}
        [MainColor] _BaseColor("RGB:颜色 A:透明度", Color) = (1,1,1,1)

        [NoScaleOffset][Normal]_BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Range(0.0, 10)) = 1.0

        [NoScaleOffset]_MetallicGlossMap("R: 金属度 G:AO B:光滑度", 2D) = "white" {}
        _Metallic("金属度", Range(0.0, 1.0)) = 1.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 1.0
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0

        [KeywordEnum(Off,Color,ColorMap)] AOCOLORSET("AO颜色",Int) = 0
        _OcclusionColor("AO颜色", Color) = (1,1,1,1)
        _OcclusionColorMap("AO颜色贴图", 2D) = "white" {}

        _EnergyLUT("_EnergyLUT", 2D) = "black" {}

        [MaterialToggle(_EMISSION_ON)] _Emission  ("Emission", float) = 0
        [NoScaleOffset]_EmissionMap("自发光遮罩", 2D) = "white" {}
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

        [KeywordEnum(Off,Shadow,And_Unity_Shadow)] ENABLE_HQ("ShadowType",Int) = 0

        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

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
            #pragma shader_feature_local _ AOCOLORSET_COLOR AOCOLORSET_COLORMAP

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #define _SHADOWS_SOFT

            // #pragma multi_compile_instancing
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            // Material Shader Feature
            #pragma shader_feature_local _NORMAL_ON
            #pragma shader_feature_local _EMISSION_ON
            #pragma shader_feature_local _EMISSION_MAP
            
            #pragma vertex PBRVert
            #pragma fragment PBRFragment
            
            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Surface/ShadingModel.hlsl"
            
            #include "Library/StandardPBRLighting.hlsl"

            ENDHLSL
        }

        Pass //2
        {
            Name "ShadowBeforePost"
            Tags {"LightMode"="ShadowBeforePost"}
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

            #include "Library/StandardPBRInput.hlsl"
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

            #include "Library/StandardPBRInput.hlsl"
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

            #include "Library/StandardPBRInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #pragma shader_feature EDITOR_VISUALIZATION
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED


            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "Library/StandardPBRForward.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UniversalMetaPass.hlsl"

            half4 UniversalFragmentMetaLit(Varyings input) : SV_Target
            {
                SurfaceData_PBR surfaceData;
                InitSurfaceData(input.uv, surfaceData);

                BRDFData brdfData;
                InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

                MetaInput metaInput;
                metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
                metaInput.Emission = surfaceData.emission;

                return UniversalFragmentMeta(input, metaInput);
            }

            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.StandardShaderGUI"
}
