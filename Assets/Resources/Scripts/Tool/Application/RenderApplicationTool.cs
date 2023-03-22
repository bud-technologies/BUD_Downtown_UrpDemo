using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Render
{
    /// <summary>
    /// 此脚本用于监听编辑器事件
    /// </summary>
    public class RenderApplicationTool
    {

#if UNITY_EDITOR
        /// <summary>
        /// 开启unity的时候 此脚本会进行初始化
        /// </summary>
        [UnityEditor.InitializeOnLoadMethod]
        static void InitializeOnLoadMethod()
        {
            SelectionChanged_Listener(() => {
                //检查所选相机是否挂载了 URPCamera
                //RenderCameraTool.CheckSelect();
                //层级设置检测
                //RenderLayerTool.CheckLayer();
                //模型规范检查 材质替换
                //RenderMatFun.CheckSelect();
            });
        }
#endif

        /// <summary>
        /// 选中物体发生变化
        /// </summary>
        /// <param name="fun"></param>
        /// <param name="add"></param>
        static void SelectionChanged_Listener(Action fun, bool add = true)
        {
#if UNITY_EDITOR
            UnityEditor.Selection.selectionChanged -= fun;
            if (add)
            {
                UnityEditor.Selection.selectionChanged += fun;
            }
#endif
        }


        /// <summary>
        /// 监听unity关闭 可在此处阻止unity退出
        /// fun格式为：bool Func()， false：不许关闭unity，true：允许关闭unity
        /// </summary>
        static void ApplicationWantsToQuit_Listener(Func<bool> fun, bool add = true)
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.wantsToQuit -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.wantsToQuit += fun;
            }
#endif
        }

        /// <summary>
        /// 当编辑器应用程序退出时，Unity会引发此事件。
        /// 请注意，如果编辑器被迫退出或出现崩溃，则不会触发此命令。 当无法取消退出过程时，将引发此事件。
        /// </summary>
        /// <param name="fun"></param>
        static void Quitting_Listener(Action fun, bool add = true)
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.quitting -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.quitting += fun;
            }
#endif
        }

        /// <summary>
        /// Hierarchy面板变动回调
        /// </summary>
        /// <param name="fun"></param>
        static void HierarchyChanged_Listener(Action fun, bool add = true)
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.hierarchyChanged -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.hierarchyChanged += fun;
            }
#endif
        }

#if UNITY_EDITOR
        /// <summary>
        /// 模式变化回调，编辑器模式/游戏模式
        /// </summary>
        /// <param name="fun"></param>
        static void PlayModeStateChanged_Listener(Action<UnityEditor.PlayModeStateChange> fun, bool add = true)
        {
            UnityEditor.EditorApplication.playModeStateChanged -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.playModeStateChanged += fun;
            }
        }
#endif

#if UNITY_EDITOR
        /// <summary>
        /// 暂停模式变化回调，暂停/取消暂停
        /// </summary>
        /// <param name="fun"></param>
        static void PauseStateChanged_Listener(Action<UnityEditor.PauseState> fun, bool add = true)
        {
            UnityEditor.EditorApplication.pauseStateChanged -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.pauseStateChanged += fun;
            }
        }
#endif

        /// <summary>
        /// Project视图资源变化
        /// </summary>
        /// <param name="fun"></param>
        static void ProjectChanged_Listener(Action fun, bool add = true)
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.projectChanged -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.projectChanged += fun;
            }
#endif
        }

#if UNITY_EDITOR
        /// <summary>
        /// 编辑器 Update
        /// </summary>
        /// <param name="fun"></param>
        static void Editor_Update(UnityEditor.EditorApplication.CallbackFunction fun, bool add = true)
        {
            UnityEditor.EditorApplication.update -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.update += fun;
            }
        }
#endif

#if UNITY_EDITOR
        /// <summary>
        /// 编辑器所有检视面板更新完之后执行一次，只会执行一次的函数
        /// </summary>
        /// <param name="fun"></param>
        /// <param name="add"></param>
        static void DelayCall_Update(UnityEditor.EditorApplication.CallbackFunction fun, bool add = true)
        {
            UnityEditor.EditorApplication.delayCall -= fun;
            if (add)
            {
                UnityEditor.EditorApplication.delayCall += fun;
            }
        }
#endif
    }
}


