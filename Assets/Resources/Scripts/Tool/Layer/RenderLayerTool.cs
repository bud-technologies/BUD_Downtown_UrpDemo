using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Render
{
    /// <summary>
    /// �㼶�ı༭����
    /// </summary>
    public class RenderLayerTool
    {

#if UNITY_EDITOR
        /// <summary>
        /// ���Layer
        /// </summary>
        public static void CheckLayer()
        {
            RenderLayerTool.AutoAddLayer("GrabPass");
            RenderLayerTool.AutoAddLayer("GrabPassCamera");
        }

        /// <summary>
        /// ���tag
        /// </summary>
        /// <param name="tag"></param>
        private static void AddTag(string tag)
        {
            if (!IsHasTag(tag))
            {
                UnityEditor.SerializedObject tagManager = new UnityEditor.SerializedObject(UnityEditor.AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
                UnityEditor.SerializedProperty it = tagManager.GetIterator();
                while (it.NextVisible(true))
                {
                    if (it.name == "tags")
                    {
                        for (int i = 0; i < it.arraySize; i++)
                        {
                            UnityEditor.SerializedProperty dataPoint = it.GetArrayElementAtIndex(i);
                            if (string.IsNullOrEmpty(dataPoint.stringValue))
                            {
                                dataPoint.stringValue = tag;
                                tagManager.ApplyModifiedProperties();
                                return;
                            }
                        }
                    }
                }
            }
        }

        static bool IsHasTag(string tag)
        {
            for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.tags.Length; i++)
            {
                if (UnityEditorInternal.InternalEditorUtility.tags[i].Contains(tag))
                    return true;
            }
            return false;
        }

        /// <summary>
        /// ���һ���µĲ�
        /// </summary>
        /// <param name="layer"></param>
        public static void AutoAddLayer(string layer)
        {
            if (!HasThisLayer(layer))
            {
                UnityEditor.SerializedObject tagMagager = new UnityEditor.SerializedObject(UnityEditor.AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/Tagmanager.asset"));
                UnityEditor.SerializedProperty it = tagMagager.GetIterator();
                while (it.NextVisible(true))
                {
                    if (it.name.Equals("layers"))
                    {
                        for (int i = 0; i < it.arraySize; i++)
                        {
                            if (i <= 7)
                            {
                                continue;
                            }
                            UnityEditor.SerializedProperty sp = it.GetArrayElementAtIndex(i);
                            if (string.IsNullOrEmpty(sp.stringValue))
                            {
                                sp.stringValue = layer;
                                tagMagager.ApplyModifiedProperties();
                                return;
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// �Ƿ����ָ���Ĳ�
        /// </summary>
        /// <param name="layer"></param>
        /// <returns></returns>
        public static bool HasThisLayer(string layer)
        {
            if (layer == null)
            {
                return false;
            }
            layer = layer.Trim();
            //������ѱ����
            UnityEditor.SerializedObject tagManager = new UnityEditor.SerializedObject(UnityEditor.AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/Tagmanager.asset"));
            UnityEditor.SerializedProperty it = tagManager.GetIterator();
            while (it.NextVisible(true))
            {
                if (it.name.Equals("layers"))
                {
                    for (int i = 0; i < it.arraySize; i++)
                    {
                        if (i <= 7)
                        {
                            continue;
                        }
                        UnityEditor.SerializedProperty sp = it.GetArrayElementAtIndex(i);
                        if (!string.IsNullOrEmpty(sp.stringValue))
                        {
                            if (sp.stringValue.CompareTo(layer) == 0)
                            {
                                return true;
                            }
                            //if (sp.stringValue.Equals(layer))
                            //{
                            //    sp.stringValue = string.Empty;
                            //    tagManager.ApplyModifiedProperties();
                            //}
                        }
                    }
                }
            }
            //for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.layers.Length; i++)
            //{
            //    if (UnityEditorInternal.InternalEditorUtility.layers[i].Contains(layer))
            //    {
            //        return true;
            //    }
            //}
            return false;
        }

#endif

    }
}


