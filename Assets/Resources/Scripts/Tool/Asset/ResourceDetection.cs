
using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System;
using System.Reflection;
using System.Linq;
using System.Text;

namespace Render
{
    /// <summary>
    /// 资源检测
    /// </summary>
    public class ResourceDetection
    {

        /// <summary>
        /// 获得ResAB中的所有的依赖文件
        /// </summary>
        public static void CheckResABPrefabDependencies()
        {
#if UNITY_EDITOR
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> resList = new List<string>();
            string checkDir = Application.dataPath + "/ResAB/";
            List<string> assetPaths = new List<string>();
            GetAllFilesSuffix(checkDir, "mat", assetPaths);
            GetAllFilesSuffix(checkDir, "prefab", assetPaths);
            GetAllFilesSuffix(checkDir, "asset", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPaths[i]);
                if (obj != null)
                {
                    string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                    UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", j, listCount2), "", j / (float)listCount2);
                        UnityEngine.Object decyAssetObj = decyAssets[j];
                        if (decyAssetObj != obj)
                        {
                            string path = UnityEditor.AssetDatabase.GetAssetPath(decyAssetObj);
                            if (!string.IsNullOrEmpty(path) && path.StartsWith("Assets/") && path.CompareTo(assetPath) != 0)
                            {
                                if (!resList.Contains(path))
                                {
                                    resList.Add(path);
                                }
                            }
                        }
                    }
                }
            }
            resList.Sort();
            //写出
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/ResAB所有资源的依赖结果.txt");
            StringBuilder stringBuilder = new StringBuilder();
            for (int j = 0, listCount2 = resList.Count; j < listCount2; ++j)
            {
                stringBuilder.Append(string.Format("路径:{0}\n", resList[j]));
            }
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());

            Debug.LogError("ResAB所有资源的依赖结果:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();

            ////将正在使用的文件移动位置
            //for (int j = 0, listCount2 = resList.Count; j < listCount2; ++j)
            //{
            //    string assetPath = resList[j];
            //    //if (assetPath.StartsWith("Assets/Art/Art_Prefabs/")
            //    //    || assetPath.StartsWith("Assets/Art_Resources/") || assetPath.StartsWith("Assets/ArtRawResource/"))
            //    if ((assetPath.StartsWith("Assets/Art/") || assetPath.StartsWith("Assets/Art_Resources/")) && assetPath.Contains("Effects"))
            //    {
            //        if (!assetPath.EndsWith(".cs"))
            //        {
            //            string toAssetPath = "Assets/Using/" + assetPath;
            //            CopyAssetFileTo(assetPath, toAssetPath);
            //        }
            //    }
            //}
            //Debug.LogError("11111111111111");
#endif
        }

        /// <summary>
        /// 拷贝资源文件和meta到指定目录
        /// </summary>
        static void CopyAssetFileTo(string assetPath, string toAssetPath)
        {
            string srcPath = RenderTool.AssetPathToFilePath(assetPath);
            RenderTool.CreateDir(srcPath);
            string disPath = RenderTool.AssetPathToFilePath(toAssetPath);
            RenderTool.CreateDir(disPath);
            string srcPathMeta = RenderTool.AssetPathToFilePath(assetPath + ".meta");
            RenderTool.CreateDir(srcPathMeta);
            string disPathMeta = RenderTool.AssetPathToFilePath(toAssetPath + ".meta");
            RenderTool.CreateDir(disPathMeta);

            disPath = disPath.Replace("Assets/", "SSS");
            RenderTool.CreateDir(disPath);
            disPathMeta = disPathMeta.Replace("Assets/", "SSS");
            RenderTool.CreateDir(disPathMeta);

            File.Copy(srcPath, disPath);
            File.Copy(srcPathMeta, disPathMeta);
            //File.Delete(srcPath);
            //File.Delete(srcPathMeta);
        }

        public static void DelVertexColor(Mesh mesh)
        {
            if (mesh != null)
            {
                if ((mesh.colors != null && mesh.colors.Length > 0) || mesh.colors32 != null && mesh.colors32.Length > 0)
                {
                    if (!MeshNeedVertexColor(mesh))
                    {
                        mesh.colors = null;
                        mesh.colors32 = null;
                    }
                }
            }
        }

        public static string WriteFolderName = "ResourceData";

        /// <summary>
        /// 目标被谁引用到了
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="assetPaths"></param>
        /// <param name="simplifyWrite">简化写出</param>
        public static void ResourceUsed(List<UnityEngine.Object> objs, List<string> assetPaths, bool simplifyWrite = false)
        {
#if UNITY_EDITOR
            UnityEditor.EditorUtility.ClearProgressBar();
            //key:要检测的目标 value:引用了目标的对象
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>> resDic = new Dictionary<UnityEngine.Object, List<UnityEngine.Object>>();
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                if (assetObj != null)
                {
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        UnityEngine.Object decyAssetObj = decyAssets[j];
                        for (int x = 0, listCount3 = objs.Count; x < listCount3; ++x)
                        {
                            if (decyAssetObj == objs[x])
                            {
                                UnityEngine.Object findObj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                                if (findObj != objs[x])
                                {
                                    List<UnityEngine.Object> objList;
                                    if (!resDic.TryGetValue(objs[x], out objList))
                                    {
                                        objList = new List<UnityEngine.Object>();
                                        resDic.Add(objs[x], objList);
                                    }
                                    objList.Add(findObj);
                                }
                            }
                        }
                    }
                }
            }
            for (int i = 0, listCount = objs.Count; i < listCount; ++i)
            {
                if (!resDic.ContainsKey(objs[i]))
                {
                    Debug.LogError(string.Format("没有发现引用者:", objs[i]));
                }
            }
            //写出
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator = resDic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string objAssetPath = UnityEditor.AssetDatabase.GetAssetPath(enumerator.Current.Key);
                List<UnityEngine.Object> resList = enumerator.Current.Value;
                string savePath = null;
                if (simplifyWrite)
                {
                    savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/谁引用了我--{0}--.txt", GetEndName(objAssetPath));
                }
                else
                {
                    savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/谁引用了我--{0}--.txt", objAssetPath.Replace("/", "_"));
                }
                StringBuilder stringBuilder = new StringBuilder();
                for (int i = 0, listCount = resList.Count; i < listCount; ++i)
                {
                    if (simplifyWrite)
                    {
                        stringBuilder.Append(string.Format("使用者:{0}\n", GetEndName(UnityEditor.AssetDatabase.GetAssetPath(resList[i]))));
                    }
                    else
                    {
                        stringBuilder.Append(string.Format("使用者:{0} 路径:{1}\n", resList[i], UnityEditor.AssetDatabase.GetAssetPath(resList[i])));
                    }
                }
                RenderTool.WriteTxt(savePath, stringBuilder.ToString());
                Debug.LogError("谁引用了我写出路径:" + savePath);
            }
            UnityEditor.EditorUtility.ClearProgressBar();
#endif
        }

        /// <summary>
        /// 获得文件名 包含后缀
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        static string GetEndName(string path)
        {
            int index = path.LastIndexOf("/");
            return path.Substring(index + 1, path.Length - index - 1);
        }

        /// <summary>
        /// 判断网格是否需要顶点颜色 非特效网格不需要顶点颜色
        /// </summary>
        /// <param name="mesh"></param>
        /// <returns></returns>
        public static bool MeshNeedVertexColor(Mesh mesh)
        {
#if UNITY_EDITOR
            string assetPath = UnityEditor.AssetDatabase.GetAssetPath(mesh);
            if (string.IsNullOrEmpty(assetPath) || !assetPath.StartsWith("Assets/"))
            {
                return true;
            }
            if (!assetPath.StartsWith("Assets/Art/Effects/"))
            {
                return false;
            }
            return true;
#else
            return false;
#endif
        }

        /// <summary>
        /// 获得指定后缀的文件
        /// </summary>
        /// <param name="suffix"></param>
        public static void GetAllFilesSuffix(string suffix, List<string> assetPaths)
        {
#if UNITY_EDITOR
            string proPath = Application.dataPath;
            string[] strs = Directory.GetFiles(proPath, string.Format("*.{0}", suffix), SearchOption.AllDirectories);
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                string assetPath = RenderTool.FilePathToAssetPath(strs[i]);
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("索引{0} {1}/{2}", suffix, i, listCount), assetPath, i / (float)listCount);
                assetPaths.Add(assetPath);
            }
#endif
        }

        /// <summary>
        /// 获得指定后缀的文件
        /// </summary>
        /// <param name="suffix"></param>
        public static void GetAllFilesSuffix(string dir, string suffix, List<string> assetPaths)
        {
#if UNITY_EDITOR
            if (!Directory.Exists(dir))
            {
                return;
            }
            string[] strs = Directory.GetFiles(dir, string.Format("*.{0}", suffix), SearchOption.AllDirectories);
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                string assetPath = RenderTool.FilePathToAssetPath(strs[i]);
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("索引{0} {1}/{2}", suffix, i, listCount), assetPath, i / (float)listCount);
                assetPaths.Add(assetPath);
            }
#endif
        }

    }

}


