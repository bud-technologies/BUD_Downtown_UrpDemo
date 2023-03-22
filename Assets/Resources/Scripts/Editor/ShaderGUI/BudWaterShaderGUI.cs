using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class BudWaterShaderGUI : CommonShaderGUI
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
                    DrawCullModeProp(material);
                    DrawReceiveShadows(material);
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            //
            EditorGUILayout.BeginVertical("box");

            if (FindMaterialProperty("_CameraDepthTextureOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_CameraDepthTextureOn"), "深度采样");
                if (FindMaterialProperty("_CameraDepthTextureOn").floatValue>=0.5f)
                {
                    if (FindMaterialProperty("_DistortionScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_DistortionScale"), "扭曲");
                    }
                }
            }
            if (FindMaterialProperty("_OpaqueTextureOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_OpaqueTextureOn"), "颜色采样");
            }
            if (FindMaterialProperty("_HighlightsColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_HighlightsColor"), "浅水区");
            }
            if (FindMaterialProperty("_ShadeColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ShadeColor"), "深水区");
            }
            if (FindMaterialProperty("_PerspectiveIntensity") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_PerspectiveIntensity"), "透视强度");
            }
            if (FindMaterialProperty("_MaxDepthSet") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_MaxDepthSet"), "可见深度");
            }
            if (FindMaterialProperty("_WaveSpeed") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaveSpeed"), "Wave速度");
            }
            if (FindMaterialProperty("_WaveNoiseScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaveNoiseScale"), "噪音");
            }
            if (FindMaterialProperty("_UVSpeed") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_UVSpeed"), "UVSpeed");
            }
            if (FindMaterialProperty("_UVTilling") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_UVTilling"), "Tilling");
            }
            if (FindMaterialProperty("_BlendDistance") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_BlendDistance"), "BlendDistance");
            }

            //light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
            if (FindMaterialProperty("_LightSamplingMap") != null)
            {
                if (FindMaterialProperty("_LightSamplingMap").textureValue==null)
                {
                    FindMaterialProperty("_LightSamplingMap").textureValue = AssetDatabase.LoadAssetAtPath<Texture>(AssetDatabase.GUIDToAssetPath("7a1e0c02807ae954ab24ba80cc59b666"));
                }
                //materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Spec贴图"), FindMaterialProperty("_LightSamplingMap"));
            }
            if (FindMaterialProperty("_SpecularPow") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularPow"), "反光形状");
            }
            if (FindMaterialProperty("_SpecularScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularScale"), "反光缩放");
            }
            if (FindMaterialProperty("_LightScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_LightScale"), "亮度缩放");
            }
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Fresnel
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fresnel", EditorStyles.boldLabel);
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
            if (FindMaterialProperty("_FresnelBias") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelBias"), "偏移");
            }
            if (FindMaterialProperty("_FresnelScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelScale"), "缩放");
            }
            if (FindMaterialProperty("_FresnelPower") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelPower"), "强度");
            }
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Scattering
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Scattering", EditorStyles.boldLabel);
            if (FindMaterialProperty("_ScatteringOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringOn"), "散射");
                if (FindMaterialProperty("_ScatteringOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_ScatteringLightScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightScale"), "灯光缩放");
                    }
                    if (FindMaterialProperty("_ScatteringLightPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightPow"), "灯光形状");
                    }
                    if (FindMaterialProperty("_ScatteringScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringScale"), "缩放");
                    }
                    if (FindMaterialProperty("_ScatteringPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringPow"), "形状");
                    }
                    if (FindMaterialProperty("_ScatteringColor") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringColor"), "颜色");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //wave
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Wave", EditorStyles.boldLabel);
            if (FindMaterialProperty("_WATER_WAVE_HEIGHT") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WATER_WAVE_HEIGHT"), "Wave");
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                if (FindMaterialProperty("_WaveHeightMap") != null)
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Wave贴图"), FindMaterialProperty("_WaveHeightMap"));
                }
                if (FindMaterialProperty("_WaveHeightMapScale") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightMapScale"), "缩放");
                }
                if (FindMaterialProperty("_WaveHeightNormalScale") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightNormalScale"), "法线缩放");
                }
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //foam
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Foam", EditorStyles.boldLabel);
            if (FindMaterialProperty("_WaterFoamOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaterFoamOn"), "泡沫");
                if (FindMaterialProperty("_WaterFoamOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_FoamMap") != null)
                    {
                        materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("泡沫贴图"), FindMaterialProperty("_FoamMap"));
                    }
                    if (FindMaterialProperty("_FoamStep") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_FoamStep"), "区间");
                    }
                    if (FindMaterialProperty("_FoamAdd") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_FoamAdd"), "偏移");
                    }
                    if (FindMaterialProperty("_WaveHeightMapFoamScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightMapFoamScale"), "Wave偏移");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //Reflect
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Reflect", EditorStyles.boldLabel);
            bool reflectScreenOn = false;
            if (FindMaterialProperty("_ReflectScreenOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScreenOn"), "镜面");
                if (FindMaterialProperty("_ReflectScreenOn").floatValue>=0.5f)
                {
                    reflectScreenOn = true;
                }
            }

            if (!reflectScreenOn)
            {
                if (FindMaterialProperty("_REFLECT_CUBE") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_REFLECT_CUBE"), "反射");
                    if (System.Math.Abs(FindMaterialProperty("_REFLECT_CUBE").floatValue - 1f) <= 0.1f)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
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
                    }else if (System.Math.Abs(FindMaterialProperty("_REFLECT_CUBE").floatValue - 2f) <= 0.1f)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        if (FindMaterialProperty("_ReflectMap") != null)
                        {
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("CubeMap"), FindMaterialProperty("_ReflectMap"));
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
            }
            else
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
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
            if (FindMaterialProperty("_ReflectReplace") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectReplace"), "反射替换");
            }
            if (FindMaterialProperty("_ReflectReplaceScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectReplaceScale"), "反射替换缩放");
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

