
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System;
using System.Linq;

namespace Render
{

    /// <summary>
    /// 文件重名检查 重复文件的被引用检查
    /// </summary>
    public class DuplicationDetection
    {
#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/所有")]
        /// <summary>
        /// 检查所有重复资源
        /// </summary>
        public static void Run()
        {

            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("xml", false);
            DuplicationName_Suffix("dll", false);
            DuplicationName_Suffix("so", false);
            DuplicationName_Suffix("prefab", false);
            DuplicationName_Suffix("tga", false);
            DuplicationName_Suffix("jpg", false);
            DuplicationName_Suffix("png", false);
            DuplicationName_Suffix("fbx", false);
            DuplicationName_Suffix("cubemap", false);
            DuplicationName_Suffix("shader", false);
            DuplicationName_Suffix("mat", false);
            DuplicationName_Suffix("unity", false);
            DuplicationName_Suffix("asset", false);

            DuplicationName_Suffix("xml", true);
            DuplicationName_Suffix("dll", true);
            DuplicationName_Suffix("so", true);
            DuplicationName_Suffix("prefab", true);
            DuplicationName_Suffix("tga", true);
            DuplicationName_Suffix("jpg", true);
            DuplicationName_Suffix("png", true);
            DuplicationName_Suffix("fbx", true);
            DuplicationName_Suffix("cubemap", true);
            DuplicationName_Suffix("shader", true);
            DuplicationName_Suffix("mat", true);
            DuplicationName_Suffix("unity", true);
            DuplicationName_Suffix("asset", true);

            UnityEditor.EditorUtility.ClearProgressBar();

        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.asset")]
        /// <summary>
        /// 检查重复资源 asset
        /// </summary>
        public static void Run_asset()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("asset", false);
            DuplicationName_Suffix("asset", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.unity")]
        /// <summary>
        /// 检查重复资源 unity
        /// </summary>
        public static void Run_unity()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("unity", false);
            DuplicationName_Suffix("unity", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.mat")]
        /// <summary>
        /// 检查重复资源 mat
        /// </summary>
        public static void Run_mat()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("mat", false);
            DuplicationName_Suffix("mat", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.shader")]
        /// <summary>
        /// 检查重复资源 shader
        /// </summary>
        public static void Run_shader()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("shader", false);
            DuplicationName_Suffix("shader", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.cubemap")]
        /// <summary>
        /// 检查重复资源 cubemap
        /// </summary>
        public static void Run_cubemap()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("cubemap", false);
            DuplicationName_Suffix("cubemap", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.fbx")]
        /// <summary>
        /// 检查重复资源 fbx
        /// </summary>
        public static void Run_fbx()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("fbx", false);
            DuplicationName_Suffix("fbx", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.png")]
        /// <summary>
        /// 检查重复资源 png
        /// </summary>
        public static void Run_png()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("png", false);
            DuplicationName_Suffix("png", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.jpg")]
        /// <summary>
        /// 检查重复资源 jpg
        /// </summary>
        public static void Run_jpg()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("jpg", false);
            DuplicationName_Suffix("jpg", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.tga")]
        /// <summary>
        /// 检查重复资源 tga
        /// </summary>
        public static void Run_tga()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("tga", false);
            DuplicationName_Suffix("tga", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.prefab")]
        /// <summary>
        /// 检查重复资源 prefab
        /// </summary>
        public static void Run_prefab()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("prefab", false);
            DuplicationName_Suffix("prefab", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.so")]
        /// <summary>
        /// 检查重复资源 so
        /// </summary>
        public static void Run_so()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("so", false);
            DuplicationName_Suffix("so", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.xml")]
        /// <summary>
        /// 检查重复资源 xml
        /// </summary>
        public static void Run_xml()
        {

            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("xml", false);
            DuplicationName_Suffix("xml", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件检索/.dll")]
        /// <summary>
        /// 检查重复资源 dll
        /// </summary>
        public static void Run_dll()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DuplicationName_Suffix("dll", false);
            DuplicationName_Suffix("dll", true);

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

        /// <summary>
        /// 检查指定后缀中的重名文件 写出
        /// 返回 key:文件名 key:md5 value:同名文件列表
        /// </summary>
        /// <param name="suffix"></param>
        static Dictionary<string, Dictionary<string, List<UnityEngine.Object>>> DuplicationName_Suffix(string suffix, bool md5)
        {
            string savePath = GetSavePath(suffix, md5, "");
            suffix = "*." + suffix;
            string dataPath = Application.dataPath + "/";
            string[] files = Directory.GetFiles(dataPath, suffix, SearchOption.AllDirectories);
            return DuplicationName(files, savePath, md5, "查询->" + suffix);
        }

        static string WriteFolderName = "DuplicationNameData";

        /// <summary>
        /// 获得写出路径
        /// </summary>
        /// <param name="suffix"></param>
        /// <returns></returns>
        static string GetSavePath(string suffix, bool md5, string add)
        {
            string savePath;
            if (md5)
            {
                savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/MD5-重名文件-{0}{1}.txt", suffix, add);
            }
            else
            {
                savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/重名文件-{0}{1}.txt", suffix, add);
            }
            return savePath;
        }

        /// <summary>
        /// 检查指定路径中的重名文件 写出
        /// 返回 key:文件名 key:md5 value:同名文件列表
        /// </summary>
        /// <param name="files"></param>
        static Dictionary<string, Dictionary<string, List<UnityEngine.Object>>> DuplicationName(string[] files, string savePath, bool md5, string progressBarTitle)
        {
#if UNITY_EDITOR
            Dictionary<string, Dictionary<string, List<UnityEngine.Object>>> resDic = new Dictionary<string, Dictionary<string, List<UnityEngine.Object>>>();
            if (md5)
            {
                //key:文件名 value:文件AssetPath
                Dictionary<string, Dictionary<string, List<string>>> dic = new Dictionary<string, Dictionary<string, List<string>>>();
                for (int i = 0, listCount = files.Length; i < listCount; ++i)
                {
                    string filePath = files[i].Replace("\\", "/");
                    string assetPath = RenderTool.FilePathToAssetPath(filePath);
                    UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                    UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("{0}({1}/{2})", progressBarTitle, i, files.Length), "", i / (float)files.Length);
                    int index = filePath.LastIndexOf("/");
                    string fileName = filePath.Substring(index + 1, filePath.Length - index - 1);
                    Dictionary<string, List<string>> dicSave;
                    Dictionary<string, List<UnityEngine.Object>> objDic;
                    if (!dic.TryGetValue(fileName, out dicSave))
                    {
                        dicSave = new Dictionary<string, List<string>>();
                        dic.Add(fileName, dicSave);
                        objDic = new Dictionary<string, List<UnityEngine.Object>>();
                        resDic.Add(fileName, objDic);
                    }
                    resDic.TryGetValue(fileName, out objDic);
                    string md5Str = RenderTool.CreateFileMD5(filePath);
                    List<string> list;
                    List<UnityEngine.Object> objList;
                    if (!dicSave.TryGetValue(md5Str, out list))
                    {
                        list = new List<string>();
                        dicSave.Add(md5Str, list);
                        objList = new List<UnityEngine.Object>();
                        objDic.Add(md5Str, objList);
                    }
                    objDic.TryGetValue(md5Str, out objList);
                    list.Add(filePath);
                    if (obj != null)
                    {
                        objList.Add(obj);
                    }
                }
                StringBuilder saveStringBuilder = new StringBuilder();
                Dictionary<string, Dictionary<string, List<string>>>.Enumerator enumerator = dic.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    Dictionary<string, List<string>> dic2 = enumerator.Current.Value;
                    Dictionary<string, List<string>>.Enumerator enumerator2 = dic2.GetEnumerator();
                    while (enumerator2.MoveNext())
                    {
                        List<string> list2 = enumerator2.Current.Value;
                        if (list2.Count >= 2)
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append(string.Format("文件名:{0}\n", enumerator.Current.Key));
                            for (int i = 0, listCount = list2.Count; i < listCount; ++i)
                            {
                                stringBuilder.Append(list2[i]);
                                stringBuilder.Append("\n");
                            }
                            saveStringBuilder.Append(stringBuilder.ToString());
                            saveStringBuilder.Append("\n");
                        }
                    }
                }
                RenderTool.WriteTxt(savePath, saveStringBuilder.ToString());
                Debug.LogError("重复文件写出路径:" + savePath);
            }
            else
            {
                //key:文件名 value:文件AssetPath
                Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
                for (int i = 0, listCount = files.Length; i < listCount; ++i)
                {
                    string filePath = files[i].Replace("\\", "/");
                    string assetPath = RenderTool.FilePathToAssetPath(filePath);
                    UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                    UnityEditor.EditorUtility.DisplayCancelableProgressBar("查询(" + i + "/" + files.Length + ")", "", i / (float)files.Length);
                    int index = filePath.LastIndexOf("/");
                    string fileName = filePath.Substring(index + 1, filePath.Length - index - 1);
                    List<string> list;
                    Dictionary<string, List<UnityEngine.Object>> objDic;
                    List<UnityEngine.Object> objList;
                    if (!dic.TryGetValue(fileName, out list))
                    {
                        list = new List<string>();
                        dic.Add(fileName, list);
                        objDic = new Dictionary<string, List<UnityEngine.Object>>();
                        resDic.Add(fileName, objDic);
                        objList = new List<UnityEngine.Object>();
                        objDic.Add("1", objList);
                    }
                    resDic.TryGetValue(fileName, out objDic);
                    objDic.TryGetValue("1", out objList);
                    list.Add(filePath);
                    if (obj != null)
                    {
                        objList.Add(obj);
                    }
                }
                StringBuilder saveStringBuilder = new StringBuilder();
                Dictionary<string, List<string>>.Enumerator enumerator = dic.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    List<string> list = enumerator.Current.Value;
                    if (list.Count >= 2)
                    {
                        StringBuilder stringBuilder = new StringBuilder();
                        stringBuilder.Append(string.Format("文件名:{0}\n", enumerator.Current.Key));

                        for (int i = 0, listCount = list.Count; i < listCount; ++i)
                        {
                            stringBuilder.Append(list[i]);
                            stringBuilder.Append("\n");
                        }
                        saveStringBuilder.Append(stringBuilder.ToString());
                        saveStringBuilder.Append("\n");
                    }
                }
                RenderTool.WriteTxt(savePath, saveStringBuilder.ToString());
                Debug.LogError("重复文件写出路径:" + savePath);
            }
            int indexRes = 0;
            int allCount = resDic.Count;
            Dictionary<string, Dictionary<string, List<UnityEngine.Object>>> newDic = new Dictionary<string, Dictionary<string, List<UnityEngine.Object>>>();
            Dictionary<string, Dictionary<string, List<UnityEngine.Object>>>.Enumerator enumeratorRes = resDic.GetEnumerator();
            while (enumeratorRes.MoveNext())
            {
                string fileName = enumeratorRes.Current.Key;
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("结果整理(" + indexRes + "/" + allCount + ")", "", indexRes / (float)allCount);
                Dictionary<string, List<UnityEngine.Object>> dic2 = enumeratorRes.Current.Value;
                Dictionary<string, List<UnityEngine.Object>>.Enumerator enumerator2 = dic2.GetEnumerator();
                while (enumerator2.MoveNext())
                {
                    string md5Vlaue = enumerator2.Current.Key;
                    List<UnityEngine.Object> list = enumerator2.Current.Value;
                    if (list.Count > 1)
                    {
                        Dictionary<string, List<UnityEngine.Object>> addDic1;
                        if (!newDic.TryGetValue(fileName, out addDic1))
                        {
                            addDic1 = new Dictionary<string, List<UnityEngine.Object>>();
                            newDic.Add(fileName, addDic1);
                        }
                        addDic1.Add(md5Vlaue, list);
                    }
                }
                indexRes++;
            }
            return newDic;
#else
            return null;
#endif
        }

        #region// .meta 文件 GUID 替换

        /// <summary>
        /// 将目标路径的 .meta 文件中的 oldGUID 替换为 newGUID
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="guid"></param>
        public static void ReplaceTargetMetaGuid(string assetPath, string oldGUID, string newGUID)
        {
            if (assetPath.EndsWith(".mat") || assetPath.EndsWith(".prefab") || assetPath.EndsWith(".asset"))
            {
                string readMatTxt = RenderTool.ReadTxt(RenderTool.AssetPathToFilePath(assetPath));
                if (readMatTxt != null)
                {
                    readMatTxt = readMatTxt.Replace(oldGUID, newGUID);
                    RenderTool.WriteTxt(RenderTool.AssetPathToFilePath(assetPath), readMatTxt);
                }
                Debug.LogError("--" + assetPath);
            }
            string assetMetaPath = assetPath + ".meta";
            string readTxt = RenderTool.ReadTxt(RenderTool.AssetPathToFilePath(assetMetaPath));
            if (readTxt != null)
            {
                readTxt = readTxt.Replace(oldGUID, newGUID);
                RenderTool.WriteTxt(RenderTool.AssetPathToFilePath(assetMetaPath), readTxt);
                Debug.LogError("--" + assetMetaPath);
            }
        }

        #endregion

        #region//重复删除

        /// <summary>
        /// 剔除列表
        /// </summary>
        static List<string> _eliminateList;

        /// <summary>
        /// 剔除列表
        /// </summary>
        static List<string> eliminateList
        {
            get
            {
                if (_eliminateList == null)
                {
                    _eliminateList = new List<string>();
                    _eliminateList.Add("Assets/Art/UI");
                    _eliminateList.Add("Assets/Art_Resources/UI");
                    _eliminateList.Add("Assets/Art_Resources/UI3D");
                }
                return _eliminateList;
            }
        }

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件删除/.jpg")]
        /// <summary>
        /// 删除重复文件 jpg
        /// </summary>
        public static void DeleteDuplicationNameFile_jpg()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DeleteDuplicationNameFile("jpg");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件删除/.png")]
        /// <summary>
        /// 删除重复文件 png
        /// </summary>
        public static void DeleteDuplicationNameFile_png()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DeleteDuplicationNameFile("png");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件删除/.tga")]
        /// <summary>
        /// 删除重复文件 tga
        /// </summary>
        public static void DeleteDuplicationNameFile_tga()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DeleteDuplicationNameFile("tga");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/重复文件删除/.mat")]
        /// <summary>
        /// 删除重复文件 mat
        /// </summary>
        public static void DeleteDuplicationNameFile_mat()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            DeleteDuplicationNameFile("mat");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

        /// <summary>
        /// 删除文件存放目录
        /// </summary>
        static string DeleteDuplicationNameFileDir = "DeleteDuplicationCopy";

        /// <summary>
        /// 删除的重复文件备份目录
        /// </summary>
        static string copyDeleteFilesDir
        {
            get
            {
                return RenderTool.WriteFolderDir + DeleteDuplicationNameFileDir + "/Delete/";
            }
        }

        /// <summary>
        /// 被修改了GUID引用的文件备份
        /// </summary>
        static string copyChangeGuidFilesDir
        {
            get
            {
                return RenderTool.WriteFolderDir + DeleteDuplicationNameFileDir + "/ChangeGuid/";
            }
        }

        /// <summary>
        /// 删除记录
        /// </summary>
        /// <param name="suffix"></param>
        /// <returns></returns>
        static string CopyDeleteInfoFilePath(string suffix)
        {
            return RenderTool.WriteFolderDir + DeleteDuplicationNameFileDir + string.Format("/data-{0}.txt", suffix);
        }

        /// <summary>
        /// 删除重复的文件 
        /// 此函数会对没有引用关系的重复文件进行删除
        /// </summary>
        /// <param name="files"></param>
        /// <param name="progressBarTitle"></param>
        static void DeleteDuplicationNameFile(string suffix)
        {
#if UNITY_EDITOR
            bool bl = UnityEditor.EditorUtility.DisplayDialog(suffix, string.Format("确定要删除重复的{0}资源吗？", suffix), "确定", "取消");
            if (!bl) return;
            //删除替换信息记录
            string copyDeleteInfoFile = CopyDeleteInfoFilePath(suffix);
            StringBuilder stringBuilder = new StringBuilder();
            List<string> waitDeleteList = new List<string>();
            UnityEditor.EditorUtility.ClearProgressBar();
            // key;文件名 key:md5 key:重复文件 value:引用了文件的物体列表
            Dictionary<string, Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>> dic = BeAdoptedDependenciesInfo(suffix);
            Dictionary<string, Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>>.Enumerator enumerator = dic.GetEnumerator();
            //剔除屏蔽目录
            int index = 0;
            int allCount = dic.Count;
            List<string> removeFirstList = new List<string>();
            while (enumerator.MoveNext())
            {
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("剔除({0}/{1})", index, allCount), enumerator.Current.Key, index / (float)allCount);
                Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>> dic2 = enumerator.Current.Value;
                Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>.Enumerator enumerator2 = dic2.GetEnumerator();
                List<string> removeList = new List<string>();
                while (enumerator2.MoveNext())
                {
                    Dictionary<UnityEngine.Object, List<UnityEngine.Object>> dic3 = enumerator2.Current.Value;
                    Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator3 = dic3.GetEnumerator();
                    List<UnityEngine.Object> removeObjectList = new List<UnityEngine.Object>();
                    while (enumerator3.MoveNext())
                    {
                        UnityEngine.Object key = enumerator3.Current.Key;
                        string assetPath = UnityEditor.AssetDatabase.GetAssetPath(key);
                        bool find = false;
                        for (int i = 0, listCount = eliminateList.Count; i < listCount; ++i)
                        {
                            if (assetPath.StartsWith(eliminateList[i]))
                            {
                                find = true;
                                break;
                            }
                        }
                        if (find)
                        {
                            removeObjectList.Add(key);
                        }
                    }
                    for (int i = 0, listCount = removeObjectList.Count; i < listCount; ++i)
                    {
                        Debug.LogError(removeObjectList[i]);
                        dic3.Remove(removeObjectList[i]);
                    }
                    removeObjectList.Clear();
                    if (dic3.Count == 0)
                    {
                        removeList.Add(enumerator2.Current.Key);
                    }
                }
                for (int i = 0, listCount = removeList.Count; i < listCount; ++i)
                {
                    dic2.Remove(removeList[i]);
                }
                if (dic2.Count == 0)
                {
                    removeFirstList.Add(enumerator.Current.Key);
                }
                index++;
            }
            for (int i = 0, listCount = removeFirstList.Count; i < listCount; ++i)
            {
                dic.Remove(removeFirstList[i]);
            }
            //
            enumerator = dic.GetEnumerator();
            index = 0;
            allCount = dic.Count;
            while (enumerator.MoveNext())
            {
                stringBuilder.Append("---------->\n");
                stringBuilder.Append(string.Format("文件名:{0}\n", enumerator.Current.Key));
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("重复文件处理({0}/{1})", index, allCount), enumerator.Current.Key, index / (float)allCount);
                Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>> dic2 = enumerator.Current.Value;
                Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>.Enumerator enumerator2 = dic2.GetEnumerator();
                while (enumerator2.MoveNext())
                {
                    stringBuilder.Append("  ->\n");
                    stringBuilder.Append(string.Format("    Md5:\n", enumerator2.Current.Key));
                    //开始处理MD5相同的文件
                    Dictionary<UnityEngine.Object, List<UnityEngine.Object>> dic3 = enumerator2.Current.Value;
                    Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator3 = dic3.GetEnumerator();
                    //先找一个要保留的文件 通过路径判断 此文件是否要选择保留
                    UnityEngine.Object firstObj = null;
                    //最小引用者数量
                    int min = int.MaxValue;
                    //最大引用者数量
                    int max = int.MinValue;
                    //最大引用者 且 引用者数量大于=1
                    UnityEngine.Object maxObj = null;
                    UnityEngine.Object dontDeleteObj = null;
                    while (enumerator3.MoveNext())
                    {
                        if (firstObj == null)
                        {
                            firstObj = enumerator3.Current.Key;
                        }
                        string assetPath = UnityEditor.AssetDatabase.GetAssetPath(enumerator3.Current.Key);
                        //判断路径是否需要保留
                        if (dontDeleteObj == null && assetPath.StartsWith("Assets/Art/") && !assetPath.Contains(".fbm/"))
                        {
                            dontDeleteObj = enumerator3.Current.Key;
                        }
                        List<UnityEngine.Object> list = enumerator3.Current.Value;
                        if (list.Count < min)
                        {
                            min = list.Count;
                        }
                        if (list.Count > max)
                        {
                            max = list.Count;
                            if (max >= 1)
                            {
                                maxObj = enumerator3.Current.Key;
                            }
                        }
                    }
                    if (dontDeleteObj == null)
                    {
                        dontDeleteObj = firstObj;
                    }
                    if ((max >= 2 || (max - min) > 1) && maxObj != null)
                    {
                        dontDeleteObj = maxObj;
                    }
                    if (dontDeleteObj != null)
                    {
                        stringBuilder.Append(string.Format("            保留文件:{0}\n", UnityEditor.AssetDatabase.GetAssetPath(dontDeleteObj)));
                        //将引用者中的不需要保留的GUID修改为需要保留的GUID
                        string guid = UnityEditor.AssetDatabase.AssetPathToGUID(UnityEditor.AssetDatabase.GetAssetPath(dontDeleteObj));
                        enumerator3 = dic3.GetEnumerator();
                        while (enumerator3.MoveNext())
                        {
                            if (enumerator3.Current.Key != dontDeleteObj)
                            {
                                List<UnityEngine.Object> list = enumerator3.Current.Value;
                                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                                {
                                    //弹对话框
                                    //修改GUID
                                    string changeAssetPath = UnityEditor.AssetDatabase.GetAssetPath(list[i]);

                                    //拷贝修改的文件到备份目录
                                    string dir1 = Path.GetDirectoryName(copyChangeGuidFilesDir + changeAssetPath);
                                    if (!Directory.Exists(dir1))
                                    {
                                        Directory.CreateDirectory(dir1);
                                    }
                                    File.Copy(RenderTool.AssetPathToFilePath(changeAssetPath), copyChangeGuidFilesDir + changeAssetPath, true);
                                    //
                                    string changeAssetMetaPath = changeAssetPath + ".meta";
                                    dir1 = Path.GetDirectoryName(copyChangeGuidFilesDir + changeAssetMetaPath);
                                    if (!Directory.Exists(dir1))
                                    {
                                        Directory.CreateDirectory(dir1);
                                    }
                                    File.Copy(RenderTool.AssetPathToFilePath(changeAssetMetaPath), copyChangeGuidFilesDir + changeAssetMetaPath, true);

                                    string guidOld = UnityEditor.AssetDatabase.AssetPathToGUID(UnityEditor.AssetDatabase.GetAssetPath(enumerator3.Current.Key));
                                    ReplaceTargetMetaGuid(changeAssetPath, guidOld, guid);

                                }
                                //需要删除的文件移动到备份文件夹
                                string deleteAssetPath = UnityEditor.AssetDatabase.GetAssetPath(enumerator3.Current.Key);
                                stringBuilder.Append(string.Format("                删除文件:{0}\n", deleteAssetPath));
                                string deleteAssetMetaPath = UnityEditor.AssetDatabase.GetAssetPath(enumerator3.Current.Key) + ".meta";
                                string dir = Path.GetDirectoryName(copyDeleteFilesDir + deleteAssetPath);
                                if (!Directory.Exists(dir))
                                {
                                    Directory.CreateDirectory(dir);
                                }
                                File.Copy(RenderTool.AssetPathToFilePath(deleteAssetPath), copyDeleteFilesDir + deleteAssetPath, true);
                                dir = Path.GetDirectoryName(copyDeleteFilesDir + deleteAssetMetaPath);
                                if (!Directory.Exists(dir))
                                {
                                    Directory.CreateDirectory(dir);
                                }
                                File.Copy(RenderTool.AssetPathToFilePath(deleteAssetMetaPath), copyDeleteFilesDir + deleteAssetMetaPath, true);
                                waitDeleteList.Add(RenderTool.AssetPathToFilePath(deleteAssetPath));
                                waitDeleteList.Add(RenderTool.AssetPathToFilePath(deleteAssetMetaPath));
                            }
                        }
                    }
                }
                index++;
            }
            for (int i = 0, listCount = waitDeleteList.Count; i < listCount; ++i)
            {
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("删除({0}/{1})", i, listCount), enumerator.Current.Key, i / (float)listCount);
                File.Delete(waitDeleteList[i]);
            }
            RenderTool.WriteTxt(copyDeleteInfoFile, stringBuilder.ToString());
            Debug.LogError("删除信息:" + copyDeleteInfoFile);
            UnityEditor.EditorUtility.ClearProgressBar();
#endif
        }

        #region//删除复原

        /// <summary>
        /// 恢复删除的UI PNG资源
        /// </summary>
        public static void DeleteDuplicationNameFileRecover_Png_UI()
        {
#if UNITY_EDITOR
            UnityEditor.EditorUtility.ClearProgressBar();

            List<string> recoverDirs = new List<string>();
            recoverDirs.Add("Assets/Art/UI/");
            recoverDirs.Add("Assets/Art_Resources/UI/");
            recoverDirs.Add("Assets/Art_Resources/UI3D/");
            recoverDirs.Add("Assets/Art_Resources/Splash/");
            DeleteDuplicationNameFileRecover("png", recoverDirs);

            UnityEditor.AssetDatabase.Refresh();

            UnityEditor.EditorUtility.ClearProgressBar();

            Debug.LogError("资源恢复完成");
#endif
        }

        /// <summary>
        /// 复原删除的文件 只可以恢复根据相同MD5删除的文件
        /// </summary>
        /// <param name="suffix">需要复原的文件后缀 如:"png"</param>
        /// <param name="recoverDirs">需要复原的目录 如:"Assets/Art/UI/"</param>
        static void DeleteDuplicationNameFileRecover(string suffix, List<string> recoverDirs)
        {
#if UNITY_EDITOR
            bool bl = UnityEditor.EditorUtility.DisplayDialog(suffix, "确定要恢复资源吗？", "确定", "取消");
            if (!bl) return;

            //删除记录
            string deletionRecord = CopyDeleteInfoFilePath(suffix);
            List<string> delList = GetDeletionRecordList(deletionRecord, recoverDirs);
            //关联关系
            string incidenceRelation = GetSavePath(suffix, true, "");
            Dictionary<string, List<string>> dic1 = GetIncidenceRelation(incidenceRelation, recoverDirs);
            //收集需要复原的文件
            Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
            Dictionary<string, List<string>>.Enumerator enumerator = dic1.GetEnumerator();
            while (enumerator.MoveNext())
            {
                if (delList.Contains(enumerator.Current.Key))
                {
                    dic.Add(enumerator.Current.Key, enumerator.Current.Value);
                }
            }

            FileRecover(dic);
#endif
        }

        /// <summary>
        /// 文件复原
        /// </summary>
        /// <param name="dic"></param>
        static void FileRecover(Dictionary<string, List<string>> dic)
        {
            Dictionary<string, List<string>>.Enumerator enumerator = dic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                List<string> list = enumerator.Current.Value;
                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                {
                    string filePath = copyChangeGuidFilesDir + list[i];
                    string filePath_CopyTo = RenderTool.AssetPathToFilePath(list[i]);
                    string filePathMeta = copyChangeGuidFilesDir + list[i] + ".meta";
                    string filePathMeta_CopyTo = RenderTool.AssetPathToFilePath(list[i] + ".meta");
                    File.Copy(filePath, filePath_CopyTo, true);
                    File.Copy(filePathMeta, filePathMeta_CopyTo, true);
                }
            }
        }

        /// <summary>
        /// 获得删除记录 获得被删除的列表
        /// </summary>
        /// <param name="deletionRecord">删除记录</param>
        /// <param name="recoverDirs">需要复原的目录 如:"Assets/Art/UI/"</param>
        /// <returns></returns>
        static List<string> GetDeletionRecordList(string deletionRecord, List<string> recoverDirs)
        {
            string txt = RenderTool.ReadTxt(deletionRecord);
            string[] strs = txt.Split('\n');
            List<string> delList = new List<string>();
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                if (strs[i].Trim().StartsWith("删除文件:"))
                {
                    string[] strs2 = strs[i].Trim().Split(':');
                    for (int j = 0, listCount2 = recoverDirs.Count; j < listCount2; ++j)
                    {
                        if (strs2[1].StartsWith(recoverDirs[j]))
                        {
                            delList.Add(strs2[1].Trim());
                            break;
                        }
                    }
                }
            }
            return delList;
        }

        /// <summary>
        /// 获得文件关联关系
        /// </summary>
        /// <param name="path2"></param>
        /// <param name="recoverDirs">需要复原的目录 如:"Assets/Art/UI/"</param>
        /// <returns></returns>
        static Dictionary<string, List<string>> GetIncidenceRelation(string path2, List<string> recoverDirs)
        {
            string txt = RenderTool.ReadTxt(path2);
            string[] strs = txt.Split('\n');
            List<List<string>> list = new List<List<string>>();
            List<string> newList = new List<string>();
            list.Add(newList);
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                if (strs[i].Trim().Length == 0)
                {
                    newList = new List<string>();
                    list.Add(newList);
                }
                else
                {
                    newList.Add(strs[i].Trim());
                }
            }

            Dictionary<string, List<string>> dic = new Dictionary<string, List<string>>();
            for (int i = 0, listCount = list.Count; i < listCount; ++i)
            {
                newList = list[i];
                List<string> targetList = null;
                for (int j = 0; j < newList.Count; ++j)
                {
                    if (newList[j].Trim().StartsWith("目标:"))
                    {
                        string[] str3 = newList[j].Trim().Split(':');
                        string key = str3[1].Trim();
                        targetList = new List<string>();
                        dic.Add(key, targetList);
                    }
                    else if (newList[j].Trim().StartsWith("引用者:"))
                    {
                        string[] str3 = newList[j].Trim().Split(':');
                        string value = str3[1].Trim();
                        targetList.Add(value);
                    }
                }
            }
            Dictionary<string, List<string>> resDic = new Dictionary<string, List<string>>();
            Dictionary<string, List<string>>.Enumerator enumerator = dic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                string key = enumerator.Current.Key;
                for (int i = 0, listCount = recoverDirs.Count; i < listCount; ++i)
                {
                    if (key.StartsWith(recoverDirs[i]))
                    {
                        List<string> listValue = enumerator.Current.Value;
                        if (listValue.Count > 0)
                        {
                            resDic.Add(key, listValue);
                        }
                        break;
                    }
                }
            }
            return resDic;
        }

        #endregion

        #endregion

        #region//引用关系

        /// <summary>
        /// 获得所有的引用关系 key:检测目标 value:引用列表
        /// </summary>
        /// <returns></returns>
        public static Dictionary<UnityEngine.Object, List<UnityEngine.Object>> GetAllDependencies()
        {
#if UNITY_EDITOR
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>> res = new Dictionary<UnityEngine.Object, List<UnityEngine.Object>>();
            UnityEditor.EditorUtility.ClearProgressBar();
            string dataPath = Application.dataPath + "/";
            List<string> suffixList = new List<string>();
            suffixList.Add("*.mat");
            suffixList.Add("*.prefab");
            suffixList.Add("*.shader");
            suffixList.Add("*.asset");
            List<string> allFiles = new List<string>();
            for (int i = 0, listCount = suffixList.Count; i < listCount; ++i)
            {
                allFiles.AddRange(Directory.GetFiles(dataPath, suffixList[i], SearchOption.AllDirectories));
            }
            for (int i = 0, listCount = allFiles.Count; i < listCount; ++i)
            {
                string assetPath = RenderTool.FilePathToAssetPath(allFiles[i]);
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("引用关系查询(" + i + "/" + listCount + ")", assetPath, i / (float)listCount);
                //查看其依赖资源
                UnityEngine.Object targetObj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                if (targetObj != null && assetObj != null)
                {
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        string aPath = UnityEditor.AssetDatabase.GetAssetPath(decyAssets[j]);
                        if (aPath != null && aPath.StartsWith("Assets/"))
                        {
                            List<UnityEngine.Object> list;
                            if (!res.TryGetValue(targetObj, out list))
                            {
                                list = new List<UnityEngine.Object>();
                                res.Add(targetObj, list);
                            }
                            list.Add(decyAssets[j]);
                        }
                    }
                }
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            Debug.LogError(res.Count);
            return res;
#else
            return null;
#endif
        }

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/所有")]
        /// <summary>
        /// 获得目标类型文件被引用关系 所有
        /// </summary>
        public static void BeAdoptedDependenciesInfo_All()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("xml");
            BeAdoptedDependenciesInfo("prefab");
            BeAdoptedDependenciesInfo("tga");
            BeAdoptedDependenciesInfo("jpg");
            BeAdoptedDependenciesInfo("png");
            BeAdoptedDependenciesInfo("fbx");
            BeAdoptedDependenciesInfo("cubemap");
            BeAdoptedDependenciesInfo("shader");
            BeAdoptedDependenciesInfo("mat");
            BeAdoptedDependenciesInfo("unity");
            BeAdoptedDependenciesInfo("asset");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.asset")]
        /// <summary>
        /// 获得目标类型文件被引用关系 asset
        /// </summary>
        public static void BeAdoptedDependenciesInfo_asset()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("asset");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.mat")]
        /// <summary>
        /// 获得目标类型文件被引用关系 mat
        /// </summary>
        public static void BeAdoptedDependenciesInfo_mat()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("mat");
            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.shader")]
        /// <summary>
        /// 获得目标类型文件被引用关系 shader
        /// </summary>
        public static void BeAdoptedDependenciesInfo_shader()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("shader");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.png")]
        /// <summary>
        /// 获得目标类型文件被引用关系 png
        /// </summary>
        public static void BeAdoptedDependenciesInfo_png()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("png");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.jpg")]
        /// <summary>
        /// 获得目标类型文件被引用关系 jpg
        /// </summary>
        public static void BeAdoptedDependenciesInfo_jpg()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("jpg");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.tga")]
        /// <summary>
        /// 获得目标类型文件被引用关系 tga
        /// </summary>
        public static void BeAdoptedDependenciesInfo_tga()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("tga");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.prefab")]
        /// <summary>
        /// 获得目标类型文件被引用关系 prefab
        /// </summary>
        public static void BeAdoptedDependenciesInfo_prefab()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("prefab");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

#if UNITY_EDITOR
        [UnityEditor.MenuItem("Tools/RenderTool/Asset/引用关系索引/.xml")]
        /// <summary>
        /// 获得目标类型文件被引用关系 xml
        /// </summary>
        public static void BeAdoptedDependenciesInfo_xml()
        {
            UnityEditor.EditorUtility.ClearProgressBar();

            BeAdoptedDependenciesInfo("xml");

            UnityEditor.EditorUtility.ClearProgressBar();
        }
#endif

        /// <summary>
        /// 获得目标类型文件的被引用关系
        /// 返回: key;文件名 key:md5 key:重复文件 value:引用了文件的物体列表
        /// </summary>
        /// <param name="suffix"></param>
        static Dictionary<string, Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>> BeAdoptedDependenciesInfo(string suffix)
        {
#if UNITY_EDITOR
            Dictionary<string, Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>> resDic = new Dictionary<string, Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>>();
            UnityEditor.EditorUtility.ClearProgressBar();
            //key;文件名 key:md5 value:相同的文件路径
            Dictionary<string, Dictionary<string, List<UnityEngine.Object>>> dic = DuplicationName_Suffix(suffix, true);
            //写出
            string savePath = GetSavePath(suffix, true, "-被引用关系");
            StringBuilder saveStringBuilder = new StringBuilder();
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>> allDependencies = GetAllDependencies();
            Dictionary<string, Dictionary<string, List<UnityEngine.Object>>>.Enumerator enumerator = dic.GetEnumerator();
            int index = 0;
            int allCount = dic.Count;
            while (enumerator.MoveNext())
            {
                Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>> resDic2 = new Dictionary<string, Dictionary<UnityEngine.Object, List<UnityEngine.Object>>>();
                resDic.Add(enumerator.Current.Key, resDic2);
                StringBuilder stringBuilder = new StringBuilder();
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("引用查询({0}/{1})", index, allCount), enumerator.Current.Key, index / (float)allCount);
                stringBuilder.Append(string.Format("文件名:{0}\n", enumerator.Current.Key));
                Dictionary<string, List<UnityEngine.Object>> dic2 = enumerator.Current.Value;
                Dictionary<string, List<UnityEngine.Object>>.Enumerator enumerator2 = dic2.GetEnumerator();
                while (enumerator2.MoveNext())
                {
                    Dictionary<UnityEngine.Object, List<UnityEngine.Object>> resDic3 = new Dictionary<UnityEngine.Object, List<UnityEngine.Object>>();
                    resDic2.Add(enumerator2.Current.Key, resDic3);
                    List<UnityEngine.Object> list = enumerator2.Current.Value;
                    stringBuilder.Append(string.Format("    MD5:{0}\n", enumerator2.Current.Key));
                    for (int i = 0, listCount = list.Count; i < listCount; ++i)
                    {
                        List<UnityEngine.Object> resDicList = new List<UnityEngine.Object>();
                        resDic3.Add(list[i], resDicList);
                        string assetPath = UnityEditor.AssetDatabase.GetAssetPath(list[i]);
                        stringBuilder.Append("        -->\n");
                        stringBuilder.Append(string.Format("        目标:{0}\n", assetPath));
                        List<UnityEngine.Object> resList = BeAdoptedDependenciesInfo(list[i], allDependencies);
                        for (int j = 0, listCount2 = resList.Count; j < listCount2; ++j)
                        {
                            resDicList.Add(resList[j]);
                            assetPath = UnityEditor.AssetDatabase.GetAssetPath(resList[j]);
                            stringBuilder.Append(string.Format("            引用者:{0}\n", assetPath));
                        }
                    }
                    stringBuilder.Append("\n");
                }
                saveStringBuilder.Append(stringBuilder.ToString());
                index++;
            }
            RenderTool.WriteTxt(savePath, saveStringBuilder.ToString());
            Debug.LogError("重复文件写出路径(被引用关系):" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
            return resDic;
#else
            return null;
#endif
        }

        /// <summary>
        /// 目标的被引用关系 返回引用了此目标的列表
        /// </summary>
        /// <param name="obj"></param>
        static List<UnityEngine.Object> BeAdoptedDependenciesInfo(UnityEngine.Object obj)
        {
            List<UnityEngine.Object> res = new List<UnityEngine.Object>();
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>> dic = GetAllDependencies();
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator = dic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                UnityEngine.Object key = enumerator.Current.Key;
                List<UnityEngine.Object> list = enumerator.Current.Value;
                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                {
                    if (list[i] == obj)
                    {
                        res.Add(key);
                        break;
                    }
                }
            }
            return res;
        }

        /// <summary>
        /// 目标的被引用关系 返回引用了此目标的列表
        /// </summary>
        /// <param name="obj"></param>
        static List<UnityEngine.Object> BeAdoptedDependenciesInfo(UnityEngine.Object obj, Dictionary<UnityEngine.Object, List<UnityEngine.Object>> dic)
        {
            List<UnityEngine.Object> res = new List<UnityEngine.Object>();
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator = dic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                UnityEngine.Object key = enumerator.Current.Key;
                if (key != obj)
                {
                    List<UnityEngine.Object> list = enumerator.Current.Value;
                    for (int i = 0, listCount = list.Count; i < listCount; ++i)
                    {
                        if (list[i] == obj)
                        {
                            res.Add(key);
                            break;
                        }
                    }
                }
            }
            return res;
        }

        #endregion

    }

}



