
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Text;

namespace Render
{
    /// <summary>
    /// 用于清空FBX文件的材质球，消除Unity的关联
    /// </summary>
    public class FbxModelDeleteMaterial
    {

#if UNITY_EDITOR

        [UnityEditor.MenuItem("Assets/RenderTool/模型/清空FBX的 unity shader 内建关联", false, -1)]
        static void ClearFBXBuildInMat()
        {
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                string path = UnityEditor.AssetDatabase.GetAssetPath(obj);
                if (path != null)
                {
                    path = path.ToLower();
                    if (path.StartsWith("assets/") && path.EndsWith(".fbx"))
                    {
                        FbxModelImporter(AssetPathToPath(path));
                    }
                }
            }
            UnityEditor.AssetDatabase.Refresh();
        }

        [UnityEditor.MenuItem("Assets/RenderTool/模型/清理所有默认材质", false, -1)]
        static void CelarAllMaByMeta()
        {

            string[] guids = UnityEditor.AssetDatabase.FindAssets("t:Model");
            int i = 0;
            foreach (string guid in guids)
            {

                string path = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
                UnityEditor.EditorUtility.DisplayProgressBar("清理默认材质...", path, (float)(i++) / guids.Length);
                string temp = path.ToLower();
                if (!temp.StartsWith("assets/art/"))
                {
                    continue;
                }


                if (temp.IndexOf(".fbx") < 0)
                {
                    continue;
                }

                string filePath = FbxModelDeleteMaterial.AssetPathToPath(path);
                FbxModelDeleteMaterial.FbxModelImporter(filePath);
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            UnityEditor.AssetDatabase.Refresh();
        }

        #region .fbx.meta 材质球清空

        public static void FbxModelImporter(UnityEditor.ModelImporter tmpImport)
        {
            return;
            //ZT_UnityEditor.DelayFunClass delayFunClass = new ZT_UnityEditor.DelayFunClass(() =>
            //{

            //    string assetPath = tmpImport.assetPath;
            //    string filePath = AssetPathToPath(assetPath);
            //    FbxModelImporter(filePath);
            //}, null, null, 0.1f);
            //delayFunClass.Run();


            //string assetPath = tmpImport.assetPath;
            //string filePath = AssetPathToPath(assetPath);
            //FbxModelImporter(filePath);
        }

        public static void FbxModelImporter(string filePath)
        {
            string metaFilePath = filePath + ".meta";
            List<string> matNames = GetAllFbxMatNames(filePath);
            if (matNames == null || matNames.Count == 0)
            {
                //Debug.LogError(string.Format("fbx中未发现材质球! 路径:{0}", filePath));
                return;
            }
            FbxMetaData fbxMetaData = new FbxMetaData(metaFilePath);
            bool needChange = fbxMetaData.NeedWrite;

            for (int i = 0, listCount = fbxMetaData.ExternalObjects.Count; i < listCount; ++i)
            {
                FbxMetaData.ExternalObject externalObject = fbxMetaData.ExternalObjects[i];
                if (externalObject.IsMat)
                {
                    fbxMetaData.ExternalObjects.Remove(externalObject);
                    i--;
                    listCount--;
                }
            }
            for (int i = 0, listCount = matNames.Count; i < listCount; ++i)
            {
                FbxMetaData.ExternalObject newMatData = new FbxMetaData.ExternalObject();
                fbxMetaData.ExternalObjects.Add(newMatData);
                //
                FbxMetaData.ExternalObjectElement firstData = new FbxMetaData.ExternalObjectElement();
                firstData.Key = "  - first:";
                firstData.Value = "";
                newMatData.Elements.Add(firstData);
                //
                FbxMetaData.ExternalObjectElement typeData = new FbxMetaData.ExternalObjectElement();
                typeData.Key = "      type:";
                typeData.Value = "UnityEngine:Material";
                newMatData.Elements.Add(typeData);
                //
                FbxMetaData.ExternalObjectElement assemblyData = new FbxMetaData.ExternalObjectElement();
                assemblyData.Key = "      assembly:";
                assemblyData.Value = "UnityEngine.CoreModule";
                newMatData.Elements.Add(assemblyData);
                //
                FbxMetaData.ExternalObjectElement nameData = new FbxMetaData.ExternalObjectElement();
                nameData.Key = "      name:";
                nameData.Value = matNames[i];
                nameData.IsMatName = true;
                newMatData.Elements.Add(nameData);
                //
                FbxMetaData.ExternalObjectElement secondData = new FbxMetaData.ExternalObjectElement();
                secondData.Key = "  - first:";
                secondData.Value = "";
                secondData.IsMatSecond = true;
                newMatData.Elements.Add(secondData);


            }
            //重新存储FBX meta 文件
            // WriteTxt(metaFilePath, fbxMetaData.ToStr());
            //awen 修改
            if (needChange)
            {
                WriteTxt(metaFilePath, fbxMetaData.ToStr());
            }
        }

        #region .fbx.meta 文件解析


        /// <summary>
        /// assetPath到文件路径
        /// </summary>
        /// <param name="assetPath"></param>
        /// <returns></returns>
        public static string AssetPathToPath(string assetPath)
        {
            string path = Application.dataPath;
            int index = path.LastIndexOf("/");
            path = path.Substring(0, index + 1) + assetPath;
            return path;
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

        public class FbxMetaData
        {
            public FbxMetaData(string path)
            {
                Path = path;
                Apply(ReadTxt(Path));
            }

            public string Path;

            public System.Text.StringBuilder UpData = new System.Text.StringBuilder();

            public List<ExternalObject> ExternalObjects = new List<ExternalObject>();
            public bool NeedWrite = false;

            public System.Text.StringBuilder DownData = new System.Text.StringBuilder();

            public void Apply(string str)
            {
                ExternalObjects.Clear();
                bool findExternalObjects = false;
                bool endExternalObjects = false;
                string[] strs = str.Split('\n');
                int lineOffset = 0;
                int count = strs.Length;
                NeedWrite = false;
                while (lineOffset < count)
                {
                    str = strs[lineOffset];
                    if (str.StartsWith("  externalObjects: {}"))
                    {
                        findExternalObjects = true;
                        endExternalObjects = true;
                        NeedWrite = true;
                        lineOffset++;
                    }
                    else
                    {
                        if (findExternalObjects)
                        {
                            if (endExternalObjects)
                            {
                                lineOffset++;
                                if (lineOffset == count)
                                {
                                    DownData.Append(string.Format("{0}", str));
                                }
                                else
                                {
                                    //if (str.StartsWith("    materialImportMode:"))
                                    //{
                                    //    str = "    materialImportMode: 0";
                                    //}
                                    DownData.Append(string.Format("{0}\n", str));
                                }
                            }
                            else
                            {
                                if (str.StartsWith("  - first:"))
                                {
                                    ExternalObject newData = new ExternalObject();
                                    newData.Apply(strs, ref lineOffset);
                                    ExternalObjects.Add(newData);
                                }
                                else
                                {
                                    endExternalObjects = true;
                                    lineOffset++;
                                    //if (str.StartsWith("    materialImportMode:"))
                                    //{
                                    //    str = "    materialImportMode: 0";
                                    //}
                                    DownData.Append(string.Format("{0}\n", str));
                                }
                            }
                        }
                        else
                        {
                            if (str.StartsWith("  externalObjects:"))
                            {
                                findExternalObjects = true;
                            }
                            else
                            {
                                UpData.Append(string.Format("{0}\n", str));
                            }
                            lineOffset++;
                        }
                    }

                }
            }

            public string ToStr()
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.Append(string.Format("{0}", UpData));
                if (ExternalObjects.Count == 0)
                {
                    sb.Append(string.Format("{0}\n", "  externalObjects: {}"));
                }
                else
                {
                    sb.Append(string.Format("{0}\n", "  externalObjects:"));
                    for (int i = 0, listCount = ExternalObjects.Count; i < listCount; ++i)
                    {
                        sb.Append(string.Format("{0}", ExternalObjects[i].ToStr()));
                    }
                }
                sb.Append(string.Format("{0}", DownData));
                return sb.ToString();
            }


            public class ExternalObject
            {
                public bool IsMat = false;

                public List<ExternalObjectElement> Elements = new List<ExternalObjectElement>();

                public void Apply(string[] strs, ref int lineOffset)
                {
                    Elements.Clear();
                    while (true)
                    {
                        if (lineOffset >= strs.Length)
                        {
                            break;
                        }
                        string str = strs[lineOffset];
                        ExternalObjectElement elementData = new ExternalObjectElement();
                        elementData.Apply(str, IsMat);
                        if (elementData.Key.CompareTo("      type:") == 0 && elementData.Value.CompareTo("UnityEngine:Material") == 0)
                        {
                            IsMat = true;
                        }
                        Elements.Add(elementData);
                        lineOffset++;
                        if (str.StartsWith("    second:"))
                        {
                            break;
                        }
                    }
                }

                public System.Text.StringBuilder ToStr()
                {
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    for (int i = 0, listCount = Elements.Count; i < listCount; ++i)
                    {
                        sb.Append(Elements[i].ToStr());
                    }
                    return sb;
                }
            }

            public class ExternalObjectElement
            {
                public bool IsMatSecond = false;

                public bool IsMatName = false;

                public string fileID = "2100000";

                public string guid = "12345678123456781234567812345678";

                public string type = "2";

                public string Key;

                public string Value;

                public void Apply(string str, bool isMat)
                {
                    Key = str.Split(':')[0] + ":";
                    Value = str.Replace(Key, "").Trim();
                    if (isMat)
                    {
                        if (Key.CompareTo("    second:") == 0)
                        {
                            IsMatSecond = true;
                        }
                        else if (Key.CompareTo("      name:") == 0)
                        {
                            IsMatName = true;
                        }
                    }
                    if (IsMatSecond)
                    {
                        string[] strs = Value.Replace("{", "").Replace("}", "").Split(',');
                        for (int i = 0, listCount = strs.Length; i < listCount; ++i)
                        {
                            str = strs[i].Trim();
                            if (str.StartsWith("fileID:"))
                            {
                                string[] strs2 = str.Split(':');
                                fileID = strs2[1].Trim();
                            }
                            if (str.StartsWith("guid:"))
                            {
                                string[] strs2 = str.Split(':');
                                guid = strs2[1].Trim();
                                if (string.IsNullOrEmpty(guid))
                                {
                                    guid = "12345678123456781234567812345678";
                                }
                            }
                            if (str.StartsWith("type:"))
                            {
                                string[] strs2 = str.Split(':');
                                type = strs2[1].Trim();
                                if (string.IsNullOrEmpty(type))
                                {
                                    type = "2";
                                }
                            }
                        }
                    }
                }

                public string ToStr()
                {
                    if (IsMatSecond)
                    {
                        System.Text.StringBuilder sb = new System.Text.StringBuilder();
                        sb.Append(Key);
                        sb.Append(" {");
                        sb.Append(string.Format("fileID: {0}, guid: {1}, type: {2}", fileID, guid, type));
                        sb.Append("}\n");
                        return sb.ToString();
                    }
                    else
                    {
                        return string.Format("{0} {1}\n", Key, Value);
                    }
                }
            }
        }

        #endregion

        #region .fbx材质球解析

        /// <summary>
        /// 获得Fbx中所有的材质球名称 二进制文件
        /// </summary>
        /// <returns></returns>
        public static List<string> GetAllFbxMatNames(string fbxFilePath)
        {
            byte[] zipdata = System.IO.File.ReadAllBytes(fbxFilePath);
            if (zipdata[0] != 75)
            {
                return GetAllFbxMatNames_TXT(fbxFilePath);
            }
            List<string> listRes = new List<string>();
            for (int offset = 0, listCount = zipdata.Length; offset < listCount;)
            {
                if (zipdata[offset] == MaterialL_Bytes[0] && zipdata[offset - 1] == 8)
                {
                    bool isSame = true;
                    for (int i = 0; i < MaterialL_Bytes.Length; ++i)
                    {
                        if (MaterialL_Bytes[i] != zipdata[offset + i])
                        {
                            isSame = false;
                            break;
                        }
                    }
                    if (isSame)
                    {
                        offset = offset + MaterialL_Bytes.Length + 13;
                        List<byte> nameList = new List<byte>();
                        int index = offset;
                        while (true)
                        {
                            if (zipdata[index] == 0 && zipdata[index + 1] == 1)
                            {
                                bool isSame2 = true;
                                for (int i = 0; i < MaterialS_Bytes.Length; ++i)
                                {
                                    if (MaterialS_Bytes[i] != zipdata[index + 2 + i])
                                    {
                                        isSame2 = false;
                                        break;
                                    }
                                }
                                if (isSame2)
                                {
                                    index = index + MaterialS_Bytes.Length + 2;
                                    offset = index;
                                    byte[] bs = nameList.ToArray();
                                    string matName = GetBytesStr(bs, 0, bs.Length);
                                    if (!listRes.Contains(matName))
                                    {
                                        listRes.Add(GetBytesStr(bs, 0, bs.Length));
                                    }
                                    break;
                                }
                                else
                                {
                                    nameList.Add(zipdata[index]);
                                    index++;
                                }
                            }
                            else
                            {
                                nameList.Add(zipdata[index]);
                                index++;
                            }
                        }
                    }
                    else
                    {
                        offset = offset + 1;
                    }
                }
                else
                {
                    offset = offset + 1;
                }
            }
            return listRes;
        }

        static int Asc(string character)
        {
            if (character.Length == 1)
            {
                System.Text.ASCIIEncoding asciiEncoding = new System.Text.ASCIIEncoding();
                int intAsciiCode = (int)asciiEncoding.GetBytes(character)[0];
                return (intAsciiCode);
            }
            else
            {
                throw new Exception("Character is not valid.");
            }
        }

        /// <summary>
        /// 获得Fbx中所有的材质球名称 文本
        /// </summary>
        /// <returns></returns>
        static List<string> GetAllFbxMatNames_TXT(string fbxFilePath)
        {
            List<string> listRes = new List<string>();
            string str = ReadTxt(fbxFilePath);
            string[] strs = str.Split('\n');
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                str = strs[i];
                if (str.Contains("\"Material::"))
                {
                    string[] strs2 = str.Split(',');
                    for (int j = 0, listCount2 = strs2.Length; j < listCount2; ++j)
                    {
                        str = strs2[j].Trim();
                        if (str.Contains("\"Material::"))
                        {
                            str = str.Replace("\"Material::", "").Replace("\"", "");
                            listRes.Add(str);
                            break;
                        }
                    }
                }
            }
            return listRes;
        }

        /// <summary>
        /// 获得bytes中的字符串
        /// </summary>
        /// <param name="bytes"></param>
        /// <param name="offset"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        static string GetBytesStr(byte[] bytes, int offset, int size)
        {
            //System.Text.Encoding gb2312;
            //gb2312 = System.Text.Encoding.GetEncoding("gb2312");
            //return gb2312.GetString(bytes, offset, size);

            return System.Text.Encoding.UTF8.GetString(bytes, offset, size);
        }


        static byte[] materialL_Bytes;

        static byte[] MaterialL_Bytes
        {
            get
            {
                if (materialL_Bytes == null)
                {
                    materialL_Bytes = new byte[9];
                    materialL_Bytes[0] = 77;
                    materialL_Bytes[1] = 97;
                    materialL_Bytes[2] = 116;
                    materialL_Bytes[3] = 101;
                    materialL_Bytes[4] = 114;
                    materialL_Bytes[5] = 105;
                    materialL_Bytes[6] = 97;
                    materialL_Bytes[7] = 108;
                    materialL_Bytes[8] = 76;
                }
                return materialL_Bytes;
            }
        }

        static byte[] materialS_Bytes;

        static byte[] MaterialS_Bytes
        {
            get
            {
                if (materialS_Bytes == null)
                {
                    materialS_Bytes = new byte[9];
                    materialS_Bytes[0] = 77;
                    materialS_Bytes[1] = 97;
                    materialS_Bytes[2] = 116;
                    materialS_Bytes[3] = 101;
                    materialS_Bytes[4] = 114;
                    materialS_Bytes[5] = 105;
                    materialS_Bytes[6] = 97;
                    materialS_Bytes[7] = 108;
                    materialS_Bytes[8] = 83;
                }
                return materialS_Bytes;
            }
        }

        #endregion

        #endregion

#endif

    }
}


