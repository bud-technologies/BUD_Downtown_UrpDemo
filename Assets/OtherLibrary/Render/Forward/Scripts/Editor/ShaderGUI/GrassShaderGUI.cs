using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class GrassShaderGUI : CommonShaderGUI
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
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("BaseMap", EditorStyles.boldLabel);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Normal
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Normal", EditorStyles.boldLabel);
            if(FindMaterialProperty("_BumpMap") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("法线贴图"), FindMaterialProperty("_BumpMap"));
                if (FindMaterialProperty("_BumpMap").textureValue==null)
                {
                    material.SetKeyword("_NORMAL_ON", false);
                }
                else
                {
                    material.SetKeyword("_NORMAL_ON", true);
                }
            }

            //Emission
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Emission", EditorStyles.boldLabel);
            if (FindMaterialProperty("_EmissionOn") !=null)
            {
                base.DrawProperty(FindMaterialProperty("_EmissionOn"),"自发光");
                if (FindMaterialProperty("_EmissionOn").floatValue>=0.5f)
                {
                    if (FindMaterialProperty("_Emission")!=null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        base.DrawProperty(FindMaterialProperty("_Emission"), "类型");
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                        //
                        if (System.Math.Abs(FindMaterialProperty("_Emission").floatValue-0f) <=0.1f)
                        {
                            if (FindMaterialProperty("_EmissionMap") != null)
                            {
                                EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_EmissionMap"), FindMaterialProperty("_EmissionColor"));
                                EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                            }
                        }else if (System.Math.Abs(FindMaterialProperty("_Emission").floatValue - 1f) <= 0.1f)
                        {
                            if (FindMaterialProperty("_EmissionColor") != null)
                            {
                                EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                                base.DrawProperty(FindMaterialProperty("_EmissionColor"), "HDR Color");
                                EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                            }
                        }
                        else if (System.Math.Abs(FindMaterialProperty("_Emission").floatValue - 2f) <= 0.1f)
                        {
                            if (FindMaterialProperty("_EmissionColor") != null)
                            {
                                EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                                base.DrawProperty(FindMaterialProperty("_EmissionColor"), "HDR Color");
                                EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                            }
                        }
                    }
                    else
                    {
                        if (FindMaterialProperty("_EmissionColor") != null)
                        {
                            EditorGUI.indentLevel = EditorGUI.indentLevel + 2;
                            base.DrawProperty(FindMaterialProperty("_EmissionColor"), "HDR Color");
                            EditorGUI.indentLevel = EditorGUI.indentLevel - 2;
                        }
                    }
                }
            }

            //Light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            if (FindMaterialProperty("_LightAndShadeOffset") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightAndShadeOffset"),"明暗偏移");
            }
            if (FindMaterialProperty("_GIScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GIScale"), "GI强度");
            }
            if (FindMaterialProperty("_SpecularPow") != null)
            {
                base.DrawProperty(FindMaterialProperty("_SpecularPow"), "高光形状");
            }
            if (FindMaterialProperty("_SpecularScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_SpecularScale"), "高光缩放");
            }

            //Scattering
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Scattering", EditorStyles.boldLabel);
            if (FindMaterialProperty("_ScatteringOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringOn"), "散射");
                if (FindMaterialProperty("_ScatteringOn").floatValue >= 0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
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

            //Fresnel
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fresnel", EditorStyles.boldLabel);
            if (FindMaterialProperty("_FresnelBias") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FresnelBias"), "FresnelBias");
            }
            if (FindMaterialProperty("_FresnelScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FresnelScale"), "FresnelScale");
            }
            if (FindMaterialProperty("_FresnelPower") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FresnelPower"), "FresnelPower");
            }

            //Anim
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Anim", EditorStyles.boldLabel);
            if (FindMaterialProperty("_GrassAnimOn") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GrassAnimOn"), "动画");
                if (FindMaterialProperty("_GrassAnimOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_PosOffsetRange") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_PosOffsetRange"), "偏移范围");
                    }
                    if (FindMaterialProperty("_AnimSpeed") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_AnimSpeed"), "动画速度");
                    }
                    if (FindMaterialProperty("_NoiseFrequency") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_NoiseFrequency"), "动画频率");
                    }
                    if (FindMaterialProperty("_AnimStrength") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_AnimStrength"), "动画强度");
                    }
                    if (FindMaterialProperty("_UVYPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_UVYPow"), "UV Y Pow");
                    }
                    if (FindMaterialProperty("_WindData") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_WindData"), "Wind xyz:方向 w:强度");
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


