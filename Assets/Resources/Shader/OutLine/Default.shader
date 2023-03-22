
//描边
Shader "NewRender/Outline/Default" {

    Properties{
        [MaterialToggle(_OUTLINE_BACK_ON)] _BackOn("背面", float) = 0
        [MaterialToggle(_OUTLINE_FRONT_ON)] _FrontOn("正面", float) = 0
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
		[HDR]_LineColor ("Line Color", Color) = (1.0,1.0,1.0,1)
        _LineWidthBack("Line Width Back", Range(0.0, 1.0)) = 0.1
        _LineWidthFront("Line Width Front", Range(0.0, 1.0)) = 0.3

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _MainTex("_MainTex", 2D) = "white" {}
    }

    SubShader{

        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
        Blend SrcAlpha OneMinusSrcAlpha

        HLSLINCLUDE

        #include "../Library/Common/CommonFunction.hlsl"
        #include "../Library/Texture/TextureLib.hlsl"
        #include "../Library/Normal/NormalLib.hlsl"

        CBUFFER_START(UnityPerMaterial)

            float4 _BaseMap_ST;
            float4 _BaseColor;
	        half4 _LineColor;
            half _Cutoff;
            half _LineWidthBack;
            half _LineWidthFront;
            half _SDFOn;
            half _BackOn;
            half _FrontOn;
        CBUFFER_END

        TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);

        struct Attributes_Outline {
            float4 positionOS : POSITION;
            float3 normalOS:NORMAL;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings_Outline {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 normalWS : TEXCOORD1;
            float3 positionWS : TEXCOORD2;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD3;
            #endif
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        float GetOutLineEdige(float3 viewDirWS,float3 normalWS) {
            float VDotN = abs(dot(viewDirWS, normalWS));
            //
            VDotN = (VDotN - 0.5) * 0.5;
            VDotN = abs(VDotN);
            VDotN = 1.0 - VDotN;
            VDotN = pow(VDotN, 4);
            return VDotN;
        }

        Varyings_Outline OutlineVert(Attributes_Outline input) {
            Varyings_Outline output = (Varyings_Outline)0;

            // Instance
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_TRANSFER_INSTANCE_ID(input, output);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            #if defined( _OUTLINE_BACK) && defined(_OUTLINE_BACK_ON)
                output.normalWS = GetNormalWorld(input.normalOS.xyz);
                float3 viewDirWS =normalize(GetCameraPositionWS() - output.normalWS);
                float VDotN = GetOutLineEdige(viewDirWS, output.normalWS);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, input.normalOS.xyz));
                //output.positionCS.xy = output.positionCS.xy + output.positionCS.w* z* 1000* _LineWidthBack * normalize(clipNormal).xy * VDotN;;// _LineWidthBack* normalize(clipNormal).xy* VDotN;
                output.positionCS.xy = output.positionCS.xy + _LineWidthBack* normalize(clipNormal).xy* VDotN;
            #else
                output.normalWS = GetNormalWorld(input.normalOS.xyz);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            #endif

            output.positionWS =   TransformObjectToWorld(input.positionOS.xyz);
            output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                output.fogFactor = ComputeFogFactor(output.positionCS.z); 
            #endif  

            #if defined( _OUTLINE_BACK) && defined(_OUTLINE_BACK_ON)
                output.positionCS.z=output.positionCS.z-output.positionCS.z*0.01;
            #endif

            #if defined( _OUTLINE_FRONT) && defined(_OUTLINE_FRONT_ON)
                output.positionCS.z = output.positionCS.z + output.positionCS.z * 0.01;
            #endif

            return output;
        }

        half stepAntiAliasing(half y, half x)
        {
            half v = x - y;
            return saturate(v / fwidth(v));
        }

        half4 OutlineFragment(Varyings_Outline input) : SV_Target{
            UNITY_SETUP_INSTANCE_ID(input);

            float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor*_LineColor;

            #if defined(_ALPHATEST_ON)
                clip(baseMap.a-_Cutoff);
            #endif

            #if defined( _OUTLINE_BACK) && !defined(_OUTLINE_BACK_ON)
                clip(-1);
            #endif

            #if defined(_OUTLINE_FRONT)
                #if !defined(_OUTLINE_FRONT_ON)
                   clip(-1);
                #endif
                float 	VDotN = dot(input.normalWS, normalize(GetCameraPositionWS() - input.positionWS));
                VDotN = step(_LineWidthFront, VDotN);
                clip(1 - VDotN - 0.5);
            #endif

            half4 finColor=half4(_LineColor.rgb,baseMap.a);

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half fogIntensity = ComputeFogIntensity(input.fogFactor);
	            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
            #endif
    
            return  finColor;
        }

        ENDHLSL

        Pass {
            Tags{"LightMode" = "SRPDefaultUnlit"}
            Cull Front
            HLSLPROGRAM

            #pragma vertex OutlineVert
            #pragma fragment OutlineFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature_local _ _OUTLINE_BACK_ON

            #define _ALPHATEST_ON
            #define _OUTLINE_BACK

            ENDHLSL
        }

        Pass {
            Tags{"LightMode" = "UniversalForward"}
            Cull Back
            HLSLPROGRAM

            #pragma vertex OutlineVert
            #pragma fragment OutlineFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature_local _ _OUTLINE_FRONT_ON

            #define _ALPHATEST_ON
            #define _OUTLINE_FRONT

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
