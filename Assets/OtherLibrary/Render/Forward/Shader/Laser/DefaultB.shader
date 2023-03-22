Shader "NewRender/Laser/DefaultB"
{
    Properties
    {
        [KeywordEnum(A,B)] LASER_TYPE("Laser Type",Int) = 0
        [KeywordEnum(Unity,Custom)] _REFLECT_CUBE("Laser Cube",Int) = 0
        [MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "black" {}
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        _AmbientCol("AmbientCol", Color) = (.75, .75, .75,1)

        [Normal]_BumpMap("法线",2D) = "bump" {}
        _BumpScale("法线强度",Float) = 1

        _FilmStrengthMap("FilmStrengthMap",2D) = "white" {}
        _FilmIOR("FilmIOR",Float) = .3
        _FilmStrength("FilmStrength",Float) = 1
        _FilmThickness("FilmThickness",Float) = 0.137
        _FilmSpread("FilmSpread",Range(0.5,3)) = 1

        _MetallicGlossMap("RGB: 金属度 AO 光滑度",2D)  = "black" {}
        _GlossMapScale("GlossMapScale",Range(0,1)) = 1
        _Anisotropy("Anisotropy",Range(-1,1)) = 0

        [HideInInspector] _MainTex("_MainTex", 2D) = "white" {}
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque" 
        }
        
        
        Pass{
            
            Tags{ "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex LaserVert
            #pragma fragment frag
            #define _NORMAL_DEFAULT
            #pragma multi_compile LASER_TYPE_A LASER_TYPE_B
            #pragma multi_compile _REFLECT_CUBE_UNITY _REFLECT_CUBE_CUSTOM

            #include "../Library/Common/CommonFunction.hlsl"
            #include "../Library/Texture/TextureLib.hlsl"
            #include "../Library/Normal/NormalLib.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

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

            half4 frag(Varyings_Laser input):SV_Target
            {
                // sample map
                float3 base_color = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy * _BaseMap_ST.xy + _BaseMap_ST.zw).rgb * _BaseColor.rgb;
                float2 pbr_map = SAMPLE_TEXTURE2D(_MetallicGlossMap,sampler_MetallicGlossMap,input.uv.xy).xy;
                float4 normal_map = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,input.uv.xy);
                float film_map = SAMPLE_TEXTURE2D(_FilmStrengthMap,sampler_FilmStrengthMap,input.uv.xy).r;

                // get light
                Light light_data = GetMainLight();

                // get dir
                float3 light_dir = SafeNormalize(light_data.direction);
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - input.positionWS);
                float3 normal_dir = normalize(input.normalWS);
                float3 tangent_dir = normalize(input.tangentWS);
                float3 binormal_dir = normalize(input.bitangentWS);
                
                float3x3 TBN = float3x3(tangent_dir,binormal_dir,normal_dir);
                
                float3 normal_data = UnpackNormal(normal_map);
                normal_data.xy *= _BumpScale;
                normal_dir = normalize(mul(normal_data,TBN));

                float3 binormal_negative = cross(-normal_dir,tangent_dir);

                // get data from dir
                float NdotV = saturate(dot(normal_dir, view_dir));
                float NdotV2 = NdotV * NdotV;

                float NdotL = saturate(dot(normal_dir,light_dir));
                
                float TdotL = dot(tangent_dir, light_dir);
                float TdotV = dot(tangent_dir, view_dir);
                float TdotV2 = TdotV * TdotV;

                float BdotL = dot(binormal_negative, light_dir);
                float BdotV = dot(binormal_negative, view_dir);
                float BdotV2 = BdotV * BdotV;

                float LdotV = saturate(dot(light_dir, view_dir));
                float oneMinusLdotV = 1.0 - LdotV;
                
                float oneMinusLdotV5 = pow(oneMinusLdotV,5);    // or be 0
                float ultraLdotV = 1.0 - oneMinusLdotV5;

                float3 radiance = NdotL * light_data.color;

                // get data from map
                float metallic = pbr_map.x;
                float oneMinusMetallic = (1.0 - metallic) * 0.95999998;

                float smoothness = (1.0 - pbr_map.y * _GlossMapScale);
                smoothness = max((smoothness * smoothness), 0.001);

                // anisotropy
                float anisotropy1 = 1 -_Anisotropy;
                anisotropy1 = (anisotropy1 * smoothness);

                float anisotropy2 = _Anisotropy + 1.0;
                anisotropy2 = (anisotropy2 * smoothness);

                float2 final_anisotropy = 0;
                final_anisotropy.x = max(anisotropy1, 0.0099999998);
                final_anisotropy.y = max(anisotropy2, 0.0099999998);

                // ----------------                
                float BoL_mul_A = BdotL * final_anisotropy.x;
                float ToL_mul_A = TdotL * final_anisotropy.y;
                float anisotropy_length1 = length(float3(ToL_mul_A,BoL_mul_A,0)) * NdotV;
                
                float ToV_mul_A = TdotV * final_anisotropy.y;
                float BoV_mul_A = BdotV * final_anisotropy.x;
                float anisotropy_length2 = length(float3(ToV_mul_A,BoV_mul_A,0));

                float final_anisotropy_length = NdotL * (anisotropy_length1 + anisotropy_length2);    // NdotL * anisotropy_length1 + anisotropy_length2
                final_anisotropy_length = 0.5 / final_anisotropy_length;
                final_anisotropy_length = min(final_anisotropy_length, 1.0);

                float2 final_anisotropy2 = final_anisotropy.yx * final_anisotropy.yx;
                float ToV_div_A2 = TdotV2 / final_anisotropy2.x;
                float BoV_div_A2 = BdotV2 / final_anisotropy2.y;
                
                half BTN = BoV_div_A2 + ToV_div_A2 + NdotV2;

                // caculate albedo and light_dir_color
                half3 albedo = base_color.xyz * 0.30530602 + float3(0.68217111, 0.68217111, 0.68217111);
                albedo = base_color.xyz * albedo + float3(0.012522878, 0.012522878, 0.012522878);

                half3 light_dir_color = base_color.xyz * albedo + float3(-0.039999999, -0.039999999, -0.039999999);
                light_dir_color = metallic * light_dir_color + float3(0.039999999, 0.039999999, 0.039999999);
                light_dir_color = light_dir_color * ultraLdotV + oneMinusLdotV5;

                float3 final_albedo = base_color.xyz * albedo;

                // caculate hight light mask
                half3 hight_light_factor = (BTN * BTN * final_anisotropy.x * final_anisotropy.y * PI).xxx;
                hight_light_factor = 1.0 / hight_light_factor;
                
                hight_light_factor = hight_light_factor * final_anisotropy_length * light_dir_color;
                hight_light_factor = pow(abs(hight_light_factor) , 1.0 / _FilmSpread);

                // caculate film color
                half BoV_lerp_ToV = lerp(BdotV,TdotV,_Anisotropy);
                half filmThickness = abs(BoV_lerp_ToV) * _FilmThickness - _FilmIOR;

                float3 film_color = cos(filmThickness * float3(24.849998, 30.450001, 35.0));
                film_color = film_color * -0.5 + float3(0.5, 0.5, 0.5);
                film_color = lerp(film_color,0.5,filmThickness);
                film_color = film_color * film_color * _FilmStrength.x * 2;
                film_color = film_map * hight_light_factor * film_color ;
                film_color = film_color + float3(-9.9999997e-05, -9.9999997e-05, -9.9999997e-05);
                film_color = min(max(film_color, 0), 100) + final_albedo * oneMinusMetallic;

                // caculate ambient color
                float3 ambient_color = oneMinusMetallic * final_albedo * _AmbientCol.xyz;

                // combine color
                float3 final_color = max(film_color * radiance + ambient_color,0);
                final_color = pow(final_color, 0.41666666) * 1.0549999 + float3(-0.055, -0.055, -0.055);
                final_color = max(final_color.xyz,0);

                return float4(final_color,1);
                
            }
            ENDHLSL 
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
