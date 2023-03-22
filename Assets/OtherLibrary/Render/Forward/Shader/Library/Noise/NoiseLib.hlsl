#ifndef NOISE_LIB_INCLUDE
#define NOISE_LIB_INCLUDE

float noise_sin_cos(float3 v)
{
	float par = v.x + v.y * 0.3 + v.z;
	float sinValue = sin(par);
	float cosValue = cos(par * 2);
	float res = (sinValue + cosValue) * 0.5;
	return res;
}

#endif // NOISE_LIB_INCLUDE















