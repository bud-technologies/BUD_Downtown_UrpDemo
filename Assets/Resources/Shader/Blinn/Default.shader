
//Blinn模型
Shader "NewRender/Blinn/Default" {

    Properties{
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		[MainColor]_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)
        _Pow("Pow", Range(0, 10)) = 2
        _Strength("Strength", Range(0, 10)) = 1
        [MaterialToggle(_LIGHTCOLOR_STEP_ON)] _StepOn("截断", float) = 0
        _Step("Step", Range(0, 1)) = 0.5
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex BlinnVert
            #pragma fragment BlinnFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #pragma shader_feature_local_fragment _ _LIGHTCOLOR_STEP_ON

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Texture/TextureLib.hlsl"
            #include "../Library/Normal/NormalLib.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                half _Pow;
                half _Strength;
                half _Step;
            CBUFFER_END

            TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);

            struct Attributes_Blinn {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Blinn {
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

            Varyings_Blinn BlinnVert(Attributes_Blinn input) {
                Varyings_Blinn output = (Varyings_Blinn)0;

                // Instance
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
                output.positionWS =   TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS =   GetNormalWorld(input.normalOS.xyz);

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
                #endif         

                return output;
            }

            half4 BlinnFragment(Varyings_Blinn input) : SV_Target{
                UNITY_SETUP_INSTANCE_ID(input);

                float3 viewDirWs =normalize(GetCameraPositionWS() - input.positionWS);

                Light mainLight = GetMainLight();
                float3 ref = normalize(reflect(-mainLight.direction,input.normalWS));
                float DotVR =saturate(dot(viewDirWs,ref));
                DotVR=pow(DotVR,_Pow);

                #if defined(_LIGHTCOLOR_STEP_ON)
                    DotVR=step(_Step,DotVR);
                #endif

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;

                half4 finColor=baseMap;
                finColor.rgb=finColor.rgb*DotVR*_Strength;

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
	                finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
                #endif
    
                return  finColor;
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
