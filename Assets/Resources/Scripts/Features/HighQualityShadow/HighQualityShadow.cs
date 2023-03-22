//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;
//using UnityEngine.Rendering.Universal.Internal;

//namespace FBRender
//{

//    /// <summary>
//    /// 只能存在一个
//    /// </summary>
//    [ExecuteAlways]
//    public class HighQualityShadow : MonoBehaviour
//    {
//        [Header("阴影类型")]
//        public ShadowType SetShadowType = ShadowType.HqShadow;

//        [Header("参与阴影渲染的")]
//        public List<Renderer> AllRenderers = new List<Renderer>();

//        [Header("额外列表(手动节点外)")]
//        public List<Renderer> ExtraRenderers = new List<Renderer>();

//        [Header("排除列表(手动节点内)")]
//        public List<Renderer> ExcludeRenderers = new List<Renderer>();

//        bool isEnabled = false;

//        void Awake()
//        {
//            EditorRefresh();
//        }

//        void EditorRefresh()
//        {
//            AllRenderers.Clear();
//            //List<MeshRenderer> tempMeshRenderList = new List<MeshRenderer>();
//            //gameObject.GetComponentsInChildren<MeshRenderer>(tempMeshRenderList);
//            //for (int i=0,listCount= tempMeshRenderList.Count;i< listCount;++i)
//            //{
//            //    if (!ExcludeRenderers.Contains(tempMeshRenderList[i]))
//            //    {
//            //        AllRenderers.Add(tempMeshRenderList[i]);
//            //    }
//            //}
//            List<SkinnedMeshRenderer> tempSkinMeshRenderList = new List<SkinnedMeshRenderer>();
//            gameObject.GetComponentsInChildren<SkinnedMeshRenderer>(tempSkinMeshRenderList);
//            for (int i = 0, listCount = tempSkinMeshRenderList.Count; i < listCount; ++i)
//            {
//                if (!ExcludeRenderers.Contains(tempSkinMeshRenderList[i]))
//                {
//                    AllRenderers.Add(tempSkinMeshRenderList[i]);
//                }
//            }
//            for (int i = 0, listCount = ExtraRenderers.Count; i < listCount; ++i)
//            {
//                if (ExtraRenderers[i] != null && !AllRenderers.Contains(ExtraRenderers[i]))
//                {
//                    AllRenderers.Add(ExtraRenderers[i]);
//                }
//            }
//        }

//        void SetEnable(bool enable)
//        {
//#if UNITY_EDITOR
//            if (!Application.isPlaying)
//            {
//                EditorRefresh();
//            }
//#endif
//            if (isEnabled != enable)
//            {
//                isEnabled = enable;
//                //LGame.RenderFeatureManager.Instance.Use(LGame.ECustomRenderFeatureType.EHighQualityShadow, enable);
//                foreach (Renderer renderer in AllRenderers)
//                {
//                    //此处控制ShadowCaster 使用UnityShadow 还是 HighQualityShadow
//                    //renderer.shadowCastingMode = isEnabled ?UnityEngine.Rendering.ShadowCastingMode.Off : UnityEngine.Rendering.ShadowCastingMode.On;
//                    switch (SetShadowType)
//                    {
//                        case ShadowType.HqShadow:
//                            {
//                                renderer.shadowCastingMode = isEnabled ? UnityEngine.Rendering.ShadowCastingMode.Off : UnityEngine.Rendering.ShadowCastingMode.On;
//                            }
//                            break;
//                        case ShadowType.HqAndUnityShadow:
//                            {
//                                renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
//                            }
//                            break;
//                    }
//                    Material[] mats = renderer.sharedMaterials;
//                    for (int i = 0, listCount = mats.Length; i < listCount; ++i)
//                    {
//                        Material mat = mats[i];
//                        if (mat == null) continue;
//                        if (isEnabled)
//                        {
//                            mat.SetFloat("_HQShadow", 1);
//                            switch (SetShadowType)
//                            {
//                                case ShadowType.HqShadow:
//                                    {
//                                        mat.SetFloat("ENABLE_HQ", 1);
//                                        mat.EnableKeyword("ENABLE_HQ_SHADOW");
//                                        mat.DisableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
//                                    }
//                                    break;
//                                case ShadowType.HqAndUnityShadow:
//                                    {
//                                        mat.SetFloat("ENABLE_HQ", 2);
//                                        mat.EnableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
//                                        mat.DisableKeyword("ENABLE_HQ_SHADOW");
//                                    }
//                                    break;
//                            }
//                        }
//                        else
//                        {
//                            mat.SetFloat("ENABLE_HQ", 0);
//                            mat.SetFloat("_HQShadow", 0);
//                            mat.DisableKeyword("ENABLE_HQ_SHADOW");
//                            mat.DisableKeyword("ENABLE_HQ_AND_UNITY_SHADOW");
//                        }
//                    }
//                }
//#if UNITY_EDITOR
//                UnityEditor.AssetDatabase.Refresh();
//#endif
//            }
//            HighQualityShadowFeature.IsFeatureEnable = enable;
//        }

//        /// <summary>
//        /// 确定 灯光方向正交矩阵范围
//        /// </summary>
//        /// <returns></returns>
//        Bounds GetBounds()
//        {
//#if UNITY_EDITOR
//            if (!Application.isPlaying)
//            {
//                EditorRefresh();
//            }
//#endif
//            Vector3 max = new Vector3(float.MinValue, float.MinValue, float.MinValue);
//            Vector3 min = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
//            for (int i = 0; i < AllRenderers.Count; i++)
//            {
//                Renderer renderer = AllRenderers[i];
//                if (!renderer.enabled || !renderer.gameObject.activeInHierarchy)
//                {
//                    continue;
//                }

//                Bounds itemBounds = renderer.bounds;
//                Vector3 itemBoundMax = itemBounds.max;
//                Vector3 itemBoundMin = itemBounds.min;
//                max = Vector3.Max(max, itemBoundMax);
//                min = Vector3.Min(min, itemBoundMin);
//            }
//            Vector3 center = (min + max) * 0.5f;
//            Vector3 size = (max - min);
//            return new Bounds(center, size);
//        }

//        void Update()
//        {
//#if UNITY_EDITOR
//            if (!Application.isPlaying)
//            {
//                SetEnable(true);
//            }
//#endif
//            HighQualityShadowFeature.m_renderBounds = GetBounds();
//        }

//        private void OnEnable()
//        {
//            SetEnable(true);
//        }

//        private void OnDisable()
//        {
//            SetEnable(false);
//        }

//        private void OnDestroy()
//        {
//            SetEnable(false);
//        }

//        private void OnDrawGizmos()
//        {
//            Bounds bounds = GetBounds();
//            Gizmos.color = Color.red;
//            Gizmos.DrawWireCube(bounds.center, bounds.size);
//        }

//        public enum ShadowType
//        {
//            [Header("高质量阴影")]
//            HqShadow,

//            [Header("高质量阴影+Unity阴影")]
//            HqAndUnityShadow,
//        }

//    }
//}

