

Shader "NewRender/Texture/Default" {

    Properties{
        [Header(Cull Mode)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("剔除模式 : Off是双面显示，否则一般用 Back", int) = 0

        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [MaterialToggle(_EMISSION_ON)] _Emission  ("Emission", float) = 0
        [NoScaleOffset]_EmissionMap("自发光遮罩", 2D) = "white" {}
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

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

        [HideInInspector] _MainTex("_MainTex", 2D) = "white" {}
    }

    SubShader{

        Tags {
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        BlendOp[_BlendOp]
        Blend[_SrcBlend][_DstBlend]
        ZWrite[_ZWrite]
        Cull[_Cull]
        ZTest On
        Lighting Off

        HLSLINCLUDE

        #include "../Library/Common/CommonFunction.hlsl"

        CBUFFER_START(UnityPerMaterial)
	        float4 _BaseMap_ST;
	        half4 _BaseColor;
	        half4 _EmissionColor;
	        half _Cutoff;
        CBUFFER_END

        TEXTURE2D_X(_BaseMap);
        TEXTURE2D_X(_EmissionMap);

        struct Attributes_Texture {
            UNITY_VERTEX_INPUT_INSTANCE_ID
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings_Texture {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD1;
            #endif
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };


        Varyings_Texture TextureVertex(Attributes_Texture v) {
            Varyings_Texture o = (Varyings_Texture)0;
            UNITY_SETUP_INSTANCE_ID(v); 
            UNITY_TRANSFER_INSTANCE_ID(v, o);
            o.uv = v.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
            o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                output.fogFactor = ComputeFogFactor(output.positionCS.z); 
            #endif   
            return o;
        }

        half4 TextureFragment(Varyings_Texture i) : COLOR{
            half4 c = SAMPLE_TEXTURE2D(_BaseMap, sampler_LinearRepeat, i.uv)*_BaseColor;

            #if defined(_ALPHATEST_ON)
                clip(c.a-_Cutoff);
            #endif

            #if defined(_EMISSION_ON)
                half3 e = SAMPLE_TEXTURE2D(_EmissionMap, sampler_LinearRepeat, i.uv).rgb*_EmissionColor.rgb;
                c.rgb=c.rgb+e;
            #endif

            half4 finColor=c;

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half fogIntensity = ComputeFogIntensity(input.fogFactor);
	            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
            #endif

            return c;
        }

        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit"}

            ZWrite On
            Cull Front
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex TextureVertex
            #pragma fragment TextureFragment
            #pragma multi_compile_instancing 
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _EMISSION_ON

            ENDHLSL
        }

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex TextureVertex
            #pragma fragment TextureFragment
            #pragma multi_compile_instancing 
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _EMISSION_ON

            ENDHLSL

        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.TextureShaderGUI"
}
