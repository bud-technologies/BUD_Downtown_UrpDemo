using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class ParticleHolographicShaderGUI : CommonShaderGUI
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
                    DrawBlendProp(material);
                    DrawCullModeProp(material);
                    base.DrawProperty(FindMaterialProperty("_ZAlways"), "ZAlways");
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            //
            EditorGUILayout.BeginVertical("box");


            //Base
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Base", EditorStyles.boldLabel);
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
            //
            DrawVector2FromVector4(FindMaterialProperty("_BaseMapUVSpeed"),"UV动画速度");
            base.DrawProperty(FindMaterialProperty("_BaseMapUVSpeedParticalLerp"), "粒子系统权重(UV0 zw)");
            //
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Mask
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Mask", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_MaskEnable"), "遮罩混合类型");
            if (FindMaterialProperty("_MaskEnable").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                //
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("遮罩贴图"), FindMaterialProperty("_MaskTex"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                DrawVector2FromVector4(FindMaterialProperty("_MaskTexUVSpeed"), "UV动画速度");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                //
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //DepthTexture
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Depth", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_CameraDepthTextureOn"), "深度启用");
            if (FindMaterialProperty("_CameraDepthTextureOn").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                //
                base.DrawProperty(FindMaterialProperty("_DepthFadeIndensity"), "边缘裁剪");
                //
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //全息
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Holographic", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_Holographic"), "全息类型");
            if (FindMaterialProperty("_Holographic").floatValue >= 0.5 && FindMaterialProperty("_Holographic").floatValue <= 1.5)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_HOLOGRAPHIC_UV"), "UV类型");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }
            base.DrawProperty(FindMaterialProperty("_HolographicInvert"), "反相");
            base.DrawProperty(FindMaterialProperty("_EmissionColor"), "自发光");
            base.DrawProperty(FindMaterialProperty("_FresnelScale"), "Fresnel Scale");
            base.DrawProperty(FindMaterialProperty("_FresnelPower"), "Fresnel Power");
            if (FindMaterialProperty("_HOLOGRAPHIC_VERTEXANIM").floatValue >= 0.5f || FindMaterialProperty("_Holographic").floatValue>=0.5)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("噪音贴图"), FindMaterialProperty("_Noise"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                DrawDoubleVector2FromVector4(FindMaterialProperty("_NoiseVertexUVTilling"), "UV Tilling", "UV Offset");
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;

            //顶点动画
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Vertex Anim", EditorStyles.boldLabel);
            base.DrawProperty(FindMaterialProperty("_HOLOGRAPHIC_VERTEXANIM"), "顶点动画");
            if (FindMaterialProperty("_HOLOGRAPHIC_VERTEXANIM").floatValue>=0.5f)
            {
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                //
                if (FindMaterialProperty("_HOLOGRAPHIC_VERTEXANIM").floatValue >= 1.5f)
                {
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("随机贴图"), FindMaterialProperty("_NoiseVertexRandomTex"));
                }
                //
                base.DrawProperty(FindMaterialProperty("_NoiseScale"), "缩放");
                DrawVector2FromVector4(FindMaterialProperty("_NoiseVertexUVSpeed"),"UV动画速度");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerFresnelLerp"), "闪烁菲尼尔缩放");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerScale"), "闪烁缩放");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerTimeInterval"), "闪烁时间间隔 秒");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerTimeRange"), "闪烁时间区域");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerTimeCount"), "闪烁次数");
                base.DrawProperty(FindMaterialProperty("_NoiseVertexFlickerTriggerScale"), "闪烁触发缩放");
                //
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_Holographic").floatValue >= 1.5f)
            {
                //HolographicMask
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Holographic Mask", EditorStyles.boldLabel);
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("全息遮罩"), FindMaterialProperty("_HolographicMaskTexture"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                base.DrawProperty(FindMaterialProperty("_HolographicMaskNoiseTiling"), "UV Tiling");
                base.DrawProperty(FindMaterialProperty("_MaskScale"), "缩放");
                base.DrawProperty(FindMaterialProperty("_NoiseMaskScale"), "噪音缩放");
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


