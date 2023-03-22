
Shader "NewRender/Grass/Default" {

    Properties{
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		[MainColor]_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)

        _NormalCenterPos("法线强度", Range(0.0, 10)) = 2

        [NoScaleOffset][Normal]_BumpMap("法线贴图", 2D) = "bump" {}
        _BumpScale("法线强度", Range(0.0, 10)) = 1.0

        [MaterialToggle(_EMISSION_ON)] _EmissionOn  ("Emission", float) = 0
        [KeywordEnum(Map,BaseMap,NoMap)] _Emission("Emission Type",Int) = 0
        [NoScaleOffset]_EmissionMap("自发光遮罩", 2D) = "black" {}
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

        _LightAndShadeOffset("Light And Shade Offset", Range(0, 1.0)) = 1

        //
        [MaterialToggle(_SCATTERING_ON)] _ScatteringOn  ("散射", float) = 0
        _ScatteringScale("Scattering Scale", Range(0, 3)) = 0.3
		_ScatteringPow("Scattering Pow", Range(0, 10)) = 4
		_ScatteringColor("Scattering Color", Color) = (0.3903779,0.5377358,0.1800908,1)

        //
        _FresnelBias("Fresnel Bias", Range(0, 0.2)) = 0.0136
		_FresnelScale("Fresnel Scale", Range(0, 5)) = 0.35
		_FresnelPower("Fresnel Power", Range(0.01, 10)) = 4.78

        [MaterialToggle(_PLANT_ANIM_ON)] _GrassAnimOn  ("Grass Anim On", float) = 0
        _PosOffsetRange("Pos Offset Range", vector) = (-1,1,0,0)
        _AnimSpeed("Anim Speed XY", vector) = (1,1,1,0)
        _NoiseFrequency("Noise Frequency", Range(0.0, 2.0)) = 1
        _AnimStrength("Anim Strength", Range(0.0, 2.0)) = 1
        _UVYPow("UV Y Pow", Range(0.0, 10)) = 1
        _WindData("Wind Data xyz:方向 w:强度", vector) = (0,0,0,0)

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

        [HideInInspector] _MainTex("_MainTex", 2D) = "white" {}
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        BlendOp[_BlendOp]
        Blend[_SrcBlend][_DstBlend]

        ZWrite[_ZWrite]
        Cull[_Cull]

        HLSLINCLUDE

        #include "../Library/Common/CommonFunction.hlsl"
        #include "../Library/Texture/TextureLib.hlsl"
        #include "../Library/Normal/NormalLib.hlsl"
        #include "../Library/Light/LightLib.hlsl"

        CBUFFER_START(UnityPerMaterial)
            half _NormalCenterPos;
            float4 _BaseMap_ST;
            float4 _EmissionMap_ST;
            half4 _BaseColor;
            half _EmissionOn;
            half _Emission;
            half4 _EmissionColor;
            half _BumpScale;
            half _LightAndShadeOffset;
            half _Cutoff;
            half _ScatteringScale;
            half _ScatteringPow;
            half3 _ScatteringColor;
            half _FresnelBias;
            half _FresnelScale;
            half _FresnelPower;
            half _GrassAnimOn;
            half4 _PosOffsetRange;
            half4 _AnimSpeed;
            half _NoiseFrequency;
            half _AnimStrength;
            half _UVYPow;
            half4 _WindData;
   
        CBUFFER_END

        TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
        TEXTURE2D_X(_EmissionMap); SAMPLER(sampler_EmissionMap);
        TEXTURE2D_X(_BumpMap); SAMPLER(sampler_BumpMap);

        struct Attributes_Grass {
            float4 positionOS : POSITION;
            float3 normalOS:NORMAL;
            #if defined(_NORMAL_ON)
                float4 tangentOS   : TANGENT;
            #endif  
            float2 uv : TEXCOORD0;
            float4 lightmapUV   : TEXCOORD1;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings_Grass {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 positionWS : TEXCOORD1;

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD2;
            #endif

            #if defined(_NORMAL_ON)
                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
	            float3 bitangentWS : TEXCOORD5;
            #else
                float3 normalWS : TEXCOORD3;
            #endif  

            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        float snoise_sin(float3 v)
        {
	        float par=v.x+v.y*0.3+v.z;
	        float sinValue = sin(par);
	        float cosValue = cos(par*2);
	        float res=(sinValue+cosValue)*0.5;
	        return res;
        }

        Varyings_Grass GrassVert(Attributes_Grass input) {
            Varyings_Grass output = (Varyings_Grass)0;

            // Instance
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_TRANSFER_INSTANCE_ID(input, output);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            input.normalOS.xyz=normalize(input.positionOS.xyz-float3(0,1,0));

	        #if defined(_PLANT_ANIM_ON)
		        float3 positonWS = TransformObjectToWorld(input.positionOS.xyz);
		        float3 animSpeed = normalize(_AnimSpeed.xyz);
		        //float worldPos = snoise( (positonWS.xy+ float2(positonWS.z*0.25+positonWS.z*0.5) + animSpeed.xy * _Time.y)*_NoiseFrequency ); //太耗性能
		        float worldPos = snoise_sin( (positonWS + animSpeed * _Time.y)*_NoiseFrequency);
		        worldPos=(worldPos+1.0)*(_PosOffsetRange.y-_PosOffsetRange.x)+_PosOffsetRange.x;
                float x=worldPos*animSpeed.x;
		        float y=worldPos*animSpeed.y;
		        float z=worldPos*animSpeed.z;
		        #if defined(SHADER_STAGE_RAY_TRACING)
                    //float3 localOffset = mul(WorldToObject3x4(), float4(worldPos.x, 0,worldPos.x,0)).xyz;
                    float3 localOffset = mul(WorldToObject3x4(), float4(x, y,z,0)).xyz;
		        #else
                    //float3 localOffset = mul(GetWorldToObjectMatrix(), float4(worldPos.x, 0,worldPos.x,0)).xyz;
                    float3 localOffset = mul(GetWorldToObjectMatrix(), float4(x, y,z,0)).xyz;
		        #endif
		        input.positionOS.xyz += localOffset*_AnimStrength*pow(abs(input.uv.y),_UVYPow);
	        #else

	        #endif
            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
            output.positionWS =   TransformObjectToWorld(input.positionOS.xyz);

            #if defined(_NORMAL_ON)
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	            half sign = input.tangentOS.w * GetOddNegativeScale();
	            output.tangentWS.xyz = half3(normalInput.tangentWS.xyz);
	            output.bitangentWS.xyz = half3(sign * cross(normalInput.normalWS.xyz, normalInput.tangentWS.xyz));
	            output.normalWS.xyz = normalInput.normalWS.xyz;
            #else
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS.xyz));
            #endif  
    
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                output.fogFactor = ComputeFogFactor(output.positionCS.z); 
            #endif         

            return output;
        }

        half4 GrassFragment(Varyings_Grass input) : SV_Target{
            UNITY_SETUP_INSTANCE_ID(input);

            float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;
   
            #if defined(_ALPHATEST_ON)
                clip(baseMap.a-_Cutoff);
            #endif

            float3 normalWS=input.normalWS;
            normalWS=normalize(normalWS);

            half3 bakedGI;
            SampleSH(normalWS, bakedGI);

            #if defined(_NORMAL_ON)
                half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, normalWS);
                half4 normalTex=SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,input.uv.xy);
		        half3 normalTS = UnpackNormalScale(normalTex,_BumpScale);
		        normalWS = normalize(mul(normalTS,TBN));
            #endif

            float3 viewDirWS =normalize(_WorldSpaceCameraPos - input.positionWS.xyz);

            float VDotN=saturate(dot(normalWS, viewDirWS));

            Light mainLight = GetMainLight();
            float lightAttenuation = mainLight.distanceAttenuation * mainLight.shadowAttenuation;
            float3 maiLightColor = mainLight.color*lightAttenuation;
            //
            float fresnel=_FresnelBias+_FresnelScale*pow(abs(1.0-VDotN),_FresnelPower);
            float3 fresnelColor=fresnel*bakedGI;
            //
            float NDotL=dot(normalWS,mainLight.direction);
            NDotL=(NDotL+_LightAndShadeOffset)/(1.0+_LightAndShadeOffset);

            //scattering
            #if defined(_SCATTERING_ON)
				float VDotInL = saturate(dot(viewDirWS, -mainLight.direction));
				half3 directLighting = VDotInL  * maiLightColor;
				half3 scatteringIntensity = directLighting  + bakedGI;//
				scatteringIntensity = scatteringIntensity * _ScatteringScale;
				scatteringIntensity=clamp(scatteringIntensity,0,5.0);
				scatteringIntensity = scatteringIntensity  * _ScatteringColor.rgb;
                half3 scatteringColor=scatteringIntensity;
            #else
                half3 scatteringColor=half3(0,0,0);
            #endif

            //
            half4 finColor=half4(0,0,0,baseMap.a);
            finColor.rgb = baseMap.rgb*NDotL*lightAttenuation*maiLightColor;
            finColor.rgb = finColor.rgb+baseMap.rgb*bakedGI+scatteringColor.rgb+saturate(NDotL)*fresnelColor;

            #if defined(_EMISSION_ON)
                #if defined(_EMISSION_MAP)
                    float3 emissionColor = SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap,input.uv.xy).rgb*_EmissionColor.rgb;
                #elif defined(_EMISSION_BASEMAP)
                    float3 emissionColor = baseMap.rgb*_EmissionColor.rgb;
                #elif defined(_EMISSION_NOMAP)
                    float3 emissionColor = _EmissionColor.rgb;
                #endif
                finColor.rgb=finColor.rgb+emissionColor;
            #endif

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half fogIntensity = ComputeFogIntensity(input.fogFactor);
	            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
            #endif
                                      
            return finColor;
        }

        ENDHLSL

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex GrassVert
            #pragma fragment GrassFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #define VARYINGS_NEED_CULLFACE

            #pragma shader_feature _ _SCATTERING_ON 
            #pragma multi_compile _ _PLANT_ANIM_ON

            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

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

            // Material Shader Feature
            #pragma shader_feature_local _NORMAL_ON
            #pragma shader_feature_local _EMISSION_ON
            #pragma shader_feature_local _EMISSION_MAP _EMISSION_BASEMAP _EMISSION_NOMAP

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

            #pragma vertex GrassVert
            #pragma fragment GrassDepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma multi_compile _ _PLANT_ANIM_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

            half4 GrassDepthOnlyFragment(Varyings_Grass input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;
   
                #if defined(_ALPHATEST_ON)
                    clip(baseMap.a-_Cutoff);
                #endif

                return 0;
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.GrassShaderGUI"
}
