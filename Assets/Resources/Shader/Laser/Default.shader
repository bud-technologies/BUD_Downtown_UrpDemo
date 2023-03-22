
//镭射
Shader "NewRender/Laser/Default" {

    Properties{
        [KeywordEnum(A,B)] LASER_TYPE("Laser Type",Int) = 0
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "black" {}
		[MainColor]_BaseColor ("Main Color", Color) = (1.0,1.0,1.0,1)
        _LaserWaveStrength("镭射强度", Range(0, 4)) = 1
        _LaserWaveCount("镭射波数", Range(0.1, 10)) = 2

        [KeywordEnum(Off,Default,Blend)] _NORMAL("法线类型",Int) = 0
        _BumpMap ("法线", 2D) = "bump" {}
        _BumpScale("法线强度", Range(0, 2)) = 1
        //
        _BumpBlendScale("法线强度", Range(0, 2)) = 0.2

        [MaterialToggle(_LASER_INTERVENE_ON)] _LaserIntervene("二次干涉", float) = 0
        _LaserInterveneCount("二次干涉数量", Range(0.1, 10)) = 2

        [MaterialToggle(_LASER_TIME_ANIM_ON)] _LaserTimeAnim("时间动画", float) = 0
        _LaserTimeAnimSpeed("时间动画速度", Range(-5,5)) = 2

        [KeywordEnum(Unity,Custom)] _REFLECT_CUBE("Laser Cube",Int) = 0
        _ReflectMap ("Reflect Map", Cube) = "white" {}
        _ReflectMapMipLevel("MipMap", Range(0, 6)) = 1.5
    }

    SubShader{

        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex LaserVert
            #pragma fragment LaserFragment
            #pragma multi_compile_instancing 
            #pragma multi_compile_fog
            #pragma multi_compile _ _LASER_INTERVENE_ON
            #pragma multi_compile _ _LASER_TIME_ANIM_ON
            #pragma multi_compile LASER_TYPE_A LASER_TYPE_B
            #pragma multi_compile _REFLECT_CUBE_UNITY _REFLECT_CUBE_CUSTOM
            #pragma shader_feature_local _ _NORMAL_DEFAULT _NORMAL_BLEND

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
                //
                float4 _AmbientCol;
                float _FilmIOR;
                float _FilmStrength;
                float _FilmThickness;
                float _FilmSpread;
                float _GlossMapScale;
                float _Anisotropy;
            CBUFFER_END

            TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D_X(_BumpMap); SAMPLER(sampler_BumpMap);

            #if defined(_REFLECT_CUBE_CUSTOM)
                TEXTURECUBE(_ReflectMap);
                SAMPLER(sampler_ReflectMap);
            #endif

            TEXTURE2D(_MetallicGlossMap);
            SAMPLER(sampler_MetallicGlossMap);
            
            TEXTURE2D(_FilmStrengthMap);
            SAMPLER(sampler_FilmStrengthMap);

            struct Attributes_Laser {
                float4 positionOS : POSITION;
                float3 normalOS:NORMAL;
                float4 uv : TEXCOORD0;
                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    float4 tangentOS : TANGENT;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_Laser {
                float4 positionCS : SV_POSITION;
                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    float4 uv : TEXCOORD0;
                #else
                    float2 uv : TEXCOORD0;
                #endif
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;

                float3 viewDirWS : TEXCOORD3;
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half  fogFactor : TEXCOORD4;
                #endif

                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    float3 tangentWS : TEXCOORD5;
                    float3 bitangentWS : TEXCOORD6;
                #endif


                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            //计算镭射偏移
            //laserCount:偏移条纹数量
            //返回色散强度
            float LaserWave(float3 normal,float3 viewDir,float laserCount,float laserInterveneCount,float laserTimeAnimSpeed)
            {
                float NdotV=1.0-dot(normalize(normal),normalize(viewDir));
                float cosPar=NdotV*laserCount*2*L_PI;
                #if defined(_LASER_TIME_ANIM_ON)
                    float cosValue=1.0-(cos(cosPar+_Time.y*laserTimeAnimSpeed)*0.5+0.5);
                #else
                    float cosValue=1.0-(cos(cosPar)*0.5+0.5);
                #endif
                #if defined(_LASER_INTERVENE_ON)
                    float cosParIntervene=NdotV*laserCount*2*L_PI*laserInterveneCount;
                    #if defined(_LASER_TIME_ANIM_ON)
                        float cosValueIntervene=1.0-(cos(cosParIntervene+_Time.y*laserTimeAnimSpeed)*0.5+0.5);
                    #else
                        float cosValueIntervene=1.0-(cos(cosParIntervene)*0.5+0.5);
                    #endif
                    cosValue=cosValue*cosValueIntervene;
                #endif
                return cosValue;
            }

            Varyings_Laser LaserVert(Attributes_Laser input) {
                Varyings_Laser output = (Varyings_Laser)0;

                // Instance
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                output.positionWS =   TransformObjectToWorld(input.positionOS.xyz);

                output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    output.uv.zw = TRANSFORM_TEX(input.uv.xy,_BumpMap);
                #endif

                output.normalWS =  GetNormalWorld(input.normalOS.xyz);
                output.viewDirWS = _WorldSpaceCameraPos - TransformObjectToWorld(input.positionOS.xyz);
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z); 
                #endif         

                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                    half sign = input.tangentOS.w * GetOddNegativeScale();
                    output.tangentWS = half3(normalInput.tangentWS.xyz);
                    output.bitangentWS = half3(sign * cross(normalInput.normalWS.xyz, normalInput.tangentWS.xyz));
                    output.normalWS = normalInput.normalWS.xyz;
                #endif      

                return output;
            }

            half4 LaserFragment(Varyings_Laser input) : SV_Target{
                UNITY_SETUP_INSTANCE_ID(input);

                half3 normalWS=input.normalWS;
                #if defined(_NORMAL_DEFAULT) || defined(_NORMAL_BLEND)
                    half4 normalTex=SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,input.uv.zw);
                    //
    	            half3 normalTS = UnpackNormalScale_RG(normalTex,_BumpScale);
                    //
                    half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                    normalWS = normalize(mul(normalTS,TBN));
                    #if defined(_NORMAL_BLEND)
                        normalTS = UnpackNormalScale_BA(normalTex,_BumpScale);
                        half3 normalWS_Blend = normalize(mul(normalTS,TBN));
                        //
                        normalWS=NormalBlendLinear(normalWS,normalWS_Blend*_BumpBlendScale);
                    #endif
                #endif

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy)*_BaseColor;
    
                float laserValue=LaserWave(normalWS,input.viewDirWS,_LaserWaveCount,_LaserInterveneCount,_LaserTimeAnimSpeed)*_LaserWaveStrength;
                half3 reflectDir = normalize(reflect(-input.viewDirWS,normalWS));

                float VDotN=dot(normalize(input.viewDirWS),normalWS);
                float mipLevel=lerp(_ReflectMapMipLevel+_ReflectMapMipLevel*2,_ReflectMapMipLevel,VDotN);

                #if defined(LASER_TYPE_A)
                    float3 reflectUV_R=float3(reflectDir.x, reflectDir.y, reflectDir.z);
                    float3 reflectUV_G=reflectDir+laserValue.xxx;
                    float3 reflectUV_B=reflectDir-laserValue.xxx;
                #elif defined(LASER_TYPE_B)
                    float3 reflectUV_R=float3(reflectDir.x+ laserValue, reflectDir.y, reflectDir.z);
                    float3 reflectUV_G=float3(reflectDir.x, reflectDir.y, reflectDir.z);
                    float3 reflectUV_B=float3(reflectDir.x, reflectDir.y + laserValue,reflectDir.z);
                #endif

                #if defined(_REFLECT_CUBE_UNITY)
                    float reflect_color_R = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0,reflectUV_R,mipLevel).r;
                    float reflect_color_G = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0,reflectUV_G,mipLevel).g;
                    float reflect_color_B = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0,reflectUV_B,mipLevel).b;
                #elif defined(_REFLECT_CUBE_CUSTOM)
                    float reflect_color_R = SAMPLE_TEXTURECUBE_LOD(_ReflectMap,sampler_ReflectMap,reflectUV_R,mipLevel).r;
                    float reflect_color_G = SAMPLE_TEXTURECUBE_LOD(_ReflectMap,sampler_ReflectMap,reflectUV_G,mipLevel).g;
                    float reflect_color_B = SAMPLE_TEXTURECUBE_LOD(_ReflectMap,sampler_ReflectMap,reflectUV_B,mipLevel).b;
                #endif

                float3 reflect=float3(reflect_color_R,reflect_color_G,reflect_color_B);
                reflect=clamp(reflect,0,16);

                half4 finColor=baseMap;
                finColor.rgb=finColor.rgb+reflect;

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
