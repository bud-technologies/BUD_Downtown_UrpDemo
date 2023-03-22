using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using System.Linq;

namespace NewRenderShaderGUI
{
    public class ParticleUberEffectGUI : CommonShaderGUI
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
                }
            }
        }

        bool optionsFoldOut;
        protected readonly GUIContent OptionsText = new GUIContent("配置参数", "可配置参数设置");

        protected readonly GUIContent EffectText = new GUIContent("特效参数", "基本参数设置");


        Dictionary<string, string> gradientDic = new Dictionary<string, string> {
            {"_Gradient","渐变叠加"},
            {"_GradientTex","渐变叠加贴图"},
            {"_GradientUV","渐变UV"},
        };

        Dictionary<string, string> vertexDic = new Dictionary<string, string> {
            {"_Vertex_Offset","顶点偏移"},
            {"_VertexOffsetTex","顶点偏移贴图"},
            {"_VertexOffsetIndensity","顶点偏移强度"},
            {"_VertexOffsetTexUV","顶点偏移贴图UV"},
            {"_DistortionInfluenceOffset","扭曲影响顶点偏移"}
        };

        Dictionary<string, string> distortDic = new Dictionary<string, string> {
            {"_Distort","扭曲"},
            {"_DistortionTex","扭曲贴图"},
            {"_DistortionIndensity","扭曲强度"},
            {"_DistortUV","扭曲UV"},
            {"_DistortionInfluenceGradient","扭曲影响渐变"},
            {"_Distortion2UV","扭曲使用UV2"}
        };

        Dictionary<string, string> alphaDic = new Dictionary<string, string> {
            {"_Alpha","Alpha"},
            {"_AlphaTex","Alpha贴图"},
            {"_AlphaUV","AlphaUV速度"},
            {"_AlphaTexUV2","透明贴图UV2"}
        };

        Dictionary<string, string> rimDic = new Dictionary<string, string> {
            {"_Rim","Fresnel"},
            {"_RimPower","Fresnel 范围"},
            {"_RimScale","Fresnel 强度"},
            {"_RimColor","Fresnel 颜色"}
        };

        Dictionary<string, string> dissoloveDic = new Dictionary<string, string> {
            {"_SoftDissolveSwitch","溶解"},
            {"_SoftDissolveTex","软溶解贴图"},
            {"_SoftDissolveIndensity","溶解强度"},
            {"_SoftDissolveSoft","溶解软度"},

            {"_LineWidth","描边宽度"},
            {"_LineColor","描边颜色"},
            {"_GradientDissolve","开启轴向溶解"},
            {"_NoiseIntensity","轴向Noise强度"},
            {"_SoftDissolveTexUV","软溶解UV速度"},

            {"_VertexColorInfluenceSoftDissolve","顶点色影响软溶解"},
            {"_DistortionInfluenceSoft","扭曲影响软溶解"}
        };

        Dictionary<string, string> secondTexDic = new Dictionary<string, string> {
            {"_SecondLayer","第二层"},
            {"_SecondColorBlend","混合模式"},
            {"_SecondColor","第二贴图颜色"},
            {"_SecondTex","第二贴图"},
            {"_SecondUV","xy:流动 zw:旋转"}
        };


        void EffectProperty(MaterialEditor materialEditor, Material material, Dictionary<string, string> dic)
        {
            EditorGUILayout.BeginVertical("Button");

            List<string> keyList = dic.Keys.ToList<string>();
            MaterialProperty property = FindMaterialProperty(keyList[0]);

            if (property != null)
            {
                // m_MaterialEditor.ShaderProperty(property, EditorGUIUtility.TrTextContent(dic[keyList[0]]));

                float nval;
                EditorGUI.BeginChangeCheck();

                nval = EditorGUILayout.ToggleLeft(dic[keyList[0]], property.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                if (EditorGUI.EndChangeCheck())
                    property.floatValue = nval;

                string keyWord = keyList[0].ToUpper() + "_ON";

                if (property.floatValue != 0)
                {
                    material.EnableKeyword(keyWord);
                    foreach (KeyValuePair<string, string> kvp in dic)
                    {
                        if (kvp.Key == keyList[0]) continue;
                        materialEditor.ShaderProperty(FindMaterialProperty(kvp.Key), kvp.Value);
                    }
                }
                else
                {
                    material.DisableKeyword(keyWord);
                    Texture t;
                    foreach (KeyValuePair<string, string> kvp in dic)
                    {
                        if (kvp.Key == keyList[0]) continue;
                        t = FindMaterialProperty(kvp.Key).textureValue;
                        if (t != null)
                            FindMaterialProperty(kvp.Key).textureValue = null;
                    }
                }

            }

            EditorGUILayout.EndVertical();
        }

        private void showVerticalLabel(string label)
        {
            EditorGUILayout.BeginVertical();
            EditorGUILayout.LabelField(label);
            EditorGUILayout.EndVertical();
        }

        void DrawSkinGUI(MaterialEditor materialEditor, Material material)
        {
            // Other ----------------------
            EditorGUILayout.Space();
            optionsFoldOut = EditorGUILayout.BeginFoldoutHeaderGroup(optionsFoldOut, OptionsText);
            if (optionsFoldOut)
            {
                EditorGUILayout.BeginVertical("box");
                {
                    DrawCullModeProp(material);

                    m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ZWrite"), "深度写入");
                    m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ZTest"), "深度测试");
                    m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DepthFade"), "深度边缘消隐");
                    m_MaterialEditor.ShaderProperty(FindMaterialProperty("_ColorMask"), "写入颜色");
                }
                EditorGUILayout.EndVertical();

                // EditorGUILayout.BeginVertical("box");
                // {
                //     //Stencil
                //     m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilRef"), "Stencil Ref");
                //     m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilComp"), "Stencil Comp");
                //     m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilPass"), "Stencil Pass");
                // }
                // EditorGUILayout.EndVertical();

            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            // Effect -----------------------
            EditorGUILayout.Space();
            EditorGUILayout.LabelField(EffectText, EditorStyles.boldLabel);

            // Base
            EditorGUILayout.BeginVertical("box");
            materialEditor.ShaderProperty(FindMaterialProperty("_Color"), "颜色");
            materialEditor.ShaderProperty(FindMaterialProperty("_MainTex"), "颜色贴图");
            materialEditor.ShaderProperty(FindMaterialProperty("_MainUV"), "xy:流动 zw:旋转");
            EditorGUILayout.EndVertical();

            // Second Tex
            EffectProperty(materialEditor, material, secondTexDic);

            // Custom Data
            // maintex u,v;secondtex u,v
            // distort,dissolve,vertex offset,rim
            EditorGUILayout.BeginVertical("Button");
            {
                MaterialProperty customData = FindMaterialProperty("_CustomData");
                if (customData != null)
                {
                    float nval;
                    EditorGUI.BeginChangeCheck();

                    nval = EditorGUILayout.ToggleLeft("Custom Data", customData.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                        customData.floatValue = nval;

                    if (customData.floatValue != 0)
                    {
                        material.EnableKeyword("_CUSTOMDATA_ON");
                        showVerticalLabel("customData1.x -> texcoord1.x -> 主贴图u偏移");
                        showVerticalLabel("customData1.y -> texcoord1.y -> 主贴图v偏移");
                        showVerticalLabel("customData1.z -> texcoord1.z -> 第二贴图u偏移");
                        showVerticalLabel("customData1.w -> texcoord1.w -> 第二贴图v偏移");
                        showVerticalLabel("customData2.y -> texcoord2.y -> 扭曲强度");
                        showVerticalLabel("customData2.x -> texcoord2.x -> 溶解强度");
                        showVerticalLabel("customData2.z -> texcoord2.z -> 顶点偏移强度");
                        showVerticalLabel("customData2.w -> texcoord2.w -> Fresnel 强度");
                    }
                    else
                        material.DisableKeyword("_CUSTOMDATA_ON");
                }
            }
            EditorGUILayout.EndVertical();


            // Radial
            EditorGUILayout.BeginVertical("Button");
            {
                MaterialProperty radial = FindMaterialProperty("_Radial");

                if (radial != null)
                {
                    float nval;
                    EditorGUI.BeginChangeCheck();

                    nval = EditorGUILayout.ToggleLeft("极坐标开关", radial.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                        radial.floatValue = nval;

                    // m_MaterialEditor.ShaderProperty(radial, EditorGUIUtility.TrTextContent("极坐标开关"));

                    if (radial.floatValue != 0)
                    {
                        material.EnableKeyword("_RADIAL_ON");
                        // RadialRing
                        MaterialProperty radialRing = FindMaterialProperty("_RadialRing");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_RadialSpeed"), "极坐标速度");

                        if (radialRing != null)
                        {
                            m_MaterialEditor.ShaderProperty(radialRing, EditorGUIUtility.TrTextContent("极坐标环"));
                            if (radialRing.floatValue != 0)
                            {
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_InverseRadialRing"), "反转极坐标环");
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_RingCount"), "极坐标环数量");
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_RadialRingIntensity"), "极坐标环强度");
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_RingRadius"), "极坐标环半径");
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_RingRange"), "极坐标环范围");
                            }
                        }

                    }
                    else
                        material.DisableKeyword("_RADIAL_ON");
                }
            }
            EditorGUILayout.EndVertical();

            // Rim
            EffectProperty(materialEditor, material, rimDic);

            // Gradient
            EffectProperty(materialEditor, material, gradientDic);

            // Distort
            EffectProperty(materialEditor, material, distortDic);

            // Alpha Tex
            EffectProperty(materialEditor, material, alphaDic);

            // Dissolve
            EditorGUILayout.BeginVertical("Button");
            {
                MaterialProperty dissolve = FindMaterialProperty("_SoftDissolveSwitch");

                if (dissolve != null)
                {
                    float nval;
                    EditorGUI.BeginChangeCheck();

                    nval = EditorGUILayout.ToggleLeft("溶解", dissolve.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                        dissolve.floatValue = nval;

                    if (dissolve.floatValue != 0)
                    {
                        material.EnableKeyword("_SOFTDISSOLVESWITCH_ON");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_SoftDissolveTex"), "软溶解贴图");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_SoftDissolveTexUV"), "软溶解UV速度");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_SoftDissolveIndensity"), "溶解强度");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_SoftDissolveSoft"), "溶解软度");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_LineWidth"), "描边宽度");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_LineColor"), "描边颜色");

                        MaterialProperty gradientDissolve = FindMaterialProperty("_GradientDissolve");

                        if (gradientDissolve != null)
                        {
                            m_MaterialEditor.ShaderProperty(gradientDissolve, EditorGUIUtility.TrTextContent("开启轴向溶解"));
                            if (gradientDissolve.floatValue != 0)
                                m_MaterialEditor.ShaderProperty(FindMaterialProperty("_NoiseIntensity"), "轴向Noise强度");
                        }

                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_VertexColorInfluenceSoftDissolve"), "顶点色影响软溶解");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_DistortionInfluenceSoft"), "扭曲影响软溶解");

                    }
                    else
                        material.DisableKeyword("_SOFTDISSOLVESWITCH_ON");
                }
            }
            EditorGUILayout.EndVertical();

            // Vertex Offset
            EffectProperty(materialEditor, material, vertexDic);

            // Stencil
            EditorGUILayout.BeginVertical("Button");
            {
                MaterialProperty stencil = FindMaterialProperty("_StencilOn");

                if (stencil != null)
                {
                    float nval;
                    EditorGUI.BeginChangeCheck();

                    nval = EditorGUILayout.ToggleLeft("开启模板", stencil.floatValue == 1, EditorStyles.boldLabel, GUILayout.Width(EditorGUIUtility.currentViewWidth - 60)) ? 1 : 0;
                    if (EditorGUI.EndChangeCheck())
                        stencil.floatValue = nval;

                    if (stencil.floatValue != 0)
                    {
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilRef"), "模板值");
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilComp"), "模板比较");  // 0 - 8
                        m_MaterialEditor.ShaderProperty(FindMaterialProperty("_StencilPass"), "模板通过");  // 0 - 7
                    }
                    else
                    {
                        material.SetFloat("_StencilRef", 0);
                        material.SetFloat("_StencilComp", 8);
                        material.SetFloat("_StencilPass", 0);
                    }
                }
            }
            EditorGUILayout.EndVertical();


            EditorGUILayout.Space();
            
            //string text = "反馈和需求点击这里";
            //string url = "https://www.baidu.com";
            //GUIStyle style = new GUIStyle();
            //style.clipping = TextClipping.Overflow;
            //style.normal.textColor = Color.cyan;
            //Rect rect = GUILayoutUtility.GetRect(new GUIContent(text), style);
            //if (Event.current.type == EventType.MouseUp && rect.Contains(Event.current.mousePosition))
            //    Application.OpenURL(url);
            //GUI.Label(rect, text, style);
            
            EditorGUILayout.Space();
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

