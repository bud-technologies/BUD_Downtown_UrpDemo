
Shader "NewRender/Other/BudEarth"
{
	Properties
	{
		_BaseMap("Base Map", 2D) = "white" {}
		_Texture_NightLight("Texture_NightLight", 2D) = "white" {}
		_Texture_Cloud1("Texture_Cloud1", 2D) = "white" {}
		_Texture_Cloud2("Texture_Cloud2", 2D) = "white" {}
		_Color_Cloud("Color_Cloud", Color) = (1,1,1,0)
		_Color_Ground("Color_Ground", Color) = (1,1,1,0)
		_Color_BackSide("Color_BackSide", Color) = (0,0,0,0)
		_Color_NightLight("Color_NightLight", Color) = (1,0.7805012,0.4292453,0)
		_Color_Rim_Inside("Color_Rim_Inside", Color) = (1,1,1,0)
		_Color_Rim_Outside("Color_Rim_Outside", Color) = (0,0,0,0)
		_Brightness_Color_Cloud("Brightness_Color_Cloud", Range( 1 , 5)) = 1
		_Brightness_Color_Ground("Brightness_Color_Ground", Range( 0 , 5)) = 2.62
		_Brightness_Color_Rim_Outside("Brightness_Color_Rim_Outside", Range( 1 , 5)) = 1
		_Brightness_Color_NightLight("Brightness_Color_NightLight", Range( 0 , 2)) = 1
		_Rim_Inside_Bias("Rim_Inside_Bias", Range( 0 , 1)) = 0
		_Rim_Inside_Scale("Rim_Inside_Scale", Range( 0 , 1)) = 0.7856761
		_Rim_Inside_Power("Rim_Inside_Power", Range( 0 , 10)) = 1.386173
		_Rim_Inside_Color_Brightness("Rim_Inside_Color_Brightness", Range( 1 , 10)) = 1
		_Rim_Outside_Bias("Rim_Outside_Bias", Range( -1 , 1)) = 0
		_Rim_Outside_Scale("Rim_Outside_Scale", Range( 0 , 0.2)) = 0.1
		_Rim_Outside_Power("Rim_Outside_Power", Range( 2 , 10)) = 5.670588
		_Rim_Outside_Offset("Rim_Outside_Offset", Range( 0 , 0.35)) = 0.35
		_Rim_Cloud_Brightness_Bias("Rim_Cloud_Brightness_Bias", Range( -1 , 1)) = 0
		_Rim_Cloud_Brightness_Scale("Rim_Cloud_Brightness_Scale", Range( 0 , 5)) = 2.705882
		_Rim_Cloud_Brightness_Power("Rim_Cloud_Brightness_Power", Range( 0 , 10)) = 3.652804
		_Cloud_Tilling1("Cloud_Tilling1", Range( 1 , 10)) = 1
		_Cloud_Tilling2("Cloud_Tilling2", Range( 1 , 10)) = 1
		_Cloud_Texture1_AlphaMin("Cloud_Texture1_AlphaMin", Range( -1 , 1)) = 0.1411765
		_Cloud_Texture1_AlphaMax("Cloud_Texture1_AlphaMax", Range( -1 , 1)) = 0.7578096
		_Cloud_Texture2_AlphaMin("Cloud_Texture2_AlphaMin", Range( -1 , 1)) = 0.4235294
		_Cloud_Texture2_AlphaMax("Cloud_Texture2_AlphaMax", Range( -1 , 1)) = 0.8598748
		_NightLight_Tilling("NightLight_Tilling", Float) = 1
		_Rotate_Ground("Rotate_Ground", Float) = 0
		_Rotate_Cloud_1("Rotate_Cloud_1", Float) = 0
		_Rotate_Cloud_2("Rotate_Cloud_2", Float) = 0

		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}

	}
	
	SubShader
	{
		LOD 0

		Tags { "RenderType"="Transparent" }

		HLSLINCLUDE

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float4 _Color_BackSide;
				float4 _Color_NightLight;
				float _Brightness_Color_NightLight;
				float _NightLight_Tilling;
				float _Rotate_Ground;
				float4 _Color_Ground;
				float _Brightness_Color_Ground;
				float _Rim_Inside_Bias;
				float _Rim_Inside_Scale;
				float _Rim_Inside_Power;
				float4 _Color_Cloud;
				float _Brightness_Color_Cloud;
				float _Cloud_Texture1_AlphaMin;
				float _Cloud_Texture1_AlphaMax;
				float _Rotate_Cloud_1;
				float _Cloud_Tilling1;
				float _Cloud_Texture2_AlphaMin;
				float _Cloud_Texture2_AlphaMax;
				float _Rotate_Cloud_2;
				float _Cloud_Tilling2;
				float _Rim_Cloud_Brightness_Bias;
				float _Rim_Cloud_Brightness_Scale;
				float _Rim_Cloud_Brightness_Power;
				float4 _Color_Rim_Inside;
				float _Rim_Inside_Color_Brightness;
				float _Rim_Outside_Offset;
				float4 _Color_Rim_Outside;
				float _Brightness_Color_Rim_Outside;
				float _Rim_Outside_Bias;
				float _Rim_Outside_Scale;
				float _Rim_Outside_Power;
			CBUFFER_END

		ENDHLSL
		
		Pass
		{
			
			Name "First"
			Tags { "LightMode" = "UniversalForward"}
			Blend Off
			Cull Back
			Offset 0 , 0
			ColorMask RGBA
			AlphaToMask Off
			ZWrite On
			ZTest LEqual

			
			HLSLPROGRAM
			
			#pragma vertex BudEarthVert
			#pragma fragment BudEarthFrag

			struct Attributes_BudEarth
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct Varyings_BudEarth
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float4 uv : TEXCOORD2;
				float4 uvCloud : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};



			TEXTURE2D(_Texture_NightLight);SAMPLER(sampler_Texture_NightLight);
			TEXTURE2D(_BaseMap);SAMPLER(sampler_BaseMap);
			TEXTURE2D(_Texture_Cloud1);SAMPLER(sampler_Texture_Cloud1);
			TEXTURE2D(_Texture_Cloud2);SAMPLER(sampler_Texture_Cloud2);

			Varyings_BudEarth BudEarthVert (Attributes_BudEarth input )
			{
				Varyings_BudEarth output=(Varyings_BudEarth)0;
				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.normalWS.xyz = TransformObjectToWorldNormal(input.normalOS);
				output.positionWS.xyz = TransformObjectToWorld(input.positionOS.xyz);
				output.uv.xy = input.uv.xy*_NightLight_Tilling+float2(_Rotate_Ground , 0.0);
				output.uv.zw = input.uv.xy+float2(_Rotate_Ground , 0.0);

				output.uvCloud.xy =input.uv.xy*_Cloud_Tilling1+_Rotate_Cloud_1;
				output.uvCloud.zw =input.uv.xy*_Cloud_Tilling2+_Rotate_Cloud_2;

				output.positionCS = TransformWorldToHClip(output.positionWS.xyz);
				return output;
			}
			
			half4 BudEarthFrag (Varyings_BudEarth input ) : SV_Target
			{
				half4 finalColor;
				float3 normalWS = input.normalWS.xyz;
				float3 positionWS = input.positionWS.xyz;
				//
				half4 shadowCoord = TransformWorldToShadowCoord(positionWS);
				Light mainLight = GetMainLight(shadowCoord);

				float NDotL = dot( normalWS , mainLight.direction );
				NDotL = smoothstep( 0.0 , 1.0 , NDotL);
				float invPowNDotL = pow( abs(1.0 - NDotL) , 10.0 ) ;

				float nightLight = smoothstep( 0.05 , 1.0 , ( SAMPLE_TEXTURE2D( _Texture_NightLight,sampler_Texture_NightLight, input.uv.xy ).r * _Brightness_Color_NightLight ));
				float4 nightLightColor = lerp( _Color_BackSide , _Color_NightLight , ( invPowNDotL * nightLight ));

				float3 viewDirWS =normalize(GetCameraPositionWS() -positionWS.xyz);

				float NDotV= dot( normalWS, viewDirWS );;


				float fresnel = _Rim_Inside_Bias + _Rim_Inside_Scale * pow( max( 1.0 - NDotV , 0.0001 ), _Rim_Inside_Power );
				fresnel= clamp( fresnel , 0.0 , 1.0 );

				float4 baseMapTex = SAMPLE_TEXTURE2D( _BaseMap,sampler_BaseMap, input.uv.zw ) * _Color_Ground * _Brightness_Color_Ground * ( 1.0 - fresnel );

				float cloud_1 = smoothstep( _Cloud_Texture1_AlphaMin , _Cloud_Texture1_AlphaMax , SAMPLE_TEXTURE2D( _Texture_Cloud1,sampler_Texture_Cloud1, input.uvCloud.xy ).r);
				float cloud_2 = smoothstep( _Cloud_Texture2_AlphaMin , _Cloud_Texture2_AlphaMax , SAMPLE_TEXTURE2D( _Texture_Cloud2,sampler_Texture_Cloud2, input.uvCloud.zw ).r);

				float fresnel2 = _Rim_Cloud_Brightness_Bias + _Rim_Cloud_Brightness_Scale * pow( max( 1.0 - NDotV , 0.0001 ), _Rim_Cloud_Brightness_Power );
				fresnel2 = smoothstep( 0.0 , 1.0 ,  1.0 - fresnel * fresnel2  );
				float4 compColor = lerp(baseMapTex , _Color_Cloud * (_Brightness_Color_Cloud -  _Brightness_Color_Cloud* NDotL / 1.4) , cloud_1 * cloud_2 * fresnel2 );
				compColor = lerp(compColor , _Color_Rim_Inside * _Rim_Inside_Color_Brightness , fresnel * ( 1.0 - invPowNDotL ));
				return lerp( nightLightColor , compColor , NDotL);
			}
			ENDHLSL
		}

		
		Pass
		{
			Name "Second"
			Tags { "LightMode" = "SRPDefaultUnlit"}
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask Off
			Cull Front
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0

			HLSLPROGRAM
			
			#pragma vertex BudEarthVert
			#pragma fragment BudEarthFrag

			struct Attributes_BudEarth
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct Varyings_BudEarth
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_BudEarth BudEarthVert ( Attributes_BudEarth input )
			{
				Varyings_BudEarth output = (Varyings_BudEarth)0;
				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.normalWS.xyz = TransformObjectToWorldNormal(input.normalOS);
				output.positionWS.xyz = TransformObjectToWorld(input.positionOS.xyz);
				

				input.positionOS.xyz += ( input.normalOS * _Rim_Outside_Offset );
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				return output;
			}
			
			half4 BudEarthFrag (Varyings_BudEarth input ) : SV_Target
			{
				half4 finalColor;
				float3 normalWS = input.normalWS.xyz;
				float3 positionWS = input.positionWS.xyz;
				//
				half4 shadowCoord = TransformWorldToShadowCoord(positionWS);
				Light mainLight = GetMainLight(shadowCoord);


				float NDotL = dot( normalWS , mainLight.direction );
				NDotL = smoothstep( 0.0 , 1.0 , NDotL);

				float3 viewDirWS =normalize(GetCameraPositionWS() -positionWS.xyz);

				float NDotV=dot( normalWS, viewDirWS );

				float fresnel = _Rim_Outside_Bias + _Rim_Outside_Scale * pow( max( 1.0 - NDotV , 0.0001 ), _Rim_Outside_Power );
				fresnel = smoothstep( 0.0 , 1.0 , ( NDotL * fresnel ));
				return float4(( NDotL * _Color_Rim_Outside * _Brightness_Color_Rim_Outside ).rgb , fresnel);
				
			}
			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "ASEMaterialInspector"
	
	
}
