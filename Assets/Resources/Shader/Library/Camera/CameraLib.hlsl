#ifndef CAMERA_LIB_INCLUDE
#define CAMERA_LIB_INCLUDE

//屏幕UV坐标
float2 GetScreenUV(float4 positionCS){
     float2 screenUV = ComputeNormalizedDeviceCoordinates(positionCS.xyz / positionCS.w);
     return screenUV;
}

//---------------------视野

//获得视野方向（世界空间）
half3 GetViewDirWorld(float3 _worldPos){
    return normalize(_WorldSpaceCameraPos.xyz-_worldPos);
}

//-------------------菲涅尔

//计算菲涅尔
//_normalWorld:世界法线
//_viewDirWorld:视角
//_fresnelPow:菲尼尔强度 >1
half GetFresnel(half3 _normalWorld,half3 _viewDirWorld,half _fresnelPow){
    half d=1-saturate(dot(_normalWorld, _viewDirWorld));
    half res = pow(d, _fresnelPow);
    return res;
}

//------------------------抓屏，截屏

//在不透明通道渲染后截图，所以截不到半透明的物体
sampler2D _CameraOpaqueTexture;

//在半透明通道渲染后和PostProcessing后截图
sampler2D _CameraColorTexture;

//URP的渲染截屏采样 需要添加一个Overlay的Camera，CullingMask设置Nothing，并把这个Camera添加到主Camera的Stack里面
sampler2D _AfterPostProcessTexture;

//获得屏幕UV
//_hClipPos:HClip空间位置 由 TransformObjectToHClip(vertexPos) 函数获得
float4 GetScreenUV_B(float4 _hClipPos){
    float4 projPos = ComputeScreenPos (_hClipPos);
    projPos.xy = projPos.xy / projPos.w;
    return projPos;
}

//根据噪音图获得坐标的偏移 根据x,y和向量偏移 返回偏移量
//_noiseTexture:造淫图采样
//_uv:uv
//_intensity:偏移强度
//_noiseTexture:噪音图
half2 GetUVByNoiseTextureNorlmal(half4 _noiseTexture,float2 _uv,float _intensity){
    half2 offsetUVs =  _noiseTexture.a * _intensity*(half2(_noiseTexture.r, _noiseTexture.g));
    return offsetUVs;
}

//根据噪音图获得坐标的偏移 根据中心点(0.5，0.5)向外偏移 返回结果：xy:新的UV z:alpha值
//_noiseTexture:造淫图采样
//_uv:uv
//_intensity:偏移强度
//_noiseTexture:噪音图
half3 GetUVByNoiseTextureCenter(half4 _noiseTexture,float2 _uv,float _intensity){
    float2 newUV=float2(_uv-0.5)*2;
    half2 offsetUVs = - _noiseTexture.a * _intensity*(half2(_noiseTexture.r*newUV.x, _noiseTexture.g*newUV.y));
    return half3(offsetUVs,_noiseTexture.a);
}

//--------------------------深度图

//UniversalRenderPipelineAsset.asset 开启Depth Texture,base相机Depth Texture=Use Pipeline Settings

//获得深度 适用于半透明物体的深度
//半透明物体的深度==NDC空间[0,1]的Z值
//NDC空间 = ComputeScreenPos(屏幕像素坐标)/ComputeScreenPos.w
//_screenPos:屏幕像素位置,由ComputeScreenPos (hClipPos)获得
//返回结果：米
float GetDepth_Translucence(float4 _screenPos){
    return _screenPos.w;
}

////获得深度 适用于半不明物体的深度
////不透明物体的深度需要使用NDC坐标[0,1]采样 _CameraDepthTexture
////_screenPos:屏幕像素位置,由ComputeScreenPos (hClipPos)获得
//float GetDepth_Opacity(float4 _screenPos){
//    float4 ndc=_screenPos/_screenPos.w;
//    //深度值 [0,1] 结果为NDC空间的深度值
//    half depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, ndc.xy).r;
//    //转换为视角空间
//    return LinearEyeDepth(depth,_ZBufferParams);
//}

////半透明物体获得与非透明物体的边缘深度 值越大距离越远
////_screenPos:屏幕像素位置,由ComputeScreenPos (hClipPos)获得
////返回值是 0-1
//float GetTranslucenceEdgeDepth(float4 _screenPos){
//    float res=GetDepth_Opacity(_screenPos)-GetDepth_Translucence(_screenPos);
//    res=abs(res);
//    return res;
//}

#endif // CAMERA_LIB_INCLUDE