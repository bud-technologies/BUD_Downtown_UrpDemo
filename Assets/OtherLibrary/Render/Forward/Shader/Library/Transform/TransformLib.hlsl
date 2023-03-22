#ifndef TRANSFORM_LIB_INCLUDE
#define TRANSFORM_LIB_INCLUDE

//#include "CommonInput.hlsl"

//获得点投影到水平面的新世界位置
//_projDirWorld:投影世界方向
//_zeroWorldPosY:虚拟的水平0平面(脚底地面的世界坐标Y轴高度)
//_vertexWorldPosOld:顶点的原始世界坐标
//_shadowHeight:指定的阴影平面的高度 相对于(脚底地面)的偏移高度
//_xzPosOffset:XZ平面的偏移
float3 GetPlantPos(float3 _projDirWorld,float _zeroWorldPosY,float3 _vertexWorldPosOld,float _shadowHeight,float2 _xzPosOffset) {
	//此处计算阴影是按照 _zeroWorldPosY Y轴0 的位置计算 XZ 的偏移 阴影顶点会压平在_ShadowHeight的高度处 处于 _zeroWorldPosY Y轴0 的位置一下的点会被剔除
	//向量比例
	float dirScale = (_projDirWorld.y - _zeroWorldPosY) / _projDirWorld.y;
	//高度比例
	float hightScale = (_vertexWorldPosOld.y - _zeroWorldPosY) / (_projDirWorld.y - _zeroWorldPosY);
	//_zeroWorldPosY平面的点坐标
	float3 vertexWorldPosZeroY = _vertexWorldPosOld - _projDirWorld * dirScale * hightScale;
	vertexWorldPosZeroY.y = vertexWorldPosZeroY.y + _shadowHeight;
	vertexWorldPosZeroY.x = vertexWorldPosZeroY.x + _xzPosOffset.x;
	vertexWorldPosZeroY.z = vertexWorldPosZeroY.z + _xzPosOffset.y;
	return vertexWorldPosZeroY;
}

//-----------------缩放
//获得物体的缩放
float3 GetObjectScale(){
    float3 objectScale = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)));
    return objectScale;
}

//-----------------位置，坐标

//获得世界坐标
float3 GetPositionWorld(float4 _vertex){
    return TransformObjectToWorld(_vertex.xyz);
}

//获得物体世界坐标
float3 GetObjectPositionWorld(){
    return TransformObjectToWorld(float3(0,0,0));
}

//-----------------视角
float3 GetViewDirWS(float positionWS){
    return normalize(GetCameraPositionWS() - positionWS);
}

//-----------------旋转
//按照轴向旋转指定角度
//input:输入方向
//axis:轴向
//rotation:旋转角度
//output:旋转后的结果
void Rotate_Axis(float3 input, float3 axis, float rotation, out float3 output)
{
    rotation = radians(rotation);
    float s = sin(rotation);
    float c = cos(rotation);
    float one_minus_c = 1.0 - c;
    axis = normalize(axis);
    float3x3 rot_mat = { 
                            one_minus_c * axis.x * axis.x + c,  one_minus_c * axis.x * axis.y - axis.z * s, one_minus_c * axis.z * axis.x + axis.y * s,
                            one_minus_c * axis.x * axis.y + axis.z * s, one_minus_c * axis.y * axis.y + c,  one_minus_c * axis.y * axis.z - axis.x * s,
                            one_minus_c * axis.z * axis.x - axis.y * s, one_minus_c * axis.y * axis.z + axis.x * s,   one_minus_c * axis.z * axis.z + c
                        };
    output = mul(rot_mat,  input);
    //output = all(isfinite(output)) ? half4(output.x, output.y, output.z, 1.0) : float4(1.0f, 0.0f, 1.0f, 1.0f);
}

//-------------------------切线空间

//世界空间到切线空间的逆矩阵（切线空间转世界空间）结构体
#define TANGENT_MATRIX_STRUCT(index0,index1,index2) \
    half4 TangentToWorld0:TEXCOORD##index0; \
    half4 TangentToWorld1:TEXCOORD##index1; \
    half4 TangentToWorld2:TEXCOORD##index2;

//世界空间到切线空间的逆矩阵（切线空间转世界空间）顶点着色器计算矩阵
//要求: o为顶点着色输出数据 ， v为输入数据
//v中需要包含 float4 vertex : POSITION;  half3 normal:NORMAL;    half4 tangent : TANGENT;
//o中需要使用宏 TANGENT_MATRIX_STRUCT(index0,index1,index2)
//w:存放世界坐标
#define TANGENT_MATRIX_VERTEX(o,v) \
    float4 worldPos=mul(unity_ObjectToWorld,v.vertex); \
    half3 worldTangent=normalize(TransformObjectToWorldDir(v.tangent.xyz)); \
    half3 worldNormal=normalize(TransformObjectToWorldNormal(v.normal.xyz)); \
    half3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w*unity_WorldTransformParams.w; \
    o.TangentToWorld0 = half4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x); \
    o.TangentToWorld1 = half4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y); \
    o.TangentToWorld2 = half4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

#endif // COMMON_TRANSFORM_INCLUDE