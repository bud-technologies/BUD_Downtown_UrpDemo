#ifndef INSTANCE_LIB_INCLUDE
#define INSTANCE_LIB_INCLUDE
//需要配置 #pragma multi_compile_instancing 


#include "../../Library/Common/CommonInput.hlsl"

//vert input
#define INPUT_INSTANCE \
	UNITY_VERTEX_INPUT_INSTANCE_ID

//vert output
#if UNITY_ANY_INSTANCING_ENABLED
	#define INPUT_INSTANCE_GET_ID \
		 uint instanceID : CUSTOM_INSTANCE_ID;
#else
	#define INPUT_INSTANCE_GET_ID
#endif

//vert output
#define OUTPUT_INSTANCE \
	UNITY_VERTEX_INPUT_INSTANCE_ID \
	UNITY_VERTEX_OUTPUT_STEREO

//vert fun
#define VERT_INSTANCE(input,output) \
	UNITY_SETUP_INSTANCE_ID(input); \
	UNITY_TRANSFER_INSTANCE_ID(input, output); \
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
	//#if defined(UNITY_INSTANCING_ENABLED) //可能会有被打断的BUG时候开启这里试一下
        //output.vertexSH.xyz = SampleSHVertex(output.normalWS.xyz);
    //#endif

//frag
#define FRAGMENT_INSTANCE(input) \
	UNITY_SETUP_INSTANCE_ID(input); \
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

//数据缓冲 如:
//UNITY_INSTANCING_BUFFER_START(Props)
//    UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
//UNITY_INSTANCING_BUFFER_END(Props)
#define L_INSTANCE_BUFFER_START UNITY_INSTANCING_BUFFER_START(Props)

#define L_INSTANCE_BUFFER_END UNITY_INSTANCING_BUFFER_END(Props)

#define L_INSTANCE_BUFFER_DATA(dataType,dataName) UNITY_DEFINE_INSTANCED_PROP(dataType, dataName)

//数据读取
#define L_INSTANCE_BUFFER_DATA_GET(dataName) UNITY_ACCESS_INSTANCED_PROP(Props, dataName)

#endif // INSTANCE_LIB_INCLUDE















