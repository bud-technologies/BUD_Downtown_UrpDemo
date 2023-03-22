using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// 延迟显示脚本
/// 当父节点具备Timeline的时候，会自动索引PlayableDirector数据
/// PlayableDirector数据可以手动指定
/// PlayableDirector数据不为空的时候，会根据Timeline时间线运行
/// PlayableDirector数据为空的时候会根据游戏时间运行
/// </summary>
[ExecuteAlways]
public class EffectDelayPlayTimeLine : MonoBehaviour
{
    public float delayTime = 2f;
    List<GameObject> childs = new List<GameObject>();

    private bool m_done = false;
    private float m_startTime = 0f;

    private void Awake()
    {
        if (!Application.isPlaying) return;
        int count = transform.childCount;
        for (int i = 0; i < count; i++)
        {
            childs.Add(transform.GetChild(i).gameObject);
        }
    }

    private void OnEnable()
    {
        if (!Application.isPlaying) return;
        m_startTime = Time.realtimeSinceStartup;
        m_done = false;
        SetChildActive(false);
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            FreshTimeline();
            #region//编辑器状态下的TimeLine刷新
            if (PlayableDirector != null)
            {
                childs.Clear();
                int count = transform.childCount;
                for (int i = 0; i < count; i++)
                {
                    childs.Add(transform.GetChild(i).gameObject);
                }
                if (PlayableDirector.time <= delayTime)
                {
                    SetChildActive(false);
                }
                else
                {
                    SetChildActive(true);
                }
            }
            #endregion
            return;
        }
        if (m_done)
            return;
        if (PlayableDirector != null)
        {
            if (PlayableDirector.time >= delayTime)
            {
                SetChildActive(true);
                m_done = true;
            }
        }
        else
        {
            if (Time.realtimeSinceStartup - m_startTime > delayTime)
            {
                SetChildActive(true);
                m_done = true;
            }
        }
    }

    private void SetChildActive(bool isActive)
    {
        for (int i = 0; i < childs.Count; i++)
        {
            childs[i].SetActive(isActive);
        }
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
