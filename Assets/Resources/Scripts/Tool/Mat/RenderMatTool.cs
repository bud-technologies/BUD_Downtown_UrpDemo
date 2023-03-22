using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Render
{
    /// <summary>
    /// �����򹤾�
    /// </summary>
    public class RenderMatTool
    {

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Assets/RenderTool/Mat/������������������")]
        static void ClearTargetMatUnuseSaveData()
        {
            bool bl = UnityEditor.EditorUtility.DisplayDialog("��ʾ", "ȷ��Ҫ���ѡ�����ʵ���Ч������", "ȷ��", "ȡ��");
            if (!bl) return;
            List<string> mats = new List<string>();
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                if (!string.IsNullOrEmpty(assetPath) && assetPath.EndsWith(".mat"))
                {
                    mats.Add(assetPath);
                }
            }
            for (int i = 0, listCount = mats.Count; i < listCount; ++i)
            {
                RenderMatFun.ClearTargetMatUnuseSaveData(mats[i]);
                Debug.LogError(string.Format("������Ч��������:{0}", mats[i]));
            }
            UnityEditor.AssetDatabase.Refresh();
            Debug.LogError("��Ч�����������");
        }
#endif
    }

}

