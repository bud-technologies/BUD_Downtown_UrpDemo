Shader "NewRender/Gem/Default"
{
    Properties
    {
        _BaseColor("Base Color",Color) = (1.0,1.0,1.0,0)

        _RefractMap ("Refract Map", Cube) = "white" {}
        _RefractIntensity("Refract Intensity",float) = 1
        _ReflectMap ("Reflect Map", Cube) = "white" {}
        _ReflectIntensity("Reflect Intensity",float) = 1.5

        _RimPower("RimPower", Float) = 2
        _RimScale("RimScale", Float) = 1
        _RimBias("RimBias", Float) = 0

        [Normal]_BumpMap("Bump Map",2D) = "bump" {}
        _BumpScale("NormalIntensity",Float) = 1

        _InnerAlpha("InnerAlpha",Range(0,1)) = 1
        _OuterAlpha("OuterAlpha",Range(0,1)) = 0.6

    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}

        HLSLINCLUDE

        #include "../Library/Common/CommonFunction.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float _RefractIntensity;
            float _ReflectIntensity;
            float4 _BaseColor;
            float _RimPower;
            float _RimScale;
            float _RimBias;
            float _BumpScale;
            float _InnerAlpha;
            float _OuterAlpha;
            half _EnvironmentIntensity;
            half4 _EmissionColor;
        CBUFFER_END

        samplerCUBE _RefractMap;
        samplerCUBE _ReflectMap;
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D_X(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D_X(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

        struct Attributes_Gem
        {
            float4 positionOS   : POSITION;
            float2 uv       : TEXCOORD0;
            float3 normalOS   : NORMAL;
            float4 tangentOS          :TANGENT;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Attributes_GemLit {
            float4 positionOS : POSITION;
            float3 normalOS:NORMAL;
            float4 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings_Gem
        {
            float4 positionCS       : SV_POSITION;
            float2 uv           : TEXCOORD0;
            float3 normalWS       : TEXCOORD1;
            float3 positionWS     : TEXCOORD2;
            float3 tangentWS    :TEXCOORD3;
            float3 binormalWS   :TEXCOORD4;
            float3 reflectValue : TEXCOORD5;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD6;
            #endif
	        UNITY_VERTEX_INPUT_INSTANCE_ID
	        UNITY_VERTEX_OUTPUT_STEREO
        };

        struct Varyings_GemLit {
            float4 positionCS : SV_POSITION;
            float3 uv : TEXCOORD0;
            float2 uv0 : TEXCOORD1;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD2;
            #endif
            #if defined(GEM_LIT_FORWARD)
                half fresnel : TEXCOORD3;
            #endif
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        Varyings_Gem GemVert (Attributes_Gem input)
        {
            Varyings_Gem output=(Varyings_Gem)0;

            // Instance
	        UNITY_SETUP_INSTANCE_ID(input);
	        UNITY_TRANSFER_INSTANCE_ID(input, output);
	        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.positionWS = mul(unity_ObjectToWorld,input.positionOS).xyz;
            output.uv = input.uv;
            output.normalWS = TransformObjectToWorldNormal(input.normalOS);
            output.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
            output.binormalWS = cross(output.normalWS,output.tangentWS) * input.tangentOS.w;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                output.fogFactor = ComputeFogFactor(output.positionCS.z); 
            #endif
            return output;
        }

        Varyings_GemLit GemLitVert(Attributes_GemLit input) {
            Varyings_GemLit output = (Varyings_GemLit)0;

            // Instance
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_TRANSFER_INSTANCE_ID(input, output);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            output.uv0 = input.uv.xy;
            float3 viewDir = _WorldSpaceCameraPos - TransformObjectToWorld(input.positionOS.xyz);
            output.uv = -reflect(viewDir, TransformObjectToWorldNormal(input.normalOS));

            #if defined(GEM_LIT_FORWARD)
                output.fresnel = 1.0 - saturate(dot(input.normalOS, viewDir));
            #endif

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                output.fogFactor = ComputeFogFactor(output.positionCS.z); 
            #endif
                        
            return output;
        }

        float4 GemFragment (Varyings_Gem input) : SV_Target
        {
            Light light = GetMainLight();

            half3 normal_dir = normalize(input.normalWS);
            half3 tangent_dir = normalize(input.tangentWS);
            half3 binormal_dir = normalize(input.binormalWS);
            half3 view_dir = normalize(_WorldSpaceCameraPos - input.positionWS);
            half3 reflect_dir = normalize(reflect(-view_dir,normal_dir)) + light.direction;

            float3x3 TBN = float3x3(tangent_dir,binormal_dir,normal_dir);

            float4 normal_map = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,input.uv);
            float3 normal_data = UnpackNormal(normal_map);
            normal_data.xy *= _BumpScale;
            normal_dir = normalize(mul(normal_data,TBN));

            half NdotV = saturate(dot(view_dir,normal_dir));

            half rim = 1 - NdotV;
            float4 reflect_color = texCUBE(_ReflectMap,reflect_dir);
            float4 refract_color = texCUBE(_RefractMap,reflect_dir) * reflect_color * _BaseColor * _RefractIntensity;

            reflect_color *= _ReflectIntensity * rim;

            rim = pow(rim,_RimPower) * _RimScale + _RimBias;

            float4 final_color = refract_color + reflect_color;
            final_color += final_color * rim;

            half4 finColor=half4(0,0,0,1);

            #if defined(_GEM_INNER_ALPHA)
                finColor = half4(final_color.rgb,_InnerAlpha);
            #elif defined(_GEM_OUTER_ALPHA)
                finColor = half4(final_color.rgb,_OuterAlpha);
            #endif

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half fogIntensity = ComputeFogIntensity(input.fogFactor);
	            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
            #endif

            return  finColor;
        }

        half4 GemLitFragment(Varyings_GemLit input) : SV_Target{
            UNITY_SETUP_INSTANCE_ID(input);
            half4 refraction  = texCUBE(_RefractMap, input.uv);   
            #if !defined(UNITY_USE_NATIVE_HDR)
                refraction.rgb = DecodeHDREnvironment(refraction, unity_SpecCube0_HDR);
            #endif
                refraction.rgb= refraction.rgb* _BaseColor.rgb;
                half4 reflection = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, input.uv, 4);
            #if !defined(UNITY_USE_NATIVE_HDR)
                reflection.rgb = DecodeHDREnvironment(reflection, unity_SpecCube0_HDR);
            #endif
            half4 emissionTex = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv0);
            emissionTex = clamp(emissionTex, 0, 0.7);
            half3 multiplier = reflection.rgb * _EnvironmentIntensity + _EmissionColor.rgb * emissionTex.rgb;

            half4 finColor;

            #if defined(GEM_LIT_FORWARD)
                half3 reflection2 = reflection.rgb * _RefractIntensity * input.fresnel;
                finColor= half4(reflection2 + refraction.rgb * multiplier, 1.0f);
            #else
                finColor=half4(refraction.rgb * multiplier.rgb, 1.0f);
            #endif

            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half fogIntensity = ComputeFogIntensity(input.fogFactor);
	            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
            #endif
    
            return  finColor;
        }

        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "SRPDefaultUnlit"}
            //Blend One Zero, One OneMinusSrcAlpha

            Blend SrcAlpha OneMinusSrcAlpha

            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex GemVert
            #pragma fragment GemFragment
            #define _GEM_INNER_ALPHA
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog

            ENDHLSL
        }


        Pass
        {
            Tags { "LightMode" = "UniversalForward"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            HLSLPROGRAM
            #pragma vertex GemVert
            #pragma fragment GemFragment
            #define _GEM_OUTER_ALPHA
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog

            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
