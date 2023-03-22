using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class ModelCloundShaderGUI : CommonShaderGUI
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
                    if (material.shader!=Shader.Find(string.Intern("NewRender/Cloud/PlantCloud")) && material.shader != Shader.Find(string.Intern("NewRender/Cloud/Default")))
                    {
                        DrawSurfaceTypeProp(material);
                        DrawBlendProp(material);
                    }
                    DrawCullModeProp(material);
                    DrawReceiveShadows(material);
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            //
            EditorGUILayout.BeginVertical("box");

            //
            if (FindMaterialProperty("_BaseMap") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
                EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            if (FindMaterialProperty("_FogHeight") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FogHeight"), "Fog Height");
            }

            //_Light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            if (FindMaterialProperty("_GIScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GIScale"), "GI Scale");
            }
            if (FindMaterialProperty("_EmissionColor") != null)
            {
                base.DrawProperty(FindMaterialProperty("_EmissionColor"), "Emission Color");
            }
            if (FindMaterialProperty("_LightPow") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightPow"), "Light Pow");
            }
            if (FindMaterialProperty("_LightScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightScale"), "Light Scale");
            }
            if (FindMaterialProperty("_LightNegateRangOffset") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightNegateRangOffset"), "Light Negate Range Offset");
            }
            if (FindMaterialProperty("_LightNegateRangeLeftMin") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightNegateRangeLeftMin"), "Light Negate Range Left Min");
            }
            if (FindMaterialProperty("_LightNegateRangeLeftMax") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightNegateRangeLeftMax"), "Light Negate Range Left Max");
            }
            if (FindMaterialProperty("_LightNegateRangeRightMin") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightNegateRangeRightMin"), "Light Negate Range Right Min");
            }
            if (FindMaterialProperty("_LightNegateRangeRightMax") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LightNegateRangeRightMax"), "Light Negate Range Right Max");
            }

            //Occlusion
            if (FindMaterialProperty("_OcclusionMap") != null)
            {
                materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("AO贴图"), FindMaterialProperty("_OcclusionMap"));
            }

            //_FurMap
            //_FurOn
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fur", EditorStyles.boldLabel);
            if (FindMaterialProperty("_FurOn") != null)
            {
                base.DrawProperty(FindMaterialProperty("_FurOn"), "FurOn 云的虚边，需要开启半透");
                if (FindMaterialProperty("_FurOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Fur贴图"), FindMaterialProperty("_FurMap"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_FurMap"));
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                    base.DrawProperty(FindMaterialProperty("_FurMapScale"), "_FurMapScale");
                    base.DrawProperty(FindMaterialProperty("_FurMapStep"), "FurMapStep");
                    EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
                }
            }

            //Color
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Color", EditorStyles.boldLabel);
            if (FindMaterialProperty("_SkyColor") != null)
            {
                base.DrawProperty(FindMaterialProperty("_SkyColor"), "SkyColor");
            }
            if (FindMaterialProperty("_EquatorColor") != null)
            {
                base.DrawProperty(FindMaterialProperty("_EquatorColor"), "EquatorColor");
            }
            if (FindMaterialProperty("_GroundColor") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundColor"), "GroundColor");
            }

            //Light
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Light", EditorStyles.boldLabel);
            if (FindMaterialProperty("_LambertScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_LambertScale"), "LambertScale");
            }
            if (FindMaterialProperty("_ScatteringPow") != null)
            {
                base.DrawProperty(FindMaterialProperty("_ScatteringPow"), "ScatteringPow");
            }
            if (FindMaterialProperty("_ScatteringScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_ScatteringScale"), "ScatteringScale");
            }

            //GroundPlanish
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("GroundPlanish", EditorStyles.boldLabel);
            if (FindMaterialProperty("_GroundPlanishOffset") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundPlanishOffset"), "GroundPlanishOffset");
            }
            if (FindMaterialProperty("_GroundPlanishScaleStenghtH") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundPlanishScaleStenghtH"), "GroundPlanishScaleStenghtH");
            }
            if (FindMaterialProperty("_GroundPlanishScaleStenghtV") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundPlanishScaleStenghtV"), "GroundPlanishScaleStenghtV");
            }
            if (FindMaterialProperty("_GroundPlanishStenght") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundPlanishStenght"), "GroundPlanishStenght");
            }
            if (FindMaterialProperty("_GroundNormalPlanishStenght") != null)
            {
                base.DrawProperty(FindMaterialProperty("_GroundNormalPlanishStenght"), "GroundNormalPlanishStenght");
            }

            //Anim
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Anim", EditorStyles.boldLabel);
            if (FindMaterialProperty("_TreeAnimOn") != null)
            {
                base.DrawProperty(FindMaterialProperty("_TreeAnimOn"), "TreeAnimOn");
            }
            if (FindMaterialProperty("_PosOffsetRange") != null)
            {
                base.DrawVector2FromVector4(FindMaterialProperty("_PosOffsetRange"), "PosOffsetRange");
            }
            if (FindMaterialProperty("_AnimSpeed") != null)
            {
                base.DrawProperty(FindMaterialProperty("_AnimSpeed"), "AnimSpeed");
            }
            if (FindMaterialProperty("_NoiseFrequency") != null)
            {
                base.DrawProperty(FindMaterialProperty("_NoiseFrequency"), "NoiseFrequency");
            }
            if (FindMaterialProperty("_AnimStrength") != null)
            {
                base.DrawProperty(FindMaterialProperty("_AnimStrength"), "AnimStrength");
            }
            if (FindMaterialProperty("_WindData") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WindData"), "Wind xyz:方向 w:强度");
            }

            //Normal
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Normal", EditorStyles.boldLabel);
            if (FindMaterialProperty("_SphereNormalOn") != null)
            {
                base.DrawProperty(FindMaterialProperty("_SphereNormalOn"), "SphereNormalOn");
            }
            if (FindMaterialProperty("_SphereNormalScale") != null)
            {
                base.DrawProperty(FindMaterialProperty("_SphereNormalScale"), "SphereNormalScale");
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


