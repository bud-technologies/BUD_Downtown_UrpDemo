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
                materialEditor.ShaderProperty(FindMaterialProperty("_CameraDepthTextureOn"), "��Ȳ���");
                if (FindMaterialProperty("_CameraDepthTextureOn").floatValue>=0.5f)
                {
                    if (FindMaterialProperty("_DistortionScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_DistortionScale"), "Ť��");
                    }
                }
            }
            if (FindMaterialProperty("_OpaqueTextureOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_OpaqueTextureOn"), "��ɫ����");
            }
            if (FindMaterialProperty("_HighlightsColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_HighlightsColor"), "ǳˮ��");
            }
            if (FindMaterialProperty("_ShadeColor") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ShadeColor"), "��ˮ��");
            }
            if (FindMaterialProperty("_PerspectiveIntensity") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_PerspectiveIntensity"), "͸��ǿ��");
            }
            if (FindMaterialProperty("_MaxDepthSet") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_MaxDepthSet"), "�ɼ����");
            }
            if (FindMaterialProperty("_WaveSpeed") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaveSpeed"), "Wave�ٶ�");
            }
            if (FindMaterialProperty("_WaveNoiseScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaveNoiseScale"), "����");
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
                //materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Spec��ͼ"), FindMaterialProperty("_LightSamplingMap"));
            }
            if (FindMaterialProperty("_SpecularPow") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularPow"), "������״");
            }
            if (FindMaterialProperty("_SpecularScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_SpecularScale"), "��������");
            }
            if (FindMaterialProperty("_LightScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_LightScale"), "��������");
            }
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Fresnel
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fresnel", EditorStyles.boldLabel);
            EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
            if (FindMaterialProperty("_FresnelBias") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelBias"), "ƫ��");
            }
            if (FindMaterialProperty("_FresnelScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelScale"), "����");
            }
            if (FindMaterialProperty("_FresnelPower") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_FresnelPower"), "ǿ��");
            }
            EditorGUI.indentLevel = EditorGUI.indentLevel - 1;

            //Scattering
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Scattering", EditorStyles.boldLabel);
            if (FindMaterialProperty("_ScatteringOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringOn"), "ɢ��");
                if (FindMaterialProperty("_ScatteringOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_ScatteringLightScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightScale"), "�ƹ�����");
                    }
                    if (FindMaterialProperty("_ScatteringLightPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringLightPow"), "�ƹ���״");
                    }
                    if (FindMaterialProperty("_ScatteringScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringScale"), "����");
                    }
                    if (FindMaterialProperty("_ScatteringPow") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringPow"), "��״");
                    }
                    if (FindMaterialProperty("_ScatteringColor") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_ScatteringColor"), "��ɫ");
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
                    materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("Wave��ͼ"), FindMaterialProperty("_WaveHeightMap"));
                }
                if (FindMaterialProperty("_WaveHeightMapScale") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightMapScale"), "����");
                }
                if (FindMaterialProperty("_WaveHeightNormalScale") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightNormalScale"), "��������");
                }
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }

            //foam
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Foam", EditorStyles.boldLabel);
            if (FindMaterialProperty("_WaterFoamOn") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_WaterFoamOn"), "��ĭ");
                if (FindMaterialProperty("_WaterFoamOn").floatValue>=0.5f)
                {
                    EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                    if (FindMaterialProperty("_FoamMap") != null)
                    {
                        materialEditor.TexturePropertySingleLine(EditorGUIUtility.TrTextContent("��ĭ��ͼ"), FindMaterialProperty("_FoamMap"));
                    }
                    if (FindMaterialProperty("_FoamStep") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_FoamStep"), "����");
                    }
                    if (FindMaterialProperty("_FoamAdd") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_FoamAdd"), "ƫ��");
                    }
                    if (FindMaterialProperty("_WaveHeightMapFoamScale") != null)
                    {
                        materialEditor.ShaderProperty(FindMaterialProperty("_WaveHeightMapFoamScale"), "Waveƫ��");
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
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScreenOn"), "����");
                if (FindMaterialProperty("_ReflectScreenOn").floatValue>=0.5f)
                {
                    reflectScreenOn = true;
                }
            }

            if (!reflectScreenOn)
            {
                if (FindMaterialProperty("_REFLECT_CUBE") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_REFLECT_CUBE"), "����");
                    if (System.Math.Abs(FindMaterialProperty("_REFLECT_CUBE").floatValue - 1f) <= 0.1f)
                    {
                        EditorGUI.indentLevel = EditorGUI.indentLevel + 1;
                        if (FindMaterialProperty("_ReflectMapMipLevel") != null)
                        {
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectMapMipLevel"), "ģ��");
                        }
                        if (FindMaterialProperty("_ReflectRatio") != null)
                        {
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectRatio"), "����");
                        }
                        if (FindMaterialProperty("_ReflectScale") != null)
                        {
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScale"), "����");
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
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectMapMipLevel"), "ģ��");
                        }
                        if (FindMaterialProperty("_ReflectRatio") != null)
                        {
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectRatio"), "����");
                        }
                        if (FindMaterialProperty("_ReflectScale") != null)
                        {
                            materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScale"), "����");
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
                    materialEditor.ShaderProperty(FindMaterialProperty("_ReflectMapMipLevel"), "ģ��");
                }
                if (FindMaterialProperty("_ReflectRatio") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_ReflectRatio"), "����");
                }
                if (FindMaterialProperty("_ReflectScale") != null)
                {
                    materialEditor.ShaderProperty(FindMaterialProperty("_ReflectScale"), "����");
                }
                EditorGUI.indentLevel = EditorGUI.indentLevel - 1;
            }
            if (FindMaterialProperty("_ReflectReplace") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectReplace"), "�����滻");
            }
            if (FindMaterialProperty("_ReflectReplaceScale") != null)
            {
                materialEditor.ShaderProperty(FindMaterialProperty("_ReflectReplaceScale"), "�����滻����");
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

