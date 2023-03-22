#ifndef NORMAL_LIB_INCLUDE
#define NORMAL_LIB_INCLUDE

#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
#endif

//vert input
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define VERT_INPUT_NORMAL_STRUCT \
        float3 normalOS : NORMAL; \
        float4 tangentOS : TANGENT;
#else
    #define VERT_INPUT_NORMAL_STRUCT \
        float3 normalOS : NORMAL;
#endif

//vert output (no positionWS)
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define VERT_OUTPUT_NORMAL_STRUCT(index0,index1,index2) \
        float3 normalWS : TEXCOORD##index0; \
        float3 tangentWS : TEXCOORD##index1; \
        float3 bitangentWS : TEXCOORD##index2;
#else
    #define VERT_OUTPUT_NORMAL_STRUCT(index0,index1,index2) \
        float3 normalWS : TEXCOORD##index0;
#endif

//vert output (positionWS)
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define VERT_OUTPUT_NORMAL_POSITION_STRUCT(index0,index1,index2) \
        float4 normalWS : TEXCOORD##index0; \
        float4 tangentWS : TEXCOORD##index1; \
        float4 bitangentWS : TEXCOORD##index2;
#else
    #define VERT_OUTPUT_NORMAL_POSITION_STRUCT(index0,index1,index2) \
        float3 positionWS : TEXCOORD##index0; \
        float3 normalWS : TEXCOORD##index1;
#endif

//vert (positionWS) //VERT_NORMAL_POSITION(input,output,positionWS) 
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define VERT_NORMAL_POSITION(input,output,positionWS) \
        real sign = real(input.tangentOS.w) * GetOddNegativeScale(); \
	    output.normalWS =half4( TransformObjectToWorldNormal(input.normalOS) , positionWS.x); \
	    output.tangentWS =half4(real3(TransformObjectToWorldDir(input.tangentOS.xyz)),positionWS.y) ; \
	    output.bitangentWS = half4(real3(cross(output.normalWS.xyz, float3(output.tangentWS.xyz))) * sign,positionWS.z);
#else
    #define VERT_NORMAL_POSITION(input,output,positionWS) \
        output.positionWS = positionWS; \
        output.normalWS = TransformObjectToWorldNormal(input.normalOS);
#endif

//vert (no positionWS) //VERT_NORMAL(input,output) 
#if defined(_NORMAL_ON) && defined(_NORMALMAP)
    #define VERT_NORMAL(input,output) \
        real sign = real(input.tangentOS.w) * GetOddNegativeScale(); \
	    output.normalWS = TransformObjectToWorldNormal(input.normalOS); \
	    output.tangentWS = real3(TransformObjectToWorldDir(input.tangentOS.xyz)); \
	    output.bitangentWS = real3(cross(output.normalWS.xyz, float3(output.tangentWS.xyz))) * sign;
#else
    #define VERT_NORMAL(input,output) \
        output.normalWS = TransformObjectToWorldNormal(input.normalOS);
#endif

//frag //FRAGMENT_GET_WORLD_NORMAL(input,normalTS) //input:vert output
#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
    #if defined(_NORMAL_ON) && defined(_NORMALMAP)
        #define FRAGMENT_GET_WORLD_NORMAL(input,normalTS) \
            float2 sampleCoords = (input.lightmapUV.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy; \
            float3 twn = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1)); \
            float3 twt = -cross(GetObjectToWorldMatrix()._13_23_33, twn); \
            float3 twb = cross(twn, -twt); \
            float3 normalWS = TransformTangentToWorld(normalTS, half3x3(twt.xyz, twb.xyz, twn.xyz)); \
            normalWS = NormalizeNormalPerPixel(normalWS);
    #else
        #define FRAGMENT_GET_WORLD_NORMAL(input,normalTS) \
            float3 normalWS = input.normalWS.xyz; \
            normalWS = NormalizeNormalPerPixel(normalWS);
    #endif
#else
    #if defined(_NORMAL_ON) && defined(_NORMALMAP)
        #define FRAGMENT_GET_WORLD_NORMAL(input,normalTS) \
            float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz)); \
            normalWS = NormalizeNormalPerPixel(normalWS);
    #else
        #define FRAGMENT_GET_WORLD_NORMAL(input,normalTS) \
            float3 normalWS = input.normalWS.xyz; \
            normalWS = NormalizeNormalPerPixel(normalWS);
    #endif
#endif

//获得世界法线
half3 GetNormalWorld(half3 _normal){
    half3 worldNormal=normalize(TransformObjectToWorldNormal(_normal));
    return worldNormal;
}

//读取法线数据 （切线空间） _bumpMap:切线空间的纹理坐标 _uv:uv坐标 _normalScale:法线缩放比例
half3 GetTangentNormalFromTexture(sampler2D _bumpMap,float2 _uv,float _normalScale){
	half3 normal = UnpackNormal(tex2D(_bumpMap,_uv));
    normal.xy *= _normalScale;
    normal.z = sqrt(1 - saturate(dot(normal.xy,normal.xy)));
    return normal;
}

//frag
#if defined(_NORMAL_ON)
    #define FRAGMENT_NORMAL(bumpTexture,uv,bumpScale,input) \
        half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(bumpTexture,sampler##bumpTexture,uv)); \
        normalTS.xy *= bumpScale; \
        normalTS.z = sqrt(1 - saturate(dot(normalTS.xy,normalTS.xy))); \
        half3x3 TBN = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz); \
        float3 normalWS = normalize(mul(normalTS,TBN));
#else
    #define FRAGMENT_NORMAL(bumpTexture,uv,bumpScale,input)
#endif

float3 ColorRGToNormal(float colorR, float colorG)
{
    //-1 - 1
    float2 newV2=float2(colorR,colorG)*2.0- 1.0;
    //z
    float addValue=abs(newV2.x)+abs(newV2.y);
    float subValue=addValue-1.0;
    float saturateValue=saturate(subValue);
    float oneMinusValue=1.0-saturateValue;
    float sqrtValue=sqrt(oneMinusValue);
    //
    float3 combineValue=normalize(float3(newV2.x, newV2.y,sqrtValue));
    return combineValue;
}

//R G通道采样法线
real3 UnpackNormalScale_RG(real4 packedNormal, real scale = 1.0)
{
    real3 normal;
    normal.xy = packedNormal.rg * 2.0 - 1.0;
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    normal.xy *= scale;
    return normal;
}

//B A通道采样法线
real3 UnpackNormalScale_BA(real4 packedNormal, real scale = 1.0)
{
    real3 normal;
    normal.xy = packedNormal.ba * 2.0 - 1.0;
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    normal.xy *= scale;
    return normal;
}

//R G通道采样法线
real3 UnpackNormal_RG(real4 packedNormal)
{
    real3 normal;
    normal.xy = packedNormal.rg * 2.0 - 1.0;
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    return normal;
}

//B A通道采样法线
real3 UnpackNormal_BA(real4 packedNormal)
{
    real3 normal;
    normal.xy = packedNormal.ba * 2.0 - 1.0;
    normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
    return normal;
}

//将切线空间的法线计算为世界空间
//需要传入转换矩阵
//矩阵规则:
//
//顶点切线(世界空间).x  |  切线与法线垂直轴(世界空间).x  |  法线(世界空间).x  -->matrix0
//顶点切线(世界空间).y	|  切线与法线垂直轴(世界空间).y  |  法线(世界空间).y  -->matrix1
//顶点切线(世界空间).z  |  切线与法线垂直轴(世界空间).z  |  法线(世界空间).z  -->matrix2
//
//normalTangent:法线(（切线空间）)
half3 GetWorldNormalFromTexture(half3 _matrix0,half3 _matrix1,half3 _matrix2,half3 _normalTangent){
	half3 normalWorld = normalize(half3(dot(_matrix0,_normalTangent),dot(_matrix1,_normalTangent),dot(_matrix2,_normalTangent)));
	return normalWorld;
}

//将切线空间的法线计算为世界空间
//normalTS:法线纹理采样
//tangent:切线空间
//bitangent:切线空间 副切线
//normal:切线空间 法线
half3 GetWorldNormalFromTextureB(half3 normalTS, half3 tangent, half3 bitangent, half3 normal)
{
    half3 normalWS = TransformTangentToWorld(normalTS, half3x3(tangent.xyz, bitangent.xyz, normal.xyz));
    return normalWS;
}

float3 NormalBlend(float3 A, float3 B)
{
    return SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
}

float3 NormalBlendLinear(float3 A, float3 B)
{
    float3 res=normalize(A+B);
    return res;
}

float3 NormalBlendReoriented(float3 A, float3 B)
{
	float3 t = A.xyz + float3(0.0, 0.0, 1.0);
	float3 u = B.xyz * float3(-1.0, -1.0, 1.0);
	return (t / t.z) * dot(t, u) - u;
}

float NormalFiltering(float roughness, const float3 worldNormal) {
    // Kaplanyan 2016, "Stable specular highlights"
    // Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
    // Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"

    // This implementation is meant for deferred rendering in the original paper but
    // we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
    // 2019). The main reason is that the forward version requires an expensive transform
    // of the half vector by the tangent frame for every light. This is therefore an
    // approximation but it works well enough for our needs and provides an improvement
    // over our original implementation based on Vlachos 2015, "Advanced VR Rendering".

    float3 du = ddx(worldNormal);
    float3 dv = ddy(worldNormal);

    float variance = 0.5 * (dot(du, du) + dot(dv, dv));

    float kernelRoughness = min(2.0 * variance, 1);
    float squareRoughness = saturate(roughness * roughness + kernelRoughness);

    return sqrt(squareRoughness);
}

#endif // NORMAL_LIB_INCLUDE