
Shader "NewRender/Water/Default" {
	Properties { 
		[MainTexture]_BaseMap ("Base (RGB) RefStrength (A)", 2D) = "white" {}
		_BaseColor ("Main Color", Color) = (0.6603774,0.6603774,0.6603774,1)
		_ReflectColor ("Reflection Color", Color) = (0.4352941,0.4352941,0.4352941,0.5)
		_ENV ("_ENV Color", Color) = (0.3607843,0.3960784,0.4392157,1)
		_ReflectMap ("Reflection Cubemap", Cube) = "white"
		_BumpMapA ("Bumpmap A (RGB)", 2D) = "bump" {}
		_BumpMapB ("Bumpmap B (RGB)", 2D) = "bump2" {}
		_BlendA ("BlendA", Range(-1.0,1.0)) = -0.24
		_BlendB ("BlendB", Range(-1.0,1.0)) = 0.24
		_RefelctIntencity ("_RefelctIntencity", Range(0.0,10.0)) = 2.6
		_Startfresnel ("_Startfresnel", Range(0.01,0.15)) = 0.1275

		_BaseMapSpeed ("Base Map Speed",vector) = (0.1,-0.1,0,0)
		_BumpMapASpeed ("Bump MapA Speed",vector) = (0.15,-0.15,0,0)
		_BumpMapBSpeed ("Bump MapB Speed",vector) = (0.05,-0.05,0,0)

		[HideInInspector]_MainTex ("MainTex (RGB)", 2D) = "white" {}
	}

	SubShader {

		Pass {
			Name "BASE"

			Tags {"LightMode" = "UniversalForward"}

			HLSLPROGRAM

			#pragma vertex WaterVert
			#pragma fragment WaterFragment
			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

			CBUFFER_START(UnityPerMaterial)
				half2 _BaseMapSpeed;
				half2 _BumpMapASpeed;
				half2 _BumpMapBSpeed;
				float4 _BaseMap_ST, _BumpMapA_ST,_BumpMapB_ST;
				float4 _ReflectColor;
				float4 _BaseColor;
				float _BlendA;
				float _BlendB;
				float4 _ENV;
				float _RefelctIntencity;
				float _Startfresnel;
			CBUFFER_END

			samplerCUBE _ReflectMap;
			TEXTURE2D_X(_BaseMap); SAMPLER(sampler_BaseMap);
			TEXTURE2D_X(_BumpMapA); SAMPLER(sampler_BumpMapA);
			TEXTURE2D_X(_BumpMapB); SAMPLER(sampler_BumpMapB);

			struct Attributes_Water {
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR0;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings_Water
			{
				float4 positionCS : SV_POSITION;
				float4 color : COLOR;
				float2	uv		: TEXCOORD0;
				float4	uvBump     : TEXCOORD1;
				float3	inverseViewDir		: TEXCOORD2;
				float3	TtoW0 	: TEXCOORD3;
				float3	TtoW1	: TEXCOORD4;
				float3	TtoW2	: TEXCOORD5;

			#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
				half  fogFactor : TEXCOORD6; // x: fogFactor
			#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings_Water WaterVert (Attributes_Water input)
			{
				Varyings_Water output=(Varyings_Water)0;

				// Instance
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				//output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
				//output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				//output.color = input.color*_BaseColor;
				//return output;

				output.positionCS = TransformObjectToHClip (input.positionOS.xyz);
				output.color = input.color; 

				half2 uvOffset=_Time.y*_BaseMapSpeed.xy;
				_BaseMap_ST.zw=_BaseMap_ST.zw+uvOffset;

				half2 uv2Offset=_Time.y*_BumpMapASpeed.xy;
				_BumpMapA_ST.zw=_BumpMapA_ST.zw+uv2Offset;

				half2 uv3Offset=_Time.y*_BumpMapBSpeed.xy;
				_BumpMapB_ST.zw=	_BumpMapB_ST.zw+uv3Offset;

				output.uv.xy = TRANSFORM_TEX(input.uv,_BaseMap);
				output.uvBump.xy = TRANSFORM_TEX(input.uv,_BumpMapA);
				output.uvBump.zw = TRANSFORM_TEX(input.uv,_BumpMapB);

				float3 objSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz;

				output.inverseViewDir = mul( (float3x3)unity_ObjectToWorld, input.positionOS.xyz-objSpaceCameraPos );	

				float3 binormal = cross( normalize(input.normal), normalize(input.tangent.xyz) ) * input.tangent.w;
				float3x3 rotation = float3x3( input.tangent.xyz, binormal, input.normal );

				output.TtoW0 = mul(rotation, unity_ObjectToWorld[0].xyz);
				output.TtoW1 = mul(rotation, unity_ObjectToWorld[1].xyz);
				output.TtoW2 = mul(rotation, unity_ObjectToWorld[2].xyz);

				#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2) 
					output.fogFactor = ComputeFogFactor(output.positionCS.z);
				#endif
	
				return output; 
			}

			half4 WaterFragment(Varyings_Water input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				//
				half4 normalA = SAMPLE_TEXTURE2D(_BumpMapA,sampler_BumpMapA,input.uvBump.xy);
				half4 normalB = SAMPLE_TEXTURE2D(_BumpMapB,sampler_BumpMapB,input.uvBump.zw);
				half4 normal = ((normalA - 0.5) *_BlendA + (normalB - 0.5)*_BlendB)*2;
				normal.z = normalA.z + normalB.z;
				normal.w = 1.0;
				normal = normalize (normal);
	
				//
				half3 normalWS;
				normalWS.x = dot(input.TtoW0, normal.xyz);
				normalWS.y = dot(input.TtoW1, normal.xyz);
				normalWS.z = dot(input.TtoW2, normal.xyz);

				half3 r = reflect(input.inverseViewDir, normalWS);
				float3 eye = -normalize(input.inverseViewDir);
				float facing = 1.0 - max(dot(eye, normalWS), 0);
				float fresnel = _Startfresnel+ (1.0-0.2)*exp(log(facing) * 6.0);
				fresnel=clamp(fresnel,0,1.0);
				float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv.xy);
				half4 c = baseTex;
				c.rgb *= _BaseColor.rgb;
				half4 reflcolor = _ReflectColor * texCUBE(_ReflectMap, r)*_RefelctIntencity;
				float4 xx = c*max(dot(eye, normalWS), 0) + c*_ENV;

				half4 finColor = lerp (xx, reflcolor, fresnel)*float4(_BaseColor.rgb,1)*input.color*2;
	
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
}
