using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;

namespace Render
{
    public class RenderAssetTool
    {
#if UNITY_EDITOR
        [UnityEditor.MenuItem("Assets/RenderTool/Asset/����������/����Щ��Դ���õ���")]
        static void ResourceUsed()
        {
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            if (objs == null || objs.Length == 0)
            {
                return;
            }
            bool bl = UnityEditor.EditorUtility.DisplayDialog("��ʾ", "ȷ��Ҫ��ѯ������", "ȷ��", "ȡ��");
            if (!bl) return;
            List<UnityEngine.Object> list = new List<UnityEngine.Object>();
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                if (!string.IsNullOrEmpty(assetPath) && assetPath.StartsWith("Assets/"))
                {
                    list.Add(obj);
                }
            }
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("prefab", assetPaths);
            ResourceDetection.GetAllFilesSuffix("asset", assetPaths);
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            ResourceDetection.GetAllFilesSuffix("shader", assetPaths);
            ResourceDetection.GetAllFilesSuffix("unity", assetPaths);
            ResourceDetection.GetAllFilesSuffix("controller", assetPaths);
            ResourceDetection.ResourceUsed(list, assetPaths);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Asset/����������/��������Щ��Դ")]
        static void GetDependencies()
        {
            UnityEditor.EditorUtility.ClearProgressBar();
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                List<string> resList = new List<string>();
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                {
                    UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ{0}/{1}", j, listCount2), "", j / (float)listCount2);
                    UnityEngine.Object decyAssetObj = decyAssets[j];
                    if (decyAssetObj != obj)
                    {
                        string path = UnityEditor.AssetDatabase.GetAssetPath(decyAssetObj);
                        if (!string.IsNullOrEmpty(path) && path.StartsWith("Assets/") && path.CompareTo(assetPath) != 0)
                        {
                            //if (path.StartsWith("Assets/Art_Resources/Effects/Model/"))
                            //{
                            //    if (!kkkk.Contains(path))
                            //    {
                            //        kkkk.Add(path);
                            //    }
                            //}
                            resList.Add(path);
                        }
                    }
                }
                //д��
                string savePath = RenderTool.WriteFolderDir + ResourceDetection.WriteFolderName + string.Format("/�������{0}.txt", assetPath.Replace("/", "_"));
                StringBuilder stringBuilder = new StringBuilder();
                for (int j = 0, listCount2 = resList.Count; j < listCount2; ++j)
                {
                    stringBuilder.Append(string.Format("·��:{0}\n", resList[j]));
                }
                RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            }

            Debug.LogError("�������:" + RenderTool.WriteFolderDir + ResourceDetection.WriteFolderName + "�������");
            UnityEditor.EditorUtility.ClearProgressBar();

        }

#endif
    }
}


