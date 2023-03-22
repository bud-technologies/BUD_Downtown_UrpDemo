using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class TerrainShaderGUI : CommonShaderGUI
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

            //
            if (FindMaterialProperty("_TEERAINSPLATSIZE")!=null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_TEERAINSPLATSIZE"), "����");
            }

            //
            if (FindMaterialProperty("_TerrainTextureAutoBlender") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_TerrainTextureAutoBlender"), "�߶Ȼ�� ����");
                if (FindMaterialProperty("_TerrainTextureAutoBlender").floatValue >= 0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.ShaderProperty(FindMaterialProperty("_BlenderPow"), "��״");
                    base.DrawVectorSlider(FindMaterialProperty("_SectionTop"), true, true, false, false, new Vector2(0, 1), new Vector2(0, 1), Vector2.zero, Vector2.zero,
                        "�������� min", "�������� max", null, null);
                    base.DrawVectorSlider(FindMaterialProperty("_SectionMid"), true, true, false, false, new Vector2(0, 1), new Vector2(0, 1), Vector2.zero, Vector2.zero,
                        "�в����� min", "�в����� max", null, null);
                    base.DrawVectorSlider(FindMaterialProperty("_SectionDown"), true, true, false, false, new Vector2(0, 1), new Vector2(0, 1), Vector2.zero, Vector2.zero,
                        "�ײ����� min", "�ײ����� max", null, null);
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //

            if (FindMaterialProperty("_Emission") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_Emission"), "Emission");
                if (FindMaterialProperty("_Emission").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.ShaderProperty(FindMaterialProperty("_EmissionColor"), "Emission Color");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            if (FindMaterialProperty("_Metallic") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_Metallic"), "Metallic");
            }
            if (FindMaterialProperty("_Smoothness") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_Smoothness"), "Smoothness");
            }
            if (FindMaterialProperty("_OcclusionStrength") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_OcclusionStrength"), "OcclusionStrength");
            }

            if (FindMaterialProperty("_Control") != null)
            {
                if (FindMaterialProperty("_TerrainTextureAutoBlender") == null ||
                    (FindMaterialProperty("_TerrainTextureAutoBlender") != null && FindMaterialProperty("_TerrainTextureAutoBlender").floatValue <= 0.5f))
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("���ͼ RGBA:���Ȩ��"), FindMaterialProperty("_Control"));
                }
            }

            if (FindMaterialProperty("_SplatMap01") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Top a:AO"), FindMaterialProperty("_SplatMap01"), FindMaterialProperty("_SplatMap01Color"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_SplatMap01"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Top Normal GB:�����ȣ��⻬��"), FindMaterialProperty("_BumpMap01"));
                materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale01"), "����");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_SplatMap02") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("MidUp a:AO"), FindMaterialProperty("_SplatMap02"), FindMaterialProperty("_SplatMap02Color"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_SplatMap02"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("MidUp Normal GB:�����ȣ��⻬��"), FindMaterialProperty("_BumpMap02"));
                materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale02"), "����");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_SplatMap03") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("MidDown  a:AO"), FindMaterialProperty("_SplatMap03"), FindMaterialProperty("_SplatMap03Color"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_SplatMap03"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("MidDown Normal GB:�����ȣ��⻬��"), FindMaterialProperty("_BumpMap03"));
                materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale03"), "����");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_SplatMap04") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Down  a:AO"), FindMaterialProperty("_SplatMap04"), FindMaterialProperty("_SplatMap04Color"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_SplatMap04"));
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Down Normal GB:�����ȣ��⻬��"), FindMaterialProperty("_BumpMap04"));
                materialEditor.ShaderProperty(FindMaterialProperty("_BumpScale04"), "����");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
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


