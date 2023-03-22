
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
    /// 此脚本用于检查文件的SVN错误
    /// </summary>
    public class RenderSvnTool
    {

#if UNITY_EDITOR

        static string WriteFolderName = "SvnErrData";

        /// <summary>
        /// 检查项目中的所有的SVN错误资源 写出到文件
        /// </summary>
        public static void InspectAllErrAssetObject()
        {
            StringBuilder stringBuilder = new StringBuilder();
            UnityEditor.EditorUtility.ClearProgressBar();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            int allount = allAssetPaths.Length;
            for (int i = 0; i < allount; ++i)
            {
                string assetPath = allAssetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("SVN错误检查(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
                if (InspectObjectSvnErr(assetPath))
                {
                    stringBuilder.Append(string.Format("SVN错误资源路径={0}\n", assetPath));
                }
            }
            //写出
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + "/所有的SVN错误资源记录.txt";
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("所有的SVN错误资源记录写出路径:" + savePath);
            stringBuilder.Clear();
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查项目中的SVN错误资源 写出到文件 Shader
        /// </summary>
        public static void InspectErrAssetObject_Shader()
        {
            InspectAllErrAssetObjectSuffix("shader");
        }

        /// <summary>
        /// 检查项目中的SVN错误资源 写出到文件 Material
        /// </summary>
        public static void InspectErrAssetObject_Material()
        {
            InspectAllErrAssetObjectSuffix("mat");
        }

        /// <summary>
        /// 检查项目中的SVN错误资源 写出到文件 Asset
        /// </summary>
        public static void InspectErrAssetObject_Asset()
        {
            InspectAllErrAssetObjectSuffix("asset");
        }

        /// <summary>
        /// 检查项目中的指定后缀的的SVN错误资源 写出到文件
        /// </summary>
        /// <param name="suffix"></param>
        static void InspectAllErrAssetObjectSuffix(string suffix)
        {
            suffix = "." + suffix.ToLower();
            StringBuilder stringBuilder = new StringBuilder();
            UnityEditor.EditorUtility.ClearProgressBar();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            int allount = allAssetPaths.Length;
            for (int i = 0; i < allount; ++i)
            {
                string assetPath = allAssetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("SVN错误检查(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
                if (assetPath.ToLower().EndsWith(suffix))
                {
                    if (InspectObjectSvnErr(assetPath))
                    {
                        stringBuilder.Append(string.Format("SVN错误资源路径={0}\n", assetPath));
                    }
                }
            }
            //写出
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/SVN错误资源记录({0}).txt", suffix);
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("SVN错误资源记录写出路径:" + savePath);
            stringBuilder.Clear();
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查资源是否有SVN错误
        /// </summary>
        /// <param name="assetPath"></param>
        /// <returns></returns>
        public static bool InspectObjectSvnErr(string assetPath)
        {
            string path = RenderTool.AssetPathToFilePath(assetPath);
            string txt = RenderTool.ReadTxt(path);
            if (txt != null && txt.Contains("<<<<<<< .mine"))
            {
                return true;
            }
            return false;
        }

        ///// <summary>
        ///// 检查项目中的错误资源
        ///// 返回错误资源路径
        ///// </summary>
        ///// <returns></returns>
        //public static List<string> InspectAllErrAssetObject()
        //{
        //    List<string> list = new List<string>();
        //    UnityEditor.EditorUtility.ClearProgressBar();
        //    string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
        //    int allount = allAssetPaths.Length;
        //    for (int i = 0; i < allount; ++i)
        //    {
        //        string assetPath = allAssetPaths[i];
        //        UnityEditor.EditorUtility.DisplayCancelableProgressBar("查询(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
        //        try
        //        {
        //            UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        //        }
        //        catch
        //        {
        //            list.Add(assetPath);
        //        }
        //    }
        //    UnityEditor.EditorUtility.ClearProgressBar();
        //    return list;
        //}

        /// <summary>
        /// 检查项目中的指定后缀的错误材质
        /// 返回错误错误材质路径
        /// </summary>
        /// <returns></returns>
        public static List<string> InspectAllErrAssetObject(string suffix)
        {
            suffix = suffix.ToLower().Trim();
            List<string> list = new List<string>();
            UnityEditor.EditorUtility.ClearProgressBar();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            int allount = allAssetPaths.Length;
            for (int i = 0; i < allount; ++i)
            {
                string assetPath = allAssetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("查询(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
                if (assetPath.ToLower().EndsWith(suffix))
                {
                    try
                    {
                        UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                    }
                    catch
                    {
                        list.Add(assetPath);
                    }
                }
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            return list;
        }

#endif
    }
}


