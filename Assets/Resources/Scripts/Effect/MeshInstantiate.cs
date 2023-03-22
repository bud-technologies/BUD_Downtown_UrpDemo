using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Text;
using UnityEngine.Playables;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
/// <summary>
/// 此脚本用于克隆一份指定网格，用于新材质在原模型上新建一个展示模型
/// //要求:
/// 淡入淡出动画需要Shader中有“_Opacity”同名都控制字段
/// 
/// 当父节点具备Timeline的时候，会自动索引PlayableDirector数据
/// PlayableDirector数据可以手动指定
/// 
/// 用途:
/// 粒子特效需要在原有角色模型克隆特效效果的时候使用
/// 
/// 使用注意事项：如果具备Timeline组件，就选择TimeMod.Timeline
/// 1：没有Timeline控制的时候，此组件会跑游戏时间执行效果,当具备Timeline的时候根据DataTimeMod选择计时
/// 2：当有Timeline控制的时候
///     a.此脚本会自动索引找到的第一个Timeline控件， PlayableDirector
///     b.DataTimeMod=TimeMod.EnableTime: 如果此脚本第一帧处于active开启状态，当更换 PlayableDirector 的时候，
///         需要在Timeline时间拖至0位置的同时要对本组件隐藏然后开启一遍，重新计算编辑器开始时间，以便于编辑器状态下的Timeline调试同步
///     c.DataTimeMod=TimeMod.Timeline: 此脚本会按照PlayableDirector时间线计时
/// </summary>
public class MeshInstantiate : MonoBehaviour
{
    #region//TimeLine相关

    public PlayableDirector PlayableDirector;

    [HideInInspector]
    public float PlayableDirectorStartTime;

    #endregion

    [Header("克隆目标")]
    public List<Data> Datas = new List<Data>();

    #region//局内调用函数

    bool isGameIn = false;

    /// <summary>
    /// 次函数在设置完 Render 目标之后调用
    /// </summary>
    public void GameInStart()
    {
        isGameIn = true;
        Show();
    }

    #endregion

    private void OnEnable()
    {
        DealEnable();
    }

    private void OnDisable()
    {
        DealDisable();
    }

    void DealEnable()
    {
        FreshTimeline();
        if (!Application.isPlaying)
        {
            if (PlayableDirector != null)
            {
                PlayableDirectorStartTime = (float)PlayableDirector.time;
            }
            else
            {
                PlayableDirectorStartTime = 0;
            }
            return;
        }
        Show();
    }

    void DealDisable()
    {
        if (!Application.isPlaying)
        {
            return;
        }
        if (isGameIn)
        {
            for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
            {
                Datas[i].Renderer = null;
            }
        }
        Hide();
    }
    void Show()
    {
        for (int i=0,listCount= Datas.Count;i< listCount;++i)
        {
            Data.Clone(Datas[i],this);
        }
    }

    void Hide()
    {
        for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
        {
            Data.Clear(Datas[i]);
        }
    }

    [Serializable]
    public class Data
    {
        [Header("Timeline:Timeline组件计时 EnableTime:组件开启的时候开始计时")]
        public TimeMod DataTimeMod;

        [Header("Once:单次 Loop:循环 Keep:保存")]
        public AnimMod DataAnimMod;

        [Header("克隆目标")]
        public Renderer Renderer;

        [Header("使用材质")]
        public Material Material;

        [Header("此节点是否生效")]
        public bool Open = true;

        /// <summary>
        /// 克隆出来的
        /// </summary>
        private GameObject InstantiateRenderer;

        /// <summary>
        /// 克隆出来的
        /// </summary>
        private Material InstantiateMaterial;

        #region//淡入淡出控制

        [HideInInspector]
        public int ShaderOpacityId;

        [Header("Shader淡入淡出控制字段")]
        [HideInInspector]
        public string ShaderOpacity = "_Opacity";

        [Header("Shader淡入淡出延迟时间(秒)")]
        public float DelayAnimLenght = 3;

        [HideInInspector]
        public float curDelayAnimLenght = 0;

        [Header("Shader淡入淡出时间长度-开始(秒)")]
        [Range(0.01f,10)]
        public float OpenAnimLenght = 1;

        [Header("Shader淡入淡出停留时间(秒)")]
        public float StayAnimLenght = 3;

        [Header("Shader淡入淡出时间长度-结束(秒)")]
        [Range(0.01f, 10)]
        public float CloseAnimLenght = 1;

        [HideInInspector]
        public float CurrentAnimTime = 0;

        [HideInInspector]
        public bool isStartAnim = false;

        /// <summary>
        /// 开始淡入淡出
        /// </summary>
        public void StartAnim(MeshInstantiate meshInstantiate)
        {
            ShaderOpacityId = Shader.PropertyToID(ShaderOpacity);
            isStartAnim = true;
            isEndAnim = false;
            isStartStay = false;
            CurrentAnimTime = 0;
            curDelayAnimLenght = 0;
            if (InstantiateMaterial != null && ShaderOpacityId >= 0)
            {
                InstantiateMaterial.SetFloat(ShaderOpacityId, 0);
            }
            if (InstantiateRenderer!=null)
            {
                MeshInstantiateAnim sc = InstantiateRenderer.GetComponent<MeshInstantiateAnim>();
                if (sc==null)
                {
                    sc = InstantiateRenderer.AddComponent<MeshInstantiateAnim>();
                }
                sc.MeshInstantiate = meshInstantiate;
                if (meshInstantiate!=null && meshInstantiate.PlayableDirector!=null)
                {
                    sc.StartTime = (float)meshInstantiate.PlayableDirector.time;
                }
                else
                {
                    sc.StartTime = 0;
                }
                sc.Data = this;
            }
        }

        [HideInInspector]
        public bool isStartStay = false;

        /// <summary>
        /// 开始停留
        /// </summary>
        public void StartStay()
        {
            isStartAnim = false;
            isEndAnim = false;
            isStartStay = true;
            CurrentAnimTime = 0;
        }

        [HideInInspector]
        public bool isEndAnim = false;

        /// <summary>
        /// 结束淡入淡出
        /// </summary>
        public void EndAnim()
        {
            isStartAnim = false;
            isEndAnim = true;
            isStartStay = false;
            CurrentAnimTime = 0;
        }

        /// <summary>
        /// 结束所有动画
        /// </summary>
        void StopAllAnim()
        {
            isStartAnim = false;
            isEndAnim = false;
            isStartStay = false;
            CurrentAnimTime = 0;
            if (InstantiateRenderer != null)
            {
                MeshInstantiateAnim sc = InstantiateRenderer.GetComponent<MeshInstantiateAnim>();
                if (sc != null)
                {
#if UNITY_EDITOR
                    GameObject.DestroyImmediate(sc);
#else
                    GameObject.Destroy(sc);
#endif
                }
            }
        }

        /// <summary>
        /// 动画播放 每帧执行
        /// </summary>
        public void AnimRun(UnityEngine.Playables.PlayableDirector playableDirector,float startTime, MeshInstantiate meshInstantiate)
        {
            if (!isStartAnim && !isEndAnim && !isStartStay) return;

            //淡入淡出时间长度-开始(秒)
            float openAnimTime = DelayAnimLenght + OpenAnimLenght;
            //淡入淡出停留时间(秒)
            float stayAnimTime = openAnimTime + StayAnimLenght;
            //淡入淡出时间长度-结束(秒)
            float closeAnimTime = stayAnimTime + CloseAnimLenght;

            float frameTime = 0;
            if (playableDirector!=null)
            {
                frameTime = (float)(playableDirector.time -startTime)% (DelayAnimLenght+ OpenAnimLenght+ StayAnimLenght+ CloseAnimLenght);
            }

            float lerpValue = 0;
            if (isStartAnim)
            {
                if (playableDirector!=null)
                {
                    if (frameTime >= DelayAnimLenght)
                    {
                        curDelayAnimLenght = 1;
                    }
                    else
                    {
                        curDelayAnimLenght = frameTime / DelayAnimLenght;
                    }
                }
                if (curDelayAnimLenght<1)
                {
                    if (playableDirector==null)
                    {
                        curDelayAnimLenght = curDelayAnimLenght + Time.deltaTime * (1 / DelayAnimLenght);
                    }
                }
                else
                {
                    if (playableDirector!=null)
                    {
                        if (frameTime >= openAnimTime)
                        {
                            CurrentAnimTime = 1;
                        }
                        else
                        {
                            CurrentAnimTime = (frameTime - DelayAnimLenght) / OpenAnimLenght;
                        }
                    }
                    else
                    {
                        CurrentAnimTime = CurrentAnimTime + Time.deltaTime * (1 / OpenAnimLenght);
                    }
                    lerpValue = Mathf.Lerp(0, 1, CurrentAnimTime);
                    if (InstantiateMaterial != null && ShaderOpacityId >= 0)
                    {
                        InstantiateMaterial.SetFloat(ShaderOpacityId, lerpValue);
                    }
                    if (CurrentAnimTime >= 1)
                    {
                        isStartAnim = false;
                        CurrentAnimTime = 0;
                        StartStay();
                    }
                }
            }
            if (isEndAnim)
            {
                if (playableDirector!=null)
                {
                    if (frameTime>= closeAnimTime)
                    {
                        CurrentAnimTime = 1f;
                    }
                    else if (frameTime <= stayAnimTime)
                    {
                        CurrentAnimTime = 1f;
                    }
                    else
                    {
                        CurrentAnimTime = (frameTime - stayAnimTime) / CloseAnimLenght;
                    }
                }
                else
                {
                    CurrentAnimTime = CurrentAnimTime + Time.deltaTime * (1 / CloseAnimLenght);
                }
                
                lerpValue = Mathf.Lerp(1, 0, CurrentAnimTime);
                if (InstantiateMaterial != null && ShaderOpacityId >= 0)
                {
                    InstantiateMaterial.SetFloat(ShaderOpacityId, lerpValue);
                }
                if (CurrentAnimTime >= 1)
                {
                    if (DataAnimMod == AnimMod.Loop)
                    {
                        StartAnim(meshInstantiate);
                    }
                    else
                    {
                        isEndAnim = false;
                        CurrentAnimTime = 0;
                        Clear(this);
                    }
                }
            }
            if (isStartStay)
            {
                if (DataAnimMod== AnimMod.Keep)
                {
                    return;
                }
                if (playableDirector != null)
                {
                    if (frameTime>= stayAnimTime)
                    {
                        CurrentAnimTime = 1;
                    }
                    else if(frameTime<= openAnimTime)
                    {
                        CurrentAnimTime = 0;
                    }
                    else
                    {
                        CurrentAnimTime = (frameTime - openAnimTime) / StayAnimLenght;
                    }
                }
                else
                {
                    CurrentAnimTime = CurrentAnimTime + Time.deltaTime * (1 / StayAnimLenght);
                }
                if (CurrentAnimTime >= 1)
                {
                    EndAnim();
                }
            }
        }

        /// <summary>
        /// 动画播放 编辑器状态下 TimeLine
        /// </summary>
        /// <param name="playableDirector"></param>
        public void AnimRun(UnityEngine.Playables.PlayableDirector playableDirector, float startTime, MeshInstantiateAnim meshInstantiateAnim)
        {
            if (Open)
            {
                //淡入淡出时间长度-开始(秒)
                float openAnimTime = DelayAnimLenght + OpenAnimLenght;
                //淡入淡出停留时间(秒)
                float stayAnimTime = openAnimTime + StayAnimLenght;
                //淡入淡出时间长度-结束(秒)
                float closeAnimTime = stayAnimTime + CloseAnimLenght;

                if (meshInstantiateAnim.ThisTarget != null)
                {
                    switch (DataAnimMod)
                    {
                        case AnimMod.Once:
                            {
                                float frameTime = (float)(playableDirector.time - startTime);
                                if (frameTime <= DelayAnimLenght)
                                {
                                    //淡入淡出延迟时间(秒)
                                    meshInstantiateAnim.ThisTarget.enabled = false;
                                }
                                else if (frameTime > DelayAnimLenght && frameTime <= openAnimTime)
                                {
                                    //淡入淡出时间长度-开始(秒)
                                    float lerp = (frameTime - DelayAnimLenght) / OpenAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, lerp);
                                }
                                else if (frameTime > openAnimTime && frameTime <= stayAnimTime)
                                {
                                    //淡入淡出停留时间(秒)
                                    //float lerp = (frameTime - openAnimTime) / StayAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, 1);

                                }
                                else if (frameTime > stayAnimTime && frameTime < closeAnimTime)
                                {
                                    //淡入淡出时间长度-结束(秒)
                                    float lerp = (frameTime - stayAnimTime) / CloseAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, 1- lerp);
                                }
                                else
                                {
                                    meshInstantiateAnim.ThisTarget.enabled = false;
                                }
                            }
                            break;
                        case AnimMod.Keep:
                            {
                                float frameTime = (float)(playableDirector.time - startTime);
                                if (frameTime<= DelayAnimLenght)
                                {
                                    //淡入淡出延迟时间(秒)
                                    meshInstantiateAnim.ThisTarget.enabled = false;

                                }else if (frameTime > DelayAnimLenght && frameTime<= openAnimTime)
                                {
                                    //淡入淡出时间长度-开始(秒)
                                    float lerp = (frameTime - DelayAnimLenght) / OpenAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, lerp);
                                }
                                else if (frameTime > openAnimTime && frameTime<=stayAnimTime)
                                {
                                    //淡入淡出停留时间(秒)
                                    //float lerp = (frameTime - openAnimTime) / StayAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, 1);

                                }
                                else if (frameTime> stayAnimTime && frameTime< closeAnimTime)
                                {
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    //淡入淡出时间长度-结束(秒)
                                    //float lerp = (frameTime - stayAnimTime) / CloseAnimLenght;

                                }
                                else
                                {
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                }
                            }
                            break;
                        case AnimMod.Loop:
                            {
                                float frameTime = (float)(playableDirector.time - startTime);
                                float he = DelayAnimLenght + OpenAnimLenght + StayAnimLenght + CloseAnimLenght;
                                frameTime = frameTime % he;
                                if (frameTime <= DelayAnimLenght)
                                {
                                    //淡入淡出延迟时间(秒)
                                    meshInstantiateAnim.ThisTarget.enabled = false;

                                }
                                else if (frameTime > DelayAnimLenght && frameTime <= openAnimTime)
                                {
                                    //淡入淡出时间长度-开始(秒)
                                    float lerp = (frameTime - DelayAnimLenght) / OpenAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, lerp);
                                }
                                else if (frameTime > openAnimTime && frameTime <= stayAnimTime)
                                {
                                    //淡入淡出停留时间(秒)
                                    float lerp = (frameTime - openAnimTime) / StayAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, 1);
                                }
                                else if (frameTime > stayAnimTime && frameTime < closeAnimTime)
                                {
                                    //淡入淡出时间长度-结束(秒)
                                    float lerp = (frameTime - stayAnimTime) / CloseAnimLenght;
                                    meshInstantiateAnim.ThisTarget.enabled = true;
                                    meshInstantiateAnim.ThisTarget.sharedMaterial.SetFloat(ShaderOpacity, 1- lerp);
                                }
                                else
                                {
                                    meshInstantiateAnim.ThisTarget.enabled = false;
                                }
                            }
                            break;
                    }
                }
            }
            else
            {
                if (meshInstantiateAnim.ThisTarget != null)
                {
                    meshInstantiateAnim.ThisTarget.enabled = false;
                }
            }
        }

        #endregion

        /// <summary>
        /// 执行克隆
        /// </summary>
        /// <param name="data"></param>
        public static void Clone(Data data, MeshInstantiate meshInstantiate,bool setParent=true)
        {
            if (data.Renderer == null || !data.Open) return;
            MeshInstantiate[] scs = data.Renderer.gameObject.GetComponentsInChildren<MeshInstantiate>(true);
            if (scs != null && scs.Length > 0)
            {
                return;
            }
            data.StopAllAnim();
            if (data.InstantiateRenderer == null)
            {
                data.InstantiateRenderer = InstantiateGameObject(data.Renderer.gameObject);
                if (setParent)
                {
                    data.InstantiateRenderer.transform.SetParent(data.Renderer.transform.parent);
                    data.InstantiateRenderer.transform.localPosition = data.Renderer.transform.localPosition;
                    data.InstantiateRenderer.transform.localRotation = data.Renderer.transform.localRotation;
                    data.InstantiateRenderer.transform.localScale = data.Renderer.transform.localScale;
                }
                if (data.Material !=null)
                {
                    data.InstantiateMaterial = Material.Instantiate(data.Material);
                    Renderer r = data.InstantiateRenderer.GetComponent<Renderer>();
                    r.sharedMaterial = data.InstantiateMaterial;
                    if (data.Renderer.sharedMaterial!=null)
                    {
                        if (data.Renderer.sharedMaterial.renderQueue> data.InstantiateMaterial.renderQueue)
                        {
                            data.InstantiateMaterial.renderQueue = data.Renderer.sharedMaterial.renderQueue + 1;
                        }
                    }
                }
            }
            if (data.InstantiateRenderer!=null)
            {
                data.StartAnim(meshInstantiate);
            }
        }

        /// <summary>
        /// 编辑器状态下的TimeLine调试
        /// </summary>
        /// <param name="data"></param>
        /// <param name="meshInstantiate"></param>
        public static MeshInstantiateAnim CloneTimeLineEditor(Data data, MeshInstantiate meshInstantiate,float startTime)
        {
            if (data.Renderer == null || !data.Open) return null;
            MeshInstantiate[] scs = data.Renderer.gameObject.GetComponentsInChildren<MeshInstantiate>(true);
            if (scs != null && scs.Length > 0)
            {
                return null;
            }
            if (data.Material != null)
            {
                GameObject newObj = InstantiateGameObject(data.Renderer.gameObject);
                Material instantiateMaterial = Material.Instantiate(data.Material);
                Renderer r = newObj.GetComponent<Renderer>();
                r.sharedMaterial = instantiateMaterial;
                if (data.Renderer.sharedMaterial != null)
                {
                    if (data.Renderer.sharedMaterial.renderQueue > instantiateMaterial.renderQueue)
                    {
                        instantiateMaterial.renderQueue = data.Renderer.sharedMaterial.renderQueue + 1;
                    }
                }
                //创建动画播放
                MeshInstantiateAnim meshInstantiateAnim = newObj.AddComponent<MeshInstantiateAnim>();
                meshInstantiateAnim.IsEditor = true;
                meshInstantiateAnim.MeshInstantiate = meshInstantiate;
                meshInstantiateAnim.StartTime = startTime;
                meshInstantiateAnim.RootTarget = data.Renderer;
                meshInstantiateAnim.ThisTarget = newObj.GetComponent<Renderer>();
                meshInstantiateAnim.Data = data;
                return meshInstantiateAnim;
            }
            return null;
        }

        static GameObject InstantiateGameObject(GameObject target)
        {
            GameObject newObj = GameObject.Instantiate(target);
            return newObj;
        }

        /// <summary>
        /// 关闭效果
        /// </summary>
        /// <param name="data"></param>
        public static void Close(Data data)
        {
            data.EndAnim();
        }

        /// <summary>
        /// 清空
        /// </summary>
        /// <param name="data"></param>
        public static void Clear(Data data)
        {
            data.StopAllAnim();
            if (data.InstantiateRenderer != null)
            {
                Destroy(data.InstantiateRenderer);
                data.InstantiateRenderer = null;
            }
            if (data.InstantiateMaterial != null)
            {
                Destroy(data.InstantiateMaterial);
                data.InstantiateMaterial = null;
            }
        }

        [System.Serializable]
        /// <summary>
        /// 动画模式
        /// </summary>
        public enum AnimMod
        {
            Once,
            Loop,
            Keep,
        }

        /// <summary>
        /// 时间计算模式
        /// </summary>
        public enum TimeMod
        {
            /// <summary>
            /// 开启计时
            /// </summary>
            EnableTime,

            /// <summary>
            /// 当有Timeline组件的时候会根据Timeline时间计时
            /// </summary>
            Timeline,

        }
    }

    #region// TimeLine

    /// <summary>
    /// 刷新 TimeLine 数据
    /// </summary>
    void FreshTimeline()
    {
        if (PlayableDirector!=null) return;
        PlayableDirector = gameObject.GetComponent<PlayableDirector>();
        Transform root=transform;
        while (PlayableDirector==null)
        {
            root = root.parent;
            if (root!=null)
            {
                PlayableDirector = root.gameObject.GetComponent<PlayableDirector>();
            }
            else
            {
                break;
            }
        }
    }

#if UNITY_EDITOR

    /// <summary>
    /// 存储编辑器下的动画控件
    /// </summary>
    [HideInInspector]
    public List<MeshInstantiateAnim> EditorTimeLineAnims = new List<MeshInstantiateAnim>();

    void EditorFresh()
    {
        if (PlayableDirector == null)
        {
            EditorTimeLineAnims.Clear();
            return;
        }
        List<MeshInstantiateAnim> tempList = new List<MeshInstantiateAnim>();
        for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
        {
            bool find = false;
            for (int j=0,listCount2= EditorTimeLineAnims.Count;j< listCount2;++j)
            {
                if (EditorTimeLineAnims[j]!=null && EditorTimeLineAnims[j].Data!=null && EditorTimeLineAnims[j].RootTarget!=null && EditorTimeLineAnims[j].ThisTarget!=null
                    && EditorTimeLineAnims[j].RootTarget== Datas[i].Renderer)
                {
                    find = true;
                    tempList.Add(EditorTimeLineAnims[j]);
                    break;
                }
            }
            if (!find)
            {
                MeshInstantiateAnim meshInstantiateAnim = Data.CloneTimeLineEditor(Datas[i], this, PlayableDirectorStartTime);
                if (meshInstantiateAnim!=null)
                {
                    tempList.Add(meshInstantiateAnim);
                }
            }
        }
        EditorTimeLineAnims = tempList;
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            FreshTimeline();
            EditorFresh();
            return;
        }
    }



#endif


    #endregion
    public void OnCreate()
    {

    }

    public void OnGet()
    {
        DealEnable();
    }

    public void OnRecycle()
    {
        DealDisable();
    }
}
