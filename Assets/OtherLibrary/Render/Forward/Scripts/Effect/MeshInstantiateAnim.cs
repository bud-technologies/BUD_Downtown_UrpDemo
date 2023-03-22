using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
/// <summary>
/// TA_MeshInstantiate脚本的淡入淡出控制脚本
/// </summary>
public class MeshInstantiateAnim : MonoBehaviour
{
    #region//Editor

    /// <summary>
    /// 是否是编辑器状态下的产物
    /// </summary>
    [HideInInspector]
    public bool IsEditor = false;

    [HideInInspector]
    public MeshInstantiate MeshInstantiate;

    public MeshInstantiate.Data Data;

    public Renderer RootTarget;

    public Renderer ThisTarget;

    public float StartTime;

    #endregion

    private void Awake()
    {
        if (Application.isPlaying)
        {
            if (IsEditor)
            {
                Destroy(gameObject);
            }
        }
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            if (MeshInstantiate==null || Data==null 
                || MeshInstantiate.PlayableDirector==null || RootTarget==null || ThisTarget==null || !MeshInstantiate.gameObject.activeInHierarchy)
            {
                DestroyImmediate(gameObject);
                return;
            }
            #if UNITY_EDITOR
                if (MeshInstantiate != null && !MeshInstantiate.EditorTimeLineAnims.Contains(this))
                {
                    DestroyImmediate(gameObject);
                    return;
                }
            #endif
            if (Data.DataTimeMod == MeshInstantiate.Data.TimeMod.Timeline)
            {
                Data.AnimRun(MeshInstantiate.PlayableDirector, 0, this);
            }
            else
            {
                Data.AnimRun(MeshInstantiate.PlayableDirector, StartTime, this);
            }
        }
        else
        {
            if (MeshInstantiate!=null && MeshInstantiate.PlayableDirector!=null)
            {
                if (Data.DataTimeMod == MeshInstantiate.Data.TimeMod.Timeline)
                {
                    Data.AnimRun(MeshInstantiate.PlayableDirector, 0, MeshInstantiate);
                }
                else
                {
                    Data.AnimRun(MeshInstantiate.PlayableDirector, StartTime, MeshInstantiate);
                }
            }
            else
            {
                Data.AnimRun(null, StartTime,MeshInstantiate);
            }
        }
    }
}
