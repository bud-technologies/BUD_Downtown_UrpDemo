#ifndef COMMON_FUNCTION_INCLUDE
#define COMMON_FUNCTION_INCLUDE

#include "CommonInput.hlsl"

//VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
//VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);
//uint vertexID     : SV_VertexID;

//float c = col.r * 0.2989 + col.g*0.5870 + col.b*0.1140; 

struct DotData{
    half NdotV;//(法线) dot (视角方向) (世界空间)
    half NdotL;//(法线) dot (灯光方向) (世界空间)
    half VdotH;//菲涅尔 (视角方向) dot (灯光方向+视角方向)*0.5 (世界空间)
    half NdotH;//(法线) dot (灯光方向+视角方向)*0.5 (世界空间)
    half LdotH;////(灯光方向) dot (灯光方向+视角方向)*0.5 (世界空间)
};

//计算点积数据
DotData GetDot(half3 _normalWorld,float3 _viewDirWorld,half3 _lightDirWorld){
    DotData dotData;
    ZERO_INITIALIZE(DotData, dotData);
    half3 halfDirWorld = normalize(_viewDirWorld + _lightDirWorld);
    dotData.NdotV=max(saturate(dot(_normalWorld,_viewDirWorld)),0.000001);//不取0 避免除以0的计算错误
    dotData.NdotL=max(saturate(dot(_normalWorld,_lightDirWorld)),0.000001);
    dotData.VdotH=max(saturate(dot(halfDirWorld,_viewDirWorld)),0.000001);
    dotData.NdotH=max(saturate(dot(halfDirWorld,_normalWorld)),0.000001);
    dotData.LdotH=max(saturate(dot(halfDirWorld,_lightDirWorld)),0.000001);
    return dotData;
}

//-----------------Shader Graph Function 
float3 NormalStrength(float3 In, float Strength)
{
    return float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
}

float Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

//-----------------颜色
//根据纹理灰度改变纹理颜色
//_color:原纹理颜色
//_color_H:新颜色 亮部
//_color_M:新颜色 过度
//_color_L:新颜色 暗部
half4 ThreeColorRamp(half4 _color,half4 _color_H,half4 _color_M,half4 _color_L)
{
    float _ramp = dot(_color.rgb, float3(0.299, 0.587, 0.114));
    half _ramp_BG =saturate(_ramp*2);		
    half4 _color_BG =lerp(_color_L,_color_M,_ramp_BG);
    half _ramp_GW =saturate((_ramp-0.5)*2);
    half4 _color_GW =lerp(_color_M,_color_H,_ramp_GW);
    half4 _OutColor = lerp(_color_BG,_color_GW,_ramp);
    return _OutColor;
}

//-----------------半透

//构建抖动顺序矩阵
float4x4 thresholdMatrix =
{ 
    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
	13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
	4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
	16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
};

float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };

//抖动Alpha剔除
void DitherAlphaTest(half4 _color,float2 screenUV){
    //0~1坐标乘以画面像素总数
    float2 pos=screenUV*_ScreenParams.xy;
    //依据动态抖动计算透明度
	clip(_color.a - thresholdMatrix[fmod(pos.x, 4)] * _RowAccess[fmod(pos.y, 4)]);
}

//-----------------uv
//UV(网格原始UV)坐标系 转 极坐标，顶点阶段
//返回 角度+距离
float2 Polar(float2 meshUV)
{
    float2 uv = meshUV-0.5;
    float distance=length(uv);
    distance *=2;
    float angle=atan2(uv.x,uv.y);
    float angle01=angle/3.14159926/2+0.5;
    return float2(angle01,distance);
}

//计算纹理的极坐标
float2 PolarTexture(float2 meshUV,float4 texture_ST,float2 uvOffset)
{
    float2 polar = Polar(meshUV);
    polar=polar*texture_ST.xy+texture_ST.zw+uvOffset;
    return polar;
}

//-----------------平台

#if UNITY_UV_STARTS_AT_TOP
    #define IS_DIRECT3D int isDirect3D = 1;
#else
    #define IS_DIRECT3D int isDirect3D = 0;
#endif

//-----------------抗锯齿 反转
//顶点阶段 抗锯齿情况下 UV反转
#if UNITY_UV_STARTS_AT_TOP
    #define ANTI_UV_FLIP(textureMap,uv) \
        if(textureMap##_TexelSize.y < 0){ \
            uv##.y=1-uv##.y; \
        }
#else
    #define ANTI_UV_FLIP(textureMap,uv)
#endif

//-------------------图像处理

//灰色
#define COLOR_GRAY half3(0.5,0.5,0.5)

//染血特效
//_uv:_mainTex的UV
//_albedo:_mainTex的采样值
//_effectBloodPower:效果强度 0-1
half3 GetEffectBlood(float2 _uv,half3 _albedo,half _effectBloodPower){
    float power=_effectBloodPower;
    _effectBloodPower *= 1.41421356;
    float2  tmpUV =  _uv ;
    float  tmpLength = 0 ;
    if(tmpUV.x < 0.5)
    {
       tmpLength  =  length ( tmpUV - float2(-0.5 ,0.5)) ;
    }
    else
    {
       tmpLength  =  length (float2(1.5 ,0.5)- tmpUV  ) ;
    }
    tmpLength  *= _effectBloodPower;
    half3 color = lerp(_albedo,half3(1,0,0) , 1-clamp(tmpLength,0,1) ) ;
    color = lerp(color,_albedo,power);
    return color;
}

//抖动效果 (使用在顶点阶段)
//_frenquncy:频率 10000
//_arange:范围 0.0001
//_speed:速度 1000
//要求:
//v 中需要包含 vertex:POSITION
#define EFFECT_SHAKE(_frenquncy,_arange,_speed,v) \
    float timer = _Time.y*_speed; \
    float waver = _arange*sin(timer + v.vertex.x*_frenquncy); \
    v.vertex.y =  v.vertex.y + waver;

//获得热扭曲效果的 uv 修改结果
//用法，在纹理采样前使用获得新的 UV 坐标，代替原来的UV坐标进行采样
//_displaceTex:噪点图 噪点图的warp mode设置为repeat ，否则就是一闪而过的波动  热扭曲噪点图.png
//_magnitude:偏移强度 0-0.1 默认值:0.0018
//_strength:流动速度 0-1 默认值:0.5
//_uv:原来的uv坐标
float2 GetHotPlug(sampler2D _displaceTex,half _magnitude,half _strength,float2 _uv){
    //纹理采样,只要xy;i.uv - _Time.xy是为了流动感
    float2 disp = tex2D(_displaceTex, _uv - _Time.xy * _strength).xy;
    //disp的范围是0-1，这步操作让其变成-1 到 1 乘以 参数
    disp = ((disp * 2) - 1) * _magnitude;
    return _uv+disp;
}

//获得一个最亮颜色
half3 ColorBrightet(half3 _color) {
    _color.r = max(0.001, _color.r);
    _color.g = max(0.001, _color.g);
    _color.b = max(0.001, _color.b);
    half maxValue = max(_color.r, _color.g);
    maxValue = max(maxValue, _color.b);
    half maxScale = 1/maxValue;
    _color = _color * maxScale;
    return _color;
}

//------------------------常用方法

//获得取值范围0中的值在取值范围1中的结果 按照比例缩放
half GetRange(half _value,half _min0,half _max0,half _min1,half _max1){
    return _min1+((_value-_min0)*(_max1-_min1))/(_max0-_min0);
}

//获得取值范围0中的值在取值范围1中的结果 按照比例缩放
half3 GetRangeHalf3(half3 _value,half _min0,half _max0,half _min1,half _max1){
    half x=GetRange(_value.x,_min0,_max0,_min1,_max1);
    half y=GetRange(_value.y,_min0,_max0,_min1,_max1);
    half z=GetRange(_value.z,_min0,_max0,_min1,_max1);
    return half3(x,y,z);
}

//从光滑度计算粗糙度
//_smoothness:光滑度
//_roughnessPower:粗糙度强度
half GetRoughnessFromSmoothness(half _smoothness,half _roughnessPower){
    //中间粗糙度
    half tempRoughness=1-_smoothness;
    // 粗糙度
    return pow(tempRoughness,2)*_roughnessPower;
}

//从粗糙度计算光滑度
half GetSmoothnessFormRoughness(half _roughness,half _roughnessPower){
    return 1-sqrt(_roughness/_roughnessPower);
}

//广告牌，公告牌 面向摄像机 使用在顶点着色器阶段，用于转换顶点空间坐标
//_vertexPos:顶点坐标
float3 BilboardRotate(float3 _vertexPos) {
    //简化版
    float3 forwardDir = UNITY_MATRIX_MV[2].xyz;
    float3 upDir = UNITY_MATRIX_MV[1].xyz;
    float3 rightDir = UNITY_MATRIX_MV[0].xyz;
    //繁琐
    //float3 forwardDir =mul(UNITY_MATRIX_T_MV,FLOT4(0,0,1,1)).xyz;
    //float3 upDir = mul(UNITY_MATRIX_T_MV, FLOT4(0, 1, 0, 1)).xyz;
    //float3 rightDir = mul(UNITY_MATRIX_T_MV, FLOT4(1, 0, 0, 1)).xyz;

    float3 vertexLocalPos = rightDir * _vertexPos.x + upDir * _vertexPos.y + forwardDir * _vertexPos.x;
    return vertexLocalPos;
}

//------------------------水体

////获得水的深度
////_screenPos:屏幕像素位置,由ComputeScreenPos (hClipPos)获得
////_waterDepthStrength:深度 >0 默认5 越大越深，越深返回值越大(越白)
////返回值是 0-1
//float GetWaterDepth(float4 _screenPos,half _waterDepthStrength){
//    float sceneZ = GetDepth_Opacity(_screenPos);
//    float partZ = GetDepth_Translucence(_screenPos);
//    float diffZ =saturate(abs((sceneZ - partZ)/_waterDepthStrength));
//    return diffZ;
//}

////获得谁的颜色
////_screenPos:屏幕像素位置,由ComputeScreenPos (hClipPos)获得
////_waterDepthStrength:深度 >0 默认5 越大越深
////_deepColor:深水颜色
////_shoalColor:浅水颜色
//half4 GetWaterColor(float4 _screenPos,half _waterDepthStrength,half3 _deepColor,half3 _shoalColor){
//    float diffZ=GetWaterDepth(_screenPos,_waterDepthStrength);
//    half3 col=lerp((_deepColor+_deepColor*diffZ)*_shoalColor,_deepColor,diffZ);
//    half alpha = GetRange(diffZ,0,1,0.15,1);
//    return half4(col,alpha);
//}

#endif // COMMON_STRUCT_INCLUDE