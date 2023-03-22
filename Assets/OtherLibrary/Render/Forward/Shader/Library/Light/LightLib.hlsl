#ifndef LIGHT_LIB_INCLUDE
#define LIGHT_LIB_INCLUDE

void GetMainLight(float3 lightPositionWS, out half3 lightDirWS, out half3 lightColor, out half lightDistanceAtten, out half lightShadowAtten)
{
    half4 shadowCoord = TransformWorldToShadowCoord(lightPositionWS);
    Light mainLight = GetMainLight(shadowCoord);
    lightDirWS = mainLight.direction;
    lightColor = mainLight.color;
    lightDistanceAtten = mainLight.distanceAttenuation;
    lightShadowAtten = mainLight.shadowAttenuation;
}

void GetMainLight(out half3 lightDirWS, out half3 lightColor, out half lightDistanceAtten, out half lightShadowAtten)
{
    Light mainLight = GetMainLight();
    lightDirWS = mainLight.direction;
    lightColor = mainLight.color;
    lightDistanceAtten = mainLight.distanceAttenuation;
    lightShadowAtten = mainLight.shadowAttenuation;
}

void GetMainLightSC(half4 shadowCoord , out half3 lightDirWS, out half3 lightColor, out half lightDistanceAtten, out half lightShadowAtten)
{
    Light mainLight = GetMainLight(shadowCoord);
    lightDirWS = mainLight.direction;
    lightColor = mainLight.color;
    lightDistanceAtten = mainLight.distanceAttenuation;
    lightShadowAtten = mainLight.shadowAttenuation;
}

half3 GetAddLightsLambertColor(float3 positionWS,half3 normalWS,half3 color)
{
    half3 addColor;
    int addLightCount=GetAdditionalLightsCount(); 
    for(int k; k<addLightCount;k++)
    {
        Light addLight=GetAdditionalLight(k,positionWS);
        half3 addLDirWs=normalize(addLight.direction);
        addColor+=(dot(normalWS,addLDirWs)*0.5+0.5)*addLight.color*color * addLight.distanceAttenuation*addLight.shadowAttenuation;      
    }
    return addColor;
}

void SampleSH(half3 normalWS, out half3 ambient)
{
    // LPPV is not supported in Ligthweight Pipeline
    real4 SHCoefficients[7];
    SHCoefficients[0] = unity_SHAr;
    SHCoefficients[1] = unity_SHAg;
    SHCoefficients[2] = unity_SHAb;
    SHCoefficients[3] = unity_SHBr;
    SHCoefficients[4] = unity_SHBg;
    SHCoefficients[5] = unity_SHBb;
    SHCoefficients[6] = unity_SHC;
    ambient = max(half3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
}

#endif // LIGHT_LIB_INCLUDE















