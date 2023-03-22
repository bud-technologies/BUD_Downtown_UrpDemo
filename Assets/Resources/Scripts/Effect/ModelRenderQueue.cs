using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.Playables;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// 模型节点渲染层级设置
/// 当父节点具备Timeline的时候，会自动索引PlayableDirector数据
/// PlayableDirector数据可以手动指定
/// PlayableDirector数据不为空的时候，会根据Timeline时间线运行
/// PlayableDirector数据为空的时候会根据游戏时间运行
/// </summary>
[ExecuteAlways]
public class ModelRenderQueue : MonoBehaviour
{
    public List<Data> Datas = new List<Data>();

    /// <summary>
    /// 设置的开始时间
    /// </summary>
    public float SetRenderQueueTimeStart = 0;

    /// <summary>
    /// 设置的结束时间
    /// </summary>
    public float SetRenderQueueTimeEnd = 1;

    SetState setState;

    void Update()
    {
        if (!Application.isPlaying)
        {
            FreshTimeline();
            #region//编辑器状态下的TimeLine刷新
            Fresh();
            #endregion
            return;
        }
        Fresh();
    }

    void Fresh()
    {
        if (PlayableDirector != null)
        {
            if (PlayableDirector.time <= SetRenderQueueTimeStart || PlayableDirector.time >= SetRenderQueueTimeEnd)
            {
                if (setState == SetState.None || setState == SetState.SetIn)
                {
                    setState = SetState.SetOut;
                    for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                    {
                        SetData(Datas[i], setState);
                    }
                }
            }
            else
            {
                if (setState == SetState.None || setState == SetState.SetOut)
                {
                    setState = SetState.SetIn;
                    for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                    {
                        SetData(Datas[i], setState);
                    }
                }
            }
        }
    }

    void SetData(Data data, SetState setState)
    {
        for (int i=0,listCount= data.Renderers.Count;i< listCount;++i)
        {
            if (data.Renderers[i] == null) continue;
            Material[] mats = data.Renderers[i].sharedMaterials;
            if (setState== SetState.SetOut)
            {
                for (int j=0,listCount2= mats.Length;j< listCount2;++j)
                {
                    mats[j].renderQueue = data.OldRenderQueue;
                }
            }
            else
            {
                for (int j = 0, listCount2 = mats.Length; j < listCount2; ++j)
                {
                    mats[j].renderQueue = data.SetRenderQueue;
                }
            }
        }
    }

    public enum SetState
    {
        /// <summary>
        /// 设置状态
        /// </summary>
        None,
        /// <summary>
        /// 设置期间之外
        /// </summary>
        SetOut,
        /// <summary>
        /// 设置期间之内
        /// </summary>
        SetIn,
    }

    [Serializable]
    public class Data
    {
        public List<Renderer> Renderers;

        /// <summary>
        /// 原始 RenderQueue
        /// </summary>
        public int OldRenderQueue;

        /// <summary>
        /// 要设置为
        /// </summary>
        public int SetRenderQueue = 3001;

    }

    #region// TimeLine

    public PlayableDirector PlayableDirector;

    /// <summary>
    /// 刷新 TimeLine 数据
    /// </summary>
    void FreshTimeline()
    {
        if (PlayableDirector != null) return;
        PlayableDirector = gameObject.GetComponent<PlayableDirector>();
        Transform root = transform;
        while (PlayableDirector == null)
        {
            root = root.parent;
            if (root != null)
            {
                PlayableDirector = root.gameObject.GetComponent<PlayableDirector>();
            }
            else
            {
                break;
            }
        }
    }

    #endregion
}
