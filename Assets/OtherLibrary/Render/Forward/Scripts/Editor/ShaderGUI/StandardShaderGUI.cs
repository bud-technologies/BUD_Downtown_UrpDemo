using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace NewRenderShaderGUI
{
    public class StandardShaderGUI : CommonShaderGUI
    {
        public override void ShaderPropertiesGUI(Material material)
        {
            base.ShaderPropertiesGUI(material);
        }

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

        MaterialProperty shadowType;

        void ChangeShadowType(Material mat)
        {
            if (shadowType != null)
            {
                switch (shadowType.floatValue)
                {
                    case 0:     // Off
                        mat.SetFloat("ENABLE_HQ", 0);
                        mat.SetFloat("_HQShadow", 0);
                        mat.DisableKeyword("ENABLE_HQ_SHADOW");
                        mat.DisableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
                        break;
                    case 1f:    // ENABLE_HQ_SHADOW
                        mat.SetFloat("ENABLE_HQ", 1);
                        mat.EnableKeyword("ENABLE_HQ_SHADOW");
                        mat.DisableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
                        break;
                    case 2f:    // ENABLE_HQ_AND_UNITY_SHADOW
                        mat.SetFloat("ENABLE_HQ", 2);
                        mat.EnableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
                        mat.DisableKeyword("ENABLE_HQ_SHADOW");
                        break;
                }

            }
        }

        bool optionsFoldOut;
        protected readonly GUIContent OptionsText = new GUIContent("配置参数", "可配置参数设置");

        protected readonly GUIContent PBRText = new GUIContent("PBR参数", "基本参数设置");

        bool plantShadowFoldOut;
        protected readonly GUIContent PlantShadow = new GUIContent("Plane Shadow(Not Self Shadow)");

        MaterialProperty detailCount;

        void DrawSkinGUI(MaterialEditor materialEditor, Material material)
        {

            // Other ----------------------
            EditorGUILayout.Space();

            optionsFoldOut = EditorGUILayout.BeginFoldoutHeaderGroup(optionsFoldOut, OptionsText);
            if (optionsFoldOut)
            {
                EditorGUILayout.BeginVertical("box");
                {
                    SurfaceType surfaceType = DrawSurfaceTypeProp(material);
                    DrawCullModeProp(material);
                    DrawReceiveShadows(material);
                    if (surfaceType != SurfaceType.Transparent)
                        DrawAlphaClipProp(material);

                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            // PBR -----------------------
            EditorGUILayout.Space();
            EditorGUILayout.LabelField(PBRText, EditorStyles.boldLabel);

            EditorGUILayout.BeginVertical("box");
            // Base
            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("颜色贴图"), FindMaterialProperty("_BaseMap"), FindMaterialProperty("_BaseColor"));
            materialEditor.TextureScaleOffsetProperty(FindMaterialProperty("_BaseMap"));

            // Normal
            MaterialProperty normal = FindMaterialProperty("_BumpMap");
            base.DrawPropertyTexture(normal, "法线贴图");
            if (normal.textureValue != null)
            {
                material.EnableKeyword("_NORMAL_ON");

                // Bent normal
                if (material.shader.name.CompareTo("NewRender/Standard/PBRUber") == 0)
                {
                    MaterialProperty bent_normal = FindMaterialProperty("_BentNormalMap");
                    m_MaterialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Bent法线贴图"), bent_normal, FindMaterialProperty("_SpecularOcclusionStrength"));
                    if (normal != null && bent_normal != null && bent_normal.textureValue != null)
                        material.EnableKeyword("_SPECULAROCCLUSION_ON");
                    else
                        material.DisableKeyword("_SPECULAROCCLUSION_ON");
                    MaterialProperty bentNormalScale = FindMaterialProperty("_BentBumpScale");
                    if (bentNormalScale != null)
                    {
                        m_MaterialEditor.ShaderProperty(bentNormalScale, "法线强度", 2);
                    }
                }
                MaterialProperty normalScale = FindMaterialProperty("_BumpScale");
                if (normalScale!=null)
                {
                    m_MaterialEditor.ShaderProperty(normalScale, "法线强度", 2);
                }
            }
            else
                material.DisableKeyword("_NORMAL_ON");

            // MetallicGlossMap
            base.DrawPropertyTexture(FindMaterialProperty("_MetallicGlossMap"), "PBR 遮罩");

            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_Metallic"), "R 通道 : 金属度", 2);
            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_OcclusionStrength"), "G 通道 : AO", 2);
            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_Smoothness"), "B 通道 : 光滑度", 2);

            //AO Color
            if(FindMaterialProperty("_MetallicGlossMap")!=null)
            {
                MaterialProperty aoColorSetProperty = FindMaterialProperty("AOCOLORSET");
                if (aoColorSetProperty!=null)
                {
                    m_MaterialEditor.ShaderProperty(aoColorSetProperty,"AO颜色控制", 2);
                    float aoColorSetPropertyValue = aoColorSetProperty.floatValue;

                    MaterialProperty occlusionColor = null;
                    MaterialProperty occlusionColorMap = null;
                    if (System.Math.Abs(aoColorSetPropertyValue-1) <0.1f )
                    {
                        occlusionColor = FindMaterialProperty("_OcclusionColor");
                    }
                    else if (System.Math.Abs(aoColorSetPropertyValue - 2) < 0.1f)
                    {
                        occlusionColor = FindMaterialProperty("_OcclusionColor");
                        occlusionColorMap = FindMaterialProperty("_OcclusionColorMap");
                    }
                    if (occlusionColor!=null)
                    {
                        if (occlusionColorMap==null)
                        {
                            m_MaterialEditor.ShaderProperty(occlusionColor, "AO颜色", 3);
                        }
                        else
                        {
                            EditorGUI.indentLevel= EditorGUI.indentLevel+3;
                            materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("AO颜色贴图"), occlusionColorMap, occlusionColor);
                            EditorGUI.indentLevel = EditorGUI.indentLevel - 3;
                        }
                    }else if (occlusionColorMap!=null)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 3;
                        materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("AO颜色贴图"), occlusionColorMap);
                        EditorGUI.indentLevel = EditorGUI.indentLevel - 3;
                    }
                }
            }

            EditorGUILayout.EndVertical();

            // Emission
            EditorGUILayout.BeginVertical("box");
            {
                MaterialProperty emission = FindMaterialProperty("_Emission");
                if (emission != null)
                {
                    m_MaterialEditor.ShaderProperty(emission, EditorGUIUtility.TrTextContent("自发光"), 2);
                    if (emission.floatValue != 0)
                    {
                        material.EnableKeyword("_EMISSION_ON");
                        MaterialProperty emission_map = FindMaterialProperty("_EmissionMap");
                        m_MaterialEditor.TexturePropertyWithHDRColor(EditorGUIUtility.TrTextContent("自发光遮罩"), emission_map, FindMaterialProperty("_EmissionColor"), true);
                        if (emission_map.textureValue != null)
                            material.EnableKeyword("_EMISSION_MAP");
                        else
                            material.DisableKeyword("_EMISSION_MAP");
                    }
                    else
                        material.DisableKeyword("_EMISSION_ON");
                }
            }
            EditorGUILayout.EndVertical();

            // PBRUber Part
            if (material.shader.name.CompareTo("NewRender/Standard/PBRUber") == 0)
            {

                MaterialProperty detail = null;
                // Clear Coat
                EditorGUILayout.BeginVertical("box");
                {
                    MaterialProperty clearCoat = FindMaterialProperty("_ClearCoat");
                    if (clearCoat != null)
                    {
                        m_MaterialEditor.ShaderProperty(clearCoat, EditorGUIUtility.TrTextContent("清漆"), 2);
                        if (clearCoat.floatValue != 0)
                        {
                            material.EnableKeyword("_CLEARCOAT_ON");

                            MaterialProperty clearcoat_map = FindMaterialProperty("_ClearCoatMap");
                            base.DrawPropertyTexture(clearcoat_map, "清漆遮罩(透明度)");
                            if (clearcoat_map.textureValue != null)
                                material.EnableKeyword("_CLEARCOATMAP");
                            else
                                material.DisableKeyword("_CLEARCOATMAP");


                            MaterialProperty clearCoatCubeMap = FindMaterialProperty("_ClearCoatCubeMap");
                            base.DrawPropertyTexture(clearCoatCubeMap, "清漆反射球");
                            if (clearCoatCubeMap.textureValue != null)
                                material.EnableKeyword("_CLEARCOATCUBEMAP_ON");
                            else
                                material.DisableKeyword("_CLEARCOATCUBEMAP_ON");

                            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ClearCoatMask"), "清漆透明度", 2);
                            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ClearCoatSmoothness"), "清漆光滑度", 2);
                            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ClearCoatDownSmoothness"), "清漆底层光滑度", 2);

                            if (detail != null && detail.floatValue != 0)
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ClearCoat_Detail_Factor"), "清漆 Detail 强度", 2);

                        }
                        else
                        {
                            material.DisableKeyword("_CLEARCOAT_ON");
                        }
                    }
                }
                EditorGUILayout.EndVertical();

                // Detail Map
                if (normal.textureValue != null)
                {
                    EditorGUILayout.BeginVertical("box");
                    {
                        detail = FindMaterialProperty("_UseDetailMap");
                        if (detail != null)
                        {
                            m_MaterialEditor.ShaderProperty(detail, EditorGUIUtility.TrTextContent("细节(Detail)"), 2);
                            if (detail.floatValue != 0)
                            {
                                material.EnableKeyword("_DETAILMAP_ON");

                                base.DrawPropertyTexture(FindMaterialProperty("_Detail_ID"), "细节 ID");

                                detailCount = FindMaterialProperty("_Detail_Layer");
                                m_MaterialEditor.ShaderProperty(detailCount, "细节层数", 2);

                                int count = (int)detailCount.floatValue;

                                for (int i = 1; i <= count; i++)
                                {
                                    EditorGUILayout.BeginVertical("box");
                                    {
                                        // m_MaterialEditor.TextureScaleOffsetProperty(detail_map);
                                        string channelName = "";
                                        switch (i)
                                        {
                                            case 1:
                                                channelName = " (R通道)";
                                                break;
                                            case 2:
                                                channelName = " (G通道)";
                                                break;
                                            case 3:
                                                channelName = " (B通道)";
                                                break;
                                            default:
                                                channelName = " (A通道)";
                                                break;
                                        }
                                        // base.DrawPropertyTexture(FindMaterialProperty("_DetailMap_" + i), "细节贴图" + i + channelName);
                                        m_MaterialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("细节贴图" + i + channelName), FindMaterialProperty("_DetailMap_" + i), FindMaterialProperty("_DetailAlbedoColor_" + i));
                                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DetailMap_Tilling_" + i), "缩放(Tilling)", 2);
                                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DetailAlbedoScale_" + i), "Albedo 强度", 2);
                                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DetailNormalScale_" + i), "法线强度", 2);
                                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DetailSmoothnessScale_" + i), "光滑度", 2);
                                    }
                                    EditorGUILayout.EndVertical();
                                    EditorGUILayout.Space();
                                }

                                // for (int i = count + 1; i <= 4; i++)
                                // {
                                //     FindMaterialProperty("_DetailMap_" + i).textureValue = null;
                                // }
                            }
                            else
                            {
                                material.DisableKeyword("_DETAILMAP_ON");
                            }
                        }
                    }
                    EditorGUILayout.EndVertical();
                }

                // Iridescence
                EditorGUILayout.BeginVertical("box");
                {
                    MaterialProperty iridescence = FindMaterialProperty("_UseIridescence");
                    if (iridescence != null)
                    {
                        m_MaterialEditor.ShaderProperty(iridescence, EditorGUIUtility.TrTextContent("镭射"), 2);
                        if (iridescence.floatValue != 0)
                        {
                            material.EnableKeyword("_IRIDESCENCE_ON");
                            MaterialProperty iridescence_map = FindMaterialProperty("_IridescenceMask");
                            m_MaterialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("镭射遮罩"), iridescence_map, FindMaterialProperty("_Iridescence"));

                            if (iridescence_map.textureValue != null)
                                material.EnableKeyword("_IRIDESCENCE_MASK");
                            else
                                material.DisableKeyword("_IRIDESCENCE_MASK");

                            m_MaterialEditor.ShaderProperty(FindMaterialProperty("_IridescenceThickness"), "镭射厚度", 2);
                        }
                        else
                            material.DisableKeyword("_IRIDESCENCE_ON");
                    }
                }

                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("box");
                {
                    MaterialProperty reflectionScreen = FindMaterialProperty("_UseReflectionScreen");
                    if (reflectionScreen != null)
                    {
                        m_MaterialEditor.ShaderProperty(reflectionScreen, EditorGUIUtility.TrTextContent("镜面"), 2);

                        EditorGUILayout.EndVertical();
                    }
                    else
                    {
                        EditorGUILayout.EndVertical();
                    }
                }

                EditorGUILayout.Space();
            }

            // PlantShadow ----------------------
            //plantShadowFoldOut = EditorGUILayout.BeginFoldoutHeaderGroup(plantShadowFoldOut, PlantShadow);
            //if (plantShadowFoldOut)
            //{
            //    EditorGUILayout.BeginVertical("box");
            //    {
            //        //需要与TA_HighQualityShadow.cs配合使用
            //        shadowType = FindMaterialProperty("ENABLE_HQ");
            //        m_MaterialEditor.ShaderProperty(shadowType, "ShadowType", 2);
            //        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ShadowColor"), "Shadow Color", 2);
            //        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ShadowHeight"), "Shadow Height", 2);
            //        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ShadowOffsetX"), "Shadow Offset X", 2);
            //        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ShadowOffsetZ"), "Shadow Offset Z", 2);
            //        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ProGameOutDir"), "Pro Game Out Dir", 2);
            //    }
            //    EditorGUILayout.EndVertical();

            //}
            EditorGUILayout.EndFoldoutHeaderGroup();


            // DrawStencil(material);

            //
            // EditorGUILayout.Space();
            // m_AdvancedFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(m_AdvancedFoldout, new GUIContent("Advance Options"));
            // if (m_AdvancedFoldout)
            // {
            //     DrawInstancingOnGUI(materialEditor);
            // }
            // EditorGUILayout.EndFoldoutHeaderGroup();

            //
            DrawQueueOnGUI(materialEditor);
        }


        public virtual void MaterialChanged(Material material)
        {
            if (material == null)
            {
                throw new ArgumentNullException("material");
            }

            //material.shaderKeywords = null;
            SetupMaterialBlendMode(material);
            // SetupMaterialKeywords(material);
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
                }
            }
        }
    }
}

