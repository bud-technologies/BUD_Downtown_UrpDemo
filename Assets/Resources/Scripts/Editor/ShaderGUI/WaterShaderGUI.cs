using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{

    public class WaterShaderGUI: CommonShaderGUI
    {
        public override void ShaderPropertiesGUI(Material material)
        {
            base.ShaderPropertiesGUI(material);
        }

        bool optionsFoldOut;

        protected readonly GUIContent OptionsText = new GUIContent("配置参数", "可配置参数设置");

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] materialProperties)
        {
            base.OnGUI(materialEditor, materialProperties);
            EditorGUI.BeginChangeCheck();

            Material material = m_MaterialEditor.target as Material;
            DrawSkinGUI(materialEditor, material);
            base.SetupMaterialKeywords(material);
            if (EditorGUI.EndChangeCheck())
            {
                foreach (Material mat in m_MaterialEditor.targets)
                {
                    MaterialChanged(mat);
                    // ChangeShadowType(mat);
                }
            }
        }

        void DrawSkinGUI(MaterialEditor materialEditor, Material material)
        {
            optionsFoldOut = EditorGUILayout.BeginFoldoutHeaderGroup(optionsFoldOut, OptionsText);
            if (optionsFoldOut)
            {
                EditorGUILayout.BeginVertical("box");
                {
                    SurfaceType surfaceType = DrawSurfaceTypeProp(material);
                    DrawCullModeProp(material);
                    DrawReceiveShadows(material);
                    DrawAlphaClipProp(material);
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            //
            EditorGUILayout.BeginVertical("box");

            // Base
            if (FindMaterialProperty("_BaseMap")!=null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_HighlightsColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_HighlightsColor"), "浅水区");
            }
            if (FindMaterialProperty("_ShadeColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ShadeColor"), "深水区");
            }
            if (FindMaterialProperty("_Dis") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_Dis"), "距离");
            }
            if (FindMaterialProperty("_Muddy") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_Muddy"), "浑浊");
            }

            //light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            if (FindMaterialProperty("_ScatteringOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringOn"), "散射");
                if (FindMaterialProperty("_ScatteringOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;

                    if (FindMaterialProperty("_ScatteringLightScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightScale"), "Light散射缩放");
                    }
                    if (FindMaterialProperty("_ScatteringLightPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightPow"), "Light散射Pow");
                    }

                    if (FindMaterialProperty("_ScatteringScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringScale"), "散射缩放");
                    }
                    if (FindMaterialProperty("_ScatteringPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringPow"), "散射Pow");
                    }
                    if (FindMaterialProperty("_ScatteringColor") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringColor"), "散射颜色");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }
            if (FindMaterialProperty("_SpecularPow") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularPow"), "Specular Pow");
            }
            if (FindMaterialProperty("_SpecularScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularScale"), "Specular Scale");
            }

            //wave
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Wave", EditorStyles.boldLabel);
            if (FindMaterialProperty("_WATER_WAVE_HEIGHT") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WATER_WAVE_HEIGHT"), "Wave");
                if (FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;

                    if (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue-1f) <=0.1f ||
                        (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue - 2f) <= 0.1f &&
                        FindMaterialProperty("_NORMAL").floatValue<=0.1f))
                    {
                        if (FindMaterialProperty("_WaveHeightMap") != null)
                        {
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Wave高度贴图"), FindMaterialProperty("_WaveHeightMap"));
                            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_WaveHeightMap"));
                            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                        }
                        if (FindMaterialProperty("_WaveHeightMapUVSpeed") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightMapUVSpeed"), "动画速度");
                        }
                        if (FindMaterialProperty("_WaveHeightMapOffset") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightMapOffset"), "上下偏移");
                        }
                        if (FindMaterialProperty("_WaveHeightMapScale") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightMapScale"), "缩放");
                        }
                    }
                    else if (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue - 2f) <= 0.1f)
                    {
                        if (FindMaterialProperty("_WaveHeightNormalSpeedScale") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightNormalSpeedScale"), "法线动画缩放");
                        }
                        if (System.Math.Abs(FindMaterialProperty("_NORMAL").floatValue - 2f) <= 0.1f)
                        {
                            if (FindMaterialProperty("_WaveHeightBlendNormalSpeedScale") != null)
                            {
                                base.DrawProperty(FindMaterialProperty("_WaveHeightBlendNormalSpeedScale"), "Blend法线动画缩放");
                            }
                        }
                        if (FindMaterialProperty("_WaveHeightNormalOffset") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightNormalOffset"), "上下偏移");
                        }
                        if (FindMaterialProperty("_WaveHeightNormalScale") != null)
                        {
                            base.DrawProperty(FindMaterialProperty("_WaveHeightNormalScale"), "缩放");
                        }
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //normal
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Normal", EditorStyles.boldLabel);
            if (FindMaterialProperty("_NORMAL") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_NORMAL"), "法线");
                if (FindMaterialProperty("_NormalStrenght") != null)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.ShaderProperty(FindMaterialProperty("_NormalStrenght"), "NormalStrenght");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
                if (FindMaterialProperty("_NORMAL").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_BumpMap") != null)
                    {
                        materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("法线贴图"), FindMaterialProperty("_BumpMap"));
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BumpMap"));
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                    }
                    if (FindMaterialProperty("_BumpScale") != null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale"), "法线缩放");
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                    }
                    if (FindMaterialProperty("_BumpMapUVSpeed") != null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        base.DrawVector2FromVector4(FindMaterialProperty("_BumpMapUVSpeed"), "动画速度");
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                    }
                    if (FindMaterialProperty("_NORMAL").floatValue >= 1.5f)
                    {
                        if (FindMaterialProperty("_BumpBlendMap") != null)
                        {
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("法线贴图B"), FindMaterialProperty("_BumpBlendMap"));
                            EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BumpBlendMap"));
                            EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                        }
                    }
                    if (FindMaterialProperty("_BumpBlendScale") != null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                        materialEditor.ShaderProperty(FindMaterialProperty("_BumpBlendScale"), "Blend 法线缩放");
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                    }
                    if (FindMaterialProperty("_BumpMapBlendUVSpeed") != null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                        base.DrawVector2FromVector4(FindMaterialProperty("_BumpMapBlendUVSpeed"), "Blend 动画速度");
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }
            else
            {
                if (FindMaterialProperty("_BumpMap") != null)
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("法线贴图"), FindMaterialProperty("_BumpMap"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BumpMap"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
                if (FindMaterialProperty("_BumpScale") != null)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale"), "法线缩放");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //fresnel
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fresnel", EditorStyles.boldLabel);
            if (FindMaterialProperty("_FresnelBias") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelBias"), "Fresnel Bias");
            }
            if (FindMaterialProperty("_FresnelScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelScale"), "Fresnel Scale");
            }
            if (FindMaterialProperty("_FresnelPower") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelPower"), "Fresnel Power");
            }

            //depth
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Depth", EditorStyles.boldLabel);
            if (FindMaterialProperty("_CameraDepthTextureOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_CameraDepthTextureOn"), "开启深度检测");
                if (FindMaterialProperty("_CameraDepthTextureOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_DepthFadeIndensity") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_DepthFadeIndensity"), "范围");
                    }
                    if (FindMaterialProperty("_PerspectiveIntensity") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_PerspectiveIntensity"), "透视强度");
                    }
                    if (FindMaterialProperty("_DepthFadePow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_DepthFadePow"), "形状");
                    }

                    if (FindMaterialProperty("_WaterFoamOn") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_WaterFoamOn"), "泡沫");
                        if (FindMaterialProperty("_WaterFoamOn").floatValue>=0.5f)
                        {
                            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                            if (FindMaterialProperty("_FoamMap") != null)
                            {
                                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("泡沫贴图"), FindMaterialProperty("_FoamMap"));
                                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FoamMap"));
                                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                            }
                            if (FindMaterialProperty("_FoamMapAdd") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamMapAdd"), "纹理加强");
                            }
                            if (FindMaterialProperty("_FoamSpeed") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamSpeed"), "动画速度");
                            }
                            if (FindMaterialProperty("_FoamFloatSpeed") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamFloatSpeed"), "漂浮速度");
                            }
                            if (FindMaterialProperty("_FoamAdd") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamAdd"), "泡沫增加");
                            }
                            if (FindMaterialProperty("_FoamStep") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamStep"), "范围");
                            }
                            if (FindMaterialProperty("_FoamIntensity") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamIntensity"), "强度");
                            }
                            if (FindMaterialProperty("_FoamWorldOffset") != null)
                            {
                                materialEditor.ShaderProperty(FindMaterialProperty("_FoamWorldOffset"), "偏移");
                            }
                            if (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue - 1f) <= 0.1f ||
                                (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue - 2f) <= 0.1f &&
                                FindMaterialProperty("_NORMAL").floatValue <= 0.1f))
                            {
                                if (FindMaterialProperty("_WaveHeightMapFoamScale") != null)
                                {
                                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightMapFoamScale"), "Wave高度泡沫强度");
                                }
                                if (FindMaterialProperty("_WaveHeightMapPow") != null)
                                {
                                    base.DrawProperty(FindMaterialProperty("_WaveHeightMapPow"), "形状");
                                }
                            }
                            else if (System.Math.Abs(FindMaterialProperty("_WATER_WAVE_HEIGHT").floatValue - 2f) <= 0.1f)
                            {
                                if (FindMaterialProperty("_WaveHeightNormalFoamScale") != null)
                                {
                                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightNormalFoamScale"), "Normal高度泡沫强度");
                                }
                                if (FindMaterialProperty("_WaveHeightNormalPow") != null)
                                {
                                    base.DrawProperty(FindMaterialProperty("_WaveHeightNormalPow"), "形状");
                                }
                            }
                            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                        }
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
                else
                {
                    EditorGUILayout.LabelField("顶点颜色的R通道作为深度使用", EditorStyles.boldLabel);
                }
            }
            if (FindMaterialProperty("_MaxDepthSet") != null)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_MaxDepthSet"), "最大深度设置");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }
            if (FindMaterialProperty("_MaxDepthSetPow") != null)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_MaxDepthSetPow"), "最大深度形状");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //reflect
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Reflect", EditorStyles.boldLabel);
            bool reflectScreenOn = false;
            if (FindMaterialProperty("_ReflectScreenOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScreenOn"), "相机镜面反射");
                if (FindMaterialProperty("_ReflectScreenOn").floatValue>=0.5f)
                {
                    reflectScreenOn = true;
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_ReflectMapMipLevel") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ReflectMapMipLevel"), "模糊");
                    }
                    if (FindMaterialProperty("_ReflectRatio") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ReflectRatio"), "比例");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }
            if (!reflectScreenOn && FindMaterialProperty("_REFLECT_CUBE") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_REFLECT_CUBE"), "反射");
                if (FindMaterialProperty("_REFLECT_CUBE").floatValue>=0.5)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (System.Math.Abs(FindMaterialProperty("_REFLECT_CUBE").floatValue - 1f) < 0.1f)
                    {
                    }
                    else if (System.Math.Abs(FindMaterialProperty("_REFLECT_CUBE").floatValue - 2f) < 0.1f)
                    {
                        if (FindMaterialProperty("_ReflectMap") != null)
                        {
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("CubeMap"), FindMaterialProperty("_ReflectMap"));
                        }
                    }
                    if (FindMaterialProperty("_ReflectMapMipLevel") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ReflectMapMipLevel"), "模糊");
                    }
                    if (FindMaterialProperty("_ReflectRatio") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ReflectRatio"), "比例");
                    }
                    if (FindMaterialProperty("_ReflectScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScale"), "缩放");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            EditorGUILayout.EndVertical();
        }

        public virtual void MaterialChanged(Material material)
        {
            if (material == null)
            {
                throw new ArgumentNullException("material");
            }
            SetupMaterialBlendMode(material);
        }

        private void SetupMaterialBlendMode(Material material)
        {
            if (material == null)
            {
                throw new ArgumentNullException("material");
            }

            bool alphaClip = false;
            if (material.HasProperty("_AlphaClip"))
                alphaClip = material.GetFloat("_AlphaClip") >= 0.5;

            if (material.HasProperty("_Surface"))
            {
                SurfaceType surfaceType = (SurfaceType)material.GetFloat("_Surface");
                if (surfaceType == SurfaceType.Opaque)
                {
                    if (alphaClip)
                    {
                        material.renderQueue = (int)RenderQueue.AlphaTest;
                        material.SetOverrideTag("RenderType", "TransparentCutout");
                    }
                    else
                    {
                        material.renderQueue = (int)RenderQueue.Geometry;
                        material.SetOverrideTag("RenderType", "Opaque");
                    }

                    material.renderQueue += material.HasProperty("_QueueOffset") ? (int)material.GetFloat("_QueueOffset") : 0;
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.SetShaderPassEnabled("SRPDefaultUnlit", false);
                    material.SetShaderPassEnabled("ShadowCaster", true);
                    material.SetShaderPassEnabled("DepthOnly", true);
                }
                else
                {
                    // General Transparent Material Settings
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_ZWrite", 0);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    material.renderQueue += material.HasProperty("_QueueOffset") ? (int)material.GetFloat("_QueueOffset") : 0;
                    material.SetShaderPassEnabled("ShadowCaster", false);
                    material.SetShaderPassEnabled("DepthOnly", false);
                    material.SetShaderPassEnabled("SRPDefaultUnlit", true);
                }
            }
        }
    }
}

