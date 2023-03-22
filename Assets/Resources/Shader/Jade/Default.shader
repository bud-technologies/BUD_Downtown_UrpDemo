
//玉
Shader "NewRender/Jade/Default" {

    Properties{
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		[MainColor]_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)
        _CartoonColorMap ("CartoonColorMap", 2D) = "white" {}
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex JadeVert
            #pragma fragment JadeFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Texture/TextureLib.hlsl"
            #include "../Library/Normal/NormalLib.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
            CBUFFER_END

            TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D_X(_CartoonColorMap); SAMPLER(sampler_CartoonColorMap);

            struct Attributes_Jade {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Jade {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half  fogFactor : TEXCOORD3;
                #endif

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };



            Varyings_Jade JadeVert(Attributes_Jade input) {
                Varyings_Jade output = (Varyings_Jade)0;

                // Instance
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);

                output.normalWS =  GetNormalWorld(input.normalOS.xyz);

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
                #endif         

                return output;
            }

            half4 JadeFragment(Varyings_Jade input) : SV_Target{
                UNITY_SETUP_INSTANCE_ID(input);

                Light mainLight = GetMainLight();
                float ramp =  dot(input.normalWS,mainLight.direction);
                ramp=ramp*0.5+0.5;
                half3 cartoonRamp = SAMPLE_TEXTURE2D(_CartoonColorMap, sampler_LinearClamp, half2(ramp,0.5)).rgb;

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;

                half4 finColor=baseMap;
                finColor.rgb=finColor.rgb*cartoonRamp;

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
	                finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
                #endif
    
                return  finColor;
            }

            ENDHLSL
        }
    }
    FallBack off
}
