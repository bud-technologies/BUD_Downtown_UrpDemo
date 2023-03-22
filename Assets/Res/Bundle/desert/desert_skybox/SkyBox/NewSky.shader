Shader "Custom/NewSkyBox"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        [HDR]_Color2 ("Color2", Color) = (1,1,1,1)
        
        _Mult("mult", Float) = 1
        _Power("pwer", Float) = 1
        //[Toggle(_SCREENSPACE_ON)] _Screenspace("Screen space", Float) = 0 
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Queue" 
            "RenderPipeline"="UniversalPipeline" 
        } 

        Pass
        {
            HLSLPROGRAM

            #pragma vertex SkyBoxVert
            #pragma fragment SkyBoxFrag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)

                half4 _Color;
                half4 _Color2;
                half _Mult;
                half _Power;

            CBUFFER_END

            struct Attributes_SkyBox
            {
                float4 positionOS   :   POSITION;
                float4 color        :   COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings_SkyBox
            {
                float4 positionCS   :   SV_POSITION;
                float4 positionOS   :   TEXCOORD0;
                float4 screenPos    :   TEXCOORD1;
            };

            Varyings_SkyBox SkyBoxVert (Attributes_SkyBox v)
            {
                Varyings_SkyBox o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

                o.screenPos = ComputeScreenPos(o.positionCS);
                o.positionOS = v.positionOS; 
                return o;
            }

            half4 SkyBoxFrag (Varyings_SkyBox i) : SV_Target
            {
                float4 screenPos = i.screenPos;
                float2 screenPosNorm = screenPos.xy / screenPos.w;

                // #ifdef _SCREENSPACE_ON
                    //float staticSwitch = screenPosNorm.y;
                // #else
                    float staticSwitch = i.positionOS.y;
                //#endif

                half4 col = lerp(_Color2,_Color, pow(saturate(staticSwitch * _Mult),_Power));

                return col;
            }      
        ENDHLSL
        }
       
    }
    FallBack "Diffuse"
}