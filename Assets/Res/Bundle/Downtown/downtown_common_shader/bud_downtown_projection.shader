// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "bud/downtown/projection"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		[Enum(AlphaBlend,10,Additive,1)]_Dst1("Dst", Float) = 10
		_flackingTilling("flackingTilling", Float) = 200
		[Toggle]_zwirtemode("zwirtemode", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode1("CullMode", Float) = 2
		[Enum(Default,0,On,1,Off,2)]_ZWrite1("ZWrite", Float) = 0
		[Normal]_NornalMap("NornalMap", 2D) = "bump" {}
		_Wireframe("Wireframe", 2D) = "white" {}
		_WireframeIntensity("WireframeIntensity", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		[HDR]_Scanlinetex1_color("Scanlinetex1_color", Color) = (1,1,1,1)
		_Scanlinetex1("Scanlinetex1", 2D) = "white" {}
		_Scanlinetex2("Scanlinetex2", 2D) = "white" {}
		_Scanline1Tilling("Scanline1Tilling", Float) = 0
		_Scanline1Speed("Scanline1Speed", Float) = 0
		_Scanline1Invert("Scanline1Invert", Range( 0 , 1)) = 0
		_Scanline1Power("Scanline1Power", Float) = 1
		_Scanline2Tilling("Scanline2Tilling", Float) = 0
		_Scanline2Speed("Scanline2Speed", Float) = 0
		_Scanline2Invert("Scanline2Invert", Range( 0 , 1)) = 0
		_Scanline2Power("Scanline2Power", Float) = 1
		_waichengRim2Bias("waichengRim2Bias", Float) = 0
		_waichengRimScale("waichengRimScale", Float) = 1
		_waichengRimPower("waichengRimPower", Float) = 0.25
		_borderRimBias("borderRimBias", Float) = 0
		_borderRimScale("borderRimScale", Float) = 1
		_borderRimPower("borderRimPower", Float) = 4.4
		[HDR]_bianyuan_fresnel_color("bianyuan_fresnel_color", Color) = (1,1,1,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_fkickcontrol("fkickcontrol", Range( 0 , 1)) = 0
		_Scanlinetex1_int("Scanlinetex1_int", Float) = 1
		_Scanlinetex2_int("Scanlinetex2_int", Float) = 1
		_Vertexoffiset("Vertexoffiset", Vector) = (1,0,0,0)
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_Glicth2Tilling("Glicth2Tilling", Float) = 200
		_GlicthTilling("GlicthTilling", Float) = 2
		_Glicthfreq("Glicthfreq", Float) = 0
		_GlicthPower("GlicthPower", Float) = 1
		_GlicthInvert("GlicthInvert", Range( 0 , 1)) = 0
		_GlicthSpeed("GlicthSpeed", Float) = 0
		_Alpha2("Alpha2", Float) = 0
		[ASEEnd]_Alphatex("Alphatex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
		
		Cull [_CullMode1]
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x gles3 

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
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha [_Dst1]
			ZWrite [_ZWrite1]
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Alphatex_ST;
			float4 _Scanlinetex1_color;
			float4 _NornalMap_ST;
			float4 _MainColor;
			float4 _bianyuan_fresnel_color;
			float4 _Wireframe_ST;
			float3 _Vertexoffiset;
			float _Scanlinetex1_int;
			float _Scanline2Power;
			float _Scanline2Invert;
			float _WireframeIntensity;
			float _Scanline2Tilling;
			float _Scanline1Power;
			float _Scanline1Invert;
			float _Alpha;
			float _Scanline1Speed;
			float _Scanline1Tilling;
			float _waichengRim2Bias;
			float _waichengRimScale;
			float _waichengRimPower;
			float _Scanlinetex2_int;
			float _Scanline2Speed;
			float _RimScale;
			float _Alpha2;
			float _CullMode1;
			float _zwirtemode;
			float _ZWrite1;
			float _Glicthfreq;
			float _GlicthSpeed;
			float _GlicthInvert;
			float _GlicthPower;
			float _GlicthTilling;
			float _Glicth2Tilling;
			float _borderRimBias;
			float _borderRimScale;
			float _borderRimPower;
			float _flackingTilling;
			float _fkickcontrol;
			float _RimBias;
			float _RimPower;
			float _Dst1;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _GlicthTex;
			sampler2D _NornalMap;
			sampler2D _Wireframe;
			sampler2D _Scanlinetex1;
			sampler2D _Scanlinetex2;
			sampler2D _Alphatex;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
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
				return 130.0 * dot( m, g );
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 objToWorld2_g10 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g10 = _TimeParameters.x * _GlicthSpeed;
				float2 appendResult11_g10 = (float2(0.0 , (( ase_worldPos.y - objToWorld2_g10.y )*_Glicthfreq + mulTime7_g10)));
				float3 objToWorldDir201 = mul( GetObjectToWorldMatrix(), float4( _Vertexoffiset, 0 ) ).xyz;
				float3 GlicthTexg235 = ( ( ( tex2Dlod( _GlicthTex, float4( appendResult11_g10, 0, 0.0) ).r - _GlicthInvert ) * _GlicthPower ) * ( objToWorldDir201 * 0.01 ) );
				float mulTime189 = _TimeParameters.x * -2.5;
				float mulTime192 = _TimeParameters.x * -2.0;
				float2 appendResult190 = (float2((ase_worldPos.y*_GlicthTilling + mulTime189) , mulTime192));
				float simplePerlin2D191 = snoise( appendResult190 );
				simplePerlin2D191 = simplePerlin2D191*0.5 + 0.5;
				float3 objToWorld202 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime209 = _TimeParameters.x * -5.0;
				float mulTime211 = _TimeParameters.x * -1.0;
				float2 appendResult213 = (float2((( objToWorld202.x + objToWorld202.y + objToWorld202.z )*_Glicth2Tilling + mulTime209) , mulTime211));
				float simplePerlin2D212 = snoise( appendResult213 );
				simplePerlin2D212 = simplePerlin2D212*0.5 + 0.5;
				float clampResult216 = clamp( (simplePerlin2D212*2.0 + -1.0) , 0.0 , 1.0 );
				float temp_output_217_0 = ( (simplePerlin2D191*2.0 + -1.0) * clampResult216 );
				float2 break219 = appendResult190;
				float2 appendResult222 = (float2(( break219.x * 20.0 ) , break219.y));
				float simplePerlin2D223 = snoise( appendResult222 );
				simplePerlin2D223 = simplePerlin2D223*0.5 + 0.5;
				float clampResult225 = clamp( (simplePerlin2D223*2.0 + -1.0) , 0.0 , 1.0 );
				float3 Vertexoffiset199 = ( GlicthTexg235 * ( temp_output_217_0 + ( temp_output_217_0 * clampResult225 ) ) );
				
				float3 normalizeWorldNormal = normalize( TransformObjectToWorldNormal(v.ase_normal) );
				o.ase_texcoord3.xyz = normalizeWorldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.zw = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Vertexoffiset199;
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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeWorldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV127 = dot( normalizeWorldNormal, ase_worldViewDir );
				float fresnelNode127 = ( _borderRimBias + _borderRimScale * pow( max( 1.0 - fresnelNdotV127 , 0.0001 ), _borderRimPower ) );
				float4 bianyuan_fresnel128 = ( fresnelNode127 * _bianyuan_fresnel_color );
				float3 objToWorld7 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime6 = _TimeParameters.x * 15.0;
				float mulTime15 = _TimeParameters.x * 0.5;
				float2 appendResult14 = (float2((( objToWorld7.x + objToWorld7.y + objToWorld7.z )*_flackingTilling + mulTime6) , mulTime15));
				float simplePerlin2D13 = snoise( appendResult14 );
				simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
				float clampResult19 = clamp( (0.0 + (simplePerlin2D13 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
				float lerpResult46 = lerp( 1.0 , clampResult19 , _fkickcontrol);
				float flacking17 = lerpResult46;
				float2 uv_NornalMap = IN.ase_texcoord4.xy * _NornalMap_ST.xy + _NornalMap_ST.zw;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24 = UnpackNormalScale( tex2D( _NornalMap, uv_NornalMap ), 1.0f );
				float3 worldNormal24 = normalize( float3(dot(tanToWorld0,tanNormal24), dot(tanToWorld1,tanNormal24), dot(tanToWorld2,tanNormal24)) );
				float fresnelNdotV23 = dot( normalize( worldNormal24 ), ase_worldViewDir );
				float fresnelNode23 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV23 , 0.0001 ), _RimPower ) );
				float Fresnelfader30 = max( fresnelNode23 , 0.0 );
				float2 uv_Wireframe = IN.ase_texcoord4.xy * _Wireframe_ST.xy + _Wireframe_ST.zw;
				float wirefreem35 = ( tex2D( _Wireframe, uv_Wireframe ).r * _WireframeIntensity );
				float3 objToWorld2_g9 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g9 = _TimeParameters.x * _Scanline1Speed;
				float2 appendResult11_g9 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g9.y )*_Scanline1Tilling + mulTime7_g9)));
				float temp_output_162_0 = ( ( tex2D( _Scanlinetex1, appendResult11_g9 ).r - _Scanline1Invert ) * _Scanline1Power );
				float3 objToWorld2_g8 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g8 = _TimeParameters.x * _Scanline2Speed;
				float2 appendResult11_g8 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g8.y )*_Scanline2Tilling + mulTime7_g8)));
				float temp_output_176_0 = ( ( tex2D( _Scanlinetex2, appendResult11_g8 ).r - _Scanline2Invert ) * _Scanline2Power );
				float4 Scanlinetexcolor167 = ( _Scanlinetex1_color * temp_output_162_0 * temp_output_176_0 );
				float3 color248 = (( bianyuan_fresnel128 + ( flacking17 * ( _MainColor + ( _MainColor * Fresnelfader30 ) + wirefreem35 + max( Scanlinetexcolor167 , float4( 0,0,0,0 ) ) ) ) )).rgb;
				
				float temp_output_179_0 = ( temp_output_176_0 * _Scanlinetex2_int );
				float Scanlinetex59 = ( ( ( temp_output_162_0 * _Scanlinetex1_int ) * temp_output_179_0 * _Scanlinetex1_color.a ) + temp_output_179_0 );
				float MainColor_a250 = _MainColor.a;
				float clampResult43 = clamp( ( Fresnelfader30 + Scanlinetex59 + MainColor_a250 ) , 0.0 , 1.0 );
				float fresnelNdotV92 = dot( normalizeWorldNormal, ase_worldViewDir );
				float fresnelNode92 = ( _waichengRim2Bias + _waichengRimScale * pow( max( 1.0 - fresnelNdotV92 , 0.0001 ), _waichengRimPower ) );
				float waicheng_fresnel96 = fresnelNode92;
				float2 uv_Alphatex = IN.ase_texcoord4.xy * _Alphatex_ST.xy + _Alphatex_ST.zw;
				float alpha245 = ( ( ( ( clampResult43 * _Alpha ) * waicheng_fresnel96 ) + _Alpha2 ) * tex2D( _Alphatex, uv_Alphatex ).r );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = color248;
				float Alpha = alpha245;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Alphatex_ST;
			float4 _Scanlinetex1_color;
			float4 _NornalMap_ST;
			float4 _MainColor;
			float4 _bianyuan_fresnel_color;
			float4 _Wireframe_ST;
			float3 _Vertexoffiset;
			float _Scanlinetex1_int;
			float _Scanline2Power;
			float _Scanline2Invert;
			float _WireframeIntensity;
			float _Scanline2Tilling;
			float _Scanline1Power;
			float _Scanline1Invert;
			float _Alpha;
			float _Scanline1Speed;
			float _Scanline1Tilling;
			float _waichengRim2Bias;
			float _waichengRimScale;
			float _waichengRimPower;
			float _Scanlinetex2_int;
			float _Scanline2Speed;
			float _RimScale;
			float _Alpha2;
			float _CullMode1;
			float _zwirtemode;
			float _ZWrite1;
			float _Glicthfreq;
			float _GlicthSpeed;
			float _GlicthInvert;
			float _GlicthPower;
			float _GlicthTilling;
			float _Glicth2Tilling;
			float _borderRimBias;
			float _borderRimScale;
			float _borderRimPower;
			float _flackingTilling;
			float _fkickcontrol;
			float _RimBias;
			float _RimPower;
			float _Dst1;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _GlicthTex;
			sampler2D _NornalMap;
			sampler2D _Scanlinetex1;
			sampler2D _Scanlinetex2;
			sampler2D _Alphatex;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
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
				return 130.0 * dot( m, g );
			}
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 objToWorld2_g10 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g10 = _TimeParameters.x * _GlicthSpeed;
				float2 appendResult11_g10 = (float2(0.0 , (( ase_worldPos.y - objToWorld2_g10.y )*_Glicthfreq + mulTime7_g10)));
				float3 objToWorldDir201 = mul( GetObjectToWorldMatrix(), float4( _Vertexoffiset, 0 ) ).xyz;
				float3 GlicthTexg235 = ( ( ( tex2Dlod( _GlicthTex, float4( appendResult11_g10, 0, 0.0) ).r - _GlicthInvert ) * _GlicthPower ) * ( objToWorldDir201 * 0.01 ) );
				float mulTime189 = _TimeParameters.x * -2.5;
				float mulTime192 = _TimeParameters.x * -2.0;
				float2 appendResult190 = (float2((ase_worldPos.y*_GlicthTilling + mulTime189) , mulTime192));
				float simplePerlin2D191 = snoise( appendResult190 );
				simplePerlin2D191 = simplePerlin2D191*0.5 + 0.5;
				float3 objToWorld202 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime209 = _TimeParameters.x * -5.0;
				float mulTime211 = _TimeParameters.x * -1.0;
				float2 appendResult213 = (float2((( objToWorld202.x + objToWorld202.y + objToWorld202.z )*_Glicth2Tilling + mulTime209) , mulTime211));
				float simplePerlin2D212 = snoise( appendResult213 );
				simplePerlin2D212 = simplePerlin2D212*0.5 + 0.5;
				float clampResult216 = clamp( (simplePerlin2D212*2.0 + -1.0) , 0.0 , 1.0 );
				float temp_output_217_0 = ( (simplePerlin2D191*2.0 + -1.0) * clampResult216 );
				float2 break219 = appendResult190;
				float2 appendResult222 = (float2(( break219.x * 20.0 ) , break219.y));
				float simplePerlin2D223 = snoise( appendResult222 );
				simplePerlin2D223 = simplePerlin2D223*0.5 + 0.5;
				float clampResult225 = clamp( (simplePerlin2D223*2.0 + -1.0) , 0.0 , 1.0 );
				float3 Vertexoffiset199 = ( GlicthTexg235 * ( temp_output_217_0 + ( temp_output_217_0 * clampResult225 ) ) );
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float3 normalizeWorldNormal = normalize( TransformObjectToWorldNormal(v.ase_normal) );
				o.ase_texcoord6.xyz = normalizeWorldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Vertexoffiset199;
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NornalMap = IN.ase_texcoord2.xy * _NornalMap_ST.xy + _NornalMap_ST.zw;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24 = UnpackNormalScale( tex2D( _NornalMap, uv_NornalMap ), 1.0f );
				float3 worldNormal24 = normalize( float3(dot(tanToWorld0,tanNormal24), dot(tanToWorld1,tanNormal24), dot(tanToWorld2,tanNormal24)) );
				float fresnelNdotV23 = dot( normalize( worldNormal24 ), ase_worldViewDir );
				float fresnelNode23 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV23 , 0.0001 ), _RimPower ) );
				float Fresnelfader30 = max( fresnelNode23 , 0.0 );
				float3 objToWorld2_g9 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g9 = _TimeParameters.x * _Scanline1Speed;
				float2 appendResult11_g9 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g9.y )*_Scanline1Tilling + mulTime7_g9)));
				float temp_output_162_0 = ( ( tex2D( _Scanlinetex1, appendResult11_g9 ).r - _Scanline1Invert ) * _Scanline1Power );
				float3 objToWorld2_g8 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g8 = _TimeParameters.x * _Scanline2Speed;
				float2 appendResult11_g8 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g8.y )*_Scanline2Tilling + mulTime7_g8)));
				float temp_output_176_0 = ( ( tex2D( _Scanlinetex2, appendResult11_g8 ).r - _Scanline2Invert ) * _Scanline2Power );
				float temp_output_179_0 = ( temp_output_176_0 * _Scanlinetex2_int );
				float Scanlinetex59 = ( ( ( temp_output_162_0 * _Scanlinetex1_int ) * temp_output_179_0 * _Scanlinetex1_color.a ) + temp_output_179_0 );
				float MainColor_a250 = _MainColor.a;
				float clampResult43 = clamp( ( Fresnelfader30 + Scanlinetex59 + MainColor_a250 ) , 0.0 , 1.0 );
				float3 normalizeWorldNormal = IN.ase_texcoord6.xyz;
				float fresnelNdotV92 = dot( normalizeWorldNormal, ase_worldViewDir );
				float fresnelNode92 = ( _waichengRim2Bias + _waichengRimScale * pow( max( 1.0 - fresnelNdotV92 , 0.0001 ), _waichengRimPower ) );
				float waicheng_fresnel96 = fresnelNode92;
				float2 uv_Alphatex = IN.ase_texcoord2.xy * _Alphatex_ST.xy + _Alphatex_ST.zw;
				float alpha245 = ( ( ( ( clampResult43 * _Alpha ) * waicheng_fresnel96 ) + _Alpha2 ) * tex2D( _Alphatex, uv_Alphatex ).r );
				
				float Alpha = alpha245;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Alphatex_ST;
			float4 _Scanlinetex1_color;
			float4 _NornalMap_ST;
			float4 _MainColor;
			float4 _bianyuan_fresnel_color;
			float4 _Wireframe_ST;
			float3 _Vertexoffiset;
			float _Scanlinetex1_int;
			float _Scanline2Power;
			float _Scanline2Invert;
			float _WireframeIntensity;
			float _Scanline2Tilling;
			float _Scanline1Power;
			float _Scanline1Invert;
			float _Alpha;
			float _Scanline1Speed;
			float _Scanline1Tilling;
			float _waichengRim2Bias;
			float _waichengRimScale;
			float _waichengRimPower;
			float _Scanlinetex2_int;
			float _Scanline2Speed;
			float _RimScale;
			float _Alpha2;
			float _CullMode1;
			float _zwirtemode;
			float _ZWrite1;
			float _Glicthfreq;
			float _GlicthSpeed;
			float _GlicthInvert;
			float _GlicthPower;
			float _GlicthTilling;
			float _Glicth2Tilling;
			float _borderRimBias;
			float _borderRimScale;
			float _borderRimPower;
			float _flackingTilling;
			float _fkickcontrol;
			float _RimBias;
			float _RimPower;
			float _Dst1;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _GlicthTex;
			sampler2D _NornalMap;
			sampler2D _Scanlinetex1;
			sampler2D _Scanlinetex2;
			sampler2D _Alphatex;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
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
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 objToWorld2_g10 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g10 = _TimeParameters.x * _GlicthSpeed;
				float2 appendResult11_g10 = (float2(0.0 , (( ase_worldPos.y - objToWorld2_g10.y )*_Glicthfreq + mulTime7_g10)));
				float3 objToWorldDir201 = mul( GetObjectToWorldMatrix(), float4( _Vertexoffiset, 0 ) ).xyz;
				float3 GlicthTexg235 = ( ( ( tex2Dlod( _GlicthTex, float4( appendResult11_g10, 0, 0.0) ).r - _GlicthInvert ) * _GlicthPower ) * ( objToWorldDir201 * 0.01 ) );
				float mulTime189 = _TimeParameters.x * -2.5;
				float mulTime192 = _TimeParameters.x * -2.0;
				float2 appendResult190 = (float2((ase_worldPos.y*_GlicthTilling + mulTime189) , mulTime192));
				float simplePerlin2D191 = snoise( appendResult190 );
				simplePerlin2D191 = simplePerlin2D191*0.5 + 0.5;
				float3 objToWorld202 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime209 = _TimeParameters.x * -5.0;
				float mulTime211 = _TimeParameters.x * -1.0;
				float2 appendResult213 = (float2((( objToWorld202.x + objToWorld202.y + objToWorld202.z )*_Glicth2Tilling + mulTime209) , mulTime211));
				float simplePerlin2D212 = snoise( appendResult213 );
				simplePerlin2D212 = simplePerlin2D212*0.5 + 0.5;
				float clampResult216 = clamp( (simplePerlin2D212*2.0 + -1.0) , 0.0 , 1.0 );
				float temp_output_217_0 = ( (simplePerlin2D191*2.0 + -1.0) * clampResult216 );
				float2 break219 = appendResult190;
				float2 appendResult222 = (float2(( break219.x * 20.0 ) , break219.y));
				float simplePerlin2D223 = snoise( appendResult222 );
				simplePerlin2D223 = simplePerlin2D223*0.5 + 0.5;
				float clampResult225 = clamp( (simplePerlin2D223*2.0 + -1.0) , 0.0 , 1.0 );
				float3 Vertexoffiset199 = ( GlicthTexg235 * ( temp_output_217_0 + ( temp_output_217_0 * clampResult225 ) ) );
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float3 normalizeWorldNormal = normalize( TransformObjectToWorldNormal(v.ase_normal) );
				o.ase_texcoord6.xyz = normalizeWorldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Vertexoffiset199;
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
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
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
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NornalMap = IN.ase_texcoord2.xy * _NornalMap_ST.xy + _NornalMap_ST.zw;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24 = UnpackNormalScale( tex2D( _NornalMap, uv_NornalMap ), 1.0f );
				float3 worldNormal24 = normalize( float3(dot(tanToWorld0,tanNormal24), dot(tanToWorld1,tanNormal24), dot(tanToWorld2,tanNormal24)) );
				float fresnelNdotV23 = dot( normalize( worldNormal24 ), ase_worldViewDir );
				float fresnelNode23 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV23 , 0.0001 ), _RimPower ) );
				float Fresnelfader30 = max( fresnelNode23 , 0.0 );
				float3 objToWorld2_g9 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g9 = _TimeParameters.x * _Scanline1Speed;
				float2 appendResult11_g9 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g9.y )*_Scanline1Tilling + mulTime7_g9)));
				float temp_output_162_0 = ( ( tex2D( _Scanlinetex1, appendResult11_g9 ).r - _Scanline1Invert ) * _Scanline1Power );
				float3 objToWorld2_g8 = mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz;
				float mulTime7_g8 = _TimeParameters.x * _Scanline2Speed;
				float2 appendResult11_g8 = (float2(0.0 , (( WorldPosition.y - objToWorld2_g8.y )*_Scanline2Tilling + mulTime7_g8)));
				float temp_output_176_0 = ( ( tex2D( _Scanlinetex2, appendResult11_g8 ).r - _Scanline2Invert ) * _Scanline2Power );
				float temp_output_179_0 = ( temp_output_176_0 * _Scanlinetex2_int );
				float Scanlinetex59 = ( ( ( temp_output_162_0 * _Scanlinetex1_int ) * temp_output_179_0 * _Scanlinetex1_color.a ) + temp_output_179_0 );
				float MainColor_a250 = _MainColor.a;
				float clampResult43 = clamp( ( Fresnelfader30 + Scanlinetex59 + MainColor_a250 ) , 0.0 , 1.0 );
				float3 normalizeWorldNormal = IN.ase_texcoord6.xyz;
				float fresnelNdotV92 = dot( normalizeWorldNormal, ase_worldViewDir );
				float fresnelNode92 = ( _waichengRim2Bias + _waichengRimScale * pow( max( 1.0 - fresnelNdotV92 , 0.0001 ), _waichengRimPower ) );
				float waicheng_fresnel96 = fresnelNode92;
				float2 uv_Alphatex = IN.ase_texcoord2.xy * _Alphatex_ST.xy + _Alphatex_ST.zw;
				float alpha245 = ( ( ( ( clampResult43 * _Alpha ) * waicheng_fresnel96 ) + _Alpha2 ) * tex2D( _Alphatex, uv_Alphatex ).r );
				
				float Alpha = alpha245;
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

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18912
569;203;1440;954;2124.608;1916.154;4.026432;True;False
Node;AmplifyShaderEditor.CommentaryNode;163;-2666.846,1002.425;Inherit;False;2287.589;1139.357;Scanlinetex1;22;166;167;59;162;165;63;91;53;54;62;171;172;173;174;175;176;177;178;179;180;181;182;Scanlinetex1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;31;-2636.403,-133.854;Inherit;False;1197.795;541.4598;Fresnelfader;9;25;24;27;26;28;23;29;30;82;Fresnelfader;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-2541.977,1894.596;Inherit;False;Property;_Scanline2Invert;Scanline2Invert;24;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2616.846,1342.974;Inherit;False;Property;_Scanline1Invert;Scanline1Invert;20;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-2454.789,1979.022;Inherit;False;Property;_Scanline2Power;Scanline2Power;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-2444.142,1749.666;Inherit;False;Property;_Scanline2Tilling;Scanline2Tilling;22;0;Create;True;0;0;0;False;0;False;0;80;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;198;-219.5877,1405.153;Inherit;False;2797.119;1526.915;Vertexoffiset;42;199;194;196;201;197;195;227;226;217;205;216;215;212;213;204;211;203;209;202;188;225;224;193;191;223;222;221;219;190;187;192;189;186;228;229;230;231;232;233;234;235;236;Vertexoffiset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2529.658,1427.4;Inherit;False;Property;_Scanline1Power;Scanline1Power;21;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2520.689,1272.326;Inherit;False;Property;_Scanline1Speed;Scanline1Speed;19;0;Create;True;0;0;0;False;0;False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;91;-2170.076,1052.425;Inherit;True;Property;_Scanlinetex1;Scanlinetex1;16;0;Create;True;0;0;0;False;0;False;None;c57f4f5bd55135a4580d6b312c61c36c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;53;-2519.011,1198.044;Inherit;False;Property;_Scanline1Tilling;Scanline1Tilling;18;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2445.82,1823.948;Inherit;False;Property;_Scanline2Speed;Scanline2Speed;23;0;Create;True;0;0;0;False;0;False;0;-3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;174;-2095.208,1604.046;Inherit;True;Property;_Scanlinetex2;Scanlinetex2;17;0;Create;True;0;0;0;False;0;False;None;dc6aa1a3be4f13c4aabca6a99b714b0d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;162;-1760.02,1231.771;Inherit;False;scanline;0;;9;5f611127c69fca244aa9c377d9d74c3d;0;6;23;SAMPLER2D;;False;19;FLOAT;0;False;20;FLOAT;2;False;22;FLOAT;1;False;24;FLOAT;2;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-2585.403,-83.85403;Inherit;True;Property;_NornalMap;NornalMap;8;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;d29531474f3a624439d7889621103aae;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;178;-1507.462,1649.874;Inherit;False;Property;_Scanlinetex1_int;Scanlinetex1_int;35;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-1500.258,1854.379;Inherit;False;Property;_Scanlinetex2_int;Scanlinetex2_int;36;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;176;-1777.952,1744.993;Inherit;False;scanline;0;;8;5f611127c69fca244aa9c377d9d74c3d;0;6;23;SAMPLER2D;;False;19;FLOAT;0;False;20;FLOAT;2;False;22;FLOAT;1;False;24;FLOAT;2;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;189;-136.2967,1744.542;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-168.7967,1624.942;Inherit;False;Property;_GlicthTilling;GlicthTilling;40;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;186;-169.5877,1455.153;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-1216.458,1746.479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;165;-1701.583,1036.607;Inherit;False;Property;_Scanlinetex1_color;Scanlinetex1_color;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0.4087237,1.709965,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-1215.695,1632.534;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2274.779,217.6058;Inherit;False;Property;_RimScale;RimScale;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;24;-2265.588,-66.42898;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;187;147.1026,1561.242;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2276.779,291.6058;Inherit;False;Property;_RimPower;RimPower;14;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;202;-173.8186,1959.609;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;192;133.2254,1767.74;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2270.335,141.2412;Inherit;False;Property;_RimBias;RimBias;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1035.065,1634.434;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-57.08868,2250.959;Inherit;False;Property;_Glicth2Tilling;Glicth2Tilling;39;0;Create;True;0;0;0;False;0;False;200;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;203;95.60744,1980.109;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;23;-2048.946,-70.47346;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;247;-593.5584,-706.5541;Inherit;False;2555.286;653.2678;color;15;248;134;39;135;40;20;168;136;170;68;38;169;37;250;1;color;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;190;346.6035,1636.941;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;209;150.9754,2246.303;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;29;-1749.458,-72.74198;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-543.5584,-456.9532;Inherit;False;Property;_MainColor;MainColor;2;1;[HDR];Create;True;0;0;0;True;0;False;1,1,1,1;0.2552055,0,2.522313,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;182;-863.6646,1633.134;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;211;389.2963,2248.261;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;219;452.1874,1814.556;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ScaleAndOffsetNode;204;311.6044,2011.189;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1625.608,-79.50506;Inherit;False;Fresnelfader;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;-283.6393,-261.8161;Inherit;False;MainColor_a;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;97;-225.7832,913.1411;Inherit;False;923.8792;321.8525;waicheng_fresnel;5;92;94;93;95;96;waicheng_fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;213;555.4124,2032.758;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;577.0423,1825.113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;244;-563.7979,59.898;Inherit;False;2271.152;628.6939;alpha;17;239;240;99;44;98;48;43;41;42;61;245;251;71;70;72;252;253;alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-636.0242,1632.717;Inherit;False;Scanlinetex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-194.3394,961.1411;Inherit;False;Property;_waichengRim2Bias;waichengRim2Bias;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-513.7979,138.7621;Inherit;False;30;Fresnelfader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;195;706.5794,2747.165;Inherit;False;Property;_Vertexoffiset;Vertexoffiset;37;0;Create;True;0;0;0;False;0;False;1,0,0;100,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;251;-489.8371,325.3689;Inherit;False;250;MainColor_a;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-194.7832,1121.505;Inherit;False;Property;_waichengRimPower;waichengRimPower;28;0;Create;True;0;0;0;False;0;False;0.25;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-193.7832,1038.505;Inherit;False;Property;_waichengRimScale;waichengRimScale;27;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;212;766.7962,2087.797;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-502.1145,233.7815;Inherit;False;59;Scanlinetex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;742.4422,1826.513;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;228;279.6245,2408.508;Inherit;True;Property;_GlicthTex;GlicthTex;38;0;Create;True;0;0;0;False;0;False;None;c57f4f5bd55135a4580d6b312c61c36c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;229;-70.98761,2628.408;Inherit;False;Property;_GlicthSpeed;GlicthSpeed;44;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;215;1068.686,2075.209;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-69.30963,2554.128;Inherit;False;Property;_Glicthfreq;Glicthfreq;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;-167.1446,2699.057;Inherit;False;Property;_GlicthInvert;GlicthInvert;43;0;Create;True;0;0;0;False;0;False;0;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-79.9566,2782.482;Inherit;False;Property;_GlicthPower;GlicthPower;42;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;191;567.5652,1636.699;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;1304.347,2822.862;Inherit;False;Constant;_Float0;Float 0;37;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;92;30.23064,980.9932;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;223;921.8084,1822.206;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;201;1031.699,2747.461;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-36.1641,110.8858;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;1473.229,2648.56;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;233;596.8803,2549.456;Inherit;True;scanline;0;;10;5f611127c69fca244aa9c377d9d74c3d;0;6;23;SAMPLER2D;;False;19;FLOAT;0;False;20;FLOAT;2;False;22;FLOAT;1;False;24;FLOAT;2;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;459.0956,1003.231;Inherit;False;waicheng_fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;43;150.7278,109.898;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;193;997.0332,1683.373;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-23.37906,250.956;Inherit;False;Property;_Alpha;Alpha;33;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;216;1369.853,2074.807;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;224;1116.025,1826.635;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;320.6122,348.8645;Inherit;False;96;waicheng_fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;1560.661,1801.91;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;225;1340.766,1841.467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;312.861,119.3255;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;1708.91,2545.124;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;609.3568,183.3434;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;676.2698,493.2113;Inherit;False;Property;_Alpha2;Alpha2;45;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;1715.615,1883.784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;1951.494,2542.831;Inherit;False;GlicthTexg;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;1670.278,1692.49;Inherit;False;235;GlicthTexg;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;958.2701,275.2117;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;253;891.3731,494.1833;Inherit;True;Property;_Alphatex;Alphatex;46;0;Create;True;0;0;0;False;0;False;-1;None;2ecf3cd18b040344fb6d9c35826da914;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;227;1855.7,1811.252;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;2106.659,1683.727;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;1229.373,327.1833;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;2275.398,141.9625;Inherit;False;237;166;properties;1;21;properties;0.8301887,0.1527234,0.1527234,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-2639.019,457.8672;Inherit;False;1414.837;382.9403;wirefreem;6;35;33;80;34;77;76;wirefreem;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;1437.814,332.2691;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;767.0474,916.4399;Inherit;False;1428.879;333.8521;border_fresnel;7;128;125;126;124;132;131;127;border_fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-2636.859,-675.5872;Inherit;False;1925.28;468.0601;flacking;13;19;17;18;13;15;6;11;14;9;8;7;46;47;flacking;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;2376.887,1674.172;Inherit;False;Vertexoffiset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;2325.398,191.9625;Inherit;False;Property;_zwirtemode;zwirtemode;5;1;[Toggle];Create;True;0;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-1289.799,1099.466;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;1561.257,979.8442;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-2262.065,-338.8929;Inherit;False;1;0;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;1945.927,978.5303;Inherit;False;bianyuan_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-1857.628,-552.4384;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-949.3074,-517.7927;Inherit;False;flacking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-990.0137,1097.598;Inherit;False;Scanlinetexcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;2550.257,142.0005;Inherit;False;Property;_ZWrite1;ZWrite;7;1;[Enum];Create;False;0;3;Default;0;On;1;Off;2;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;136;1362.834,-527.5134;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-1646.244,-497.3995;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;817.0474,1116.805;Inherit;False;Property;_borderRimPower;borderRimPower;31;0;Create;True;0;0;0;False;0;False;4.4;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;823.4914,966.4399;Inherit;False;Property;_borderRimBias;borderRimBias;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;7;-2586.859,-625.5872;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;124;819.0474,1042.805;Inherit;False;Property;_borderRimScale;borderRimScale;30;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;46;-958.2554,-396.3636;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;127;1023.062,984.292;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2085.149,742.4045;Inherit;False;Property;_WireframeIntensity;WireframeIntensity;11;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;2126.653,486.7398;Inherit;False;245;alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;612.1663,-523.2861;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-2582.171,498.6705;Inherit;True;Property;_Wireframe;Wireframe;10;0;Create;True;0;0;0;False;0;False;None;934942965f960ee45aeb599c4a99a881;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;39;408.2061,-497.4161;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;983.567,-560.4691;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1591.894,717.6821;Inherit;False;wirefreem;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;2129.083,399.4175;Inherit;False;248;color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-2317.433,-605.0866;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;19;-1145.966,-523.7653;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1287.683,-313.8822;Inherit;False;Property;_fkickcontrol;fkickcontrol;34;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;170;291.368,-255.9693;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-1345.454,-525.7091;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;1599.082,-525.0998;Inherit;False;color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;131;1321.257,1057.844;Inherit;False;Property;_bianyuan_fresnel_color;bianyuan_fresnel_color;32;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-2574.171,705.6703;Inherit;False;0;76;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;20;378.8504,-586.8289;Inherit;False;17;flacking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;2126.29,589.4615;Inherit;False;199;Vertexoffiset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;649.1009,-656.5541;Inherit;False;128;bianyuan_fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;2550.8,315.2678;Inherit;False;Property;_Dst1;Dst;3;1;[Enum];Create;False;0;2;AlphaBlend;10;Additive;1;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;9;-2101.436,-574.0073;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;80;-2133.539,537.3658;Inherit;True;Property;_TextureSample1;Texture Sample 1;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;169;-5.46378,-253.6832;Inherit;False;167;Scanlinetexcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;134.0499,-337.5883;Inherit;False;35;wirefreem;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-189.1616,-365.8247;Inherit;False;30;Fresnelfader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-2023.744,-336.9348;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;155.4893,-440.5645;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-2600.324,141.4525;Inherit;False;Property;_NornalMap_int;NornalMap_int;9;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2470.129,-334.2365;Inherit;False;Property;_flackingTilling;flackingTilling;4;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;2552.414,225.8519;Inherit;False;Property;_CullMode1;CullMode;6;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1749.149,704.4045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;71;648.1014,-31.82244;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;70;648.1014,-31.82244;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;1080.053,-660.1984;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;72;648.1014,-31.82244;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;69;2425.087,431.9198;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;bud/downtown/projection;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;101;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;16;d3d9;d3d11;glcore;gles;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;True;True;2;5;False;-1;10;True;100;0;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;0;True;102;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
WireConnection;162;23;91;0
WireConnection;162;20;53;0
WireConnection;162;22;54;0
WireConnection;162;24;62;0
WireConnection;162;25;63;0
WireConnection;176;23;174;0
WireConnection;176;20;173;0
WireConnection;176;22;172;0
WireConnection;176;24;171;0
WireConnection;176;25;175;0
WireConnection;179;0;176;0
WireConnection;179;1;180;0
WireConnection;177;0;162;0
WireConnection;177;1;178;0
WireConnection;24;0;25;0
WireConnection;187;0;186;2
WireConnection;187;1;188;0
WireConnection;187;2;189;0
WireConnection;181;0;177;0
WireConnection;181;1;179;0
WireConnection;181;2;165;4
WireConnection;203;0;202;1
WireConnection;203;1;202;2
WireConnection;203;2;202;3
WireConnection;23;0;24;0
WireConnection;23;1;26;0
WireConnection;23;2;27;0
WireConnection;23;3;28;0
WireConnection;190;0;187;0
WireConnection;190;1;192;0
WireConnection;29;0;23;0
WireConnection;182;0;181;0
WireConnection;182;1;179;0
WireConnection;219;0;190;0
WireConnection;204;0;203;0
WireConnection;204;1;205;0
WireConnection;204;2;209;0
WireConnection;30;0;29;0
WireConnection;250;0;1;4
WireConnection;213;0;204;0
WireConnection;213;1;211;0
WireConnection;221;0;219;0
WireConnection;59;0;182;0
WireConnection;212;0;213;0
WireConnection;222;0;221;0
WireConnection;222;1;219;1
WireConnection;215;0;212;0
WireConnection;191;0;190;0
WireConnection;92;1;94;0
WireConnection;92;2;93;0
WireConnection;92;3;95;0
WireConnection;223;0;222;0
WireConnection;201;0;195;0
WireConnection;41;0;42;0
WireConnection;41;1;61;0
WireConnection;41;2;251;0
WireConnection;196;0;201;0
WireConnection;196;1;197;0
WireConnection;233;23;228;0
WireConnection;233;20;232;0
WireConnection;233;22;229;0
WireConnection;233;24;230;0
WireConnection;233;25;231;0
WireConnection;96;0;92;0
WireConnection;43;0;41;0
WireConnection;193;0;191;0
WireConnection;216;0;215;0
WireConnection;224;0;223;0
WireConnection;217;0;193;0
WireConnection;217;1;216;0
WireConnection;225;0;224;0
WireConnection;44;0;43;0
WireConnection;44;1;48;0
WireConnection;234;0;233;0
WireConnection;234;1;196;0
WireConnection;99;0;44;0
WireConnection;99;1;98;0
WireConnection;226;0;217;0
WireConnection;226;1;225;0
WireConnection;235;0;234;0
WireConnection;239;0;99;0
WireConnection;239;1;240;0
WireConnection;227;0;217;0
WireConnection;227;1;226;0
WireConnection;194;0;236;0
WireConnection;194;1;227;0
WireConnection;252;0;239;0
WireConnection;252;1;253;1
WireConnection;245;0;252;0
WireConnection;199;0;194;0
WireConnection;166;0;165;0
WireConnection;166;1;162;0
WireConnection;166;2;176;0
WireConnection;132;0;127;0
WireConnection;132;1;131;0
WireConnection;128;0;132;0
WireConnection;14;0;9;0
WireConnection;14;1;15;0
WireConnection;17;0;46;0
WireConnection;167;0;166;0
WireConnection;136;0;135;0
WireConnection;13;0;14;0
WireConnection;46;1;19;0
WireConnection;46;2;47;0
WireConnection;127;1;126;0
WireConnection;127;2;124;0
WireConnection;127;3;125;0
WireConnection;40;0;20;0
WireConnection;40;1;39;0
WireConnection;39;0;1;0
WireConnection;39;1;38;0
WireConnection;39;2;168;0
WireConnection;39;3;170;0
WireConnection;135;0;134;0
WireConnection;135;1;40;0
WireConnection;35;0;33;0
WireConnection;8;0;7;1
WireConnection;8;1;7;2
WireConnection;8;2;7;3
WireConnection;19;0;18;0
WireConnection;170;0;169;0
WireConnection;18;0;13;0
WireConnection;248;0;136;0
WireConnection;9;0;8;0
WireConnection;9;1;11;0
WireConnection;9;2;6;0
WireConnection;80;0;76;0
WireConnection;80;1;77;0
WireConnection;38;0;1;0
WireConnection;38;1;37;0
WireConnection;33;0;80;1
WireConnection;33;1;34;0
WireConnection;69;2;249;0
WireConnection;69;3;246;0
WireConnection;69;5;200;0
ASEEND*/
//CHKSM=D08DC070A308767B5DF17424002E2158CBD497C1