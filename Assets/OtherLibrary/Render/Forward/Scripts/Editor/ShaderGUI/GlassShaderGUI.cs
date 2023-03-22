using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class GlassShaderGUI : CommonShaderGUI
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

                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            //
            EditorGUILayout.BeginVertical("box");

            //Base
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Base", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_BASEMAP"), "底图类型");
            if (FindMaterialProperty("_BASEMAP").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));
                if (FindMaterialProperty("_BASEMAP").floatValue > 1.5f)
                {
                    base.DrawProperty(FindMaterialProperty("_Cutoff"), "剪裁");
                }
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //Normal
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Normal", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_NormalOn"), "法线");
            if (FindMaterialProperty("_NormalOn").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("法线贴图"), FindMaterialProperty("_BumpMap"));
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BumpMap"));
                base.DrawProperty(FindMaterialProperty("_BumpScale"), "缩放");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //Refract
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Refract", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_REFRACT"), "折射类型");
            if (FindMaterialProperty("_REFRACT").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_ChannelSplittingOn"), "通道拆分");
                if (FindMaterialProperty("_ChannelSplittingOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    base.DrawProperty(FindMaterialProperty("_ChannelSplittingScale"), "拆分强度");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
                if (FindMaterialProperty("_REFRACT").floatValue>=1.5f && FindMaterialProperty("_REFRACT").floatValue <= 2.5f)
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("折射贴图 2D"), FindMaterialProperty("_RefractMap"));
                }
                if (FindMaterialProperty("_REFRACT").floatValue >= 2.5f)
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("折射贴图 Cube"), FindMaterialProperty("_RefractCubeMap"));
                }
                base.DrawProperty(FindMaterialProperty("_Refractive"), "折射率");
                base.DrawProperty(FindMaterialProperty("_RefractScale"), "强度");
                base.DrawProperty(FindMaterialProperty("_RefractColor"), "颜色");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //Reflect
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Reflect", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_FRESNEL"), "灯光反应");
            base.DrawProperty(FindMaterialProperty("_FresnelScale"), "Fresnel Scale");
            base.DrawProperty(FindMaterialProperty("_FresnelPower"), "Fresnel Power");
            base.DrawProperty(FindMaterialProperty("_FresnelAdd"), "Fresnel Add");
            base.DrawProperty(FindMaterialProperty("_ReflectColor"), "颜色");
            base.DrawProperty(FindMaterialProperty("_ReflectScale"), "缩放");
            base.DrawProperty(FindMaterialProperty("_REFLECT_CUBE"), "采样类型");
            if (FindMaterialProperty("_REFLECT_CUBE").floatValue>=1.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("反射Cube"), FindMaterialProperty("_ReflectMap"));
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

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


