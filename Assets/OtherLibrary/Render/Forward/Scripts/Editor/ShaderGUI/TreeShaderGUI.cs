using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class TreeShaderGUI : CommonShaderGUI
    {
        public override void ShaderPropertiesGUI(Material material)
        {
            base.ShaderPropertiesGUI(material);
        }

        bool optionsFoldOut;

        protected readonly GUIContent OptionsText = new GUIContent("���ò���", "�����ò�������");

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
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("��ɫ��ͼ"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));

            //light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            if (FindMaterialProperty("_LightAndShadeOffset") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_LightAndShadeOffset"), "Light Shade Offset");
            }

            //Scattering
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Scattering", EditorStyles.boldLabel);
            if (FindMaterialProperty("_ScatteringOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringOn"), "Scattering");
                if (FindMaterialProperty("_ScatteringOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringScale"), "Scale");
                    materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringPow"), "Pow");
                    materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringColor"), "Color");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //Emission
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Emission", EditorStyles.boldLabel);
            if (FindMaterialProperty("_EmissionOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_EmissionOn"), "�Է���");
                if (FindMaterialProperty("_Emission") != null)
                {
                    if (FindMaterialProperty("_EmissionOn").floatValue>=0.5f)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        materialEditor.ShaderProperty(FindMaterialProperty("_Emission"), "����");
                        materialEditor.ShaderProperty(FindMaterialProperty("_EmissionColor"), "��ɫ");
                        if (FindMaterialProperty("_Emission").floatValue<=0.5f)
                        {
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("�Է�����ͼ"), FindMaterialProperty("_EmissionMap"));
                            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_EmissionMap"));
                        }
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                    }
                }
            }

            //Normal
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Normal", EditorStyles.boldLabel);
            if (FindMaterialProperty("_NormalCenterSet") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_NormalCenterSet"), "����ӳ��");
                if(FindMaterialProperty("_NormalCenterSet").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_NormalCenterPos") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_NormalCenterPos"), "������������(�ֲ�)");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //Anim
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Anim", EditorStyles.boldLabel);
            if (FindMaterialProperty("_TreeAnimOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_TreeAnimOn"), "��������");
                if (FindMaterialProperty("_TreeAnimOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_PosOffsetRange") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_PosOffsetRange"), "ƫ�Ʒ�Χ");
                    }
                    if (FindMaterialProperty("_AnimSpeed") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_AnimSpeed"), "�����ٶ�");
                    }
                    if (FindMaterialProperty("_NoiseFrequency") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_NoiseFrequency"), "����Ƶ��");
                    }
                    if (FindMaterialProperty("_AnimStrength") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_AnimStrength"), "����ǿ��");
                    }
                    if (FindMaterialProperty("_WindData") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_WindData"), "Wind xyz:���� w:ǿ��");
                    }
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //Fresnel
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fresnel", EditorStyles.boldLabel);
            if (FindMaterialProperty("_FresnelBias") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelBias"), "FresnelBias");
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelScale"), "FresnelScale");
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelPower"), "FresnelPower");
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


