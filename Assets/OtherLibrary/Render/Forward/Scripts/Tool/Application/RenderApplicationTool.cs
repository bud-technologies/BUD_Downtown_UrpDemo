using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Render
{
    /// <summary>
    /// �˽ű����ڼ����༭���¼�
    /// </summary>
    public class RenderApplicationTool
    {

#if UNITY_EDITOR
        /// <summary>
        /// ����unity��ʱ�� �˽ű�����г�ʼ��
        /// </summary>
        [UnityEditor.InitializeOnLoadMethod]
        static void InitializeOnLoadMethod()
        {
            SelectionChanged_Listener(() => {
                //�����ѡ����Ƿ������ URPCamera
                //RenderCameraTool.CheckSelect();
                //�㼶���ü��
                //RenderLayerTool.CheckLayer();
                //ģ�͹淶��� �����滻
                //RenderMatFun.CheckSelect();
            });
        }
#endif

        /// <summary>
        /// ѡ�����巢���仯
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
        /// ����unity�ر� ���ڴ˴���ֹunity�˳�
        /// fun��ʽΪ��bool Func()�� false������ر�unity��true������ر�unity
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
        /// ���༭��Ӧ�ó����˳�ʱ��Unity���������¼���
        /// ��ע�⣬����༭�������˳�����ֱ������򲻻ᴥ������� ���޷�ȡ���˳�����ʱ�����������¼���
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
        /// Hierarchy���䶯�ص�
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
        /// ģʽ�仯�ص����༭��ģʽ/��Ϸģʽ
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
        /// ��ͣģʽ�仯�ص�����ͣ/ȡ����ͣ
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
        /// Project��ͼ��Դ�仯
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
        /// �༭�� Update
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
        /// �༭�����м�����������֮��ִ��һ�Σ�ֻ��ִ��һ�εĺ���
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


