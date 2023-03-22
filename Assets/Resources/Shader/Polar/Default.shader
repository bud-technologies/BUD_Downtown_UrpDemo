
//极坐标 UV
Shader "NewRender/Polar/Default" {

    Properties{
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)
      
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex PolarVert
            #pragma fragment PolarFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Texture/TextureLib.hlsl"
            #include "../Library/Normal/NormalLib.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                half _LaserIntervene;
                half _LaserInterveneCount;
                half _LaserWaveCount;
                half _LaserTimeAnim;
                half _LaserTimeAnimSpeed;
                half _LaserWaveStrength;
                int LASER_TYPE;
                int _REFLECT_CUBE;
                half _ReflectMapMipLevel;
                half _BumpScale;
                float4 _BumpMap_ST;
                int _NORMAL;
                float _BumpBlendScale;
            CBUFFER_END

            TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D_X(_BumpMap); SAMPLER(sampler_BumpMap);

            TEXTURECUBE(_ReflectMap);
            SAMPLER(sampler_ReflectMap);

            struct Attributes_Polar {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Polar {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half  fogFactor : TEXCOORD3;
                #endif

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings_Polar PolarVert(Attributes_Polar input) {
                Varyings_Polar output = (Varyings_Polar)0;

                // Instance
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                output.uv.xy = PolarTexture(input.uv.xy,_BaseMap_ST,float2(_Time.y,_Time.y*0.5));

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
                #endif         

                return output;
            }

            half4 PolarFragment(Varyings_Polar input) : SV_Target{
                UNITY_SETUP_INSTANCE_ID(input);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;
                half4 finColor=baseMap;
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
