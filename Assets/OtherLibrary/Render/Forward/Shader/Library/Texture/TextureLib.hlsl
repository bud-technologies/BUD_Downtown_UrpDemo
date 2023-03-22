#ifndef TEXTURE_LIB_INCLUDE
#define TEXTURE_LIB_INCLUDE

//纹理像素尺寸 Vector4(1 / width, 1 / height, width, height)
#define TEXEL_SIZE(textureMap) \
    float texelSizeWidth = textureMap##_TexelSize.z; \
    float texelSizeHeight = textureMap##_TexelSize.w;

#define L_SAMPLER_TEXTURE(textureName)\
    TEXTURE2D(_##textureName);\
    SAMPLER(sampler_##textureName);

#define L_SAMPLER_TEXTURE2D_ARRAY(textureName)\
    TEXTURE2D_ARRAY(textureName);\
    SAMPLER(sampler_##textureName);

#define L_SAMPLER_TEXTURE3D(textureName)\
    TEXTURE3D(textureName);\
    SAMPLER(sampler_##textureName);

//-----------------cube map

SamplerState sampler_Cube_LinearClamp;

//获取折射
float3 GetReflectionUV(float3 positionWS,float3 normalWS){
    float3 viewDir = _WorldSpaceCameraPos.xyz - positionWS;
    float3 uv = reflect(-viewDir, normalWS);
    return uv;
}

//获取Unity环境 Cube
half4 GetUnityCube(float3 positionWS,float3 normalWS,int mipLevel){
    float3 uv = GetReflectionUV(positionWS,normalWS);
    half4 sampleCubemapOut = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, uv, mipLevel);
#if !defined(UNITY_USE_NATIVE_HDR)
    sampleCubemapOut.rgb = DecodeHDREnvironment(sampleCubemapOut, unity_SpecCube0_HDR);
#endif
    return sampleCubemapOut;
}

//获取 Cube
half4 GetCube(TextureCube textureCube ,float3 positionWS,float3 normalWS,int mipLevel){
    float3 uv = GetReflectionUV(positionWS,normalWS);
    half4 sampleCubemapOut = SAMPLE_TEXTURECUBE_LOD(textureCube, sampler_Cube_LinearClamp, uv, mipLevel);
#if !defined(UNITY_USE_NATIVE_HDR)
    sampleCubemapOut.rgb = DecodeHDREnvironment(sampleCubemapOut, unity_SpecCube0_HDR);
#endif
    return sampleCubemapOut;
}

//获取折射,传入顶点阶段
float3 GetReflectionUVVert(float3 positionOS,float3 normalOS)
{
     float3 viewDir = _WorldSpaceCameraPos - TransformObjectToWorld(positionOS);
     float3 uv = reflect(-viewDir, TransformObjectToWorldNormal(normalOS));
     return uv;
}

//获取Unity环境 Cube ,传入顶点阶段
half4 GetUnityCubeVert(float3 positionOS,float3 normalOS,int mipLevel)
{
     float3 uv = GetReflectionUVVert(positionOS,normalOS);
     half4 sampleCubemapOut = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, uv, mipLevel);
#if !defined(UNITY_USE_NATIVE_HDR)
     sampleCubemapOut.rgb = DecodeHDREnvironment(sampleCubemapOut, unity_SpecCube0_HDR);
#endif
     return sampleCubemapOut;
}

//获取 Cube ,传入顶点阶段
half4 GetCubeVert(TextureCube textureCube ,float3 positionOS,float3 normalOS,int mipLevel)
{
     float3 uv = GetReflectionUVVert(positionOS,normalOS);
     half4 sampleCubemapOut = SAMPLE_TEXTURECUBE_LOD(textureCube, sampler_Cube_LinearClamp, uv, mipLevel);
#if !defined(UNITY_USE_NATIVE_HDR)
     sampleCubemapOut.rgb = DecodeHDREnvironment(sampleCubemapOut, unity_SpecCube0_HDR);
#endif
     return sampleCubemapOut;
}

//-----------------UV
//UV计算 
//textureName:纹理名
//uvVertextInput:顶点阶段输入的网格UV
//uv:计算结果
#define L_TRANSFORM_TEX(textureName,uvVertextInput,uv) \
    uv##.xy = TRANSFORM_TEX(uvVertextInput##.xy,textureName);

//-----------------2D纹理 数组

//纹理数组
#define L_SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, uv, index) \
    half4 textureName##_Tex  = SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, uv, index);

//纹理数组 LOD
#define L_SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, uv, index, mipLevel) \
    half4 textureName##_Tex  = SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, uv, index,mipLevel);

//纹理
#define L_SAMPLE_TEXTURE2D(textureName, samplerName, uv) \
    half4 textureName##_Tex =  SAMPLE_TEXTURE2D(textureName, samplerName, uv);

//纹理 LOD
#define L_SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uv, mipLevel) \
    half4 textureName##_Tex = SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uv,mipLevel);

//纹理
half4 SampleTexture2D(TEXTURE2D_PARAM(texMap, sampler_texMap),half2 uv){
   half4 sampleTexture2DRGBA = SAMPLE_TEXTURE2D(texMap, sampler_texMap, uv);
   return sampleTexture2DRGBA;
}

//纹理 LOD
half4 SampleTexture2D_LOD(TEXTURE2D_PARAM(texMap, sampler_texMap),half2 uv,half mipLevel){
   half4 sampleTexture2DRGBA = SAMPLE_TEXTURE2D_LOD(texMap, sampler_texMap, uv,mipLevel);
   return sampleTexture2DRGBA;
}

//-----------------法线纹理

//法线纹理
#define L_SAMPLE_NORMAL_TEXTURE2D(textureName, samplerName, uv) \
    half4 textureName##_Tex  = SAMPLE_TEXTURE2D(textureName, samplerName, uv); \
    sampleTexture2DRGBA.rgb= UnpackNormal(sampleTexture2DRGBA);

//法线纹理 LOD
#define L_SAMPLE_NORMAL_TEXTURE2D_LOD(textureName, samplerName, uv, mipLevel) \
    half4 textureName##_Tex = SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uv,mipLevel); \
    sampleTexture2DRGBA.rgb= UnpackNormal(sampleTexture2DRGBA);

//纹理
half4 SampleNomalTexture2D(TEXTURE2D_PARAM(texMap, sampler_texMap),half2 uv){
   half4 sampleTexture2DRGBA = SAMPLE_TEXTURE2D(texMap, sampler_texMap, uv);
   sampleTexture2DRGBA.rgb= UnpackNormal(sampleTexture2DRGBA);
   return sampleTexture2DRGBA;
}

//纹理 LOD
half4 SampleNomalTexture2D_LOD(TEXTURE2D_PARAM(texMap, sampler_texMap),half2 uv,half mipLevel){
   half4 sampleTexture2DRGBA = SAMPLE_TEXTURE2D_LOD(texMap, sampler_texMap, uv,mipLevel);
   sampleTexture2DRGBA.rgb= UnpackNormal(sampleTexture2DRGBA);
   return sampleTexture2DRGBA;
}

//-----------------3D纹理

//3D纹理
#define L_SAMPLE_TEXTURE3D(textureName, samplerName, uv) \
    float4 textureName##_Tex = SAMPLE_TEXTURE3D(textureName, samplerName, uv);

//3D纹理 LOD
#define L_SAMPLE_TEXTURE3D_LOD(textureName, samplerName, uv,mipLevel) \
    float4 textureName##_Tex = SAMPLE_TEXTURE3D_LOD(textureName, samplerName, uv,mipLevel);

#endif // TEXTURE_LIB_INCLUDE