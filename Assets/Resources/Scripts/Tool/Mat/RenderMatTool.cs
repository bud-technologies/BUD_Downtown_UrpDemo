using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Render
{
    /// <summary>
    /// 材质球工具
    /// </summary>
    public class RenderMatTool
    {

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Assets/RenderTool/Mat/清除材质球的无用数据")]
        static void ClearTargetMatUnuseSaveData()
        {
            bool bl = UnityEditor.EditorUtility.DisplayDialog("提示", "确定要清除选定材质的无效数据吗？", "确定", "取消");
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
                Debug.LogError(string.Format("材质无效数据清理:{0}", mats[i]));
            }
            UnityEditor.AssetDatabase.Refresh();
            Debug.LogError("无效数据清理完成");
        }
#endif
    }

}

