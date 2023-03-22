#ifndef FRONTFACE_LIB_INCLUDE
#define FRONTFACE_INCLUDE

#include "../../Library/Common/CommonInput.hlsl"

//顶点输出结构初始化 
//需要手动开启 #define VARYINGS_NEED_CULLFACE
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
	#define INPUT_FRONT_FACE_GET \
		FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#else
	#define INPUT_FRONT_FACE_GET
#endif

//正反面获取 0:反面 1:正面
 #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
	#define FRAGMENT_FRONT_FACE_GET(input) \
		float FaceSign = IS_FRONT_VFACE(input.cullFace, true, false); \
		FaceSign = max(0, FaceSign);
 #else
	#define FRAGMENT_FRONT_FACE_GET(input) \
		float FaceSign=0;
 #endif

#endif // FRONTFACE_INCLUDE















