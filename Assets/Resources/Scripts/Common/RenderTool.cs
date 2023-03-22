using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Text;
using UnityEngine.Rendering.Universal;
using System.Threading.Tasks;

namespace Render
{
    public class RenderTool
    {

        /// <summary>
        /// 场景相机
        /// </summary>
        public static Camera EditorSceneViewCamera
        {
            get
            {
#if UNITY_EDITOR
                return UnityEditor.SceneView.lastActiveSceneView.camera;
#else

                return null;
#endif
            }
        }

        /// <summary>
        /// 场景相机URP数据
        /// </summary>
        public static UniversalAdditionalCameraData EditorSceneViewCameraURPData
        {
            get
            {
                return EditorSceneViewCamera.GetUniversalAdditionalCameraData();
            }
        }

        /// <summary>
        /// 文件写出目录
        /// </summary>
        public static string WriteFolderDir
        {
            get
            {
                return Application.dataPath + "/../Caches/EditorDebug/";
            }
        }

        /// <summary>
        /// 延迟执行
        /// </summary>
        /// <param name="action"></param>
        /// <param name="actionObjs"></param>
        /// <param name="objs"></param>
        /// <param name="delay"></param>
        public static void DelayAction(Action action, Action<object[]> actionObjs, object[] objs, double delay)
        {
            Render.DelayFunHelper delayFunHelper = new Render.DelayFunHelper(action, actionObjs, objs, delay);
            delayFunHelper.Run();
        }

        /// <summary>
        /// 创建目录
        /// </summary>
        /// <param name="path"></param>
        public static void CreateDir(string path)
        {
            string dir = Path.GetDirectoryName(path);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
        }

        /// <summary>
        /// 字符串的MD5
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static string CreateStringMD5(string input)
        {
            if (string.IsNullOrEmpty(input)) return "";
            using (System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create())
            {
                byte[] inputBytes = System.Text.Encoding.ASCII.GetBytes(input);
                byte[] hashBytes = md5.ComputeHash(inputBytes);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("X2"));
                }
                return sb.ToString();
            }
        }

        /// <summary>
        /// 存储byte数组
        /// </summary>
        /// <param name="path"></param>
        /// <param name="bytes"></param>
        public static void SaveByte(string path, byte[] bytes)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            else
            {
                string dir = Path.GetDirectoryName(path);
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }
            }
            FileStream filestr = File.Create(path);
            filestr.Write(bytes, 0, bytes.Length);
            filestr.Close();
        }

        /// <summary>
        /// 读取byte数组 在读取移动StreamingAssets文件夹的时候会读取失败
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static byte[] ReadByte(string path)
        {
            if (!File.Exists(path))
            {
                return null;
            }
            using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
            {
                byte[] byteArray = new byte[fs.Length];
                fs.Read(byteArray, 0, byteArray.Length);
                fs.Close();
                return byteArray;
            }
        }

        /// <summary>
        /// 将文件pathA拷贝到pathB
        /// </summary>
        /// <param name="pathA"></param>
        /// <param name="pathB"></param>
        /// <param name="errList">错误列表</param>
        /// <param name="thread"></param>
        public static void CopyTo(string pathA, string pathB)
        {
            if (File.Exists(pathA))
            {
                string dir = Path.GetDirectoryName(pathB);
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }
                File.Copy(pathA, pathB);
            }
        }

        /// <summary>
        /// 删除指定路径的文件
        /// </summary>
        /// <param name="path"></param>
        public static void DeletFile(string path)
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }

        /// <summary>
        /// 指定文件的md5
        /// </summary>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public static string CreateFileMD5(string filePath)
        {
            return CreateStringMD5(ReadTxt(filePath));
        }

        static char[] charIAr = new char[] { '/', '\\' };

        static char[] CharIAr
        {
            get
            {
                if (charIAr == null)
                {
                    charIAr = new char[] { '/', '\\' };
                }
                return charIAr;
            }
        }

        /// <summary>
        /// 写文件
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="txt"></param>
        public static void WriteTxt(string filePath, string txt)
        {
            string dir = Path.GetDirectoryName(filePath);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }
            StreamWriter sw = new StreamWriter(filePath, true);
            sw.Write(txt);
            sw.Close();
        }

        /// <summary>
        /// 读文件
        /// </summary>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public static string ReadTxt(string filePath)
        {
            if (File.Exists(filePath))
            {
                return File.ReadAllText(filePath);
            }
            return null;
        }

        /// <summary>
        /// assetPath到文件路径
        /// </summary>
        /// <param name="assetPath"></param>
        /// <returns></returns>
        public static string AssetPathToFilePath(string assetPath)
        {
            int index = Application.dataPath.LastIndexOf('/');
            string path = Application.dataPath.Substring(0, index + 1) + assetPath;
            return path;
        }

        /// <summary>
        /// 路径转换为assetPath
        /// </summary>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public static string FilePathToAssetPath(string filePath)
        {
            filePath = filePath.Replace('\\', '/');
            filePath = filePath.Replace(Application.dataPath, "Assets");
            return filePath;
        }

        /// <summary>
        /// 获得后缀名 没有'.'  如: "Abc/file.txt" -> "txt"
        /// </summary>
        /// <param name="pathOrName"></param>
        /// <returns></returns>
        public static string GetSuffix(string pathOrName)
        {
            int endIndex = pathOrName.LastIndexOf('.');
            string endStr = pathOrName.Substring(endIndex + 1, pathOrName.Length - endIndex - 1);
            return endStr;
        }

        /// <summary>
        /// 获得去掉后缀的路径 如: "Abc/file.txt" -> "Abc/file"
        /// </summary>
        /// <param name="pathOrName"></param>
        /// <returns></returns>
        public static string DeleteSuffix(string pathOrName)
        {
            int start = pathOrName.LastIndexOfAny(CharIAr);
            int endIndex = pathOrName.LastIndexOf('.');
            if (endIndex > start)
            {
                return pathOrName.Substring(0, endIndex);
            }
            return pathOrName;
        }

        /// <summary>
        /// 文件名 去掉后缀 如: "Abc/file.txt" -> "file"
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static string GetNameDeleteSuffix(string pathOrName)
        {
            int start = pathOrName.LastIndexOfAny(CharIAr);
            int end = pathOrName.LastIndexOf('.');
            if (start >= 0)
            {
                if (end >= 0 && end > start)
                {
                    return pathOrName.Substring(start + 1, end - start - 1);
                }
                else
                {
                    return pathOrName.Substring(start + 1);
                }
            }
            else
            {
                return pathOrName;
            }
        }

        /// <summary>
        /// 设置刷新
        /// </summary>
        /// <param name="obj"></param>
        public static void SetDirty(UnityEngine.Object obj)
        {
#if UNITY_EDITOR
            UnityEditor.SerializedObject so = new UnityEditor.SerializedObject(obj);
            UnityEditor.EditorUtility.SetDirty(so.targetObject);
#endif
        }

    }

    /// <summary>
    /// 延迟执行
    /// </summary>
    public class DelayFunHelper
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="action"></param>
        /// <param name="actionObjs"></param>
        /// <param name="objs"></param>
        /// <param name="delay">秒</param>
        public DelayFunHelper(Action action, Action<object[]> actionObjs, object[] objs, double delay)
        {
            Action = action;
            ActionObjs = actionObjs;
            Objs = objs;
            Delay = delay;
        }

        /// <summary>
        /// 需要执行的逻辑
        /// </summary>
        public Action Action;

        /// <summary>
        /// 需要执行的逻辑
        /// </summary>
        public Action<object[]> ActionObjs;

        /// <summary>
        /// 需要执行的逻辑参数
        /// </summary>
        public object[] Objs;

        /// <summary>
        /// 延迟执行时间
        /// </summary>
        public double Delay = 0.1f;

        /// <summary>
        /// 执行方法
        /// </summary>
        public void Run()
        {
            System.Func<Task> func = async () =>
            {
                await Task.Delay(System.TimeSpan.FromSeconds(Delay));
                if (Action != null)
                {
                    Action();
                }
                if (ActionObjs != null)
                {
                    ActionObjs(Objs);
                }
            };
            func();
        }
    }
}

