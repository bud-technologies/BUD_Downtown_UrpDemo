
//树叶
Shader "NewRender/Tree/DefaultLeaves" {

    Properties{
        [Header(Cull Mode)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("剔除模式 : Off是双面显示，否则一般用 Back", int) = 0

        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

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

        [MaterialToggle(_NORMAL_CENTERSET_ON)] _NormalCenterSet  ("法线映射", float) = 0
        _NormalCenterPos("Normal Center Pos 法线重新映射", vector) = (0,0,0,0)

        [MaterialToggle(_PLANT_ANIM_ON)] _TreeAnimOn  ("Tree Anim On", float) = 0
        _PosOffsetRange("Pos Offset Range", vector) = (-1,1,0,0)
        _AnimSpeed("Anim Speed XY", vector) = (1,1,1,0)
        _NoiseFrequency("Noise Frequency", Range(0.0, 2.0)) = 1
        _AnimStrength("Anim Strength", Range(0.0, 2.0)) = 1
        _WindData("Wind Data xyz:方向 w:强度", vector) = (0,0,0,0)

        //
        _FresnelBias("Fresnel Bias", Range(0, 0.2)) = 0.0136
		_FresnelScale("Fresnel Scale", Range(0, 5)) = 0.35
		_FresnelPower("Fresnel Power", Range(0.01, 10)) = 4.78



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

        Tags {
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        BlendOp[_BlendOp]
        Blend[_SrcBlend][_DstBlend]

        ZWrite[_ZWrite]
        Cull[_Cull]

        ZTest On
        Lighting Off

        HLSLINCLUDE

        #include "../Library/Common/CommonFunction.hlsl"
        #include "../Library/Texture/TextureLib.hlsl"
        #include "../Library/Normal/NormalLib.hlsl"
        #include "../Library/Light/LightLib.hlsl"

        CBUFFER_START(UnityPerMaterial)
            half _FresnelBias;
            half _FresnelScale;
            half _FresnelPower;
	        float4 _BaseMap_ST;
	        half4 _BaseColor;
	        half _Cutoff;
	        float3 _AnimSpeed;
	        float _AnimStrength;
	        float _NoiseFrequency;
	        float2 _PosOffsetRange;
	        int _TreeAnimOn;
	        float _Emission;
	        float3 _NormalCenterPos;
	        half4 _WindData;
            half _LightAndShadeOffset;
            float4 _EmissionMap_ST;
            half _EmissionOn;
            half4 _EmissionColor;
            half _ScatteringOn;
            half _ScatteringScale;
            half _ScatteringPow;
            half3 _ScatteringColor;


        CBUFFER_END

        TEXTURE2D_X(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D_X(_EmissionMap); SAMPLER(sampler_EmissionMap);

        struct Attributes_Tree {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
	        float3 normalOS : NORMAL;
	        UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings_Tree {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;

	        #if defined(_NORMAL_ON)
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
	            float3 bitangentWS : TEXCOORD3;
            #else
                float3 normalWS : TEXCOORD1;
            #endif  

	        DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 2);
	        #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
		        half  fogFactor : TEXCOORD4; // x: fogFactor
	        #endif

           float3 positionWS : TEXCOORD5;

	        UNITY_VERTEX_INPUT_INSTANCE_ID
	        UNITY_VERTEX_OUTPUT_STEREO
        };

        float3 mod2D289( float3 x ) { return x - floor(x * 0.0034602076124567) * 289.0; }
        float2 mod2D289( float2 x ) { return x - floor(x * 0.0034602076124567) * 289.0; }

        float3 permute( float3 x ) { 
	        return mod2D289((x * 34.0 + 1.0) * x ); 
        }

        float snoise( float2 v )
        {
	        const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
	        float2 i = floor( v + dot( v, C.yy ) );
	        float2 x0 = v - i + dot( i, C.xx );
	        float2 i1;
	        i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
	        float4 x12 = x0.xyxy + C.xxzz;
	        x12.xy -= i1;
	        i = mod2D289( i );
	        float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
	        float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
	        m = m * m;
	        m = m * m;
	        float3 x = 2.0 * frac( p * C.www ) - 1.0;
	        float3 h = abs( x ) - 0.5;
	        float3 ox = floor( x + 0.5 );
	        float3 a0 = x - ox;
	        m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
	        float3 g;
	        g.x = a0.x * x0.x + h.x * x0.y;
	        g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	        float res = 130.0 * dot( m, g );
	        return res;
        }

        float snoise_sin(float3 v)
        {
	        float par=v.x+v.y*0.3+v.z;
	        float sinValue = sin(par);
	        float cosValue = cos(par*2);
	        float res=(sinValue+cosValue)*0.5;
	        res=res*0.5+0.5;
	        return res;
        }

        Varyings_Tree TreeVertex(Attributes_Tree input) {
            Varyings_Tree output = (Varyings_Tree)0;

	        // Instance
	        UNITY_SETUP_INSTANCE_ID(input);
	        UNITY_TRANSFER_INSTANCE_ID(input, output);
	        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

	        output.uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;

	        #if defined(_PLANT_ANIM_ON)
		        //wind
	            _WindData.w=max(_WindData.w,0)+1.0;
		        _AnimSpeed=_AnimSpeed*_WindData.w;
		        _NoiseFrequency=_NoiseFrequency*_WindData.w;
		        _PosOffsetRange=_PosOffsetRange*_WindData.w;
		        _WindData.xyz=saturate(_WindData.xyz)+1.0;
		        //
		        float3 positonWS = TransformObjectToWorld(input.positionOS.xyz);

		        //float worldPos = snoise( (positonWS.xy+ float2(positonWS.z*0.25+positonWS.z*0.5) + animSpeed.xy * _Time.y)*_NoiseFrequency ); //太耗性能
		        float worldPos = snoise_sin( (positonWS + _AnimSpeed * _Time.y)*_NoiseFrequency );
		        worldPos=worldPos*(_PosOffsetRange.y-_PosOffsetRange.x)+_PosOffsetRange.x;
		        float3 animSpeed = normalize(_AnimSpeed );
		        float x=worldPos*_WindData.x*animSpeed.x;
		        //float y=worldPos*_WindData.y*animSpeed.y;
		        float y=0;
		        float z=worldPos*_WindData.z*animSpeed.z;
		        #if defined(SHADER_STAGE_RAY_TRACING)
			        //float3 localOffset = mul(WorldToObject3x4(), float4(worldPos.xxx, 0)).xyz;
			        float3 localOffset = mul(WorldToObject3x4(), float4(x,y,z, 0)).xyz;
		        #else
			        //float3 localOffset = mul(GetWorldToObjectMatrix(), float4(worldPos.xxx, 0)).xyz;
			        float3 localOffset = mul(GetWorldToObjectMatrix(), float4(x,y,z, 0)).xyz;
		        #endif

		        input.positionOS.xyz += localOffset*_AnimStrength;
	        #else

	        #endif

            #if defined(_NORMAL_CENTERSET_ON)
                input.normalOS.xyz=normalize(input.positionOS.xyz-float3(0,1,0));
	        #endif

            #if defined(_NORMAL_ON)
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
	            half sign = input.tangentOS.w * GetOddNegativeScale();
	            output.tangentWS.xyz = half3(normalInput.tangentWS.xyz);
	            output.bitangentWS.xyz = half3(sign * cross(normalInput.normalWS.xyz, normalInput.tangentWS.xyz));
	            output.normalWS.xyz = normalInput.normalWS.xyz;
            #else
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS.xyz));
            #endif  

            output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
	        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

	        #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
		        output.fogFactor = ComputeFogFactor(output.positionCS.z);
	        #endif

	        // Indirect light
	        OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
	        OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

            return output;
        }

        half4 TreeFragment(Varyings_Tree input) : SV_TARGET{

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
            NDotL=saturate(NDotL);

            //scattering
            #if defined(_SCATTERING_ON)
				float VDotInL = saturate(dot(viewDirWS, -mainLight.direction));
				half3 directLighting = VDotInL  * mainLight.color;
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

            //
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

            #pragma vertex TreeVertex
            #pragma fragment TreeFragment
            #pragma multi_compile_instancing 
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ _SCATTERING_ON 
            #pragma multi_compile _ _PLANT_ANIM_ON
            #pragma multi_compile _ _NORMAL_CENTERSET_ON

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

            #pragma vertex TreeVertex
            #pragma fragment TreeDepthOnlyFragment

            #pragma shader_feature _ALPHATEST_ON
            #pragma multi_compile _ _PLANT_ANIM_ON

            #pragma multi_compile_instancing

            half4 TreeDepthOnlyFragment(Varyings_Tree input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

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
    CustomEditor "NewRenderShaderGUI.TreeShaderGUI"
}
