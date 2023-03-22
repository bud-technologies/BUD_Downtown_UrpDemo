// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NewRender/Particle/UberEffect"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR]_SecondColor("SecondColor", Color) = (1,1,1,1)
		[HDR]_Color("主颜色", Color) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("剔除模式", Float) = 0
		[Toggle(_DEPTHFADE_ON)] _DepthFade("深度边缘消隐", Float) = 0
		_DepthFadeIndensity("深度消隐强度", Float) = 1
		_MainTex("主贴图", 2D) = "white" {}
		_GradientTex("渐变叠加贴图", 2D) = "white" {}
		_GradientUV("渐变UV", Vector) = (0,0,0,0)
		_DistortionTex("扭曲贴图", 2D) = "white" {}
		[Toggle(_DISTORTIONINFLUENCEGRADIENT)] _DistortionInfluenceGradient("扭曲影响渐变", Float) = 0
		[Toggle(_DISTORTION2UV_ON)] _Distortion2UV("扭曲使用UV2", Float) = 0
		_DistortionIndensity("UV扭曲强度", Float) = 0
		_DistortUV("扭曲UV", Vector) = (0,0,0,0)
		_AlphaTex("Alpha贴图", 2D) = "white" {}
		[Toggle(_ALPHATEXUV2_ON)] _AlphaTexUV2("透明贴图UV2", Float) = 0
		_AlphaUV("AlphaUV速度", Vector) = (0,0,0,0)
		[Toggle(_SOFTDISSOLVESWITCH_ON)] _SoftDissolveSwitch("溶解开关", Float) = 0
		[Toggle(_VERTEXCOLORINFLUENCESOFTDISSOLVE_ON)] _VertexColorInfluenceSoftDissolve("顶点色影响软溶解", Float) = 0
		[Toggle(_DISTORTIONINFLUENCESOFT_ON)] _DistortionInfluenceSoft("扭曲影响软溶解", Float) = 0
		_SoftDissolveTex("软溶解贴图", 2D) = "white" {}
		_SoftDissolveIndensity("软溶解强度", Range( 0 , 1.05)) = 0
		_SoftDissolveSoft("软溶解软度", Range( 0 , 1)) = 0
		[HDR]_LineColor("溶解描边颜色", Color) = (1,1,1,1)
		_SoftDissolveTexUV("软溶解UV速度", Vector) = (0,0,0,0)
		[Toggle(_VERTEX_OFFSET_ON)] _Vertex_Offset("Vertex_Offset", Float) = 0
		_VertexOffsetTex("顶点偏移贴图", 2D) = "white" {}
		[Toggle(_DISTORTIONINFLUENCEOFFSET_ON)] _DistortionInfluenceOffset("扭曲影响顶点偏移", Float) = 0
		_VertexOffsetIndensity("顶点偏移强度", Float) = 0
		_VertexOffsetTexUV("顶点偏移贴图UV", Vector) = (0,0,0,0)
		[Toggle(_GRADIENT_ON)] _Gradient("Gradient", Float) = 0
		[Toggle(_ALPHA_ON)] _Alpha("Alpha", Float) = 0
		[Toggle(_DISTORT_ON)] _Distort("Distort", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("深度测试", Float) = 4
		[Enum(Off,0,On,1)]_ZWrite("深度写入", Float) = 0
		[Toggle(_RADIAL_ON)] _Radial("Radial", Float) = 0
		_RadialSpeed("RadialSpeed", Float) = 0.2
		[IntRange]_RingCount("RingCount", Range( 1 , 10)) = 1
		_RingRadius("RingRadius", Range( 0.01 , 1)) = 0.4767059
		_RingRange("RingRange", Range( 0 , 0.49)) = 0.3574118
		[Toggle(_RADIALRING_ON)] _RadialRing("RadialRing", Float) = 0
		[Toggle(_INVERSERADIALRING_ON)] _InverseRadialRing("InverseRadialRing", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 1
		[HDR]_RimColor("RimColor", Color) = (1,1,1,1)
		[Toggle(_RIM_ON)] _Rim("Rim", Float) = 0
		_LineWidth("LineWidth", Range( 0 , 1)) = 0
		_SecondTex("第二贴图", 2D) = "white" {}
		[Enum(Blend,0,Add,1,Mul,2)]_SecondColorBlend("SecondColorBlend", Float) = 2
		_MainUV("主贴图UV", Vector) = (0,0,0,0)
		_SecondUV("副贴图UV", Vector) = (0,0,0,0)
		[Toggle(_SECONDLAYER_ON)] _SecondLayer("SecondLayer", Float) = 0
		[Toggle(_CUSTOMDATA_ON)] _CustomData("CustomData", Float) = 0
		_NoiseIntensity("NoiseIntensity", Range( 0 , 1)) = 0
		[Toggle(_GRADIENTDISSOLVE_ON)] _GradientDissolve("GradientDissolve", Float) = 0
		_RadialRingIntensity("RadialRingIntensity", Range( 0 , 10)) = 1
		_StencilRef("Stencil Ref", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("Stencil Pass", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comp", Float) = 8
		[Toggle]_StencilOn("StencilOn", Float) = 0
		[ASEEnd][Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask("ColorMask", Float) = 15

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull [_Cull]
		AlphaToMask Off
		Stencil
		{
			Ref [_StencilRef]
			Comp [_StencilComp]
			Pass [_StencilPass]
			Fail Keep
			ZFail Keep
		}
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma only_renderers d3d11 glcore gles gles3 metal vulkan nomrt 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite [_ZWrite]
			ZTest [_ZTest]
			Offset 0 , 0
			ColorMask [_ColorMask]
			

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#include "../Library/Effect/ParticleFunction.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _VERTEX_OFFSET_ON
			#pragma shader_feature_local _CUSTOMDATA_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCEOFFSET_ON
			#pragma shader_feature_local _DISTORTION2UV_ON
			#pragma shader_feature_local _DISTORT_ON
			#pragma shader_feature_local _SOFTDISSOLVESWITCH_ON
			#pragma shader_feature_local _RIM_ON
			#pragma shader_feature_local _GRADIENT_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCEGRADIENT
			#pragma shader_feature_local _SECONDLAYER_ON
			#pragma shader_feature_local _RADIAL_ON
			#pragma shader_feature_local _RADIALRING_ON
			#pragma shader_feature_local _INVERSERADIALRING_ON
			#pragma shader_feature_local _GRADIENTDISSOLVE_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCESOFT_ON
			#pragma shader_feature_local _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON
			#pragma shader_feature_local _DEPTHFADE_ON
			#pragma shader_feature_local _ALPHA_ON
			#pragma shader_feature_local _ALPHATEXUV2_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_color : COLOR;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _AlphaTex_ST;
			float4 _MainUV;
			float4 _GradientTex_ST;
			float4 _RimColor;
			float4 _SecondUV;
			float4 _SecondTex_ST;
			float4 _SecondColor;
			float4 _DistortionTex_ST;
			float4 _VertexOffsetTex_ST;
			float4 _Color;
			float4 _LineColor;
			float4 _SoftDissolveTex_ST;
			float2 _SoftDissolveTexUV;
			float2 _GradientUV;
			float2 _AlphaUV;
			float2 _VertexOffsetTexUV;
			float2 _DistortUV;
			float _RadialRingIntensity;
			float _SoftDissolveIndensity;
			float _SoftDissolveSoft;
			float _LineWidth;
			float _NoiseIntensity;
			float _SecondColorBlend;
			float _ZWrite;
			float _RingRadius;
			float _RingCount;
			float _RadialSpeed;
			float _RimPower;
			float _RimScale;
			float _DistortionIndensity;
			float _VertexOffsetIndensity;
			float _StencilOn;
			float _StencilRef;
			float _ColorMask;
			float _ZTest;
			float _StencilComp;
			float _Cull;
			float _StencilPass;
			float _RingRange;
			float _DepthFadeIndensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _GradientTex;
			sampler2D _MainTex;
			sampler2D _SecondTex;
			sampler2D _SoftDissolveTex;
			sampler2D _AlphaTex;
			uniform float4 _CameraDepthTexture_TexelSize;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 temp_cast_0 = 0;
				float4 texCoord521 = v.ase_texcoord2;
				texCoord521.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch520 = texCoord521.z;
				#else
				float staticSwitch520 = 0.0;
				#endif
				float2 uv_VertexOffsetTex = v.ase_texcoord.xy * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_186_0 = ( ( _VertexOffsetTexUV * _TimeParameters.x ) + uv_VertexOffsetTex );
				float2 uv_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2Dlod( _DistortionTex, float4( panner269, 0, 0.0) ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = v.ase_texcoord2;
				texCoord510.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult201 = lerp( float3( temp_output_186_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCEOFFSET_ON
				float3 staticSwitch225 = lerpResult201;
				#else
				float3 staticSwitch225 = float3( temp_output_186_0 ,  0.0 );
				#endif
				#ifdef _VERTEX_OFFSET_ON
				float4 staticSwitch263 = ( ( staticSwitch520 + _VertexOffsetIndensity ) * ( tex2Dlod( _VertexOffsetTex, float4( staticSwitch225.xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a );
				#else
				float4 staticSwitch263 = temp_cast_0;
				#endif
				float4 VertexOffest253 = staticSwitch263;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord8 = screenPos;
				
				o.ase_texcoord4 = v.ase_texcoord2;
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				o.ase_texcoord6 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				o.ase_texcoord7 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffest253.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float4 temp_cast_0 = (0.0).xxxx;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float4 texCoord525 = IN.ase_texcoord4;
				texCoord525.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch526 = texCoord525.w;
				#else
				float staticSwitch526 = 0.0;
				#endif
				float fresnelNdotV347 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode347 = ( 0.0 + ( _RimScale + staticSwitch526 ) * pow(abs(1.0 - fresnelNdotV347) ,_RimPower  ) );
				#ifdef _RIM_ON
				float4 staticSwitch359 = float4( ( fresnelNode347 * (_RimColor).rgb ) , 0.0 );
				#else
				float4 staticSwitch359 = float4(0,0,0,1);
				#endif
				float4 RimColor353 = max( staticSwitch359 , float4( 0,0,0,0 ) );
				#ifdef _RIM_ON
				float4 staticSwitch411 = RimColor353;
				#else
				float4 staticSwitch411 = temp_cast_0;
				#endif
				float3 temp_cast_2 = (1.0).xxx;
				float2 uv_GradientTex = IN.ase_texcoord5.xy * _GradientTex_ST.xy + _GradientTex_ST.zw;
				float2 temp_output_171_0 = ( ( _GradientUV * _TimeParameters.x ) + uv_GradientTex );
				float2 uv_DistortionTex = IN.ase_texcoord5.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = IN.ase_texcoord6.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2D( _DistortionTex, panner269 ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = IN.ase_texcoord4;
				texCoord510.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult179 = lerp( float3( temp_output_171_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCEGRADIENT
				float3 staticSwitch227 = lerpResult179;
				#else
				float3 staticSwitch227 = float3( temp_output_171_0 ,  0.0 );
				#endif
				#ifdef _GRADIENT_ON
				float3 staticSwitch264 = (tex2D( _GradientTex, staticSwitch227.xy )).rgb;
				#else
				float3 staticSwitch264 = temp_cast_2;
				#endif
				float2 temp_cast_8 = (0.0).xx;
				float4 texCoord497 = IN.ase_texcoord6;
				texCoord497.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult503 = (float2(texCoord497.x , texCoord497.y));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch506 = appendResult503;
				#else
				float2 staticSwitch506 = temp_cast_8;
				#endif
				float2 uv_MainTex = IN.ase_texcoord5.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv447 = ( staticSwitch506 + uv_MainTex );
				float mulTime462 = _TimeParameters.x * _MainUV.w;
				float rotatorAngle447 = ( ( 1.0 - _MainUV.z ) + ( 1.0 - mulTime462 ) );
				float2 localUvRotatorAngle2447 = UvRotatorAngle2( uv447 , rotatorAngle447 );
				float2 MainTexUV450 = localUvRotatorAngle2447;
				float2 panner260 = ( 1.0 * _Time.y * (_MainUV).xy + MainTexUV450);
				float2 temp_cast_9 = (0.5).xx;
				float2 temp_output_282_0 = ( MainTexUV450 - temp_cast_9 );
				float2 break284 = temp_output_282_0;
				float2 temp_cast_10 = (0.5).xx;
				float mulTime297 = _TimeParameters.x * _RadialSpeed;
				float2 appendResult289 = (float2((( atan2( break284.x , break284.y ) / PI )*0.5 + 0.5) , ( 1.0 - ( length( temp_output_282_0 ) + frac( mulTime297 ) ) )));
				float2 RadialUV293 = appendResult289;
				float mulTime318 = _TimeParameters.x * _RadialSpeed;
				float2 temp_cast_11 = (0.5).xx;
				float2 temp_output_306_0 = ( MainTexUV450 - temp_cast_11 );
				float2 break307 = temp_output_306_0;
				float2 temp_cast_12 = (0.5).xx;
				float smoothstepResult325 = smoothstep( 0.0 , _RingRadius , length( temp_output_306_0 ));
				float temp_output_327_0 = (0.0 + (( 1.0 - smoothstepResult325 ) - _RingRange) * (1.0 - 0.0) / (( 1.0 - _RingRange ) - _RingRange));
				#ifdef _INVERSERADIALRING_ON
				float staticSwitch345 = ( 1.0 - temp_output_327_0 );
				#else
				float staticSwitch345 = temp_output_327_0;
				#endif
				float2 appendResult313 = (float2(frac( ( frac( ( frac( mulTime318 ) + (( atan2( break307.x , break307.y ) / PI )*0.5 + 0.5) ) ) * _RingCount ) ) , staticSwitch345));
				float2 RadialUV2314 = appendResult313;
				#ifdef _RADIALRING_ON
				float2 staticSwitch342 = RadialUV2314;
				#else
				float2 staticSwitch342 = RadialUV293;
				#endif
				#ifdef _RADIAL_ON
				float2 staticSwitch295 = staticSwitch342;
				#else
				float2 staticSwitch295 = frac( panner260 );
				#endif
				float4 temp_output_491_0 = ( tex2D( _MainTex, ( float3( staticSwitch295 ,  0.0 ) + DistortionUV70 ).xy ) * _Color );
				float RadialRingMask334 = ( saturate( ( temp_output_327_0 * ( 1.0 - temp_output_327_0 ) ) ) * _RadialRingIntensity );
				#ifdef _RADIALRING_ON
				float staticSwitch337 = RadialRingMask334;
				#else
				float staticSwitch337 = 1.0;
				#endif
				#ifdef _RADIAL_ON
				float staticSwitch346 = staticSwitch337;
				#else
				float staticSwitch346 = 1.0;
				#endif
				float4 temp_output_195_0 = ( ( temp_output_491_0 * staticSwitch346 ) * IN.ase_color );
				float BlendModel482 = _SecondColorBlend;
				float4 col482 = temp_output_195_0;
				float2 temp_cast_18 = (0.0).xx;
				float4 texCoord516 = IN.ase_texcoord6;
				texCoord516.xy = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult517 = (float2(texCoord516.z , texCoord516.w));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch515 = appendResult517;
				#else
				float2 staticSwitch515 = temp_cast_18;
				#endif
				float2 uv_SecondTex = IN.ase_texcoord5.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				float2 uv472 = ( staticSwitch515 + uv_SecondTex );
				float mulTime467 = _TimeParameters.x * _SecondUV.w;
				float rotatorAngle472 = ( ( 1.0 - _SecondUV.z ) + ( 1.0 - mulTime467 ) );
				float2 localUvRotatorAngle2472 = UvRotatorAngle2( uv472 , rotatorAngle472 );
				float2 panner466 = ( 1.0 * _Time.y * (_SecondUV).xy + localUvRotatorAngle2472);
				float4 SecondTexColor479 = ( tex2D( _SecondTex, frac( panner466 ) ) * _SecondColor );
				float4 col2482 = SecondTexColor479;
				float4 localBlendColor482 = BlendColor( BlendModel482 , col482 , col2482 );
				#ifdef _SECONDLAYER_ON
				float4 staticSwitch494 = localBlendColor482;
				#else
				float4 staticSwitch494 = temp_output_195_0;
				#endif
				float4 temp_output_405_0 = ( staticSwitch411 + ( float4( staticSwitch264 , 0.0 ) * staticSwitch494 ) );
				float2 uv_SoftDissolveTex = IN.ase_texcoord5.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_72_0 = ( ( _SoftDissolveTexUV * _TimeParameters.x ) + uv_SoftDissolveTex );
				float3 lerpResult75 = lerp( float3( temp_output_72_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCESOFT_ON
				float3 staticSwitch229 = lerpResult75;
				#else
				float3 staticSwitch229 = float3( temp_output_72_0 ,  0.0 );
				#endif
				float3 desaturateInitialColor85 = tex2D( _SoftDissolveTex, staticSwitch229.xy ).rgb;
				float desaturateDot85 = dot( desaturateInitialColor85, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar85 = lerp( desaturateInitialColor85, desaturateDot85.xxx, 0.0 );
				#ifdef _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON
				float staticSwitch231 = IN.ase_color.a;
				#else
				float staticSwitch231 = 1.0;
				#endif
				float temp_output_119_0 = (( desaturateVar85 * staticSwitch231 )).x;
				float4 texCoord504 = IN.ase_texcoord4;
				texCoord504.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch508 = texCoord504.y;
				#else
				float staticSwitch508 = 0.0;
				#endif
				float temp_output_424_0 = saturate( ( ( ( temp_output_119_0 - ( ( ( staticSwitch508 + _SoftDissolveIndensity ) * ( 1.0 + _SoftDissolveSoft ) ) - _SoftDissolveSoft ) ) / _SoftDissolveSoft ) * 2.0 ) );
				float EdgeFactor431 = saturate( ( 1.0 - ( distance( temp_output_424_0 , 0.5 ) / _LineWidth ) ) );
				float GradientDissolve555 = ( ( ( saturate( ( ( IN.ase_texcoord7.xyz.y - 0 ) + 0.5 ) ) - (-_SoftDissolveSoft + (_SoftDissolveIndensity - 0.0) * (1.0 - -_SoftDissolveSoft) / (1.0 - 0.0)) ) / _SoftDissolveSoft ) * 2.0 );
				float temp_output_568_0 = ( GradientDissolve555 - ( temp_output_119_0 * _NoiseIntensity ) );
				float GradientDissolveEdge563 = saturate( ( 1.0 - ( distance( temp_output_568_0 , 0.5 ) / _LineWidth ) ) );
				#ifdef _GRADIENTDISSOLVE_ON
				float staticSwitch577 = GradientDissolveEdge563;
				#else
				float staticSwitch577 = EdgeFactor431;
				#endif
				float4 lerpResult432 = lerp( temp_output_405_0 , _LineColor , staticSwitch577);
				#ifdef _SOFTDISSOLVESWITCH_ON
				float4 staticSwitch440 = lerpResult432;
				#else
				float4 staticSwitch440 = temp_output_405_0;
				#endif
				
				float2 uv_AlphaTex = IN.ase_texcoord5.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv2_AlphaTex = IN.ase_texcoord6.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				#ifdef _ALPHATEXUV2_ON
				float2 staticSwitch233 = uv2_AlphaTex;
				#else
				float2 staticSwitch233 = uv_AlphaTex;
				#endif
				float3 desaturateInitialColor157 = tex2D( _AlphaTex, ( ( _AlphaUV * _TimeParameters.x ) + staticSwitch233 ) ).rgb;
				float desaturateDot157 = dot( desaturateInitialColor157, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar157 = lerp( desaturateInitialColor157, desaturateDot157.xxx, 1.0 );
				#ifdef _ALPHA_ON
				float staticSwitch266 = (desaturateVar157).x;
				#else
				float staticSwitch266 = 1.0;
				#endif
				float AlphaMap250 = staticSwitch266;
				float temp_output_166_0 = ( (staticSwitch494).a * IN.ase_color.a * AlphaMap250 );
				float DissolveVal425 = temp_output_424_0;
				float GradientDissolveOpacity554 = step( 0.5 , temp_output_568_0 );
				#ifdef _GRADIENTDISSOLVE_ON
				float staticSwitch578 = GradientDissolveOpacity554;
				#else
				float staticSwitch578 = DissolveVal425;
				#endif
				#ifdef _SOFTDISSOLVESWITCH_ON
				float staticSwitch226 = ( temp_output_166_0 * staticSwitch578 );
				#else
				float staticSwitch226 = temp_output_166_0;
				#endif
				float4 screenPos = IN.ase_texcoord8;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth203 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth203 = abs( ( screenDepth203 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult209 = clamp( distanceDepth203 , 0.0 , 1.0 );
				#ifdef _DEPTHFADE_ON
				float staticSwitch232 = ( staticSwitch226 * clampResult209 );
				#else
				float staticSwitch232 = staticSwitch226;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch440.xyz;
				float Alpha = staticSwitch232;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#include "../Library/Effect/ParticleFunction.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _VERTEX_OFFSET_ON
			#pragma shader_feature_local _CUSTOMDATA_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCEOFFSET_ON
			#pragma shader_feature_local _DISTORTION2UV_ON
			#pragma shader_feature_local _DISTORT_ON
			#pragma shader_feature_local _DEPTHFADE_ON
			#pragma shader_feature_local _SOFTDISSOLVESWITCH_ON
			#pragma shader_feature_local _SECONDLAYER_ON
			#pragma shader_feature_local _RADIAL_ON
			#pragma shader_feature_local _RADIALRING_ON
			#pragma shader_feature_local _INVERSERADIALRING_ON
			#pragma shader_feature_local _ALPHA_ON
			#pragma shader_feature_local _ALPHATEXUV2_ON
			#pragma shader_feature_local _GRADIENTDISSOLVE_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCESOFT_ON
			#pragma shader_feature_local _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _AlphaTex_ST;
			float4 _MainUV;
			float4 _GradientTex_ST;
			float4 _RimColor;
			float4 _SecondUV;
			float4 _SecondTex_ST;
			float4 _SecondColor;
			float4 _DistortionTex_ST;
			float4 _VertexOffsetTex_ST;
			float4 _Color;
			float4 _LineColor;
			float4 _SoftDissolveTex_ST;
			float2 _SoftDissolveTexUV;
			float2 _GradientUV;
			float2 _AlphaUV;
			float2 _VertexOffsetTexUV;
			float2 _DistortUV;
			float _RadialRingIntensity;
			float _SoftDissolveIndensity;
			float _SoftDissolveSoft;
			float _LineWidth;
			float _NoiseIntensity;
			float _SecondColorBlend;
			float _ZWrite;
			float _RingRadius;
			float _RingCount;
			float _RadialSpeed;
			float _RimPower;
			float _RimScale;
			float _DistortionIndensity;
			float _VertexOffsetIndensity;
			float _StencilOn;
			float _StencilRef;
			float _ColorMask;
			float _ZTest;
			float _StencilComp;
			float _Cull;
			float _StencilPass;
			float _RingRange;
			float _DepthFadeIndensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _MainTex;
			sampler2D _SecondTex;
			sampler2D _AlphaTex;
			sampler2D _SoftDissolveTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 temp_cast_0 = 0;
				float4 texCoord521 = v.ase_texcoord2;
				texCoord521.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch520 = texCoord521.z;
				#else
				float staticSwitch520 = 0.0;
				#endif
				float2 uv_VertexOffsetTex = v.ase_texcoord.xy * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_186_0 = ( ( _VertexOffsetTexUV * _TimeParameters.x ) + uv_VertexOffsetTex );
				float2 uv_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2Dlod( _DistortionTex, float4( panner269, 0, 0.0) ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = v.ase_texcoord2;
				texCoord510.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult201 = lerp( float3( temp_output_186_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCEOFFSET_ON
				float3 staticSwitch225 = lerpResult201;
				#else
				float3 staticSwitch225 = float3( temp_output_186_0 ,  0.0 );
				#endif
				#ifdef _VERTEX_OFFSET_ON
				float4 staticSwitch263 = ( ( staticSwitch520 + _VertexOffsetIndensity ) * ( tex2Dlod( _VertexOffsetTex, float4( staticSwitch225.xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a );
				#else
				float4 staticSwitch263 = temp_cast_0;
				#endif
				float4 VertexOffest253 = staticSwitch263;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord5 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffest253.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 temp_cast_0 = (0.0).xx;
				float4 texCoord497 = IN.ase_texcoord2;
				texCoord497.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult503 = (float2(texCoord497.x , texCoord497.y));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch506 = appendResult503;
				#else
				float2 staticSwitch506 = temp_cast_0;
				#endif
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv447 = ( staticSwitch506 + uv_MainTex );
				float mulTime462 = _TimeParameters.x * _MainUV.w;
				float rotatorAngle447 = ( ( 1.0 - _MainUV.z ) + ( 1.0 - mulTime462 ) );
				float2 localUvRotatorAngle2447 = UvRotatorAngle2( uv447 , rotatorAngle447 );
				float2 MainTexUV450 = localUvRotatorAngle2447;
				float2 panner260 = ( 1.0 * _Time.y * (_MainUV).xy + MainTexUV450);
				float2 temp_cast_1 = (0.5).xx;
				float2 temp_output_282_0 = ( MainTexUV450 - temp_cast_1 );
				float2 break284 = temp_output_282_0;
				float2 temp_cast_2 = (0.5).xx;
				float mulTime297 = _TimeParameters.x * _RadialSpeed;
				float2 appendResult289 = (float2((( atan2( break284.x , break284.y ) / PI )*0.5 + 0.5) , ( 1.0 - ( length( temp_output_282_0 ) + frac( mulTime297 ) ) )));
				float2 RadialUV293 = appendResult289;
				float mulTime318 = _TimeParameters.x * _RadialSpeed;
				float2 temp_cast_3 = (0.5).xx;
				float2 temp_output_306_0 = ( MainTexUV450 - temp_cast_3 );
				float2 break307 = temp_output_306_0;
				float2 temp_cast_4 = (0.5).xx;
				float smoothstepResult325 = smoothstep( 0.0 , _RingRadius , length( temp_output_306_0 ));
				float temp_output_327_0 = (0.0 + (( 1.0 - smoothstepResult325 ) - _RingRange) * (1.0 - 0.0) / (( 1.0 - _RingRange ) - _RingRange));
				#ifdef _INVERSERADIALRING_ON
				float staticSwitch345 = ( 1.0 - temp_output_327_0 );
				#else
				float staticSwitch345 = temp_output_327_0;
				#endif
				float2 appendResult313 = (float2(frac( ( frac( ( frac( mulTime318 ) + (( atan2( break307.x , break307.y ) / PI )*0.5 + 0.5) ) ) * _RingCount ) ) , staticSwitch345));
				float2 RadialUV2314 = appendResult313;
				#ifdef _RADIALRING_ON
				float2 staticSwitch342 = RadialUV2314;
				#else
				float2 staticSwitch342 = RadialUV293;
				#endif
				#ifdef _RADIAL_ON
				float2 staticSwitch295 = staticSwitch342;
				#else
				float2 staticSwitch295 = frac( panner260 );
				#endif
				float2 uv_DistortionTex = IN.ase_texcoord3.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = IN.ase_texcoord2.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2D( _DistortionTex, panner269 ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = IN.ase_texcoord4;
				texCoord510.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float4 temp_output_491_0 = ( tex2D( _MainTex, ( float3( staticSwitch295 ,  0.0 ) + DistortionUV70 ).xy ) * _Color );
				float RadialRingMask334 = ( saturate( ( temp_output_327_0 * ( 1.0 - temp_output_327_0 ) ) ) * _RadialRingIntensity );
				#ifdef _RADIALRING_ON
				float staticSwitch337 = RadialRingMask334;
				#else
				float staticSwitch337 = 1.0;
				#endif
				#ifdef _RADIAL_ON
				float staticSwitch346 = staticSwitch337;
				#else
				float staticSwitch346 = 1.0;
				#endif
				float4 temp_output_195_0 = ( ( temp_output_491_0 * staticSwitch346 ) * IN.ase_color );
				float BlendModel482 = _SecondColorBlend;
				float4 col482 = temp_output_195_0;
				float2 temp_cast_11 = (0.0).xx;
				float4 texCoord516 = IN.ase_texcoord2;
				texCoord516.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult517 = (float2(texCoord516.z , texCoord516.w));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch515 = appendResult517;
				#else
				float2 staticSwitch515 = temp_cast_11;
				#endif
				float2 uv_SecondTex = IN.ase_texcoord3.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				float2 uv472 = ( staticSwitch515 + uv_SecondTex );
				float mulTime467 = _TimeParameters.x * _SecondUV.w;
				float rotatorAngle472 = ( ( 1.0 - _SecondUV.z ) + ( 1.0 - mulTime467 ) );
				float2 localUvRotatorAngle2472 = UvRotatorAngle2( uv472 , rotatorAngle472 );
				float2 panner466 = ( 1.0 * _Time.y * (_SecondUV).xy + localUvRotatorAngle2472);
				float4 SecondTexColor479 = ( tex2D( _SecondTex, frac( panner466 ) ) * _SecondColor );
				float4 col2482 = SecondTexColor479;
				float4 localBlendColor482 = BlendColor( BlendModel482 , col482 , col2482 );
				#ifdef _SECONDLAYER_ON
				float4 staticSwitch494 = localBlendColor482;
				#else
				float4 staticSwitch494 = temp_output_195_0;
				#endif
				float2 uv_AlphaTex = IN.ase_texcoord3.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv2_AlphaTex = IN.ase_texcoord2.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				#ifdef _ALPHATEXUV2_ON
				float2 staticSwitch233 = uv2_AlphaTex;
				#else
				float2 staticSwitch233 = uv_AlphaTex;
				#endif
				float3 desaturateInitialColor157 = tex2D( _AlphaTex, ( ( _AlphaUV * _TimeParameters.x ) + staticSwitch233 ) ).rgb;
				float desaturateDot157 = dot( desaturateInitialColor157, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar157 = lerp( desaturateInitialColor157, desaturateDot157.xxx, 1.0 );
				#ifdef _ALPHA_ON
				float staticSwitch266 = (desaturateVar157).x;
				#else
				float staticSwitch266 = 1.0;
				#endif
				float AlphaMap250 = staticSwitch266;
				float temp_output_166_0 = ( (staticSwitch494).a * IN.ase_color.a * AlphaMap250 );
				float2 uv_SoftDissolveTex = IN.ase_texcoord3.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_72_0 = ( ( _SoftDissolveTexUV * _TimeParameters.x ) + uv_SoftDissolveTex );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult75 = lerp( float3( temp_output_72_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCESOFT_ON
				float3 staticSwitch229 = lerpResult75;
				#else
				float3 staticSwitch229 = float3( temp_output_72_0 ,  0.0 );
				#endif
				float3 desaturateInitialColor85 = tex2D( _SoftDissolveTex, staticSwitch229.xy ).rgb;
				float desaturateDot85 = dot( desaturateInitialColor85, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar85 = lerp( desaturateInitialColor85, desaturateDot85.xxx, 0.0 );
				#ifdef _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON
				float staticSwitch231 = IN.ase_color.a;
				#else
				float staticSwitch231 = 1.0;
				#endif
				float temp_output_119_0 = (( desaturateVar85 * staticSwitch231 )).x;
				float4 texCoord504 = IN.ase_texcoord4;
				texCoord504.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch508 = texCoord504.y;
				#else
				float staticSwitch508 = 0.0;
				#endif
				float temp_output_424_0 = saturate( ( ( ( temp_output_119_0 - ( ( ( staticSwitch508 + _SoftDissolveIndensity ) * ( 1.0 + _SoftDissolveSoft ) ) - _SoftDissolveSoft ) ) / _SoftDissolveSoft ) * 2.0 ) );
				float DissolveVal425 = temp_output_424_0;
				float GradientDissolve555 = ( ( ( saturate( ( ( IN.ase_texcoord5.xyz.y - 0 ) + 0.5 ) ) - (-_SoftDissolveSoft + (_SoftDissolveIndensity - 0.0) * (1.0 - -_SoftDissolveSoft) / (1.0 - 0.0)) ) / _SoftDissolveSoft ) * 2.0 );
				float temp_output_568_0 = ( GradientDissolve555 - ( temp_output_119_0 * _NoiseIntensity ) );
				float GradientDissolveOpacity554 = step( 0.5 , temp_output_568_0 );
				#ifdef _GRADIENTDISSOLVE_ON
				float staticSwitch578 = GradientDissolveOpacity554;
				#else
				float staticSwitch578 = DissolveVal425;
				#endif
				#ifdef _SOFTDISSOLVESWITCH_ON
				float staticSwitch226 = ( temp_output_166_0 * staticSwitch578 );
				#else
				float staticSwitch226 = temp_output_166_0;
				#endif
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth203 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth203 = abs( ( screenDepth203 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult209 = clamp( distanceDepth203 , 0.0 , 1.0 );
				#ifdef _DEPTHFADE_ON
				float staticSwitch232 = ( staticSwitch226 * clampResult209 );
				#else
				float staticSwitch232 = staticSwitch226;
				#endif
				
				float Alpha = staticSwitch232;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#include "../Library/Effect/ParticleFunction.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _VERTEX_OFFSET_ON
			#pragma shader_feature_local _CUSTOMDATA_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCEOFFSET_ON
			#pragma shader_feature_local _DISTORTION2UV_ON
			#pragma shader_feature_local _DISTORT_ON
			#pragma shader_feature_local _DEPTHFADE_ON
			#pragma shader_feature_local _SOFTDISSOLVESWITCH_ON
			#pragma shader_feature_local _SECONDLAYER_ON
			#pragma shader_feature_local _RADIAL_ON
			#pragma shader_feature_local _RADIALRING_ON
			#pragma shader_feature_local _INVERSERADIALRING_ON
			#pragma shader_feature_local _ALPHA_ON
			#pragma shader_feature_local _ALPHATEXUV2_ON
			#pragma shader_feature_local _GRADIENTDISSOLVE_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCESOFT_ON
			#pragma shader_feature_local _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _AlphaTex_ST;
			float4 _MainUV;
			float4 _GradientTex_ST;
			float4 _RimColor;
			float4 _SecondUV;
			float4 _SecondTex_ST;
			float4 _SecondColor;
			float4 _DistortionTex_ST;
			float4 _VertexOffsetTex_ST;
			float4 _Color;
			float4 _LineColor;
			float4 _SoftDissolveTex_ST;
			float2 _SoftDissolveTexUV;
			float2 _GradientUV;
			float2 _AlphaUV;
			float2 _VertexOffsetTexUV;
			float2 _DistortUV;
			float _RadialRingIntensity;
			float _SoftDissolveIndensity;
			float _SoftDissolveSoft;
			float _LineWidth;
			float _NoiseIntensity;
			float _SecondColorBlend;
			float _ZWrite;
			float _RingRadius;
			float _RingCount;
			float _RadialSpeed;
			float _RimPower;
			float _RimScale;
			float _DistortionIndensity;
			float _VertexOffsetIndensity;
			float _StencilOn;
			float _StencilRef;
			float _ColorMask;
			float _ZTest;
			float _StencilComp;
			float _Cull;
			float _StencilPass;
			float _RingRange;
			float _DepthFadeIndensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _MainTex;
			sampler2D _SecondTex;
			sampler2D _AlphaTex;
			sampler2D _SoftDissolveTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float4 temp_cast_0 = 0;
				float4 texCoord521 = v.ase_texcoord2;
				texCoord521.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch520 = texCoord521.z;
				#else
				float staticSwitch520 = 0.0;
				#endif
				float2 uv_VertexOffsetTex = v.ase_texcoord.xy * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_186_0 = ( ( _VertexOffsetTexUV * _TimeParameters.x ) + uv_VertexOffsetTex );
				float2 uv_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2Dlod( _DistortionTex, float4( panner269, 0, 0.0) ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = v.ase_texcoord2;
				texCoord510.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult201 = lerp( float3( temp_output_186_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCEOFFSET_ON
				float3 staticSwitch225 = lerpResult201;
				#else
				float3 staticSwitch225 = float3( temp_output_186_0 ,  0.0 );
				#endif
				#ifdef _VERTEX_OFFSET_ON
				float4 staticSwitch263 = ( ( staticSwitch520 + _VertexOffsetIndensity ) * ( tex2Dlod( _VertexOffsetTex, float4( staticSwitch225.xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a );
				#else
				float4 staticSwitch263 = temp_cast_0;
				#endif
				float4 VertexOffest253 = staticSwitch263;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord1;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffest253.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 temp_cast_0 = (0.0).xx;
				float4 texCoord497 = IN.ase_texcoord;
				texCoord497.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult503 = (float2(texCoord497.x , texCoord497.y));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch506 = appendResult503;
				#else
				float2 staticSwitch506 = temp_cast_0;
				#endif
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv447 = ( staticSwitch506 + uv_MainTex );
				float mulTime462 = _TimeParameters.x * _MainUV.w;
				float rotatorAngle447 = ( ( 1.0 - _MainUV.z ) + ( 1.0 - mulTime462 ) );
				float2 localUvRotatorAngle2447 = UvRotatorAngle2( uv447 , rotatorAngle447 );
				float2 MainTexUV450 = localUvRotatorAngle2447;
				float2 panner260 = ( 1.0 * _Time.y * (_MainUV).xy + MainTexUV450);
				float2 temp_cast_1 = (0.5).xx;
				float2 temp_output_282_0 = ( MainTexUV450 - temp_cast_1 );
				float2 break284 = temp_output_282_0;
				float2 temp_cast_2 = (0.5).xx;
				float mulTime297 = _TimeParameters.x * _RadialSpeed;
				float2 appendResult289 = (float2((( atan2( break284.x , break284.y ) / PI )*0.5 + 0.5) , ( 1.0 - ( length( temp_output_282_0 ) + frac( mulTime297 ) ) )));
				float2 RadialUV293 = appendResult289;
				float mulTime318 = _TimeParameters.x * _RadialSpeed;
				float2 temp_cast_3 = (0.5).xx;
				float2 temp_output_306_0 = ( MainTexUV450 - temp_cast_3 );
				float2 break307 = temp_output_306_0;
				float2 temp_cast_4 = (0.5).xx;
				float smoothstepResult325 = smoothstep( 0.0 , _RingRadius , length( temp_output_306_0 ));
				float temp_output_327_0 = (0.0 + (( 1.0 - smoothstepResult325 ) - _RingRange) * (1.0 - 0.0) / (( 1.0 - _RingRange ) - _RingRange));
				#ifdef _INVERSERADIALRING_ON
				float staticSwitch345 = ( 1.0 - temp_output_327_0 );
				#else
				float staticSwitch345 = temp_output_327_0;
				#endif
				float2 appendResult313 = (float2(frac( ( frac( ( frac( mulTime318 ) + (( atan2( break307.x , break307.y ) / PI )*0.5 + 0.5) ) ) * _RingCount ) ) , staticSwitch345));
				float2 RadialUV2314 = appendResult313;
				#ifdef _RADIALRING_ON
				float2 staticSwitch342 = RadialUV2314;
				#else
				float2 staticSwitch342 = RadialUV293;
				#endif
				#ifdef _RADIAL_ON
				float2 staticSwitch295 = staticSwitch342;
				#else
				float2 staticSwitch295 = frac( panner260 );
				#endif
				float2 uv_DistortionTex = IN.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = IN.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2D( _DistortionTex, panner269 ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = IN.ase_texcoord2;
				texCoord510.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float4 temp_output_491_0 = ( tex2D( _MainTex, ( float3( staticSwitch295 ,  0.0 ) + DistortionUV70 ).xy ) * _Color );
				float RadialRingMask334 = ( saturate( ( temp_output_327_0 * ( 1.0 - temp_output_327_0 ) ) ) * _RadialRingIntensity );
				#ifdef _RADIALRING_ON
				float staticSwitch337 = RadialRingMask334;
				#else
				float staticSwitch337 = 1.0;
				#endif
				#ifdef _RADIAL_ON
				float staticSwitch346 = staticSwitch337;
				#else
				float staticSwitch346 = 1.0;
				#endif
				float4 temp_output_195_0 = ( ( temp_output_491_0 * staticSwitch346 ) * IN.ase_color );
				float BlendModel482 = _SecondColorBlend;
				float4 col482 = temp_output_195_0;
				float2 temp_cast_11 = (0.0).xx;
				float4 texCoord516 = IN.ase_texcoord;
				texCoord516.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult517 = (float2(texCoord516.z , texCoord516.w));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch515 = appendResult517;
				#else
				float2 staticSwitch515 = temp_cast_11;
				#endif
				float2 uv_SecondTex = IN.ase_texcoord1.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				float2 uv472 = ( staticSwitch515 + uv_SecondTex );
				float mulTime467 = _TimeParameters.x * _SecondUV.w;
				float rotatorAngle472 = ( ( 1.0 - _SecondUV.z ) + ( 1.0 - mulTime467 ) );
				float2 localUvRotatorAngle2472 = UvRotatorAngle2( uv472 , rotatorAngle472 );
				float2 panner466 = ( 1.0 * _Time.y * (_SecondUV).xy + localUvRotatorAngle2472);
				float4 SecondTexColor479 = ( tex2D( _SecondTex, frac( panner466 ) ) * _SecondColor );
				float4 col2482 = SecondTexColor479;
				float4 localBlendColor482 = BlendColor( BlendModel482 , col482 , col2482 );
				#ifdef _SECONDLAYER_ON
				float4 staticSwitch494 = localBlendColor482;
				#else
				float4 staticSwitch494 = temp_output_195_0;
				#endif
				float2 uv_AlphaTex = IN.ase_texcoord1.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv2_AlphaTex = IN.ase_texcoord.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				#ifdef _ALPHATEXUV2_ON
				float2 staticSwitch233 = uv2_AlphaTex;
				#else
				float2 staticSwitch233 = uv_AlphaTex;
				#endif
				float3 desaturateInitialColor157 = tex2D( _AlphaTex, ( ( _AlphaUV * _TimeParameters.x ) + staticSwitch233 ) ).rgb;
				float desaturateDot157 = dot( desaturateInitialColor157, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar157 = lerp( desaturateInitialColor157, desaturateDot157.xxx, 1.0 );
				#ifdef _ALPHA_ON
				float staticSwitch266 = (desaturateVar157).x;
				#else
				float staticSwitch266 = 1.0;
				#endif
				float AlphaMap250 = staticSwitch266;
				float temp_output_166_0 = ( (staticSwitch494).a * IN.ase_color.a * AlphaMap250 );
				float2 uv_SoftDissolveTex = IN.ase_texcoord1.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_72_0 = ( ( _SoftDissolveTexUV * _TimeParameters.x ) + uv_SoftDissolveTex );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult75 = lerp( float3( temp_output_72_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCESOFT_ON
				float3 staticSwitch229 = lerpResult75;
				#else
				float3 staticSwitch229 = float3( temp_output_72_0 ,  0.0 );
				#endif
				float3 desaturateInitialColor85 = tex2D( _SoftDissolveTex, staticSwitch229.xy ).rgb;
				float desaturateDot85 = dot( desaturateInitialColor85, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar85 = lerp( desaturateInitialColor85, desaturateDot85.xxx, 0.0 );
				#ifdef _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON
				float staticSwitch231 = IN.ase_color.a;
				#else
				float staticSwitch231 = 1.0;
				#endif
				float temp_output_119_0 = (( desaturateVar85 * staticSwitch231 )).x;
				float4 texCoord504 = IN.ase_texcoord2;
				texCoord504.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch508 = texCoord504.y;
				#else
				float staticSwitch508 = 0.0;
				#endif
				float temp_output_424_0 = saturate( ( ( ( temp_output_119_0 - ( ( ( staticSwitch508 + _SoftDissolveIndensity ) * ( 1.0 + _SoftDissolveSoft ) ) - _SoftDissolveSoft ) ) / _SoftDissolveSoft ) * 2.0 ) );
				float DissolveVal425 = temp_output_424_0;
				float GradientDissolve555 = ( ( ( saturate( ( ( IN.ase_texcoord3.xyz.y - 0 ) + 0.5 ) ) - (-_SoftDissolveSoft + (_SoftDissolveIndensity - 0.0) * (1.0 - -_SoftDissolveSoft) / (1.0 - 0.0)) ) / _SoftDissolveSoft ) * 2.0 );
				float temp_output_568_0 = ( GradientDissolve555 - ( temp_output_119_0 * _NoiseIntensity ) );
				float GradientDissolveOpacity554 = step( 0.5 , temp_output_568_0 );
				#ifdef _GRADIENTDISSOLVE_ON
				float staticSwitch578 = GradientDissolveOpacity554;
				#else
				float staticSwitch578 = DissolveVal425;
				#endif
				#ifdef _SOFTDISSOLVESWITCH_ON
				float staticSwitch226 = ( temp_output_166_0 * staticSwitch578 );
				#else
				float staticSwitch226 = temp_output_166_0;
				#endif
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth203 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth203 = abs( ( screenDepth203 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult209 = clamp( distanceDepth203 , 0.0 , 1.0 );
				#ifdef _DEPTHFADE_ON
				float staticSwitch232 = ( staticSwitch226 * clampResult209 );
				#else
				float staticSwitch232 = staticSwitch226;
				#endif
				
				surfaceDescription.Alpha = staticSwitch232;
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#include "../Library/Effect/ParticleFunction.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _VERTEX_OFFSET_ON
			#pragma shader_feature_local _CUSTOMDATA_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCEOFFSET_ON
			#pragma shader_feature_local _DISTORTION2UV_ON
			#pragma shader_feature_local _DISTORT_ON
			#pragma shader_feature_local _DEPTHFADE_ON
			#pragma shader_feature_local _SOFTDISSOLVESWITCH_ON
			#pragma shader_feature_local _SECONDLAYER_ON
			#pragma shader_feature_local _RADIAL_ON
			#pragma shader_feature_local _RADIALRING_ON
			#pragma shader_feature_local _INVERSERADIALRING_ON
			#pragma shader_feature_local _ALPHA_ON
			#pragma shader_feature_local _ALPHATEXUV2_ON
			#pragma shader_feature_local _GRADIENTDISSOLVE_ON
			#pragma shader_feature_local _DISTORTIONINFLUENCESOFT_ON
			#pragma shader_feature_local _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _AlphaTex_ST;
			float4 _MainUV;
			float4 _GradientTex_ST;
			float4 _RimColor;
			float4 _SecondUV;
			float4 _SecondTex_ST;
			float4 _SecondColor;
			float4 _DistortionTex_ST;
			float4 _VertexOffsetTex_ST;
			float4 _Color;
			float4 _LineColor;
			float4 _SoftDissolveTex_ST;
			float2 _SoftDissolveTexUV;
			float2 _GradientUV;
			float2 _AlphaUV;
			float2 _VertexOffsetTexUV;
			float2 _DistortUV;
			float _RadialRingIntensity;
			float _SoftDissolveIndensity;
			float _SoftDissolveSoft;
			float _LineWidth;
			float _NoiseIntensity;
			float _SecondColorBlend;
			float _ZWrite;
			float _RingRadius;
			float _RingCount;
			float _RadialSpeed;
			float _RimPower;
			float _RimScale;
			float _DistortionIndensity;
			float _VertexOffsetIndensity;
			float _StencilOn;
			float _StencilRef;
			float _ColorMask;
			float _ZTest;
			float _StencilComp;
			float _Cull;
			float _StencilPass;
			float _RingRange;
			float _DepthFadeIndensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _VertexOffsetTex;
			sampler2D _DistortionTex;
			sampler2D _MainTex;
			sampler2D _SecondTex;
			sampler2D _AlphaTex;
			sampler2D _SoftDissolveTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float4 temp_cast_0 = 0;
				float4 texCoord521 = v.ase_texcoord2;
				texCoord521.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch520 = texCoord521.z;
				#else
				float staticSwitch520 = 0.0;
				#endif
				float2 uv_VertexOffsetTex = v.ase_texcoord.xy * _VertexOffsetTex_ST.xy + _VertexOffsetTex_ST.zw;
				float2 temp_output_186_0 = ( ( _VertexOffsetTexUV * _TimeParameters.x ) + uv_VertexOffsetTex );
				float2 uv_DistortionTex = v.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = v.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2Dlod( _DistortionTex, float4( panner269, 0, 0.0) ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = v.ase_texcoord2;
				texCoord510.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult201 = lerp( float3( temp_output_186_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCEOFFSET_ON
				float3 staticSwitch225 = lerpResult201;
				#else
				float3 staticSwitch225 = float3( temp_output_186_0 ,  0.0 );
				#endif
				#ifdef _VERTEX_OFFSET_ON
				float4 staticSwitch263 = ( ( staticSwitch520 + _VertexOffsetIndensity ) * ( tex2Dlod( _VertexOffsetTex, float4( staticSwitch225.xy, 0, 0.0) ) * float4( v.ase_normal , 0.0 ) ) * v.ase_color.a );
				#else
				float4 staticSwitch263 = temp_cast_0;
				#endif
				float4 VertexOffest253 = staticSwitch263;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord1;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffest253.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 temp_cast_0 = (0.0).xx;
				float4 texCoord497 = IN.ase_texcoord;
				texCoord497.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult503 = (float2(texCoord497.x , texCoord497.y));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch506 = appendResult503;
				#else
				float2 staticSwitch506 = temp_cast_0;
				#endif
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv447 = ( staticSwitch506 + uv_MainTex );
				float mulTime462 = _TimeParameters.x * _MainUV.w;
				float rotatorAngle447 = ( ( 1.0 - _MainUV.z ) + ( 1.0 - mulTime462 ) );
				float2 localUvRotatorAngle2447 = UvRotatorAngle2( uv447 , rotatorAngle447 );
				float2 MainTexUV450 = localUvRotatorAngle2447;
				float2 panner260 = ( 1.0 * _Time.y * (_MainUV).xy + MainTexUV450);
				float2 temp_cast_1 = (0.5).xx;
				float2 temp_output_282_0 = ( MainTexUV450 - temp_cast_1 );
				float2 break284 = temp_output_282_0;
				float2 temp_cast_2 = (0.5).xx;
				float mulTime297 = _TimeParameters.x * _RadialSpeed;
				float2 appendResult289 = (float2((( atan2( break284.x , break284.y ) / PI )*0.5 + 0.5) , ( 1.0 - ( length( temp_output_282_0 ) + frac( mulTime297 ) ) )));
				float2 RadialUV293 = appendResult289;
				float mulTime318 = _TimeParameters.x * _RadialSpeed;
				float2 temp_cast_3 = (0.5).xx;
				float2 temp_output_306_0 = ( MainTexUV450 - temp_cast_3 );
				float2 break307 = temp_output_306_0;
				float2 temp_cast_4 = (0.5).xx;
				float smoothstepResult325 = smoothstep( 0.0 , _RingRadius , length( temp_output_306_0 ));
				float temp_output_327_0 = (0.0 + (( 1.0 - smoothstepResult325 ) - _RingRange) * (1.0 - 0.0) / (( 1.0 - _RingRange ) - _RingRange));
				#ifdef _INVERSERADIALRING_ON
				float staticSwitch345 = ( 1.0 - temp_output_327_0 );
				#else
				float staticSwitch345 = temp_output_327_0;
				#endif
				float2 appendResult313 = (float2(frac( ( frac( ( frac( mulTime318 ) + (( atan2( break307.x , break307.y ) / PI )*0.5 + 0.5) ) ) * _RingCount ) ) , staticSwitch345));
				float2 RadialUV2314 = appendResult313;
				#ifdef _RADIALRING_ON
				float2 staticSwitch342 = RadialUV2314;
				#else
				float2 staticSwitch342 = RadialUV293;
				#endif
				#ifdef _RADIAL_ON
				float2 staticSwitch295 = staticSwitch342;
				#else
				float2 staticSwitch295 = frac( panner260 );
				#endif
				float2 uv_DistortionTex = IN.ase_texcoord1.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				float2 uv2_DistortionTex = IN.ase_texcoord.xy * _DistortionTex_ST.xy + _DistortionTex_ST.zw;
				#ifdef _DISTORTION2UV_ON
				float2 staticSwitch228 = uv2_DistortionTex;
				#else
				float2 staticSwitch228 = uv_DistortionTex;
				#endif
				float2 panner269 = ( 1.0 * _Time.y * _DistortUV + staticSwitch228);
				float3 desaturateInitialColor65 = tex2D( _DistortionTex, panner269 ).rgb;
				float desaturateDot65 = dot( desaturateInitialColor65, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar65 = lerp( desaturateInitialColor65, desaturateDot65.xxx, 1.0 );
				float4 texCoord510 = IN.ase_texcoord2;
				texCoord510.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch512 = texCoord510.x;
				#else
				float staticSwitch512 = 0.0;
				#endif
				float temp_output_513_0 = ( _DistortionIndensity + staticSwitch512 );
				#ifdef _DISTORT_ON
				float staticSwitch272 = temp_output_513_0;
				#else
				float staticSwitch272 = 0.0;
				#endif
				float3 DistortionUV70 = ( desaturateVar65 * staticSwitch272 );
				float4 temp_output_491_0 = ( tex2D( _MainTex, ( float3( staticSwitch295 ,  0.0 ) + DistortionUV70 ).xy ) * _Color );
				float RadialRingMask334 = ( saturate( ( temp_output_327_0 * ( 1.0 - temp_output_327_0 ) ) ) * _RadialRingIntensity );
				#ifdef _RADIALRING_ON
				float staticSwitch337 = RadialRingMask334;
				#else
				float staticSwitch337 = 1.0;
				#endif
				#ifdef _RADIAL_ON
				float staticSwitch346 = staticSwitch337;
				#else
				float staticSwitch346 = 1.0;
				#endif
				float4 temp_output_195_0 = ( ( temp_output_491_0 * staticSwitch346 ) * IN.ase_color );
				float BlendModel482 = _SecondColorBlend;
				float4 col482 = temp_output_195_0;
				float2 temp_cast_11 = (0.0).xx;
				float4 texCoord516 = IN.ase_texcoord;
				texCoord516.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult517 = (float2(texCoord516.z , texCoord516.w));
				#ifdef _CUSTOMDATA_ON
				float2 staticSwitch515 = appendResult517;
				#else
				float2 staticSwitch515 = temp_cast_11;
				#endif
				float2 uv_SecondTex = IN.ase_texcoord1.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				float2 uv472 = ( staticSwitch515 + uv_SecondTex );
				float mulTime467 = _TimeParameters.x * _SecondUV.w;
				float rotatorAngle472 = ( ( 1.0 - _SecondUV.z ) + ( 1.0 - mulTime467 ) );
				float2 localUvRotatorAngle2472 = UvRotatorAngle2( uv472 , rotatorAngle472 );
				float2 panner466 = ( 1.0 * _Time.y * (_SecondUV).xy + localUvRotatorAngle2472);
				float4 SecondTexColor479 = ( tex2D( _SecondTex, frac( panner466 ) ) * _SecondColor );
				float4 col2482 = SecondTexColor479;
				float4 localBlendColor482 = BlendColor( BlendModel482 , col482 , col2482 );
				#ifdef _SECONDLAYER_ON
				float4 staticSwitch494 = localBlendColor482;
				#else
				float4 staticSwitch494 = temp_output_195_0;
				#endif
				float2 uv_AlphaTex = IN.ase_texcoord1.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 uv2_AlphaTex = IN.ase_texcoord.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				#ifdef _ALPHATEXUV2_ON
				float2 staticSwitch233 = uv2_AlphaTex;
				#else
				float2 staticSwitch233 = uv_AlphaTex;
				#endif
				float3 desaturateInitialColor157 = tex2D( _AlphaTex, ( ( _AlphaUV * _TimeParameters.x ) + staticSwitch233 ) ).rgb;
				float desaturateDot157 = dot( desaturateInitialColor157, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar157 = lerp( desaturateInitialColor157, desaturateDot157.xxx, 1.0 );
				#ifdef _ALPHA_ON
				float staticSwitch266 = (desaturateVar157).x;
				#else
				float staticSwitch266 = 1.0;
				#endif
				float AlphaMap250 = staticSwitch266;
				float temp_output_166_0 = ( (staticSwitch494).a * IN.ase_color.a * AlphaMap250 );
				float2 uv_SoftDissolveTex = IN.ase_texcoord1.xy * _SoftDissolveTex_ST.xy + _SoftDissolveTex_ST.zw;
				float2 temp_output_72_0 = ( ( _SoftDissolveTexUV * _TimeParameters.x ) + uv_SoftDissolveTex );
				float DistortionIndeisty69 = temp_output_513_0;
				float3 lerpResult75 = lerp( float3( temp_output_72_0 ,  0.0 ) , DistortionUV70 , DistortionIndeisty69);
				#ifdef _DISTORTIONINFLUENCESOFT_ON
				float3 staticSwitch229 = lerpResult75;
				#else
				float3 staticSwitch229 = float3( temp_output_72_0 ,  0.0 );
				#endif
				float3 desaturateInitialColor85 = tex2D( _SoftDissolveTex, staticSwitch229.xy ).rgb;
				float desaturateDot85 = dot( desaturateInitialColor85, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar85 = lerp( desaturateInitialColor85, desaturateDot85.xxx, 0.0 );
				#ifdef _VERTEXCOLORINFLUENCESOFTDISSOLVE_ON
				float staticSwitch231 = IN.ase_color.a;
				#else
				float staticSwitch231 = 1.0;
				#endif
				float temp_output_119_0 = (( desaturateVar85 * staticSwitch231 )).x;
				float4 texCoord504 = IN.ase_texcoord2;
				texCoord504.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _CUSTOMDATA_ON
				float staticSwitch508 = texCoord504.y;
				#else
				float staticSwitch508 = 0.0;
				#endif
				float temp_output_424_0 = saturate( ( ( ( temp_output_119_0 - ( ( ( staticSwitch508 + _SoftDissolveIndensity ) * ( 1.0 + _SoftDissolveSoft ) ) - _SoftDissolveSoft ) ) / _SoftDissolveSoft ) * 2.0 ) );
				float DissolveVal425 = temp_output_424_0;
				float GradientDissolve555 = ( ( ( saturate( ( ( IN.ase_texcoord3.xyz.y - 0 ) + 0.5 ) ) - (-_SoftDissolveSoft + (_SoftDissolveIndensity - 0.0) * (1.0 - -_SoftDissolveSoft) / (1.0 - 0.0)) ) / _SoftDissolveSoft ) * 2.0 );
				float temp_output_568_0 = ( GradientDissolve555 - ( temp_output_119_0 * _NoiseIntensity ) );
				float GradientDissolveOpacity554 = step( 0.5 , temp_output_568_0 );
				#ifdef _GRADIENTDISSOLVE_ON
				float staticSwitch578 = GradientDissolveOpacity554;
				#else
				float staticSwitch578 = DissolveVal425;
				#endif
				#ifdef _SOFTDISSOLVESWITCH_ON
				float staticSwitch226 = ( temp_output_166_0 * staticSwitch578 );
				#else
				float staticSwitch226 = temp_output_166_0;
				#endif
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth203 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth203 = abs( ( screenDepth203 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFadeIndensity ) );
				float clampResult209 = clamp( distanceDepth203 , 0.0 , 1.0 );
				#ifdef _DEPTHFADE_ON
				float staticSwitch232 = ( staticSwitch226 * clampResult209 );
				#else
				float staticSwitch232 = staticSwitch226;
				#endif
				
				surfaceDescription.Alpha = staticSwitch232;
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
	
	}
	
	CustomEditor "NewRenderShaderGUI.ParticleUberEffectGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
205;306;1758;940;6826.46;1303.458;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;452;-4030.464,-961.0177;Inherit;False;1226.25;526.726;;9;450;447;461;137;463;455;462;486;501;主贴图UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;497;-4256.407,-1196.305;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;486;-3969.341,-727.8342;Inherit;False;Property;_MainUV;主贴图UV;48;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;462;-3742.285,-586.3488;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;503;-4012.835,-1176.576;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;507;-4014.73,-1287.173;Inherit;False;Constant;_Float0;Float 0;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;137;-3949.851,-912.7639;Inherit;False;0;155;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;463;-3559.285,-585.3488;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;506;-3806.326,-1200.329;Inherit;False;Property;_CustomData;CustomData;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;455;-3731.079,-758.6335;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;501;-3532.696,-918.0615;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;461;-3385.285,-759.3488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;447;-3268.298,-906.2913;Inherit;False;float DiffuseMaskAng_cos@$float DiffuseMaskAng_sin@$sincos(0.0174 * rotatorAngle,DiffuseMaskAng_sin,DiffuseMaskAng_cos)@$$  float2 panner = mul(uv - float2(0.5,0.5),$            float2x2(DiffuseMaskAng_cos, -DiffuseMaskAng_sin, DiffuseMaskAng_sin, DiffuseMaskAng_cos)) + float2(0.5,0.5) /* + jxTime * float2(_USpeed_diffusem, _VSpeed_diffusem) */@$    ;2;File;2;True;uv;FLOAT2;0,0;In;;Inherit;False;True;rotatorAngle;FLOAT;0;In;;Inherit;False;UvRotatorAngle2;False;False;0;3b3c02992cfc0ac43a4717ba06eff910;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;450;-3012.68,-909.412;Inherit;False;MainTexUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;303;-6182.549,3154.428;Inherit;False;3089.572;929.1223;;32;333;331;328;326;330;329;327;325;311;322;315;313;314;324;323;321;312;319;318;320;309;310;308;307;306;304;334;344;345;453;581;582;极坐标2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-6031.384,3523.79;Inherit;False;Constant;_Float7;Float 7;39;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;453;-6079.228,3295.128;Inherit;False;450;MainTexUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;306;-5826.748,3469.843;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;307;-5500.178,3278.601;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;24;-6176.913,-434.2155;Inherit;False;1946.859;578.7284;UV扭曲贴图;15;272;271;70;64;273;69;65;237;228;269;62;57;56;511;513;扭曲;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;300;-6181.139,2433.388;Inherit;False;1871.582;681.0234;;16;293;289;288;291;286;292;290;299;287;285;297;284;282;298;454;283;极坐标1;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-5553.774,2944.937;Inherit;False;Property;_RadialSpeed;RadialSpeed;35;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-6145.913,-376.2164;Inherit;False;0;62;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;56;-6146.913,-243.2164;Inherit;False;1;62;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;310;-5372.775,3385.539;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;308;-5322.178,3278.601;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;315;-5496.729,3664.162;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;237;-5861.347,-163.9343;Inherit;False;Property;_DistortUV;扭曲UV;12;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;228;-5912.89,-322.7952;Float;False;Property;_Distortion2UV;扭曲使用UV2;10;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;318;-4838.391,3205.646;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;454;-6083.091,2620.677;Inherit;False;450;MainTexUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;326;-5473.583,3797.398;Inherit;False;Property;_RingRadius;RingRadius;37;0;Create;True;0;0;0;False;0;False;0.4767059;0;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;309;-5122.178,3303.601;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;-5540.996,67.98598;Inherit;False;Constant;_Float11;Float 11;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;283;-6033.9,2799.804;Inherit;False;Constant;_Float6;Float 6;39;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;510;-5595.66,156.6678;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;328;-5115.583,3930.398;Inherit;False;Property;_RingRange;RingRange;38;0;Create;True;0;0;0;False;0;False;0.3574118;0;0;0.49;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;512;-5341.212,138.0458;Inherit;False;Property;_Keyword1;Keyword 1;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;506;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;282;-5849.901,2748.804;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;325;-5161.864,3672.412;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;319;-4665.959,3204.646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-5307.813,-16.05126;Float;False;Property;_DistortionIndensity;UV扭曲强度;11;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;269;-5671.769,-235.5264;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;320;-4983.528,3306.333;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;329;-4776.49,3935.93;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;513;-5109.54,-14.81953;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-5114.136,-134.7062;Inherit;False;Constant;_Float5;Float 5;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;311;-4867.407,3664.493;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;312;-4528.974,3284.611;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;284;-5523.331,2557.563;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;297;-5394.369,2946.298;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-5472.912,-263.2164;Inherit;True;Property;_DistortionTex;扭曲贴图;8;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LengthOpNode;290;-5518.215,2836.541;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;272;-4900.136,-152.7063;Inherit;False;Property;_Distort;Distort;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;285;-5345.331,2557.563;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;299;-5221.937,2945.298;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;65;-5122.911,-258.2164;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;287;-5395.927,2664.5;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;321;-4263.268,3375.436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-4390.611,3511.864;Inherit;False;Property;_RingCount;RingCount;36;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4114.941,1911.73;Inherit;False;5167.014;736.8362;;34;417;134;418;113;425;431;430;429;428;427;424;422;421;419;416;119;89;231;85;78;82;79;229;75;72;74;73;68;71;66;243;437;439;505;溶解;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;327;-4546.583,3671.398;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;243;-3999.633,1988.981;Inherit;False;Property;_SoftDissolveTexUV;软溶解UV速度;23;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;286;-5145.331,2582.563;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-4087.267,3409.373;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-4651.136,-265.7064;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;66;-4002.977,2158.345;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;344;-4214.635,3625.326;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;292;-5083.183,2840.321;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;485;-2935.168,224.1028;Inherit;False;2202.632;707.1644;;14;466;478;477;468;472;470;471;467;469;464;481;479;487;488;第二贴图;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;291;-4936.227,2840.344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-3642.617,2020.538;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;345;-4049.635,3674.326;Inherit;False;Property;_InverseRadialRing;InverseRadialRing;40;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;71;-3654.446,2214.645;Inherit;False;0;78;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;288;-5006.679,2585.294;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;516;-3057.109,10.11961;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;324;-3952.268,3423.373;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;487;-2924.529,500.411;Inherit;False;Property;_SecondUV;副贴图UV;49;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-4895.939,26.53475;Float;False;DistortionIndeisty;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-4483.782,-274.8563;Float;False;DistortionUV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-3228.547,2236.321;Inherit;False;69;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;533;-417.099,3213.608;Inherit;False;Constant;_VertexOrigin;Vertex Origin;56;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;313;-3745.178,3617.543;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;467;-2697.294,600.7716;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;517;-2738.051,74.51414;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-3437.499,2021.132;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;514;-2740.745,-43.54088;Inherit;False;Constant;_Float12;Float 12;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;531;-328.7533,2959.662;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;330;-4131.244,3898.104;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3217.034,2146.527;Inherit;False;70;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;37;-2765.629,-977.6823;Inherit;False;2742.103;600.051;主贴图;22;195;335;337;338;336;346;156;155;276;249;295;342;296;343;294;260;451;459;491;492;483;484;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;289;-4717.693,2813.134;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;469;-2479.294,601.7716;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;515;-2576.961,21.51887;Inherit;False;Property;_Keyword1;Keyword 1;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;506;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;75;-2983.051,2087.381;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-3398.348,3617.377;Inherit;False;RadialUV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;470;-2501.509,274.1028;Inherit;False;0;464;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;459;-2656.608,-709.5421;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;536;-67.09892,3063.714;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1417.305,2475.257;Float;False;Property;_SoftDissolveSoft;软溶解软度;21;0;Create;False;0;0;0;False;0;False;0;0.81;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;-3942.543,3856.004;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;468;-2500.088,425.4869;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;293;-4530.056,2809.159;Inherit;False;RadialUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;451;-2685.522,-864.0972;Inherit;False;450;MainTexUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;546;154.7399,3400.493;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;229;-2795.938,2042.526;Float;False;Property;_DistortionInfluenceSoft;扭曲影响软溶解;18;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;260;-2382.163,-850.7703;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;509;-1376.819,1617.864;Inherit;False;Constant;_Float2;Float 2;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;471;-2310.294,426.7715;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-2323.075,-531.5325;Inherit;False;314;RadialUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1331.704,2181.422;Float;False;Property;_SoftDissolveIndensity;软溶解强度;20;0;Create;False;0;0;0;False;0;False;0;0;0;1.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;518;-2296.468,102.6809;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;539;301.9011,3066.714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;504;-1437.183,1720.546;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;581;-3730.288,3993.013;Inherit;False;Property;_RadialRingIntensity;RadialRingIntensity;54;0;Create;True;0;0;0;False;0;False;1;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;333;-3630.96,3866.065;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-2320.058,-631.8884;Inherit;False;293;RadialUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;477;-2160.083,518.0849;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;547;504.3296,3335.004;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;78;-2436.059,2008.73;Inherit;True;Property;_SoftDissolveTex;软溶解贴图;19;0;Create;False;0;0;0;False;0;False;-1;None;a80188ff7e2a0b04eb5f16788dffd910;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;540;505.901,3070.714;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;296;-2112.298,-852.887;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;342;-2097.635,-627.5833;Inherit;False;Property;_RadialRing;RadialRing;39;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;417;-1307.137,2311.874;Inherit;False;Constant;_Float10;Float 10;55;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;32;-6214,1645.01;Inherit;False;1918.573;579.3191;一堆Alpha;14;168;267;266;250;0;157;147;135;120;233;102;238;111;116;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-2361.382,2221.783;Float;False;Constant;_Float1;Float 1;50;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;472;-2179.307,278.8291;Inherit;False;float DiffuseMaskAng_cos@$float DiffuseMaskAng_sin@$sincos(0.0174 * rotatorAngle,DiffuseMaskAng_sin,DiffuseMaskAng_cos)@$$  float2 panner = mul(uv - float2(0.5,0.5),$            float2x2(DiffuseMaskAng_cos, -DiffuseMaskAng_sin, DiffuseMaskAng_sin, DiffuseMaskAng_cos)) + float2(0.5,0.5) /* + jxTime * float2(_USpeed_diffusem, _VSpeed_diffusem) */@$    ;2;File;2;True;uv;FLOAT2;0,0;In;;Inherit;False;True;rotatorAngle;FLOAT;0;In;;Inherit;False;UvRotatorAngle2;False;False;0;3b3c02992cfc0ac43a4717ba06eff910;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;-3451.746,3859.627;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;508;-1184.035,1701.924;Inherit;False;Property;_Keyword1;Keyword 1;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;506;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;79;-2373.195,2314.282;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-6161.948,2057.395;Inherit;False;1;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;295;-1807.475,-869.2065;Inherit;False;Property;_Radial;Radial;34;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;543;771.901,3080.714;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-1797.787,-741.5444;Inherit;False;70;DistortionUV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;505;-998.3995,2079.205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-6167.082,1914.334;Inherit;False;0;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;116;-5970.982,1833.035;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;-3273.094,3858.478;Inherit;False;RadialRingMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;85;-2054.872,2017.693;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;238;-5966.352,1691.064;Inherit;False;Property;_AlphaUV;AlphaUV速度;15;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;231;-2199.765,2227.622;Float;False;Property;_VertexColorInfluenceSoftDissolve;顶点色影响软溶解;17;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;418;-1132.259,2311.172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;466;-1885.103,504.5355;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-5773.52,1725.628;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;478;-1652.062,506.4778;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;416;-879.1607,2180.015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;276;-1594.478,-871.4077;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;572;992.9677,3201.942;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;336;-1003.915,-609.3739;Inherit;False;334;RadialRingMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1768.988,2020.42;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-975.1398,-737.1428;Inherit;False;Constant;_Float8;Float 8;47;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;233;-5853.188,1934.315;Float;False;Property;_AlphaTexUV2;透明贴图UV2;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;1183.915,3079.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-6139.373,452.0958;Inherit;False;2422.674;968.7926;顶点偏移;15;263;253;262;220;223;222;221;208;212;184;246;173;186;180;43;顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;464;-1487.327,475.6491;Inherit;True;Property;_SecondTex;第二贴图;46;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;119;-1563.669,2014.684;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-5615.256,1722.051;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;337;-794.4405,-660.6854;Inherit;False;Property;_RadialRing;RadialRing;46;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;419;-722.3588,2182.099;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;155;-1452.251,-899.5755;Inherit;True;Property;_MainTex;主贴图;5;0;Create;False;0;0;0;False;0;False;-1;None;4020bc339d184d445ba2768b879e20be;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;156;-1641.942,-616.4335;Float;False;Property;_Color;主颜色;1;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;488;-1419.541,729.0651;Float;False;Property;_SecondColor;SecondColor;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;421;-616.8297,2030.209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;246;-6100.936,601.9171;Inherit;False;Property;_VertexOffsetTexUV;顶点偏移贴图UV;28;0;Create;False;0;0;0;False;0;False;0,0;0.09,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;481;-1158.118,482.149;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;575;-638.7473,3622.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1355.112,-319.0439;Inherit;False;467.8296;259.9428;顶点颜色;1;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;346;-558.0253,-738.882;Inherit;False;Property;_Radial;Radial;39;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;147;-5484.943,1695.01;Inherit;True;Property;_AlphaTex;Alpha贴图;13;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;555;1458.847,3100.208;Inherit;False;GradientDissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;491;-1111.547,-877.8895;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;173;-5850.301,708.2189;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;573;-528.9021,3825.578;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;52;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;479;-966.5361,475.2105;Inherit;False;SecondTexColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;556;-437.5087,3518.753;Inherit;False;555;GradientDissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-423.8229,-890.794;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;43;-5758.85,987.4744;Inherit;False;730.8218;342.6487;;4;225;201;190;189;扭曲贴图影响顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;180;-5859.6,801.7189;Inherit;False;0;208;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;157;-5166.823,1700.955;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;160;-1130.912,-254.0344;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;422;-427.444,2046.931;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-5684.838,613.6132;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;569;-137.8001,3752.591;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;484;-286.4903,-597.0421;Inherit;False;479;SecondTexColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;186;-5548.071,614.1931;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-5746.467,1213.411;Inherit;False;69;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;483;-278.1102,-707.4539;Inherit;False;Property;_SecondColorBlend;SecondColorBlend;47;1;[Enum];Create;True;0;3;Blend;0;Add;1;Mul;2;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-5748.53,1095.767;Inherit;False;70;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;568;28.04184,3703.775;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-279.8137,2046.97;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;-4888.821,1843.953;Inherit;False;Constant;_Float4;Float 4;37;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;168;-4944.954,1922.112;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-164.5315,-897.8204;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;424;-113.4034,2047.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;266;-4690.821,1873.953;Inherit;False;Property;_Alpha;Alpha;30;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;552;245.9162,3614.856;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;482;61.50549,-711.2698;Inherit;False; ;4;File;3;False;BlendModel;FLOAT;0;In;;Inherit;False;False;col;FLOAT4;0,0,0,0;In;;Inherit;False;False;col2;FLOAT4;0,0,0,0;In;;Inherit;False;BlendColor;False;False;0;3b3c02992cfc0ac43a4717ba06eff910;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;201;-5518.932,1095.643;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;519;-4998.399,272.106;Inherit;False;Constant;_Float13;Float 13;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;-4465.766,1872.901;Inherit;False;AlphaMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;425;117.1837,2039.101;Inherit;False;DissolveVal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;554;463.3224,3609.301;Inherit;False;GradientDissolveOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;521;-5240.482,286.2882;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;225;-5319.645,1050.429;Float;False;Property;_DistortionInfluenceOffset;扭曲影响顶点偏移;26;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;494;315.3927,-921.8278;Inherit;False;Property;_SecondLayer;SecondLayer;50;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;46;96.72559,8.673832;Inherit;False;751.9431;208;深度消隐;3;209;203;199;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;-848.5516,89.38976;Inherit;False;554;GradientDissolveOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-4777.855,522.8679;Float;False;Property;_VertexOffsetIndensity;顶点偏移强度;27;0;Create;False;0;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;208;-4963.401,617.4873;Inherit;True;Property;_VertexOffsetTex;顶点偏移贴图;25;0;Create;False;0;0;0;False;0;False;-1;None;a80188ff7e2a0b04eb5f16788dffd910;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;436;-817.0988,-13.91655;Inherit;False;425;DissolveVal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;520;-4807.976,352.6258;Inherit;False;Property;_Keyword1;Keyword 1;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;506;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-764.113,-136.8272;Inherit;False;250;AlphaMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;493;681.1165,-776.3393;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;212;-4858.337,809.9458;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-4651.449,621.9872;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;522;-4574.146,361.0795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-571.4877,-286.7889;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;222;-4639.875,768.8838;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;199;163.7262,80.86826;Float;False;Property;_DepthFadeIndensity;深度消隐强度;4;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;578;-562.6684,-2.738007;Inherit;False;Property;_GradientDissolve;GradientDissolve;53;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;577;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-4451.272,591.2811;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;203;409.5111,67.46416;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;262;-4437.866,506.0366;Inherit;False;Constant;_Int0;Int 0;34;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-280.1002,-225.6865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;226;58.38539,-332.235;Float;False;Property;_SoftDissolveSwitch;溶解开关;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;209;672.0032,58.67386;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;263;-4236.577,519.749;Inherit;False;Property;_Vertex_Offset;Vertex_Offset;24;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;35;-1624.458,-1366.278;Inherit;False;719.1189;379.1068;渐变叠加贴图流动;5;171;164;163;159;235;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;-3916.087,525.8817;Inherit;False;VertexOffest;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;362;-6087.018,-1150.199;Inherit;False;744.2539;183.9343;;4;278;247;361;588;设置;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-24.5564,-1368.731;Inherit;False;830.2609;294;渐变叠加贴图;4;205;198;264;265;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;586;-6359.351,-845.1783;Inherit;False;890.4375;183.2505;;4;585;584;583;587;模板;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;1258.98,-354.4683;Inherit;False;315.3334;189.3333;深度消隐开关;1;232;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;352;-6185.646,4181.251;Inherit;False;1790.069;564.9304;;12;351;524;526;350;399;414;359;354;412;347;355;353;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;40;-881.2944,-1369.757;Inherit;False;843.4887;320.6486;扭曲贴图影响软溶解;4;227;179;177;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;937.8615,-196.625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;401.0844,-1336.463;Inherit;False;Constant;_Float3;Float 3;36;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;179;-603.7583,-1282.543;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;214;966.166,-737.4718;Float;False;Property;_LineColor;溶解描边颜色;22;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;4,1.631373,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;411;1095.265,-1100.045;Inherit;False;Property;_Keyword0;Keyword 0;44;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;359;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;159;-1406.921,-1214.671;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-1215.458,-1316.278;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-828.3555,-1229.419;Inherit;False;70;DistortionUV;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;866.6799,-1081.635;Inherit;False;353;RimColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;198;23.8436,-1307.031;Inherit;True;Property;_GradientTex;渐变叠加贴图;6;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;562;859.1906,3804.402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;566;946.963,-421.5677;Inherit;False;563;GradientDissolveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;492;-1039.693,-470.3653;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;278;-5876.496,-1095.265;Inherit;False;Property;_ZWrite;深度写入;33;1;[Enum];Create;False;0;2;Off;0;On;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;227;-374.8713,-1323.256;Float;False;Property;_DistortionInfluenceGradient;扭曲影响渐变;9;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;431;849.112,2204.599;Inherit;False;EdgeFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;427;76.09458,2203.11;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;432;1485.889,-755.8601;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-5725.764,-1100.198;Inherit;False;Property;_ZTest;深度测试;32;1;[Enum];Create;False;0;3;Off;0;On;1;Option3;2;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;235;-1603.989,-1316.293;Inherit;False;Property;_GradientUV;渐变UV;7;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;437;-57.50556,2368.841;Inherit;False;Property;_LineWidth;LineWidth;45;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;1790.819,-221.8644;Inherit;False;253;VertexOffest;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-6037.018,-1098.17;Inherit;False;Property;_Cull;剔除模式;2;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;-1053.339,-1321.684;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;584;-5858.335,-781.9279;Inherit;False;Property;_StencilComp;Stencil Comp;57;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-5660.914,-795.1783;Inherit;False;Property;_StencilPass;Stencil Pass;56;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.StencilOp;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;232;1310.462,-298.903;Float;False;Property;_DepthFade;深度边缘消隐;3;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;428;276.0946,2200.11;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;557;237.589,3799.696;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;583;-6047.351,-779.028;Inherit;False;Property;_StencilRef;Stencil Ref;55;0;Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;405;1309.206,-946.8578;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;526;-6161.142,4556.185;Inherit;False;Property;_Keyword1;Keyword 1;51;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;506;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;350;-6101.121,4441.251;Inherit;False;Property;_RimScale;RimScale;41;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;-5212.592,4464.87;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-852.7438,-1142.058;Inherit;False;69;DistortionIndeisty;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;577;1223.95,-484.5795;Inherit;False;Property;_GradientDissolve;GradientDissolve;53;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;766.8832,-937.1847;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;414;-4764.232,4321.679;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;558;483.9815,3801.225;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;525;-6528.956,4561.118;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;205;344.0386,-1218.215;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-6453.872,4466.936;Inherit;False;Constant;_Float14;Float 14;56;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;412;-5420.819,4482.487;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;404;869.1201,-1211.916;Inherit;False;Constant;_Float9;Float 9;57;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;347;-5770.677,4243.142;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;440;1704.556,-784.701;Float;False;Property;_SoftDissolveSwitch1;溶解开关;16;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;226;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;399;-5191.322,4229.411;Inherit;False;Constant;_Vector0;Vector 0;56;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;433;968.72,-526.4365;Inherit;False;431;EdgeFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;164;-1456.252,-1138.202;Inherit;False;0;198;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;359;-4971.197,4317.884;Inherit;False;Property;_Rim;Rim;44;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;1038.191,3805.402;Inherit;False;GradientDissolveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;587;-6239.429,-781.4323;Inherit;False;Property;_StencilOn;StencilOn;58;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;524;-5930.313,4540.637;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;264;561.0844,-1258.463;Inherit;False;Property;_Gradient;Gradient;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;353;-4594.625,4318.722;Inherit;False;RimColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;351;-6017.272,4331.712;Inherit;False;Property;_RimPower;RimPower;42;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;561;661.4142,3801.998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-5546.46,-1096.458;Inherit;False;Property;_ColorMask;ColorMask;59;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.ColorWriteMask;True;0;False;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;354;-5663.181,4486.936;Inherit;False;Property;_RimColor;RimColor;43;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;430;649.9935,2206.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;429;445.9937,2203.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-4798.902,1931.835;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2053.803,-398.9543;Float;False;True;-1;2;NewRenderShaderGUI.ParticleUberEffectGUI;0;3;UberEffect;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;247;False;False;False;False;False;False;False;False;True;True;True;255;True;583;255;False;-1;255;False;-1;7;True;584;1;True;585;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;7;d3d11;glcore;gles;gles3;metal;vulkan;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;True;0;True;588;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;True;278;True;3;True;361;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637973383695724405;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;637973381888451993;  Use Shadow Threshold;0;0;Receive Shadows;0;637973381898080550;GPU Instancing;0;637973381908487370;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;False;True;True;False;False;False;;False;0
WireConnection;462;0;486;4
WireConnection;503;0;497;1
WireConnection;503;1;497;2
WireConnection;463;0;462;0
WireConnection;506;1;507;0
WireConnection;506;0;503;0
WireConnection;455;0;486;3
WireConnection;501;0;506;0
WireConnection;501;1;137;0
WireConnection;461;0;455;0
WireConnection;461;1;463;0
WireConnection;447;0;501;0
WireConnection;447;1;461;0
WireConnection;450;0;447;0
WireConnection;306;0;453;0
WireConnection;306;1;304;0
WireConnection;307;0;306;0
WireConnection;308;0;307;0
WireConnection;308;1;307;1
WireConnection;315;0;306;0
WireConnection;228;1;57;0
WireConnection;228;0;56;0
WireConnection;318;0;298;0
WireConnection;309;0;308;0
WireConnection;309;1;310;0
WireConnection;512;1;511;0
WireConnection;512;0;510;1
WireConnection;282;0;454;0
WireConnection;282;1;283;0
WireConnection;325;0;315;0
WireConnection;325;2;326;0
WireConnection;319;0;318;0
WireConnection;269;0;228;0
WireConnection;269;2;237;0
WireConnection;320;0;309;0
WireConnection;329;0;328;0
WireConnection;513;0;64;0
WireConnection;513;1;512;0
WireConnection;311;0;325;0
WireConnection;312;0;319;0
WireConnection;312;1;320;0
WireConnection;284;0;282;0
WireConnection;297;0;298;0
WireConnection;62;1;269;0
WireConnection;290;0;282;0
WireConnection;272;1;273;0
WireConnection;272;0;513;0
WireConnection;285;0;284;0
WireConnection;285;1;284;1
WireConnection;299;0;297;0
WireConnection;65;0;62;0
WireConnection;321;0;312;0
WireConnection;327;0;311;0
WireConnection;327;1;328;0
WireConnection;327;2;329;0
WireConnection;286;0;285;0
WireConnection;286;1;287;0
WireConnection;323;0;321;0
WireConnection;323;1;322;0
WireConnection;271;0;65;0
WireConnection;271;1;272;0
WireConnection;344;0;327;0
WireConnection;292;0;290;0
WireConnection;292;1;299;0
WireConnection;291;0;292;0
WireConnection;68;0;243;0
WireConnection;68;1;66;0
WireConnection;345;1;327;0
WireConnection;345;0;344;0
WireConnection;288;0;286;0
WireConnection;324;0;323;0
WireConnection;69;0;513;0
WireConnection;70;0;271;0
WireConnection;313;0;324;0
WireConnection;313;1;345;0
WireConnection;467;0;487;4
WireConnection;517;0;516;3
WireConnection;517;1;516;4
WireConnection;72;0;68;0
WireConnection;72;1;71;0
WireConnection;330;0;327;0
WireConnection;289;0;288;0
WireConnection;289;1;291;0
WireConnection;469;0;467;0
WireConnection;515;1;514;0
WireConnection;515;0;517;0
WireConnection;75;0;72;0
WireConnection;75;1;73;0
WireConnection;75;2;74;0
WireConnection;314;0;313;0
WireConnection;459;0;486;0
WireConnection;536;0;531;2
WireConnection;536;1;533;2
WireConnection;331;0;327;0
WireConnection;331;1;330;0
WireConnection;468;0;487;3
WireConnection;293;0;289;0
WireConnection;546;0;134;0
WireConnection;229;1;72;0
WireConnection;229;0;75;0
WireConnection;260;0;451;0
WireConnection;260;2;459;0
WireConnection;471;0;468;0
WireConnection;471;1;469;0
WireConnection;518;0;515;0
WireConnection;518;1;470;0
WireConnection;539;0;536;0
WireConnection;333;0;331;0
WireConnection;477;0;487;0
WireConnection;547;0;113;0
WireConnection;547;3;546;0
WireConnection;78;1;229;0
WireConnection;540;0;539;0
WireConnection;296;0;260;0
WireConnection;342;1;294;0
WireConnection;342;0;343;0
WireConnection;472;0;518;0
WireConnection;472;1;471;0
WireConnection;582;0;333;0
WireConnection;582;1;581;0
WireConnection;508;1;509;0
WireConnection;508;0;504;2
WireConnection;295;1;296;0
WireConnection;295;0;342;0
WireConnection;543;0;540;0
WireConnection;543;1;547;0
WireConnection;505;0;508;0
WireConnection;505;1;113;0
WireConnection;334;0;582;0
WireConnection;85;0;78;0
WireConnection;231;1;82;0
WireConnection;231;0;79;4
WireConnection;418;0;417;0
WireConnection;418;1;134;0
WireConnection;466;0;472;0
WireConnection;466;2;477;0
WireConnection;120;0;238;0
WireConnection;120;1;116;0
WireConnection;478;0;466;0
WireConnection;416;0;505;0
WireConnection;416;1;418;0
WireConnection;276;0;295;0
WireConnection;276;1;249;0
WireConnection;572;0;543;0
WireConnection;572;1;134;0
WireConnection;89;0;85;0
WireConnection;89;1;231;0
WireConnection;233;1;111;0
WireConnection;233;0;102;0
WireConnection;548;0;572;0
WireConnection;464;1;478;0
WireConnection;119;0;89;0
WireConnection;135;0;120;0
WireConnection;135;1;233;0
WireConnection;337;1;338;0
WireConnection;337;0;336;0
WireConnection;419;0;416;0
WireConnection;419;1;134;0
WireConnection;155;1;276;0
WireConnection;421;0;119;0
WireConnection;421;1;419;0
WireConnection;481;0;464;0
WireConnection;481;1;488;0
WireConnection;575;0;119;0
WireConnection;346;1;338;0
WireConnection;346;0;337;0
WireConnection;147;1;135;0
WireConnection;555;0;548;0
WireConnection;491;0;155;0
WireConnection;491;1;156;0
WireConnection;479;0;481;0
WireConnection;335;0;491;0
WireConnection;335;1;346;0
WireConnection;157;0;147;0
WireConnection;422;0;421;0
WireConnection;422;1;134;0
WireConnection;184;0;246;0
WireConnection;184;1;173;0
WireConnection;569;0;575;0
WireConnection;569;1;573;0
WireConnection;186;0;184;0
WireConnection;186;1;180;0
WireConnection;568;0;556;0
WireConnection;568;1;569;0
WireConnection;439;0;422;0
WireConnection;168;0;157;0
WireConnection;195;0;335;0
WireConnection;195;1;160;0
WireConnection;424;0;439;0
WireConnection;266;1;267;0
WireConnection;266;0;168;0
WireConnection;552;1;568;0
WireConnection;482;0;483;0
WireConnection;482;1;195;0
WireConnection;482;2;484;0
WireConnection;201;0;186;0
WireConnection;201;1;190;0
WireConnection;201;2;189;0
WireConnection;250;0;266;0
WireConnection;425;0;424;0
WireConnection;554;0;552;0
WireConnection;225;1;186;0
WireConnection;225;0;201;0
WireConnection;494;1;195;0
WireConnection;494;0;482;0
WireConnection;208;1;225;0
WireConnection;520;1;519;0
WireConnection;520;0;521;3
WireConnection;493;0;494;0
WireConnection;220;0;208;0
WireConnection;220;1;212;0
WireConnection;522;0;520;0
WireConnection;522;1;221;0
WireConnection;166;0;493;0
WireConnection;166;1;160;4
WireConnection;166;2;251;0
WireConnection;578;1;436;0
WireConnection;578;0;567;0
WireConnection;223;0;522;0
WireConnection;223;1;220;0
WireConnection;223;2;222;4
WireConnection;203;0;199;0
WireConnection;191;0;166;0
WireConnection;191;1;578;0
WireConnection;226;1;166;0
WireConnection;226;0;191;0
WireConnection;209;0;203;0
WireConnection;263;1;262;0
WireConnection;263;0;223;0
WireConnection;253;0;263;0
WireConnection;219;0;226;0
WireConnection;219;1;209;0
WireConnection;179;0;171;0
WireConnection;179;1;174;0
WireConnection;179;2;177;0
WireConnection;411;1;404;0
WireConnection;411;0;358;0
WireConnection;163;0;235;0
WireConnection;163;1;159;0
WireConnection;198;1;227;0
WireConnection;562;0;561;0
WireConnection;492;0;491;0
WireConnection;227;1;171;0
WireConnection;227;0;179;0
WireConnection;431;0;430;0
WireConnection;427;0;424;0
WireConnection;432;0;405;0
WireConnection;432;1;214;0
WireConnection;432;2;577;0
WireConnection;171;0;163;0
WireConnection;171;1;164;0
WireConnection;232;1;226;0
WireConnection;232;0;219;0
WireConnection;428;0;427;0
WireConnection;428;1;437;0
WireConnection;557;0;568;0
WireConnection;405;0;411;0
WireConnection;405;1;211;0
WireConnection;526;1;523;0
WireConnection;526;0;525;4
WireConnection;355;0;347;0
WireConnection;355;1;412;0
WireConnection;577;1;433;0
WireConnection;577;0;566;0
WireConnection;211;0;264;0
WireConnection;211;1;494;0
WireConnection;414;0;359;0
WireConnection;558;0;557;0
WireConnection;558;1;437;0
WireConnection;205;0;198;0
WireConnection;412;0;354;0
WireConnection;347;2;524;0
WireConnection;347;3;351;0
WireConnection;440;1;405;0
WireConnection;440;0;432;0
WireConnection;359;1;399;0
WireConnection;359;0;355;0
WireConnection;563;0;562;0
WireConnection;524;0;350;0
WireConnection;524;1;526;0
WireConnection;264;1;265;0
WireConnection;264;0;205;0
WireConnection;353;0;414;0
WireConnection;561;0;558;0
WireConnection;430;0;429;0
WireConnection;429;0;428;0
WireConnection;1;2;440;0
WireConnection;1;3;232;0
WireConnection;1;5;254;0
ASEEND*/
//CHKSM=49417EF8475EA94899C6EE3F64848B2416DDF495