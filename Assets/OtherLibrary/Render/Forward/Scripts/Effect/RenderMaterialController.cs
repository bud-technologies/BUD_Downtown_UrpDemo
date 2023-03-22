using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// <summary>
/// 此脚本用于动态替换材质球
/// </summary>
public class RenderMaterialController : MonoBehaviour
{
    [Header("动画数据")]
    public List<Data> Datas = new List<Data>();

    private void OnEnable()
    {
        if (Application.isPlaying)
        {
            AnimStart();
        }
    }

    void OnDisable()
    {
        if (Application.isPlaying)
        {
            AnimEnd();
        }
    }

    void OnDestroy()
    {
        if (Application.isPlaying)
        {
            AnimEnd();
        }
    }

    bool isAnim = false;

    void AnimStart()
    {
        if (!isAnim)
        {
            isAnim = true;
            for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
            {
                Data data = Datas[i];
                data.StartAnim();
            }
        }
    }

    void AnimEnd()
    {
        if (isAnim)
        {
            isAnim = false;
            for (int i=0,listCount= Datas.Count;i< listCount;++i)
            {
                Data data = Datas[i];
                data.Restore();
            }
        }
    }

    void Update()
    {
        if (!isAnim) return;
        for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
        {
            Data data = Datas[i];
            data.AnimCheck();
        }
    }

    [Serializable]
    public class Data
    {

        [Header("动画目标")]
        public List<Renderer> TargetRenderers;

        [Header("替换材质")]
        public Material ReplaceMaterial;

        [Header("延迟")]
        public float DelayTime;

        /// <summary>
        /// 原来的材质
        /// </summary>
        Dictionary<Renderer, Material> quondamMaterials;

        /// <summary>
        /// 克隆的材质
        /// </summary>
        Material cloneMaterial;

        [Header("闪烁动画配置")]
        public List<MaterialFlickerController.MatAnimData> MatAnimDatas;

        bool isReplaceed = false;

        /// <summary>
        /// 材质替换
        /// </summary>
        public void Replace()
        {
            if (cloneMaterial!=null) return;
            quondamMaterials = new Dictionary<Renderer, Material>();
            for (int i=0,listCount= TargetRenderers.Count;i< listCount;++i)
            {
                if (TargetRenderers[i]==null)
                {
                    TargetRenderers.RemoveAt(i);
                    i--;
                    listCount--;
                }
                else
                {
                    quondamMaterials.Add(TargetRenderers[i],TargetRenderers[i].sharedMaterial);
                }
            }
            if (TargetRenderers.Count==0 || ReplaceMaterial==null) return;
            cloneMaterial = Material.Instantiate(ReplaceMaterial);
            for (int i = 0, listCount = TargetRenderers.Count; i < listCount; ++i)
            {
                TargetRenderers[i].sharedMaterial = cloneMaterial;
            }
            StartCloneMaterialAnim();
            isReplaceed = true;
        }

        /// <summary>
        /// 材质还原
        /// </summary>
        public void Restore()
        {
            if (!isReplaceed) return;
            isReplaceed = false;
            animTime = 0;
            isDelayTime = false;
            Dictionary<Renderer, Material>.Enumerator enumerator = quondamMaterials.GetEnumerator();
            while (enumerator.MoveNext())
            {
                if (enumerator.Current.Key!=null)
                {
                    MaterialFlickerController ta_MaterialFlickerController = enumerator.Current.Key.gameObject.GetComponent<MaterialFlickerController>();
                    if (ta_MaterialFlickerController != null)
                    {
                        GameObject.Destroy(ta_MaterialFlickerController);
                        ta_MaterialFlickerController = null;
                    }
                    enumerator.Current.Key.sharedMaterial = enumerator.Current.Value;
                }
            }
            if (cloneMaterial!=null)
            {
                GameObject.Destroy(cloneMaterial);
                cloneMaterial = null;
            }
        }

        /// <summary>
        /// 动画时间
        /// </summary>
        float animTime = 0;

        /// <summary>
        /// 正在延迟
        /// </summary>
        bool isDelayTime = false;

        /// <summary>
        /// 开始播放动画
        /// </summary>
        public void StartAnim()
        {
            animTime = 0;
            isDelayTime = true;
        }

        /// <summary>
        /// 动画检测
        /// </summary>
        public void AnimCheck()
        {
            animTime = animTime + Time.deltaTime;
            if (isDelayTime)
            {
                if (animTime>= DelayTime)
                {
                    isDelayTime = false;
                    animTime = 0;
                    //isSustainTime = true;
                    Replace();
                }
            }
        }

        #region//克隆材质动画

        void StartCloneMaterialAnim()
        {
            if (cloneMaterial != null)
            {
                if (MatAnimDatas.Count>0)
                {
                    MaterialFlickerController.MatAnimData matAnimData = MatAnimDatas[0];
                    if (MaterialFlickerController.shaderId_Opacity == -1)
                    {
                        MaterialFlickerController.shaderId_Opacity = Shader.PropertyToID("_Opacity");
                    }
                    cloneMaterial.SetFloat(MaterialFlickerController.shaderId_Opacity, matAnimData.StartOpacity);
                    CreateCloneMaterialAnim(matAnimData);
                }
            }
        }

        void CreateCloneMaterialAnim(MaterialFlickerController.MatAnimData matAnimData)
        {
            for (int i = 0, listCount = TargetRenderers.Count; i < listCount; ++i)
            {
                Renderer targetRenderer = TargetRenderers[i];
                if (targetRenderer != null)
                {
                    MaterialFlickerController ta_MaterialFlickerController = targetRenderer.gameObject.GetComponent<MaterialFlickerController>();
                    if (ta_MaterialFlickerController == null)
                    {
                        ta_MaterialFlickerController = targetRenderer.gameObject.AddComponent<MaterialFlickerController>();
                    }
                    ta_MaterialFlickerController.StartAnim(matAnimData, cloneMaterial, CloneMaterialAnimEndCallBack);
                }
            }
        }

        void CloneMaterialAnimEndCallBack(MaterialFlickerController.MatAnimData matAnimData)
        {
            int index = MatAnimDatas.IndexOf(matAnimData);
            if (index== MatAnimDatas.Count-1)
            {
                isDelayTime = false;
                animTime = 0;
                Restore();
            }
            else
            {
                index = index + 1;
                CreateCloneMaterialAnim(MatAnimDatas[index]);
            }
        }

        #endregion

    }



}
