
//面比率 要求纹理不能由色相突变
Shader "NewRender/ColorShift/Default" {

    Properties{
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		[MainColor]_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)
        _GIScale("GI Scale", Range(0, 1)) = 0.3
        _FresnelPow("FresnelPow", Range(0.01, 10)) = 4
        _PhongLightPow("PhongLightPow", Range(0.01, 10)) = 4

        [KeywordEnum(Off,Common,HighQualityPicture)] _COLORSHIFT("颜色偏移",Int) = 0
        [KeywordEnum(Off,Fresnel,VDotN,VDotNPower,VDotNStrength,VDotNRamp,VDotNMainLight,VDotNMainLightStrength,NDotHPhong)] _COLORSHIFT_DEBUG("调试",Int) = 0
        _LerpLeft("LerpLeft(区域映射 左)", float) = -0.15
        _LerpMid("LerpMid(区域映射 中)", float) = 0
        _LerpRight("LerpRight(区域映射 右)", float) = 0.3

        _NormalReflectStrength("NormalReflectStrength(法线偏移)", Range(1, 50)) = 3.4
        _VDotNPow("VDotNPow", Range(0, 10)) = 4.03
        _VDotNStrength("VDotNStrength", Range(0, 2)) = 1.2
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex ColorShiftVert
            #pragma fragment ColorShiftFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _COLORSHIFT_COMMON _COLORSHIFT_HIGHQUALITYPICTURE
            #pragma shader_feature_local _ _COLORSHIFT_DEBUG_FRESNEL _COLORSHIFT_DEBUG_VDOTN _COLORSHIFT_DEBUG_VDOTNPOWER _COLORSHIFT_DEBUG_VDOTNSTRENGTH _COLORSHIFT_DEBUG_VDOTNRAMP _COLORSHIFT_DEBUG_VDOTNMAINLIGHT _COLORSHIFT_DEBUG_VDOTNMAINLIGHTSTRENGTH _COLORSHIFT_DEBUG_NDOTHPHONG

            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Texture/TextureLib.hlsl"
            #include "../Library/Normal/NormalLib.hlsl"

            CBUFFER_START(UnityPerMaterial)

                float4 _BaseMap_ST;
                float4 _BaseColor;
                half _ColorShiftPow;
                half _ColorShiftStrength;

                half _LerpLeft;
                half _LerpMid;
                half _LerpRight;
                float _NormalReflectStrength;
                float _VDotNPow;
                half _VDotNStrength;
                half _COLORSHIFT_DEBUG;
                half _COLORSHIFT;
                half _FresnelPow;
                half _PhongLightPow;
                half _GIScale;

            CBUFFER_END

            TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);

            struct Attributes_ColorShift {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 uv : TEXCOORD0;
                float4 lightmapUV   : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_ColorShift {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                half  fogFactor : TEXCOORD3;
            #endif
	            DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct ColorShiftLightData{
                half3 albedo;
                half3 viewDirWS;
                half3 normalWS;
                float3 positionWS;
                float vDotN;
                half3 bakedGI;
                float shadowAttenuation;
                float fresnel;
            };

            Varyings_ColorShift ColorShiftVert(Attributes_ColorShift input) {
                Varyings_ColorShift output = (Varyings_ColorShift)0;

                // Instance
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
                output.positionWS =   TransformObjectToWorld(input.positionOS.xyz);
                //GetWorldNormal
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS.xyz));

                // Indirect light
	            OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
	            OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
                #endif         

                return output;
            }

            float3 GetSaturation(float3 inColor,float _Saturation)
            {
                float luminance = 0.2125 * inColor.r + 0.7154 * inColor.g + 0.0721 * inColor.b;
 	            inColor.rgb +=  (inColor.rgb - luminance.xxx) * _Saturation;
                inColor = saturate(inColor);
	            return inColor;
            }

            //需要对图片进行PS错误更正
            half3 RGBColorHMOutRGB_HighQualityPicture(half3 targetRgbColor,float highlightMulriple){
                half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                half4 P = lerp(half4(targetRgbColor.bg, K.wz), half4(targetRgbColor.gb, K.xy), step(targetRgbColor.b, targetRgbColor.g));
                half4 Q = lerp(half4(P.xyw, targetRgbColor.r), half4(targetRgbColor.r, P.yzx), step(P.x, targetRgbColor.r));
                half D = Q.x - min(Q.w, Q.y);
                half E =0.0001;
                half3 hsvValue = half3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
                float stepA=lerp(1.0/6.0,0.5,step(1.0/3.0,hsvValue.r));
                float highlightColorAngle=lerp(stepA,5.0/6.0,step(2.0/3.0,hsvValue.r));
                float minColorAngle=saturate(highlightColorAngle-1.0/6.0);
                float maxColorAngle=saturate(highlightColorAngle+1.0/6.0);
                float darkenColorAngle = lerp(minColorAngle,maxColorAngle, step(highlightColorAngle,hsvValue.r));
                float stepMulriple=step(1,highlightMulriple);
                float blastX=hsvValue.g/highlightMulriple;
                float blastY=  1.0-(1.0-hsvValue.b)/highlightMulriple;
                float blastZ= lerp(highlightColorAngle,hsvValue.r,1.0/highlightMulriple);
                float darkenX= 1.0-(1.0-hsvValue.g)*highlightMulriple;
                float darkenY= hsvValue.b*highlightMulriple;
                float darkenZ=lerp(hsvValue.r,darkenColorAngle,1.0-highlightMulriple);
                float3 setResXYZ=lerp(float3(darkenZ,darkenX,darkenY),float3(blastZ,blastX,blastY),stepMulriple);
                K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                P.rgb = abs(frac(setResXYZ.xxx + K.xyz) * 6.0 - K.www);
                return setResXYZ.z * lerp(K.xxx, saturate(P.rgb - K.xxx), setResXYZ.y);
            }

            //aohedu
            half3 RGBColorHMOutRGB_S(half3 targetRgbColor,float highlightMulriple){
                float saturation;
                half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                half4 P = lerp(half4(targetRgbColor.bg, K.wz), half4(targetRgbColor.gb, K.xy), step(targetRgbColor.b, targetRgbColor.g));
                half4 Q = lerp(half4(P.xyw, targetRgbColor.r), half4(targetRgbColor.r, P.yzx), step(P.x, targetRgbColor.r));
                half D = Q.x - min(Q.w, Q.y);
                half E =0.0001;
                half3 hsvValue = half3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
                float stepA=lerp(1.0/6.0,0.5,step(1.0/3.0,hsvValue.r));
                float highlightColorAngle=lerp(stepA,5.0/6.0,step(2.0/3.0,hsvValue.r));
                float minColorAngle=saturate(highlightColorAngle-1.0/6.0);
                float maxColorAngle=saturate(highlightColorAngle+1.0/6.0);
                float darkenColorAngle = lerp(minColorAngle,maxColorAngle, step(highlightColorAngle,hsvValue.r));
                float stepMulriple=step(1,highlightMulriple);
                float blastX=hsvValue.g;
                float saturationX=hsvValue.g/highlightMulriple;
                float blastY=  1.0-(1.0-hsvValue.b)/highlightMulriple;
                float blastZ= lerp(highlightColorAngle,hsvValue.r,1.0/highlightMulriple);
                float darkenX= hsvValue.g;
                float saturationY = 1.0-(1.0-hsvValue.g)*highlightMulriple;
                float darkenY= hsvValue.b*highlightMulriple;
                float darkenZ=lerp(hsvValue.r,darkenColorAngle,1.0-highlightMulriple);
                float3 setResXYZ=lerp(float3(darkenZ,darkenX,darkenY),float3(blastZ,blastX,blastY),stepMulriple);
                saturation=lerp(saturationY,saturationX,stepMulriple);
                K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                P.rgb = abs(frac(setResXYZ.xxx + K.xyz) * 6.0 - K.www);
                half3 res  = setResXYZ.z * lerp(K.xxx, saturate(P.rgb - K.xxx), setResXYZ.y);
                return GetSaturation(res,saturation);
            }

            float LerpMedianValueSliderRamp(float min,float max,float median,float newMin, float newMax,float newMedian, float value)
            {
                float m_r = (value - median) / (max- median);    
                float m_step = step(0,m_r);
                float m_l = (value - median) / (min - median);
                float m = lerp(m_l, m_r, m_step);
                //
                float res_r = newMedian + (newMax - newMedian) * m;
                float res_l = newMedian - (newMedian- newMin)*m;
                return lerp(res_l, res_r, m_step);
            }

            half3 ColorShiftLightBase(ColorShiftLightData colorShiftLightData,Light light){
                float NDotL = dot(normalize(colorShiftLightData.normalWS),normalize(light.direction));
                NDotL=NDotL*0.5+0.5;
                NDotL=saturate(NDotL);

                float radiance =(light.distanceAttenuation * colorShiftLightData.shadowAttenuation * NDotL);

                #if defined(_COLORSHIFT_COMMON) || defined(_COLORSHIFT_HIGHQUALITYPICTURE)
                    float maxGI=max(max(colorShiftLightData.bakedGI.r,colorShiftLightData.bakedGI.g),colorShiftLightData.bakedGI.b);
                    colorShiftLightData.vDotN=colorShiftLightData.vDotN*(radiance+maxGI);

                    #if defined(_COLORSHIFT_DEBUG_VDOTNMAINLIGHT)
                        return colorShiftLightData.vDotN;
                    #endif

                    float albedoStrength=radiance+colorShiftLightData.vDotN;

                    #if defined(_COLORSHIFT_DEBUG_VDOTNMAINLIGHTSTRENGTH)
                        return albedoStrength;
                    #endif
                #endif

                half3 albedo=colorShiftLightData.albedo;

                #if defined(_COLORSHIFT_COMMON)
                    albedo.rgb = albedo.rgb*lerp(half3(1,1,1),light.color,clamp(radiance,0,1));
                    albedo.rgb = RGBColorHMOutRGB_S(albedo.rgb,albedoStrength);//复杂色彩 
                #elif defined(_COLORSHIFT_HIGHQUALITYPICTURE)
                    albedo.rgb = albedo.rgb*lerp(half3(1,1,1),light.color,clamp(radiance,0,1));
                    albedo.rgb = RGBColorHMOutRGB_HighQualityPicture(albedo.rgb,albedoStrength);//复杂色彩 纹理要求高 
                #else
                    albedo.rgb=albedo.rgb*radiance*light.color;
                #endif

                float3 h = normalize(colorShiftLightData.viewDirWS+light.direction);
                float NDotH =saturate(dot(h,colorShiftLightData.normalWS));
                NDotH=pow(NDotH,_PhongLightPow)*colorShiftLightData.fresnel;

                #if defined(_COLORSHIFT_DEBUG_NDOTHPHONG)
                    return NDotH;
                #endif

                return albedo+NDotH*light.color+colorShiftLightData.fresnel*radiance*colorShiftLightData.bakedGI;
            }

            half3 ColorShiftLightFrag(Varyings_ColorShift input, ColorShiftLightData colorShiftLightData){
                #if defined(_COLORSHIFT_COMMON) || defined(_COLORSHIFT_HIGHQUALITYPICTURE)
                        float fresnel=pow(abs(1.0 - saturate(dot(normalize(colorShiftLightData.viewDirWS),input.normalWS))),_FresnelPow);
                        float VDotN = dot(normalize(-colorShiftLightData.viewDirWS+input.normalWS*_NormalReflectStrength),colorShiftLightData.viewDirWS);
                    #if defined(_COLORSHIFT_DEBUG_VDOTN)
                        return VDotN;
                    #endif

                        float absVDotN = pow(abs(VDotN),_VDotNPow);
                        float stepVDotN=step(0,VDotN);
                        VDotN=lerp(-absVDotN,absVDotN,stepVDotN);

                    #if defined(_COLORSHIFT_DEBUG_VDOTNPOWER)
                        return VDotN;
                    #endif

                        VDotN=VDotN*_VDotNStrength;
                    #if defined(_COLORSHIFT_DEBUG_VDOTNSTRENGTH)
                        return VDotN;
                    #endif

                        VDotN=LerpMedianValueSliderRamp(-1,1,0,_LerpLeft,_LerpRight,_LerpMid,VDotN);
                    #if defined(_COLORSHIFT_DEBUG_VDOTNRAMP)
                        return VDotN;
                    #endif
                #else
                    float VDotN = saturate(dot(input.normalWS,colorShiftLightData.viewDirWS));
                    float fresnel=pow(abs(1.0 - VDotN),_FresnelPow);
                #endif

                colorShiftLightData.fresnel=fresnel;

                 #if defined(_COLORSHIFT_DEBUG_FRESNEL)
                    return colorShiftLightData.fresnel;
                 #endif

                    colorShiftLightData.vDotN=VDotN;
                    Light mainLight = GetMainLight();
                    half3 bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);
                    colorShiftLightData.bakedGI=bakedGI;

                    half3 resColor=half3(0,0,0);
                    resColor=resColor+ColorShiftLightBase(colorShiftLightData, mainLight)+bakedGI*_GIScale;

                #if defined(_COLORSHIFT_DEBUG_VDOTNMAINLIGHT) || defined(_COLORSHIFT_DEBUG_VDOTNMAINLIGHTSTRENGTH) || defined(_COLORSHIFT_DEBUG_NDOTHPHONG)
                    return resColor;
                #endif

            #ifdef _ADDITIONAL_LIGHTS
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, colorShiftLightData.positionWS);
                    resColor += ColorShiftLightBase(colorShiftLightData,light);
                }
            #endif
    
                return resColor;

            }

            half4 ColorShiftFragment(Varyings_ColorShift input) : SV_Target{
                UNITY_SETUP_INSTANCE_ID(input);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;
                ColorShiftLightData colorShiftLightData=(ColorShiftLightData)0;
                colorShiftLightData.albedo=baseMap.rgb;
                colorShiftLightData.viewDirWS=normalize(GetCameraPositionWS().xyz - input.positionWS.xyz);
                colorShiftLightData.shadowAttenuation=1;
                colorShiftLightData.normalWS=input.normalWS;
                colorShiftLightData.positionWS=input.positionWS;

                half4 finColor=half4(ColorShiftLightFrag(input,colorShiftLightData),1);
    
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
	                finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb , fogIntensity);
                #endif

                return finColor;

            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
