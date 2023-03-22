//固定的4个图层混合

Shader "NewRender/Terrain/Default"
{
    Properties
    {

        //混合权重图
        _Control("Control (RGBA)", 2D) = "red" {}

        //纹理图
        _SplatMap01("SplatMap RGB: A:AO", 2D) = "grey" {}
        _SplatMap01Color("RGB:颜色 A:透明度", Color) = (1,1,1,1)
        _BumpMap01("BumpMap01 BA:金属度，光滑度", 2D) = "bump01" {}
        _BumpScale01("BumpMap01", Range(0,2)) = 1

        //
        _SplatMap02("SplatMap RGB: A:AO", 2D) = "grey" {}
        _SplatMap02Color("RGB:颜色 A:透明度", Color) = (1,1,1,1)
        _BumpMap02("BumpMap02 BA:金属度，光滑度", 2D) = "bump02" {}
        _BumpScale02("BumpMap02", Range(0,2)) = 1

        //
        _SplatMap03("SplatMap RGB: A:AO", 2D) = "grey" {}
        _SplatMap03Color("RGB:颜色 A:透明度", Color) = (1,1,1,1)
        _BumpMap03("BumpMap03 BA:金属度，光滑度", 2D) = "bump03" {}
        _BumpScale03("BumpMap02", Range(0,2)) = 1

        //
        _SplatMap04("SplatMap RGB: A:AO", 2D) = "grey" {}
        _SplatMap04Color("RGB:颜色 A:透明度", Color) = (1,1,1,1)
        _BumpMap04("BumpMap04 BA:金属度，光滑度", 2D) = "bump04" {}
        _BumpScale04("BumpMap02", Range(0,2)) = 1

        [MaterialToggle(TERRAINTEXTURE_AUTOBLENDER_ON)] _TerrainTextureAutoBlender("AutoBlender 自动混合", float) = 0
        _BlenderPow("BlenderPow 形状", Range(0.1,4)) = 2
        _SectionTop("SectionTop 顶部混区间", vector) = (0.35,1.0,0,0)
        _SectionMid("SectionMid 中部混区间", vector) = (0.5,0,0,0)
        _SectionDown("SectionDown 底部混区间", vector) = (0.15,0,0,0)

        _Metallic("金属度", Range(0.0, 1.0)) = 1.0
        _Smoothness("光滑度", Range(0.0, 1.0)) = 1.0
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 0

        [MaterialToggle(_EMISSION_ON)] _Emission("Emission", float) = 0
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0,1)

        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }

        HLSLINCLUDE

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/LightMap/LightMapLib.hlsl"

            struct Attributes_Terrain {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
	            float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                INPUT_ATTRIBUTES_LIGHTMAP
	            UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Terrain {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;

                float4 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
	            float4 bitangentWS : TEXCOORD4;
                OUTPUT_VARYINGS_LIGHTMAP(5)

	            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
		            half  fogFactor : TEXCOORD6; // x: fogFactor
	            #endif
                float4 shadowCoord: TEXCOORD7;

	            UNITY_VERTEX_INPUT_INSTANCE_ID
	            UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                half _BlenderPow;
                float2 _SectionTop;
                float2 _SectionMid;
                float2 _SectionDown;

                half _BumpScale;
                half4 _BaseColor;
                half _Metallic;
                half _Smoothness;
                half _OcclusionStrength;
                half4 _EmissionColor;

                float4 _BaseMap_ST;
                float4 _BumpMap_ST;
                float4 _MetallicGlossMap_ST;
                float4 _EmissionMap_ST;
                half _EmissionNightFade;
                float4 _SplatMap01_TexelSize;
                float4 _SplatMap02_TexelSize;
                float4 _SplatMap03_TexelSize;
                float4 _SplatMap04_TexelSize;

                //
                float4 _Control_TexelSize;
                float4 _Control_ST;

                //
                float4 _SplatMap01_ST;
                float4 _SplatMap02_ST;
                float4 _SplatMap03_ST;
                float4 _SplatMap04_ST;
                half3 _SplatMap01Color;
                half3 _SplatMap02Color;
                half3 _SplatMap03Color;
                half3 _SplatMap04Color;

                half _BumpScale01;
                half _BumpScale02;
                half _BumpScale03;
                half _BumpScale04;

                half _Cutoff;

                half _TerrainTextureAutoBlender;

            CBUFFER_END

            TEXTURE2D(_Control);
            SAMPLER(sampler_Control);
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_SplatMap01); TEXTURE2D(_BumpMap01); 
            TEXTURE2D(_SplatMap02);  TEXTURE2D(_BumpMap02); 
            TEXTURE2D(_SplatMap03);  TEXTURE2D(_BumpMap03);
            TEXTURE2D(_SplatMap04);  TEXTURE2D(_BumpMap04);

        ENDHLSL

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma vertex TerrainVert
            #pragma fragment TerrainFrag

            #pragma shader_feature_local _ TERRAINTEXTURE_AUTOBLENDER_ON
            #pragma shader_feature_local _ _EMISSION_ON

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_ON
            #define _SHADOWS_SOFT

            struct SurfaceDescription
            {
                half3 BaseColor;
                half3 NormalTS;
                half3 Emission;
                half Metallic;
                half Smoothness;
                half Occlusion;
                half Alpha;
                float4 shadowCoord;
                half4 shadowMask;
            };

            Varyings_Terrain TerrainVert(Attributes_Terrain input)
            {
                Varyings_Terrain output = (Varyings_Terrain)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv.xy = input.uv.xy;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

	            half sign = input.tangentOS.w * GetOddNegativeScale();
                output.normalWS.xyz = TransformObjectToWorldNormal(input.normalOS);
	            output.tangentWS.xyz =TransformObjectToWorldDir(input.tangentOS.xyz);
	            output.bitangentWS.xyz = half3(sign * cross(output.normalWS.xyz, output.tangentWS.xyz));
                output.normalWS.w=positionWS.x;
                output.tangentWS.w=positionWS.y;
                output.bitangentWS.w=positionWS.z;

	            output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
		            output.fogFactor = ComputeFogFactor(output.positionCS.z);
	            #endif

	            // Indirect light
	            LIGHTMAP_VERT(input,output)

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    #if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
                        output.shadowCoord = ComputeScreenPos(input.positionCS);
                    #else
                        output.shadowCoord = TransformWorldToShadowCoord(positionWS);
                    #endif

                #endif

                return output;
            }

            void MountainBlender(float3 normalWS,float blenderPow,float2 sectionTop,float2 sectionMid,float2 sectionDown,
                out float lerpTop,out float lerpMid , out float lerpDown){

                sectionTop.y=max(sectionTop.x,sectionTop.y);
                float NDotUp = dot(normalWS.xyz, float3(0.0, 1.0, 0.0));
                float blenderDot = 1.0 - pow(abs(NDotUp),blenderPow);
                //
                lerpTop = smoothstep(sectionTop.x,sectionTop.y,blenderDot);
                //
                float sectionMidDownX =  sectionTop.x*sectionMid.x;
                float sectionMidDownY = sectionTop.x+(sectionTop.y-sectionTop.x)*sectionMid.y;
                lerpMid = smoothstep(sectionMidDownX,sectionMidDownY,blenderDot);
                //
                float sectionDownX = sectionMidDownX*sectionDown.x;
                float sectionDownY = sectionMidDownX + (sectionTop.y-sectionMidDownX)*sectionDown.y;
                lerpDown = smoothstep(sectionDownX,sectionDownY,blenderDot);
            }

            half4 TerrainFrag(Varyings_Terrain input) : SV_TARGET
            {
                float3 positionWS = float3(input.normalWS.w,input.tangentWS.w,input.bitangentWS.w);

                float2 controlUV = input.uv.xy;
                half4 splatControl = SAMPLE_TEXTURE2D(_Control, sampler_Control, controlUV);
                half splatControlR = splatControl.r;
                half splatControlG = splatControl.g;
                half splatControlB = splatControl.b;
                half splatControlA = splatControl.a;
                half summation=0.001;
                summation=splatControlR+splatControlG+splatControlB+splatControlA;

                //
                float2 textureUV = positionWS.xz*0.5;
                half4 splatMapColor = 0;
                float2 splatUV01 = textureUV*_SplatMap01_ST.xy+_SplatMap01_ST.zw;
                half4 splatColor01 = SAMPLE_TEXTURE2D(_SplatMap01, SamplerState_Linear_Repeat, splatUV01);
                splatColor01.rgb = splatColor01.rgb*_SplatMap01Color;
                float2 splatUV02 = textureUV*_SplatMap02_ST.xy+_SplatMap02_ST.zw;
                half4 splatColor02 = SAMPLE_TEXTURE2D(_SplatMap02, SamplerState_Linear_Repeat, splatUV02);
                splatColor02.rgb = splatColor02.rgb*_SplatMap02Color;
                float2 splatUV03 = textureUV*_SplatMap03_ST.xy+_SplatMap03_ST.zw;
                half4 splatColor03 = SAMPLE_TEXTURE2D(_SplatMap03, SamplerState_Linear_Repeat, splatUV03);
                splatColor03.rgb = splatColor03.rgb*_SplatMap02Color;
                float2 splatUV04 = textureUV*_SplatMap04_ST.xy+_SplatMap04_ST.zw;
                half4 splatColor04 = SAMPLE_TEXTURE2D(_SplatMap04, SamplerState_Linear_Repeat, splatUV04);
                splatColor04.rgb = splatColor04.rgb*_SplatMap02Color;

                #if defined(TERRAINTEXTURE_AUTOBLENDER_ON)

                    float blenderTopMid;
                    float blenderMidDownA;
                    float blenderMidDown;
          
                    MountainBlender(input.normalWS.xyz,_BlenderPow,_SectionTop,_SectionMid,_SectionDown,
                        blenderTopMid,blenderMidDownA , blenderMidDown);
                    splatMapColor = lerp(splatColor02,splatColor01,blenderTopMid);
                    splatMapColor = lerp(splatColor03,splatMapColor,blenderMidDownA);
                    splatMapColor = lerp(splatColor04,splatMapColor,blenderMidDown);

                #else
                    splatMapColor=splatColor01*splatControlR+splatColor02*splatControlG+splatColor03*splatControlB+splatColor04*splatControlA;
                    splatMapColor=splatMapColor/summation;
                #endif

                //
                half4 normalTS01 = SAMPLE_TEXTURE2D(_BumpMap01, SamplerState_Linear_Repeat, splatUV01);
                half4 normalTS02 = SAMPLE_TEXTURE2D(_BumpMap02, SamplerState_Linear_Repeat, splatUV02);
                half4 normalTS03 = SAMPLE_TEXTURE2D(_BumpMap03, SamplerState_Linear_Repeat, splatUV03);
                half4 normalTS04 = SAMPLE_TEXTURE2D(_BumpMap04, SamplerState_Linear_Repeat, splatUV04);

                #if defined(TERRAINTEXTURE_AUTOBLENDER_ON)
                    half4 normalTS = lerp(normalTS02,normalTS01,blenderTopMid);
                    normalTS = lerp(normalTS03,normalTS,blenderMidDownA);
                    normalTS = lerp(normalTS04,normalTS,blenderMidDown);
                    //
                    half normalScale = lerp(_BumpScale01,_BumpScale02,blenderTopMid);
                    normalScale = lerp(_BumpScale03,normalScale,blenderMidDownA);
                    normalScale = lerp(_BumpScale04,normalScale,blenderMidDown);
                    normalScale=clamp(normalScale,0.001,1.0);
                #else
                    half4 normalTS = normalTS01*splatControlR+normalTS02*splatControlG+normalTS03*splatControlB+normalTS04*splatControlA;
                    half normalScale = _BumpScale01*splatControlR + _BumpScale02*splatControlG + _BumpScale03*splatControlB+_BumpScale04*splatControlA;
                    normalScale=clamp(normalScale,0.001,1.0);
                    normalTS.xy =lerp(half2(0.5,0.5),normalTS.xy,summation);
                #endif

                half metallic = clamp(normalTS.b,0,1.0);
                half smoothness = clamp(normalTS.a,0,1.0);

                normalTS.xy=normalTS.rg*2.0-1.0;
                normalTS.xy *= normalScale;
                normalTS.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy))));

                //
                Light mainLight = GetMainLight();
                float3 lightDirWS = mainLight.direction;
                float3 lightColor = mainLight.color;
                float lightDistanceAtten = mainLight.distanceAttenuation;
                float lightShadowAtten = mainLight.shadowAttenuation;

                half3 emissionColor = 0;
                #if defined(_EMISSION_ON)
                    emissionColor = splatMapColor.rgb*_EmissionColor.rgb;
                #endif

                //
                half3 BaseColor = splatMapColor.rgb;
                half3 NormalTS = normalTS.xyz;
                half3 Emission = emissionColor;
                half Metallic = metallic*_Metallic;
                half Smoothness = smoothness*_Smoothness;
                half Occlusion = LerpWhiteTo(splatMapColor.g, _OcclusionStrength);
                half Alpha = 1;

                //
                SurfaceData outSurfaceData = (SurfaceData)0;
                outSurfaceData.alpha = Alpha;
                outSurfaceData.albedo = BaseColor;
                outSurfaceData.metallic = Metallic;
                outSurfaceData.specular = half3(0.0, 0.0, 0.0);
                outSurfaceData.smoothness = Smoothness;
                outSurfaceData.normalTS = normalTS.xyz;
                outSurfaceData.occlusion = Occlusion;
                outSurfaceData.emission = Emission;
                outSurfaceData.clearCoatMask       = half(0.0);
                outSurfaceData.clearCoatSmoothness = half(0.0);
                //
                InputData inputData = (InputData)0;
                inputData.positionWS = positionWS;
                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                float3 normalWS = TransformTangentToWorld(normalTS.xyz, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                normalWS = NormalizeNormalPerPixel(normalWS);
                inputData.normalWS = normalWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif
                GET_BACK_GI(input,normalWS)
                inputData.bakedGI=bakedGI;

                half4 color = UniversalFragmentPBR(inputData, outSurfaceData);
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
	                color.rgb = lerp(unity_FogColor.rgb, color.rgb , fogIntensity);
                #endif

                return half4(color.rgb,Alpha);
            }

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

            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }

    CustomEditor "NewRenderShaderGUI.TerrainShaderGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}