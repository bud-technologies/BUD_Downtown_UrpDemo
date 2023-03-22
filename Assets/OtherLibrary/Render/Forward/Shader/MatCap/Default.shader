Shader "NewRender/Matcap/Default"
{
    //Matcap 材质
    Properties
    {
       [MainTexture] _BaseMap ("Base Map", 2D) = "black" {}
       [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

       _MatcapMap ("Matcap Map", 2D) = "black" {}
       _MatcapScale ("Matcap Scale", Range(0, 2)) = 1.0

       _BumpMap ("Normal Map", 2D) = "bump" {}
       _BumpScale ("Normal Scale", Range(0, 2)) = 1.0

       _NormalAnimToggle("NormalAnim(法线动画)",int) = 0
       _NormalAnim ("NormalAnim (x, y, z, 速度)", vector) = (0.1,0.1,0.1,0.3)

       _UVScale("UVScale",float) = 1

       [HideInInspector] _Surface("__surface", Float) = 0.0
       [HideInInspector] _Blend("__blend", Float) = 0.0
       [HideInInspector] _AlphaClip("__clip", Float) = 0.0
       [HideInInspector] _SrcBlend("__src", Float) = 1.0
       [HideInInspector] _DstBlend("__dst", Float) = 0.0
       [HideInInspector] _ZWrite("__zw", Float) = 1.0
       [HideInInspector] _Cull("__cull", Float) = 2.0
       [HideInInspector] _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
       [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
       [HideInInspector] [Toggle] _EnvLight ("Env Lighting", Float) = 0.0
       [HideInInspector] _ColorBlendMode ("Blend Mode", Float) = 2.0

       [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
       [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}

        Pass
        {
            Name "Matcap"
            Tags { "LightMode" = "UniversalForward" }
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM

            #pragma shader_feature _NORMAL_ON
            #pragma shader_feature _MATCAP_ON
            #pragma shader_feature _ _NORMAL_ANIMATION_ON
            #pragma shader_feature MATCAP_OVERLAY MATCAP_MULTIPLY MATCAP_ADDITIVE MATCAP_SOFTLIGHT MATCAP_PINLIGHT MATCAP_LIGHTEN MATCAP_DARKEN

            #pragma vertex MatCapVertex
            #pragma fragment MatCapFragment
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Library/Math.hlsl"
            #include "../Library/Common/CommonFunction.hlsl"

            CBUFFER_START(UnityPerMaterial)
	            float4 _BaseMap_ST;
	            half4 _BaseColor;
	            half _BumpScale;
	            half _MatcapScale;
	            half4 _NormalAnim;
	            half _UVScale;
            CBUFFER_END

            TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MatcapMap);  SAMPLER(sampler_MatcapMap);
            TEXTURE2D(_BumpMap);  SAMPLER(sampler_BumpMap);

            struct Attributes_MatCap
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                #if defined(_MATCAP_ON)
                    half3 normalOS    : NORMAL;
                #endif
                #if defined(_MATCAP_ON) && defined(_NORMAL_ON)
                    half4 tangentOS   : TANGENT;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_MatCap
            {
                float4 positionCS : SV_POSITION;
                #if defined(_MATCAP_ON)
                    float4 uv         : TEXCOORD0;
                #else
                    float2 uv         : TEXCOORD0;
                #endif
                #if defined(_MATCAP_ON) && defined(_NORMAL_ON)
                    half3 normalWS    : TEXCOORD1;
                    half4 tangentWS   : TEXCOORD2;
                    half3 positionVS  : TEXCOORD3;
                #endif
                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half  fogFactor : TEXCOORD4;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings_MatCap MatCapVertex (Attributes_MatCap input)
            {
                Varyings_MatCap output=(Varyings_MatCap)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
    
                // Position
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;

                // Model uv
                output.uv.xy = input.uv.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                // Matcap uv  外圈收缩 内圈扩散
                #if defined(_MATCAP_ON) && !defined(_NORMAL_ON)
                    half3 normalVS = normalize(mul((half3x3)UNITY_MATRIX_MV, input.normalOS));
                    half3 r = normalize(reflect(vertexInput.positionVS, normalVS));
                    #if defined(_NORMAL_ANIMATION_ON)
                       //法线动画
                        half radius = _NormalAnim.w * _Time.y;
                        r = normalize(Rotate(r, normalize(_NormalAnim.xyz).xyz, radius));
                    #endif
                    half m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
                    output.uv.zw = r.xy / m + 0.5;

                    output.uv.zw -= half2(0.5,0.5);
                    output.uv.zw *= _UVScale;
                    output.uv.zw += half2(0.5, 0.5);

                #endif

                #if defined(_MATCAP_ON) && defined(_NORMAL_ON)
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                    real sign = input.tangentOS.w * GetOddNegativeScale();
                    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
                    output.normalWS = normalInput.normalWS;
                    output.positionVS = vertexInput.positionVS;
                #endif

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    output.fogFactor = ComputeFogFactor(output.positionCS.z);
                #endif

                return output;
            }

            half4 MatCapFragment (Varyings_MatCap input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // sample the texture
                half4 base = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
                #if defined(_MATCAP_ON) && defined(_NORMAL_ON)
                    half sgn = input.tangentWS.w;      // should be either +1 or -1
                    half3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half4 normalMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BaseMap, input.uv.xy);
                    half3 normalTS = UnpackNormalScale(normalMap, _BumpScale);
                    half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
                    half3 normalVS = normalize(mul((half3x3)UNITY_MATRIX_V, normalWS));
                    half3 r = normalize(reflect(input.positionVS, normalVS));
                    #if defined(_NORMAL_ANIMATION_ON)
                        half radius = _NormalAnim.w * _Time.y;
                        _NormalAnim.xyz = normalize(_NormalAnim.xyz);
                        r = normalize(Rotate(r, _NormalAnim.xyz, radius));
                    #endif
                    half m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
                    input.uv.zw = r.xy / m + 0.5;

                    input.uv.zw -= half2(0.5, 0.5);
                    input.uv.zw *= _UVScale;
                    input.uv.zw += half2(0.5, 0.5);
                #endif

                #if defined(_MATCAP_ON)
                    half4 matcap = SAMPLE_TEXTURE2D(_MatcapMap, sampler_MatcapMap, input.uv.zw);
                    #if defined(MATCAP_OVERLAY)
                        half3 result1 = 1.0 - 2.0 * (1.0 - base.rgb) * (1.0 - matcap.rgb);
                        half3 result2 = 2.0 * base.rgb * matcap.rgb;
                        half3 zeroOrOne = step(base.rgb, 0.5);
                        half3 final = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                        base.rgb = lerp(base.rgb, final, _MatcapScale);
                    #elif defined(MATCAP_MULTIPLY)
                        half3 final = base.rgb * matcap.rgb;
                        base.rgb = lerp(base.rgb, final, _MatcapScale);

                    #elif defined(MATCAP_ADDITIVE)
                        base.rgb += matcap.rgb * _MatcapScale;

                    #elif defined(MATCAP_SOFTLIGHT)
                        half3 result1 = 2.0 * base.rgb * matcap.rgb + base.rgb * base.rgb * (1.0 - 2.0 * matcap.rgb);
                        half3 result2 = sqrt(base.rgb) * (2.0 * matcap.rgb - 1.0) + 2.0 * base.rgb * (1.0 - matcap.rgb);
                        half3 zeroOrOne = step(0.5, matcap.rgb);
                        half3 final = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                        base.rgb = lerp(base.rgb, final, _MatcapScale);

                    #elif defined(MATCAP_PINLIGHT)
                        half3 check = step (0.5, matcap.rgb);
                        half3 result1 = check * max(2.0 * (base.rgb - 0.5), matcap.rgb);
                        half3 final = result1 + (1.0 - check) * min(2.0 * base.rgb, matcap.rgb);
                        base.rgb = lerp(base.rgb, final, _MatcapScale);

                    #elif defined(MATCAP_LIGHTEN)
                        half3 final = max(matcap.rgb, base.rgb);
                        base.rgb = lerp(base.rgb, final, _MatcapScale);

                    #elif defined(MATCAP_DARKEN)
                        half3 final = min(matcap.rgb, base.rgb);
                        base.rgb = lerp(base.rgb, final, _MatcapScale);

                    #endif
                #endif

                half4 finColor=base * _BaseColor;

                #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
                    half fogIntensity = ComputeFogIntensity(input.fogFactor);
		            finColor.rgb = lerp(unity_FogColor.rgb, finColor.rgb, fogIntensity);
                #endif

                return finColor;
            }
            
            ENDHLSL
        }

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "NewRenderShaderGUI.MatcapShaderGUI"
}
