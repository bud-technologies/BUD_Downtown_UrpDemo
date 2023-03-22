using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System;
using System.Reflection;
using System.Linq;
using System.Text;

namespace Render
{
    public class RenderTextTool
    {
#if UNITY_EDITOR

        static string WriteFolderName = "FileEditorData";

        public static void CheckAllFileContStr_WangZhe()
        {
            CheckAllFileContStr("abc");
        }

        /// <summary>
        /// 检查所有包含了字符串的文件
        /// </summary>
        /// <param name="str"></param>
        static void CheckAllFileContStr(string str)
        {
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> resList = new List<string>();
            string dir = RenderTool.FilePathToAssetPath(Application.dataPath);
            string[] allFiles = Directory.GetFiles(dir, "*.*", SearchOption.AllDirectories);
            for (int i = 0, listCount = allFiles.Length; i < listCount; ++i)
            {
                string filePath = allFiles[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), filePath, i / (float)listCount);
                string tex = RenderTool.ReadTxt(filePath);
                if (filePath.Contains(str) || (tex != null && tex.Contains(str)))
                {
                    resList.Add(RenderTool.FilePathToAssetPath(filePath));
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = resList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("路径:{0}\n", resList[i]));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些文件包含了字符串({0}).txt", str);
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError(string.Format("/哪些文件包含了字符串({0}):", str) + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

#endif
    }
}

