using System;
using UnityEngine;
using UnityEditor;

namespace NewRenderShaderGUI
{
    public class ParticleShaderGUI : CommonShaderGUI
    {
        public override void ShaderPropertiesGUI(Material material)
        {
            base.ShaderPropertiesGUI(material);
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] materialProperties)
        {
            base.OnGUI(materialEditor, materialProperties);
            Material material = m_MaterialEditor.target as Material;

            DrawSkinGUI(materialEditor, material);

            base.SetupMaterialKeywords(material);
        }

        void DrawSkinGUI(MaterialEditor materialEditor, Material material)
        {

            EditorGUILayout.LabelField(m_surfaceOptionsText, EditorStyles.boldLabel);
            DrawBlendProp(material);
            DrawCullModeProp(material);

            //
            base.DrawProperty(FindMaterialProperty("_SrcBlend"), "SrcBlend", "混合层 1 ，one one 是ADD");
            base.DrawProperty(FindMaterialProperty("_DestBlend"), "DestBlend");
            base.DrawProperty(FindMaterialProperty("_CullMode"), "CullMode");
            base.DrawProperty(FindMaterialProperty("_ZAlways"), "ZAlways");

            //

            //主帖图相关放这里
            SetTextureClamp(material, "_BaseMapClamp", "_BaseMapRepeatU", "_BaseMapRepeatV", "开启Repeat(_BaseMapClamp)");

            if (FindMaterialProperty("_ACESToneMapOn") != null)
            {
                base.DrawProperty(FindMaterialProperty("_ACESToneMapOn"), "ACESTonemap");
            }
            if (FindMaterialProperty("_BaseMap") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));
                base.DrawVector2FromVector4(FindMaterialProperty("_BaseMapUVSpeed"), "UV动画速度");
                if (FindMaterialProperty("_BaseMapColorOn") != null)
                {
                    base.DrawProperty(FindMaterialProperty("_BaseMapColorOn"), "使用BaseMap颜色");
                }
                if (FindMaterialProperty("_BaseMapUVSpeedParticalLerp") != null)
                {
                    base.DrawProperty(FindMaterialProperty("_BaseMapUVSpeedParticalLerp"), "粒子权重 UV0.zw");
                }
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }


            if (FindMaterialProperty("_FogMask") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("FogMask"), FindMaterialProperty("_FogMask"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FogMask"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("FogTex"), FindMaterialProperty("_FogTex"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FogTex"));
                base.DrawProperty(FindMaterialProperty("_FogColor"), "FogColor");
                base.DrawProperty(FindMaterialProperty("_FLowSpeed"), "FLowSpeed");
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("FogTex2"), FindMaterialProperty("_FogTex2"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FogTex2"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("FogTex3"), FindMaterialProperty("_FogTex3"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FogTex3"));
                base.DrawProperty(FindMaterialProperty("_FogIntensity"), "FogIntensity");
                base.DrawProperty(FindMaterialProperty("_TimeOffset"), "TimeOffset");
            }
            if (FindMaterialProperty("_NearFogClip") != null)
            {
                base.DrawProperty(FindMaterialProperty("_NearFogClip"), "NearFogClip");
            }
            if (FindMaterialProperty("_CtN") != null)
            {
                base.DrawProperty(FindMaterialProperty("_CtN"), "CtN");
            }
            if (FindMaterialProperty("_FarFogClip") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FarFogClip"), "FarFogClip");
            }
            if (FindMaterialProperty("_CtF") != null)
            {
                base.DrawProperty(FindMaterialProperty("_CtF"), "CtF");
            }
            if (FindMaterialProperty("_Height") != null)
            {
                base.DrawProperty(FindMaterialProperty("_Height"), "Height");
            }
            if (FindMaterialProperty("_Foffset") != null)
            {
                base.DrawProperty(FindMaterialProperty("_Foffset"), "Foffset");
            }

            if (FindMaterialProperty("_MixFogColor") != null)
            {
                base.DrawProperty(FindMaterialProperty("_MixFogColor"), "雾效颜色");
            }

            if (FindMaterialProperty("_MixSmoothStep") != null)
            {
                base.DrawProperty(FindMaterialProperty("_MixSmoothStep"), "混合区间");
            }

            if (FindMaterialProperty("MixReverse") != null)
            {
                base.DrawProperty(FindMaterialProperty("MixReverse"), "反相");
            }

            if (FindMaterialProperty("_Color_Channel") != null)
            {
                base.DrawProperty(FindMaterialProperty("_Color_Channel"), "混合通道");
            }

            if (FindMaterialProperty("_MixTexA") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("混合A"), FindMaterialProperty("_MixTexA"), FindMaterialProperty("_MixTexAColor"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_MixTexA"));
                base.DrawProperty(FindMaterialProperty("_MixTexARatio"), "比重");
                base.DrawVector2FromVector4(FindMaterialProperty("_MixTexAUVSpeed"),"UV动画速度");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

                if (FindMaterialProperty("_MixTexB") != null)
                {
                    if (FindMaterialProperty("_MixTexB").textureValue==null)
                    {
                        material.SetKeyword("MIXTEXB_ON",false);
                    }
                    else
                    {
                        material.SetKeyword("MIXTEXB_ON", true);
                    }
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("混合A"), FindMaterialProperty("_MixTexB"), FindMaterialProperty("_MixTexBColor"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_MixTexB"));
                    base.DrawProperty(FindMaterialProperty("_MixTexBRatio"), "比重");
                    base.DrawVector2FromVector4(FindMaterialProperty("_MixTexBUVSpeed"), "UV动画速度");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            if (FindMaterialProperty("_SmoothStepMax") !=null)
            {
                base.DrawProperty(FindMaterialProperty("_SmoothStepMax"), "区间上限");
            }

            if (FindMaterialProperty("_LerpColorA") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LerpColorA"), "渐变色 A");
            }

            if (FindMaterialProperty("_LerpColorB") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LerpColorB"), "渐变色 B");
            }

            base.DrawProperty(FindMaterialProperty("_ToggleCustom"), "ToggleCustom");
            MaterialProperty baseMapRotateToggle = FindMaterialProperty("_BaseMapRotateToggle");
            base.DrawProperty(baseMapRotateToggle, "启用主帖图旋转");
            if (baseMapRotateToggle != null && baseMapRotateToggle.floatValue == 1)
            {
                base.DrawProperty(FindMaterialProperty("_BaseMapRotAngle"), "主帖图旋转角度");
            }
            base.DrawVector2FromVector4(FindMaterialProperty("_BaseMapScale"), "主帖图缩放比例");
            base.DrawProperty(FindMaterialProperty("_AlphaControl"), "控制半透明度");
            //深度贴图相关
            base.DrawPropertyTexture(FindMaterialProperty("_DepthMap"), "深度贴图", "", false);
            base.DrawVector2FromVector4(FindMaterialProperty("_DepthMapSample"), "深度贴图采样(8)的倍数即可");
            base.DrawProperty(FindMaterialProperty("_DepthBias"), "深度控制");
            base.DrawPropertyTexture(FindMaterialProperty("_BumpMap"), "法线贴图", "", false);
            

            //环境贴图相关在这里
            base.DrawPropertyTexture(FindMaterialProperty("_CubeMap"), "环境贴图纹理", "", false);
            base.DrawProperty(FindMaterialProperty("_FresnelColor"), "菲涅尔颜色");
            base.DrawProperty(FindMaterialProperty("_RefractRatio"), "折射系数");
            base.DrawProperty(FindMaterialProperty("_FresnelAmount"), "菲涅尔系数");

            //FlowMap相关在这里
            base.DrawPropertyTexture(FindMaterialProperty("_FlowMap"), "FlowMap贴图", "", false);
            base.DrawProperty(FindMaterialProperty("_Sunction"), "吸力");

            //深度边缘
            base.DrawProperty(FindMaterialProperty("_CameraDepthTextureOn"), "深度采样");
            if (FindMaterialProperty("_CameraDepthTextureOn")!=null && FindMaterialProperty("_CameraDepthTextureOn").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_DepthFadeSoftStrength"), "深度消隐");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //Mask相关放这里
            base.DrawProperty(FindMaterialProperty("_MaskEnable"), "遮罩WrapMode");
            MaterialProperty maskEnable = FindMaterialProperty("_MaskEnable");

            if (maskEnable != null && maskEnable.floatValue != 0)
            {
                if (FindMaterialProperty("_MaskTex") != null)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("遮罩贴图"), FindMaterialProperty("_MaskTex"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_MaskTex"));
                    base.DrawVector2FromVector4(FindMaterialProperty("_MaskTexUVSpeed"), "UV动画速度");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 2;

                    //SetTextureClamp(material, "_MaskTexClamp", "_MaskTexRepeatU", "_MaskTexRepeatV", "开启Repeat(_MaskTexClamp)");
                    //base.DrawProperty(FindMaterialProperty("_MaskTex"), "MaskTex");
                    //base.DrawDoubleVector2FromVector4(FindMaterialProperty("_MaskTex_TilingOffset"), "Tiling", "Offset");
                    //base.DrawVector2FromVector4(FindMaterialProperty("_MaskTexScale"), "遮罩贴图大小");
                    //base.DrawVector2FromVector4(FindMaterialProperty("_uvMaskSpeed"), "遮罩贴图UV流速");

                    MaterialProperty maskTexRotateToggle = FindMaterialProperty("_MaskTexRotateToggle");
                    base.DrawProperty(maskTexRotateToggle, "开启旋转缩放(遮罩)");
                    if (maskTexRotateToggle != null && maskTexRotateToggle.floatValue == 1)
                    {
                        base.DrawProperty(FindMaterialProperty("_MaskTexAngle"), "遮罩贴图旋转角度");
                    }
                }
            }

            //溶解
            base.DrawProperty(FindMaterialProperty("_DissolveOn"), "溶解开启");
            if (FindMaterialProperty("_DissolveOn")!=null && FindMaterialProperty("_DissolveOn").floatValue>=0.5f)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("溶解贴图"), FindMaterialProperty("_DissolveTex"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_DissolveTex"));
                base.DrawProperty(FindMaterialProperty("_DissolveOffset"), "偏移量");
                base.DrawVector2FromVector4(FindMaterialProperty("_DissolveSmoothStep"), "范围");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            base.DrawProperty(FindMaterialProperty("_Light"), "Light");
            base.DrawProperty(FindMaterialProperty("_EdgeSoft"), "EdgeSoft");
            base.DrawProperty(FindMaterialProperty("_SoftHeight"), "SoftHeight");
            base.DrawPropertyTexture(FindMaterialProperty("_NoiseTex"), "NoiseTex", "", false);
            SetTextureClamp(material, "_NoiseTexClamp", "_NoiseTexRepeatU", "_NoiseTexRepeatV", "开启Repeat(_NoiseTexClamp)");

            base.DrawDoubleVector2FromVector4(FindMaterialProperty("_NoiseTex_TilingOffset"), "Tiling", "Offset");

            base.DrawProperty(FindMaterialProperty("_NoiseStrength"), "NoiseStrengh(噪音强度)");

            //distort扭曲效果相关放这里
            //base.DrawProperty(FindMaterialProperty("_DistortEnable"), "开启扭曲贴图");
            MaterialProperty distortEnable = FindMaterialProperty("_DistortEnable");
            MaterialProperty polarEnable = FindMaterialProperty("_PolarEnable");
            base.DrawProperty(distortEnable, "开启扭曲贴图");

            if (distortEnable != null && distortEnable.floatValue != 0)
            {
                SetTextureClamp(material, "_DistortMapClamp", "_DistortMapRepeatU", "_DistortMapRepeatV", "开启Repeat(_DistortMapClamp)");

                base.DrawProperty(FindMaterialProperty("_DistortMap"), "扭曲贴图");
                base.DrawPropertyTexture(FindMaterialProperty("_DistortMapMask"), "扭曲贴图Mask", "", false);
                
                base.DrawDoubleVector2FromVector4(FindMaterialProperty("_DistortMap_TilingOffset"), "Tiling", "Offset");

                base.DrawProperty(FindMaterialProperty("_Distort"), "扭曲强度");

                base.DrawProperty(FindMaterialProperty("_DistortMapAngle"), "扭曲贴图旋转角度");

                MaterialProperty distortPolarEnable = FindMaterialProperty("_PolarEnableDistort");
                base.DrawProperty(distortPolarEnable, "开启扭曲极坐标");

                base.DrawVector2FromVector4(FindMaterialProperty("_uvDistortSpeed"), "扭曲贴图UV流速");

            }

            //溶解相关放这里

            //base.DrawProperty(FindMaterialProperty("_DissolveEnable"), "开启溶解");
            MaterialProperty dissolveEnable = FindMaterialProperty("_DissolveEnable");
            base.DrawProperty(dissolveEnable, "开启溶解");
            if (dissolveEnable != null && dissolveEnable.floatValue != 0)
            {
                SetTextureClamp(material, "_DissolveMapClamp", "_DissolveMapRepeatU", "_DissolveMapRepeatV", "开启Repeat(_DissolveMapClamp)");
                base.DrawProperty(FindMaterialProperty("_DissolveMap"), "溶解贴图");
                base.DrawDoubleVector2FromVector4(FindMaterialProperty("_DissolveMap_TilingOffset"), "Tiling", "Offset");
                base.DrawProperty(FindMaterialProperty("_DissolveMap_BlendFilter"), "DissolveMap 通道过滤");
                base.DrawProperty(FindMaterialProperty("_DissolveColor1"), "DissolveColor1");
                base.DrawProperty(FindMaterialProperty("_DissolveColor2"), "DissolveColor2");
                base.DrawProperty(FindMaterialProperty("_DissolveStrength"), "溶解强度");
                base.DrawProperty(FindMaterialProperty("_DissolveEdgeWidth"), "溶解边宽");
                base.DrawProperty(FindMaterialProperty("_EdgeEmission"), "边界自发光颜色");
                base.DrawProperty(FindMaterialProperty("_FlowSpeed"), "UV流速");

                MaterialProperty polarEnableDissolve = FindMaterialProperty("_PolarEnableDissolve");
                base.DrawProperty(polarEnableDissolve, "开启溶解极坐标");
                
                base.DrawVector2FromVector4(FindMaterialProperty("_uvDissSpeed"), "溶解贴图uv流速");
                base.DrawProperty(FindMaterialProperty("_DissolveRange"), "DissolveRange");
            }

            base.DrawProperty(FindMaterialProperty("_HeatTime"), "HeatTime");
            base.DrawVector2FromVector4(FindMaterialProperty("_HeatStrength"), "扭曲强度");


            base.DrawProperty(FindMaterialProperty("_EdgeColor"), "EdgeColor");
            base.DrawProperty(FindMaterialProperty("_EdgePower"), "EdgePower");
            base.DrawProperty(FindMaterialProperty("_EdgeScale"), "EdgeScale");
            base.DrawProperty(FindMaterialProperty("_Brightness"), "Brightness");

            MaterialProperty tintColorON = FindMaterialProperty("_TintColorOn");

            if (tintColorON != null)
            {
                base.DrawProperty(FindMaterialProperty("_TintColorOn"), "TintColorOn");
                if (tintColorON.floatValue == 1)
                {
                    base.DrawProperty(FindMaterialProperty("_TintColor"), "TintColor");
                }
            }
            else
            {
                base.DrawProperty(FindMaterialProperty("_TintColor"), "TintColor");
            }

            base.DrawProperty(FindMaterialProperty("_Intensity"), "整体强度");

            base.DrawPropertyTexture(FindMaterialProperty("_MaskMap"), "MaskMap", "", false);


            base.DrawProperty(FindMaterialProperty("_AlphaTex"), "AlphaTex");
            base.DrawProperty(FindMaterialProperty("_CutOff"), "CutOff");
            base.DrawProperty(FindMaterialProperty("_FadeFactor"), "FadeFactor");
            base.DrawProperty(FindMaterialProperty("_ZTestMode"), "ZTestMode");
            base.DrawProperty(FindMaterialProperty("_ClipRange"), "ClipRange");
            base.DrawProperty(FindMaterialProperty("_IndicatorAttenuation"), "IndicatorAttenuation(遮挡半透衰减)");

            DrawQueueOnGUI(materialEditor);
        }

        void SetTextureClamp(Material targetMat, string proName, string proNameU, string proNameV, string showName)
        {
            if (FindMaterialProperty(proName) == null) return;
            int state = 0;//0:Clamp 1:RepeatUV 2:RepeatU 3:RepeatV
            float clamp = targetMat.GetFloat(proName);
            if (clamp == 0)
            {
                state = 0;
            }
            else
            {
                float clampU = targetMat.GetFloat(proNameU);
                float clampV = targetMat.GetFloat(proNameV);
                if (clampU == 0)
                {
                    if (clampV == 0)
                    {
                        state = 1;
                    }
                    else
                    {
                        state = 3;
                    }
                }
                else
                {
                    if (clampV == 0)
                    {
                        state = 2;
                    }
                    else
                    {
                        state = 1;
                    }
                }
            }
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(showName);

            if (GUILayout.Button("Clamp", GetGUIStyle("Clamp", state)))
            {
                targetMat.SetFloat(proName, 0);
                targetMat.SetFloat(proNameU, 0);
                targetMat.SetFloat(proNameV, 0);
            }

            if (GUILayout.Button("RepeatUV", GetGUIStyle("RepeatUV", state)))
            {
                targetMat.SetFloat(proName, 1);
                targetMat.SetFloat(proNameU, 1);
                targetMat.SetFloat(proNameV, 1);
            }

            if (GUILayout.Button("RepeatU", GetGUIStyle("RepeatU", state)))
            {
                targetMat.SetFloat(proName, 1);
                targetMat.SetFloat(proNameU, 1);
                targetMat.SetFloat(proNameV, 0);
            }

            if (GUILayout.Button("RepeatV", GetGUIStyle("RepeatV", state)))
            {
                targetMat.SetFloat(proName, 1);
                targetMat.SetFloat(proNameU, 0);
                targetMat.SetFloat(proNameV, 1);
            }

            EditorGUILayout.EndHorizontal();
        }

        GUIStyle GetGUIStyle(string showName, int state)
        {
            GUIStyle fontStyle = new GUIStyle();
            fontStyle.alignment = TextAnchor.LowerLeft;
            switch (showName)
            {
                case "Clamp":
                    {
                        if (state == 0)
                        {
                            fontStyle.normal.textColor = Color.red;
                        }
                        else
                        {
                            fontStyle.normal.textColor = Color.white;
                        }
                    }
                    break;
                case "RepeatUV":
                    {
                        if (state == 1)
                        {
                            fontStyle.normal.textColor = Color.red;
                        }
                        else
                        {
                            fontStyle.normal.textColor = Color.white;
                        }
                    }
                    break;
                case "RepeatU":
                    {
                        if (state == 2)
                        {
                            fontStyle.normal.textColor = Color.red;
                        }
                        else
                        {
                            fontStyle.normal.textColor = Color.white;
                        }
                    }
                    break;
                case "RepeatV":
                    {
                        if (state == 3)
                        {
                            fontStyle.normal.textColor = Color.red;
                        }
                        else
                        {
                            fontStyle.normal.textColor = Color.white;
                        }
                    }
                    break;
            }
            fontStyle.hover.textColor = Color.yellow;
            return fontStyle;
        }

    }
}


