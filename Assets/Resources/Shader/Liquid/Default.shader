//药剂动画
Shader "NewRender/Liquid/Default"
{
    Properties
    {
       [KeywordEnum(Off,On)] _Base_Map("起伏纹理 Base Map",Int) = 0
       [KeywordEnum(Off,On)] _Base_MapWorld("起伏纹理 世界坐标 Base Map",Int) = 0
       [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
       [MainColor] _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
       _BaseMapUVSpeed ("Base Map UV Speed", Range(-1.0, 1.0)) = 1.0
       _BaseMapStrength ("Base Map Strength", Range(-2.0, 2.0)) = 1.0

       [HDR]_BottomColor ("Bottom Color", Color) = (0,0.8207547,0.2961154, 1)
       [HDR]_TopColor ("Top Color", Color) = (0,0.6946828,0.764151)
       [HDR]_FoamColor ("Foam Color", Color) = (0.2850213,0.990566,0.7492778)

        _FillAmount ("FillAmount 高度", Range(-2, 2)) = 0.7

        //动画
        [HideInInspector]_WobbleX ("WobbleX 倾斜偏移", Range(-1, 1)) = 0.0
        [HideInInspector]_WobbleZ ("WobbleZ 倾斜偏移", Range(-1, 1)) = 0.0
        [HideInInspector] _Rotation ("Rotation 旋转角度", Range(-180, 180)) = 90
        [HideInInspector]_RotationAxis("RotationAxis 旋转轴向", vector) = (-1,0,0,0)

        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 0.0
        [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
        [HideInInspector] [Toggle] _EnvLight ("Env Lighting", Float) = 0.0
        [HideInInspector] _ColorBlendMode ("Blend Mode", Float) = 2.0

        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
        }

        Pass
        {
            Name "Matcap"
            Tags { "LightMode" = "UniversalForward" }
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM

            #pragma vertex LiquidVertex
            #pragma fragment LiquidFragment
            #pragma multi_compile_fog
            #define VARYINGS_NEED_CULLFACE
            #define _ALPHATEST_ON
            #pragma multi_compile _ _BASE_MAP_ON
            #pragma multi_compile _ _BASE_MAPWORLD_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Library/Math.hlsl"
            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Transform/TransformLib.hlsl"
            #include "../Library/FrontFace/FrontFaceLib.hlsl"

            CBUFFER_START(UnityPerMaterial)
	            float _WobbleX;
	            float _WobbleZ;
	            half _FillAmount;
	            float _Rotation;
	            float3 _RotationAxis;
	            half4 _BottomColor;
	            half4 _TopColor;
	            half4 _FoamColor;

	            float4 _BaseMap_ST;
	            half4 _BaseColor;
	            half _BumpScale;
	            half _MatcapScale;
	            half4 _NormalAnim;
	            half _UVScale;
	            half _BaseMapStrength;
	            half _BaseMapUVSpeed;
            CBUFFER_END

            TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MatcapMap);  SAMPLER(sampler_MatcapMap);
            TEXTURE2D(_BumpMap);  SAMPLER(sampler_BumpMap);

            struct Attributes_Liquid
            {
                float4 positionOS : POSITION;
                #ifdef _BASE_MAP_ON
                    float2 uv     		: TEXCOORD0;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Liquid
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS: TEXCOORD0;
                float3 objectPositionWS: TEXCOORD1;
                #ifdef _BASE_MAP_ON
                    float2 uv: TEXCOORD2;
                #endif
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                     half  fogFactor : TEXCOORD3;
                #endif
                INPUT_FRONT_FACE_GET
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings_Liquid LiquidVertex (Attributes_Liquid input)
            {
                Varyings_Liquid output=(Varyings_Liquid)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.objectPositionWS = TransformObjectToWorld(float3(0,0,0));
                output.positionCS = TransformWorldToHClip(output.positionWS);
                #ifdef _BASE_MAP_ON
                    output.uv =TRANSFORM_TEX(input.uv,_BaseMap);
                #endif
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z);
                #endif

                return output;
            }

            half4 LiquidFragment (Varyings_Liquid input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                #ifdef _BASE_MAP_ON
                    half4 baseMapTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, input.uv+(_Time.y*_BaseMapUVSpeed).xx);
                #endif

                #ifdef  _BASE_MAPWORLD_ON
                    half4 baseMapTexWorld = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, input.positionWS.xz+(_Time.y*_BaseMapUVSpeed).xx);
                    baseMapTexWorld.y=baseMapTexWorld.y*sin(input.positionWS.y*10);
                #endif

                //
                float3 objectSpacePosition = TransformWorldToObject(input.positionWS);

                float3 objectSpaceRotatePosition;
                Rotate_Axis(objectSpacePosition, _RotationAxis.xyz, _Rotation, objectSpaceRotatePosition);
                //
                objectSpaceRotatePosition=_WobbleX*objectSpacePosition + _WobbleZ*objectSpaceRotatePosition;
                objectSpaceRotatePosition=objectSpaceRotatePosition+(input.positionWS-input.objectPositionWS);
                float splitY=objectSpaceRotatePosition.y;

                #ifdef _BASE_MAP_ON
                    #ifdef _BASE_MAPWORLD_ON
                        splitY=baseMapTexWorld.y*baseMapTex.y*_BaseMapStrength+splitY;
                    #else
                        splitY=baseMapTex.y*_BaseMapStrength+splitY;
                    #endif
                #else
                    #ifdef _BASE_MAPWORLD_ON
                        splitY=baseMapTexWorld.y*_BaseMapStrength+splitY;
                    #else
                    #endif
                #endif

                //
                float fillSplitY=splitY+_FillAmount;
                fillSplitY = step(fillSplitY, 0.59);
                half alpha=fillSplitY*_BaseColor.a;
                half alphaClip=0.11;
                //
                #ifdef _ALPHATEST_ON
	                clip( alpha - alphaClip );
	            #endif
                //

                //
                float _OFfset=0.26;
                float oFfsetSplitY=_OFfset+splitY;
                oFfsetSplitY=saturate(oFfsetSplitY);
                half3 lerpColor=lerp(_BottomColor.rgb,_TopColor.rgb,oFfsetSplitY);

                //
                FRAGMENT_FRONT_FACE_GET(input)
                half3 branchColor = FaceSign ? lerpColor.rgb : _FoamColor.rgb;
                //
                #ifdef _BASE_MAP_ON
                    #ifdef _BASE_MAPWORLD_ON
                        half3 baseColor=fillSplitY*branchColor*_BaseColor.rgb+baseMapTexWorld.y*baseMapTex.y*_BaseMapStrength*0.5;
                    #else
                        half3 baseColor=fillSplitY*branchColor*_BaseColor.rgb+baseMapTex.y*_BaseMapStrength*0.5;
                    #endif
                #else
                    #ifdef _BASE_MAPWORLD_ON
                        half3 baseColor=fillSplitY*branchColor*_BaseColor.rgb+baseMapTexWorld.y*_BaseMapStrength*0.5;
                    #else
                        half3 baseColor=fillSplitY*branchColor*_BaseColor.rgb;
                    #endif
                #endif

                half4 finColor=half4(baseColor,alpha);

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
		            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb, fogIntensity);
                #endif

                return finColor;
            }
            
            ENDHLSL
        }

        //UsePass "NewRender/Standard/BasePBR/ShadowCaster"
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "NewRenderShaderGUI.MatcapShaderGUI"
}
