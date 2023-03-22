
using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System;
using System.Reflection;
using System.Linq;
using System.Text;

namespace Render
{
    public class RenderMatFun
    {
#if UNITY_EDITOR

        static void vvv()
        {
            //texListXX.Clear();
            //texListXX.Add("_MainTex");
            //texListXX.Add("_MaskTex");
            //texListXX.Add("_DistortTex");
            //texListXX.Add("_DissolveTex");
            //CheckAllMatUseShader("Xmoba/Effects/Fx_U_MaskDistort");
            //CheckAllMatUseShader("Xmoba/Effects/Fx_CustomDataUV");


            //StringBuilder sb = new StringBuilder();
            //string[] strs = Directory.GetFiles("E:/SGameNew12/Assets/Art/","*.fbx", SearchOption.AllDirectories);
            //for (int i=0,listCount= strs.Length;i< listCount;++i)
            //{
            //    sb.Append(string.Format("{0}\n",TACommon.PathToAssetPath(strs[i])));
            //}
            //strs = Directory.GetFiles("E:/SGameNew12/Assets/Art/", "*.obj", SearchOption.AllDirectories);
            //for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            //{
            //    sb.Append(string.Format("{0}\n", TACommon.PathToAssetPath(strs[i])));
            //}
            //strs = Directory.GetFiles("E:/SGameNew12/Assets/Art/", "*.max", SearchOption.AllDirectories);
            //for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            //{
            //    sb.Append(string.Format("{0}\n", TACommon.PathToAssetPath(strs[i])));
            //}
            //TACommon.WriteTxt("E:/SGameNew12/Assets/Art/xxx.txt", sb.ToString());
        }


        static List<string> texListXX = new List<string>();

        /// <summary>
        /// 清除目标材质的无效数据
        /// </summary>
        /// <param name="assetPath"></param>
        public static void ClearTargetMatUnuseSaveData(string assetPath)
        {
            Material mat =UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
            if (mat != null)
            {
                MatSavedPropertieData data = new MatSavedPropertieData();
                data.ReadMat(assetPath);
                data.ClearSavedProperties();
                StringBuilder stringBuilder = data.GetStr();
                string savePath = RenderTool.AssetPathToFilePath(assetPath);
                RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            }
        }

        static string WriteFolderName = "MatEditorData";

        /// <summary>
        /// 检查所有的材质球 找出所有的有无用数据的材质球
        /// 包含无用数据类型 纹理 浮点数 颜色
        /// </summary>
        public static void CheckAllMatSavedPropertieData()
        {
            List<Material> matList = new List<Material>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                if (mat != null && CheckMatSavedPropertieData(assetPath))
                {
                    matList.Add(mat);
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = matList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("材质球:{0} 路径:{1}\n", matList[i], UnityEditor.AssetDatabase.GetAssetPath(matList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些材质球存在无用的数据.txt");
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些材质球存在无用的数据写出路径:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查所有的使用了指定Shader的材质球
        /// </summary>
        public static void CheckAllMatUseShader(string shaderName)
        {
            Dictionary<Material, MatUseShaderData> matDic = new Dictionary<Material, MatUseShaderData>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];//M_j_ZhaDanMei_show_003 1
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                if (mat != null && mat.shader != null && mat.shader.name.CompareTo(shaderName) == 0)
                {
                    MatSavedPropertieData matSavedPropertieData = new MatSavedPropertieData();
                    matSavedPropertieData.ReadMat(assetPath);
                    MatUseShaderData matUseShaderData = new MatUseShaderData(mat, matSavedPropertieData);
                    matDic.Add(mat, matUseShaderData);
                    for (int j = 0, listCount2 = texListXX.Count; j < listCount2; ++j)
                    {
                        string texName = texListXX[j];
                        for (int z = 0, listCount3 = matSavedPropertieData.TextureList.Count; z < listCount3; ++z)
                        {
                            TexEnvs texEnvs = matSavedPropertieData.TextureList[z];
                            if (texEnvs.PropertieName.CompareTo(texName) == 0)
                            {
                                string newName = texName + "_TilingOffset";
                                bool findSame = false;
                                for (int k = 0, listCount6 = matSavedPropertieData.ColorList.Count; k < listCount6; ++k)
                                {
                                    if (matSavedPropertieData.ColorList[k].PropertieName.CompareTo(newName) == 0)
                                    {
                                        findSame = true;
                                        break;
                                    }
                                }
                                if (!findSame)
                                {
                                    Colors colors = new Colors();
                                    colors.ColorVlue = new Color(texEnvs.Scale.x, texEnvs.Scale.y, texEnvs.Offset.x, texEnvs.Offset.y);
                                    colors.PropertieName = newName;
                                    matSavedPropertieData.ColorList.Add(colors);
                                }
                                break;
                            }
                        }
                    }
                    StringBuilder stringBuilder2 = matSavedPropertieData.GetStr();
                    string savePath2 = RenderTool.AssetPathToFilePath(assetPath);
                    RenderTool.WriteTxt(savePath2, stringBuilder2.ToString());
                    //if (matUseShaderData.Textures.Count>0)
                    //{
                    //    Dictionary<string, Texture2D>.Enumerator enumerator2 = matUseShaderData.Textures.GetEnumerator();
                    //    while (enumerator2.MoveNext())
                    //    {
                    //        string textureProName = enumerator2.Current.Key;
                    //        Texture2D texture2D = enumerator2.Current.Value;
                    //        if (texture2D.wrapMode == TextureWrapMode.Clamp)
                    //        {
                    //            if (textureProName.CompareTo("_MainTex") ==0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_MainTexClamp", 0);
                    //                matSavedPropertieData.AddOneFloat("_MainTexRepeatU", 0);
                    //                matSavedPropertieData.AddOneFloat("_MainTexRepeatV", 0);
                    //            }
                    //            if (textureProName.CompareTo("_MaskTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_MaskTexClamp", 0);
                    //                matSavedPropertieData.AddOneFloat("_MaskTexRepeatU", 0);
                    //                matSavedPropertieData.AddOneFloat("_MaskTexRepeatV", 0);
                    //            }
                    //            if (textureProName.CompareTo("_DistortTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DistortTexClamp", 0);
                    //                matSavedPropertieData.AddOneFloat("_DistortTexRepeatU", 0);
                    //                matSavedPropertieData.AddOneFloat("_DistortTexRepeatV", 0);
                    //            }
                    //            if (textureProName.CompareTo("_DissolveTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexClamp", 0);
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexRepeatU", 0);
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexRepeatV", 0);
                    //            }
                    //            if (textureProName.CompareTo("_Disstex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DissTexClamp", 0);
                    //                matSavedPropertieData.AddOneFloat("_DissTexRepeatU", 0);
                    //                matSavedPropertieData.AddOneFloat("_DissTexRepeatV", 0);
                    //            }
                    //        }
                    //        else
                    //        {
                    //            if (textureProName.CompareTo("_MainTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_MainTexClamp", 1);
                    //                matSavedPropertieData.AddOneFloat("_MainTexRepeatU", 1);
                    //                matSavedPropertieData.AddOneFloat("_MainTexRepeatV", 1);
                    //            }
                    //            if (textureProName.CompareTo("_MaskTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_MaskTexClamp", 1);
                    //                matSavedPropertieData.AddOneFloat("_MaskTexRepeatU", 1);
                    //                matSavedPropertieData.AddOneFloat("_MaskTexRepeatV", 1);
                    //            }
                    //            if (textureProName.CompareTo("_DistortTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DistortTexClamp", 1);
                    //                matSavedPropertieData.AddOneFloat("_DistortTexRepeatU", 1);
                    //                matSavedPropertieData.AddOneFloat("_DistortTexRepeatV", 1);
                    //            }
                    //            if (textureProName.CompareTo("_DissolveTex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexClamp", 1);
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexRepeatU", 1);
                    //                matSavedPropertieData.AddOneFloat("_DissolveTexRepeatV", 1);
                    //            }
                    //            if (textureProName.CompareTo("_Disstex") == 0)
                    //            {
                    //                matSavedPropertieData.AddOneFloat("_DissTexClamp", 1);
                    //                matSavedPropertieData.AddOneFloat("_DissTexRepeatU", 1);
                    //                matSavedPropertieData.AddOneFloat("_DissTexRepeatV", 1);
                    //            }
                    //        }
                    //        StringBuilder stringBuilder2 = matSavedPropertieData.GetStr();
                    //        string savePath2 = TACommon.AssetPathToPath(assetPath);
                    //        TACommon.WriteTxt(savePath2, stringBuilder2.ToString());
                    //    }
                    //}

                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            Dictionary<Material, MatUseShaderData>.Enumerator enumerator = matDic.GetEnumerator();
            while (enumerator.MoveNext())
            {
                MatUseShaderData matUseShaderData = enumerator.Current.Value;
                if (matUseShaderData.Textures.Count > 0)
                {
                    stringBuilder.Append(string.Format("材质球:{0} 路径:{1}\n", matUseShaderData.Mat.name, UnityEditor.AssetDatabase.GetAssetPath(matUseShaderData.Mat)));
                    Dictionary<string, Texture2D>.Enumerator enumerator2 = matUseShaderData.Textures.GetEnumerator();
                    while (enumerator2.MoveNext())
                    {
                        stringBuilder.Append(string.Format("        属性名:{0} WrapMode:{1} 路径:{2}\n", enumerator2.Current.Key, enumerator2.Current.Value.wrapMode.ToString(), UnityEditor.AssetDatabase.GetAssetPath(enumerator2.Current.Value)));
                    }
                }
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/使用了Shader {0} 的材质数据.txt", shaderName.Replace("/", "_"));
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("使用了指定Shader的材质数据:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
            UnityEditor.AssetDatabase.Refresh();
        }

        class MatUseShaderData
        {

            public MatUseShaderData(Material mat, MatSavedPropertieData matData)
            {
                Mat = mat;
                MatData = matData;
                List<TexEnvs> textureList = matData.TextureList;
                for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
                {
                    TexEnvs texEnvs = textureList[i];
                    if (!string.IsNullOrEmpty(texEnvs.guid))
                    {
                        string assetPath = UnityEditor.AssetDatabase.GUIDToAssetPath(texEnvs.guid);
                        if (!string.IsNullOrEmpty(assetPath))
                        {
                            Texture2D tex = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
                            if (tex != null)
                            {
                                Textures.Add(texEnvs.PropertieName, tex);
                            }
                        }
                    }
                }
            }

            /// <summary>
            /// 目标材质
            /// </summary>
            public Material Mat;

            /// <summary>
            /// 存储的数据
            /// </summary>
            public MatSavedPropertieData MatData;

            /// <summary>
            /// 纹理属性类型 key:纹理属性名 value:
            /// </summary>
            public Dictionary<string, Texture2D> Textures = new Dictionary<string, Texture2D>();
        }

        /// <summary>
        /// 检查所有的材质球 找出所有的有无用数据的材质球
        /// 包含数据类型 无效纹理
        /// </summary>
        public static void CheckAllMatSavedPropertieData_Texture()
        {
            CheckAllMatSavedPropertieData(MatSavedPropertieBase.PropertieType.Texture);
        }

        /// <summary>
        /// 检查所有的材质球 找出所有的有无用数据的材质球
        /// 包含数据类型 无效Float
        /// </summary>
        public static void CheckAllMatSavedPropertieData_Float()
        {
            CheckAllMatSavedPropertieData(MatSavedPropertieBase.PropertieType.Float);
        }

        /// <summary>
        /// 检查所有的材质球 找出所有的有无用数据的材质球
        /// 包含数据类型 无效Color
        /// </summary>
        public static void CheckAllMatSavedPropertieData_Color()
        {
            CheckAllMatSavedPropertieData(MatSavedPropertieBase.PropertieType.Color);
        }

        /// <summary>
        /// 检查所有的材质球 找出所有的有无用数据的材质球
        /// 包含数据类型 MatSavedPropertieBase.PropertieType
        /// </summary>
        static void CheckAllMatSavedPropertieData(MatSavedPropertieBase.PropertieType propertieType)
        {
            List<Material> matList = new List<Material>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                if (mat != null && CheckMatSavedPropertieData(assetPath, propertieType))
                {
                    matList.Add(mat);
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = matList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("材质球:{0} 路径:{1}\n", matList[i], UnityEditor.AssetDatabase.GetAssetPath(matList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些材质球存在无用的数据{0}.txt", propertieType.ToString());
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些材质球存在无用的数据写出路径:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查材质球是否有无用的存储数据 如果存在无用的数据 会返回 true
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        static bool CheckMatSavedPropertieData(string matAssetPath)
        {
            MatSavedPropertieData matSavedPropertieData = new MatSavedPropertieData();
            matSavedPropertieData.ReadMat(matAssetPath);
            if (matSavedPropertieData.HasOldData())
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// 检查材质球是否有无用的存储数据 如果存在无用的数据 会返回 true
        /// 检查特定类型的无效数据
        /// </summary>
        /// <param name="mat"></param>
        /// <returns></returns>
        static bool CheckMatSavedPropertieData(string matAssetPath, MatSavedPropertieBase.PropertieType propertieType)
        {
            MatSavedPropertieData matSavedPropertieData = new MatSavedPropertieData();
            matSavedPropertieData.ReadMat(matAssetPath);
            if (matSavedPropertieData.HasOldData(propertieType))
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// 材质的存储属性
        /// </summary>
        public class MatSavedPropertieData
        {
            /// <summary>
            /// 保存的纹理记录
            /// </summary>
            public List<TexEnvs> TextureList = new List<TexEnvs>();

            /// <summary>
            /// 保存的浮点数记录
            /// </summary>
            public List<Floats> FloatList = new List<Floats>();

            /// <summary>
            /// 保存的颜色记录
            /// </summary>
            public List<Colors> ColorList = new List<Colors>();

            /// <summary>
            /// .mat记录的其他数据 保存属性之前
            /// </summary>
            public StringBuilder OtherLinesFront = new StringBuilder();

            /// <summary>
            /// .mat记录的其他数据 保存属性之后
            /// </summary>
            public StringBuilder OtherLinesBack = new StringBuilder();

            /// <summary>
            /// 数据格式
            /// </summary>
            public MatSavedPropertieBase.DataType DataTypeSet = MatSavedPropertieBase.DataType.New;

            string _matAssetPath;

            /// <summary>
            /// 读取.mat
            /// </summary>
            /// <param name="matAssetPath"></param>
            public void ReadMat(string matAssetPath)
            {
                DataTypeSet = MatSavedPropertieBase.DataType.New;
                _matAssetPath = matAssetPath;
                OtherLinesFront.Clear();
                OtherLinesBack.Clear();
                string filePath = RenderTool.AssetPathToFilePath(matAssetPath);
                string tex = RenderTool.ReadTxt(filePath);
                string[] strs = tex.Split('\n');
                //当前处于保存属性之前
                bool isSavedPropertiesFront = true;
                //当前正在收集的关键字
                string checkKey = null;
                StringBuilder timpStringBuilder = new StringBuilder();
                for (int i = 0, listCount = strs.Length; i < listCount; ++i)
                {
                    string line = strs[i];
                    if (checkKey != null)
                    {
                        string lineKey = line.Trim();
                        if (lineKey.StartsWith("m_BuildTextureStacks:"))
                        {
                            isSavedPropertiesFront = false;
                        }
                        bool findNewKey = false;
                        string newKey = null;
                        if (lineKey.StartsWith("m_TexEnvs"))
                        {
                            findNewKey = true;
                            newKey = "m_TexEnvs:";
                        }
                        if (lineKey.StartsWith("m_Floats"))
                        {
                            findNewKey = true;
                            newKey = "m_Floats:";
                        }
                        if (lineKey.StartsWith("m_Colors"))
                        {
                            findNewKey = true;
                            newKey = "m_Colors:";
                        }
                        if (findNewKey)
                        {
                            if (timpStringBuilder.Length > 0)
                            {
                                switch (checkKey)
                                {
                                    case "m_TexEnvs:"://保存的纹理数据
                                        {
                                            TexEnvs texEnvs = new TexEnvs();
                                            if (texEnvs.GetData(timpStringBuilder.ToString()))
                                            {
                                                TextureList.Add(texEnvs);
                                                if (texEnvs.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                {
                                                    DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                }
                                            }
                                        }
                                        break;
                                    case "m_Floats:"://保存的浮点数据
                                        {
                                            Floats floats = new Floats();
                                            if (floats.GetData(timpStringBuilder.ToString()))
                                            {
                                                FloatList.Add(floats);
                                                if (floats.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                {
                                                    DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                }
                                            }
                                        }
                                        break;
                                    case "m_Colors:"://保存的颜色数据
                                        {
                                            Colors colors = new Colors();
                                            if (colors.GetData(timpStringBuilder.ToString()))
                                            {
                                                ColorList.Add(colors);
                                                if (colors.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                {
                                                    DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                }
                                            }
                                        }
                                        break;
                                }
                                timpStringBuilder.Clear();
                            }
                            checkKey = newKey;
                        }
                        else
                        {
                            if (lineKey.StartsWith("- ") || lineKey.StartsWith("data:") || !isSavedPropertiesFront)
                            {
                                if (timpStringBuilder.Length > 0)
                                {
                                    switch (checkKey)
                                    {
                                        case "m_TexEnvs:"://保存的纹理数据
                                            {
                                                TexEnvs texEnvs = new TexEnvs();
                                                if (texEnvs.GetData(timpStringBuilder.ToString()))
                                                {
                                                    TextureList.Add(texEnvs);
                                                    if (texEnvs.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                    {
                                                        DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                    }
                                                }
                                            }
                                            break;
                                        case "m_Floats:"://保存的浮点数据
                                            {
                                                Floats floats = new Floats();
                                                if (floats.GetData(timpStringBuilder.ToString()))
                                                {
                                                    FloatList.Add(floats);
                                                    if (floats.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                    {
                                                        DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                    }
                                                }
                                            }
                                            break;
                                        case "m_Colors:"://保存的颜色数据
                                            {
                                                Colors colors = new Colors();
                                                if (colors.GetData(timpStringBuilder.ToString()))
                                                {
                                                    ColorList.Add(colors);
                                                    if (colors.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                                    {
                                                        DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                                    }
                                                }
                                            }
                                            break;
                                    }
                                    timpStringBuilder.Clear();
                                }
                            }
                            if (!isSavedPropertiesFront)
                            {
                                OtherLinesBack.Append(string.Format("{0}\n", line));
                            }
                            else
                            {
                                timpStringBuilder.Append(string.Format("{0}\n", line));
                            }
                        }
                    }
                    else
                    {
                        string lineKey = line.Trim();
                        if (lineKey.StartsWith("m_TexEnvs:"))
                        {
                            checkKey = "m_TexEnvs:";
                        }
                        if (lineKey.StartsWith("m_Floats:"))
                        {
                            checkKey = "m_Floats:";
                        }
                        if (lineKey.StartsWith("m_Colors:"))
                        {
                            checkKey = "m_Colors:";
                        }
                        if (string.IsNullOrEmpty(checkKey))
                        {
                            if (isSavedPropertiesFront)
                            {
                                OtherLinesFront.Append(string.Format("{0}\n", line));
                            }
                            else
                            {
                                OtherLinesBack.Append(string.Format("{0}\n", line));
                            }
                        }
                    }
                    if (i == (listCount - 1) && timpStringBuilder.Length > 0)
                    {
                        switch (checkKey)
                        {
                            case "m_TexEnvs:"://保存的纹理数据
                                {
                                    TexEnvs texEnvs = new TexEnvs();
                                    if (texEnvs.GetData(timpStringBuilder.ToString()))
                                    {
                                        TextureList.Add(texEnvs);
                                        if (texEnvs.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                        {
                                            DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                        }
                                    }
                                }
                                break;
                            case "m_Floats:"://保存的浮点数据
                                {
                                    Floats floats = new Floats();
                                    if (floats.GetData(timpStringBuilder.ToString()))
                                    {
                                        FloatList.Add(floats);
                                        if (floats.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                        {
                                            DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                        }
                                    }
                                }
                                break;
                            case "m_Colors:"://保存的颜色数据
                                {
                                    Colors colors = new Colors();
                                    if (colors.GetData(timpStringBuilder.ToString()))
                                    {
                                        ColorList.Add(colors);
                                        if (colors.DataTypeSet == MatSavedPropertieBase.DataType.OldData)
                                        {
                                            DataTypeSet = MatSavedPropertieBase.DataType.OldData;
                                        }
                                    }
                                }
                                break;
                        }
                        timpStringBuilder.Clear();
                    }
                }
            }

            /// <summary>
            /// 加入一个Float
            /// </summary>
            public void AddOneFloat(string proName, float value)
            {
                Floats floats = null;
                for (int i = 0; i < FloatList.Count; ++i)
                {
                    Floats data = FloatList[i];
                    if (data.PropertieName.CompareTo(proName) == 0)
                    {
                        floats = data;
                        break;
                    }
                }
                if (floats == null)
                {
                    floats = new Floats();
                    floats.DataTypeSet = DataTypeSet;
                    floats.PropertieName = proName;
                    floats.FloatValue = value;
                    FloatList.Add(floats);
                }
                else
                {
                    floats.FloatValue = value;
                }
            }

            /// <summary>
            /// 生成字符串
            /// </summary>
            /// <returns></returns>
            public StringBuilder GetStr()
            {
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.Append(OtherLinesFront.ToString());
                if (TextureList.Count > 0)
                {
                    stringBuilder.Append("    m_TexEnvs:\n");
                    for (int i = 0, listCount = TextureList.Count; i < listCount; ++i)
                    {
                        stringBuilder.Append(TextureList[i].GetString().ToString());
                    }
                }
                else
                {
                    stringBuilder.Append("    m_TexEnvs: []\n");
                }
                if (FloatList.Count > 0)
                {
                    stringBuilder.Append("    m_Floats:\n");
                    for (int i = 0, listCount = FloatList.Count; i < listCount; ++i)
                    {
                        stringBuilder.Append(FloatList[i].GetString().ToString());
                    }
                }
                else
                {
                    stringBuilder.Append("    m_Floats: []\n");
                }
                if (ColorList.Count > 0)
                {
                    stringBuilder.Append("    m_Colors:\n");
                    for (int i = 0, listCount = ColorList.Count; i < listCount; ++i)
                    {
                        stringBuilder.Append(ColorList[i].GetString().ToString());
                    }
                }
                else
                {
                    stringBuilder.Append("    m_Colors: []\n");
                }
                if (OtherLinesBack.Length > 0)
                {
                    stringBuilder.Append(OtherLinesBack.ToString());
                }
                return stringBuilder;
            }

            /// <summary>
            /// 清除保存的丢失属性
            /// </summary>
            public void ClearSavedProperties()
            {
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(_matAssetPath);
                for (int i = 0, listCount = TextureList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, TextureList[i].PropertieName))
                    {
                        TextureList.RemoveAt(i);
                        i--;
                        listCount--;
                    }
                }
                for (int i = 0, listCount = FloatList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, FloatList[i].PropertieName))
                    {
                        FloatList.RemoveAt(i);
                        i--;
                        listCount--;
                    }
                }
                for (int i = 0, listCount = ColorList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, ColorList[i].PropertieName))
                    {
                        ColorList.RemoveAt(i);
                        i--;
                        listCount--;
                    }
                }
            }

            /// <summary>
            /// 判断属性是否需要清除
            /// </summary>
            /// <param name="mat"></param>
            /// <param name="propertieName"></param>
            /// <returns></returns>
            static bool PropertieNameNeedClear(Material mat, string propertieName)
            {
                if (!propertieName.StartsWith("_"))
                {
                    return false;
                }
                if (mat.HasProperty(propertieName))
                {
                    return false;
                }
                return true;
            }

            /// <summary>
            /// 是否存在无用数据
            /// </summary>
            /// <returns></returns>
            public bool HasOldData()
            {
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(_matAssetPath);
                for (int i = 0, listCount = TextureList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, TextureList[i].PropertieName))
                    {
                        return true;
                    }
                }
                for (int i = 0, listCount = FloatList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, FloatList[i].PropertieName))
                    {
                        return true;
                    }
                }
                for (int i = 0, listCount = ColorList.Count; i < listCount; ++i)
                {
                    if (PropertieNameNeedClear(mat, ColorList[i].PropertieName))
                    {
                        return true;
                    }
                }
                return false;
            }

            /// <summary>
            /// 是否包含特定类型的无效数据
            /// </summary>
            /// <param name="propertieType"></param>
            /// <returns></returns>
            public bool HasOldData(MatSavedPropertieBase.PropertieType propertieType)
            {
                Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(_matAssetPath);
                switch (propertieType)
                {
                    case MatSavedPropertieBase.PropertieType.Texture:
                        {
                            for (int i = 0, listCount = TextureList.Count; i < listCount; ++i)
                            {
                                if (PropertieNameNeedClear(mat, TextureList[i].PropertieName))
                                {
                                    return true;
                                }
                            }
                        }
                        break;
                    case MatSavedPropertieBase.PropertieType.Float:
                        {
                            for (int i = 0, listCount = FloatList.Count; i < listCount; ++i)
                            {
                                if (PropertieNameNeedClear(mat, FloatList[i].PropertieName))
                                {
                                    return true;
                                }
                            }
                        }
                        break;
                    case MatSavedPropertieBase.PropertieType.Color:
                        {
                            for (int i = 0, listCount = ColorList.Count; i < listCount; ++i)
                            {
                                if (PropertieNameNeedClear(mat, ColorList[i].PropertieName))
                                {
                                    return true;
                                }
                            }
                        }
                        break;
                }
                return false;
            }
        }

        public class MatSavedPropertieBase
        {
            /// <summary>
            /// 属性名
            /// </summary>
            public string PropertieName;

            /// <summary>
            /// 数据格式
            /// </summary>
            public DataType DataTypeSet;

            /// <summary>
            /// 解析float
            /// </summary>
            /// <param name="str"></param>
            /// <returns></returns>
            public static float FloatParse(string str)
            {
                if (str.StartsWith("."))
                {
                    str = "0" + str;
                }
                return float.Parse(str);
            }

            /// <summary>
            /// 获得属性行
            /// </summary>
            /// <param name="str"></param>
            /// <param name="attributeName"> m_Texture: </param>
            /// <returns></returns>
            public static string GetTexAttributeLineStr(string str, string attributeName)
            {
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.Append(attributeName);
                string[] strs = str.Split('\n');
                bool findAttributeName = false;

                for (int i = 0, listCount = strs.Length; i < listCount; ++i)
                {
                    string line = strs[i].Trim();
                    if (line.StartsWith(attributeName))
                    {
                        findAttributeName = true;
                        line = line.Substring(attributeName.Length, line.Length - attributeName.Length);
                        int index = line.LastIndexOf("}");
                        if (index >= 0)
                        {
                            stringBuilder.Append(line.Substring(0, index + 1));
                            return stringBuilder.ToString();
                        }
                        else
                        {
                            stringBuilder.Append(line);
                        }
                    }
                    else
                    {
                        if (findAttributeName)
                        {
                            int index = line.LastIndexOf("}");
                            if (index >= 0)
                            {
                                stringBuilder.Append(line.Substring(0, index + 1));
                                return stringBuilder.ToString();
                            }
                            else
                            {
                                stringBuilder.Append(line);
                            }
                        }
                    }
                }

                return stringBuilder.ToString();
            }

            public enum DataType
            {
                /// <summary>
                /// 新版本.mat数据格式
                /// </summary>
                New,
                /// <summary>
                /// 旧版数据格式
                /// </summary>
                OldData,
            }

            public enum PropertieType
            {
                /// <summary>
                /// 纹理
                /// </summary>
                Texture,
                /// <summary>
                /// 浮点
                /// </summary>
                Float,
                /// <summary>
                /// 颜色
                /// </summary>
                Color
            }

        }

        /// <summary>
        /// 纹理属性
        /// </summary>
        public class TexEnvs : MatSavedPropertieBase
        {
            /// <summary>
            /// 纹理id
            /// </summary>
            public string fileID;

            /// <summary>
            /// 纹理GUID
            /// </summary>
            public string guid;

            /// <summary>
            /// 纹理类型
            /// </summary>
            public int type;

            /// <summary>
            /// 纹理缩放
            /// </summary>
            public Vector2 Scale;

            /// <summary>
            /// 纹理偏移
            /// </summary>
            public Vector2 Offset;

            /// <summary>
            /// 读取.mat数据
            /// </summary>
            /// <param name="str"></param>
            public bool GetData(string str)
            {
                if (str.Contains("[]") || str.Trim().Length == 0)
                {
                    return false;
                }
                string[] strs = str.Split('\n');
                string m_TextureLine;
                string m_ScaleLine;
                string m_OffsetLine;
                if (strs[0].Trim().StartsWith("data:"))
                {
                    DataTypeSet = DataType.OldData;
                    string line = strs[2].Trim();
                    string[] lines = line.Split(':');
                    PropertieName = lines[1].Trim();
                    m_TextureLine = strs[4].Trim();
                    m_ScaleLine = strs[5].Trim();
                    m_OffsetLine = strs[6].Trim();
                }
                else
                {
                    DataTypeSet = DataType.New;
                    PropertieName = strs[0].Trim();
                    PropertieName = PropertieName.Substring(1, PropertieName.Length - 2).Trim();

                    m_TextureLine = GetTexAttributeLineStr(str, "m_Texture:");
                    m_ScaleLine = GetTexAttributeLineStr(str, "m_Scale:");
                    m_OffsetLine = GetTexAttributeLineStr(str, "m_Offset:");

                }
                //解析纹理属性
                string m_Texture = m_TextureLine.Replace("m_Texture:", "").Replace("{", "").Replace("}", "").Trim();
                string[] m_Textures = m_Texture.Split(',');
                if (m_Textures.Length == 3)
                {
                    fileID = m_Textures[0];
                    guid = m_Textures[1];
                    string typeStr = m_Textures[2];

                    string[] fileIDs = fileID.Split(':');
                    string[] guids = guid.Split(':');
                    string[] typeStrs = typeStr.Split(':');

                    fileID = fileIDs[1].Trim();
                    guid = guids[1].Trim();
                    type = int.Parse(typeStrs[1].Trim());
                }
                //解析缩放属性
                string scaleStr = m_ScaleLine.Replace("m_Scale:", "").Replace("{", "").Replace("}", "").Trim();
                string[] scaleStrs = scaleStr.Split(',');
                Scale.x = FloatParse(scaleStrs[0].Replace("x:", "").Trim());
                Scale.y = FloatParse(scaleStrs[1].Replace("y:", "").Trim());
                //解析偏移属性
                string offsetStr = m_OffsetLine.Replace("m_Offset:", "").Replace("{", "").Replace("}", "").Trim();
                string[] offsetStrs = offsetStr.Split(',');
                Offset.x = FloatParse(offsetStrs[0].Replace("x:", "").Trim());
                Offset.y = FloatParse(offsetStrs[1].Replace("y:", "").Trim());
                return true;
            }

            /// <summary>
            /// 转换成字符串
            /// </summary>
            /// <returns></returns>
            public StringBuilder GetString()
            {
                switch (DataTypeSet)
                {
                    case DataType.New:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append(string.Format("    - {0}:\n", PropertieName));
                            //
                            stringBuilder.Append("        m_Texture: {");
                            if (!string.IsNullOrEmpty(fileID))
                            {
                                stringBuilder.Append(string.Format("fileID: {0}, guid: {1}, type: {2}", fileID, guid, type));
                            }
                            else
                            {
                                stringBuilder.Append("fileID: 0");
                            }
                            stringBuilder.Append("}\n");
                            //
                            stringBuilder.Append("        m_Scale: {");
                            stringBuilder.Append(string.Format("x: {0}, y: {1}", Scale.x, Scale.y));
                            stringBuilder.Append("}\n");
                            //
                            stringBuilder.Append("        m_Offset: {");
                            stringBuilder.Append(string.Format("x: {0}, y: {1}", Offset.x, Offset.y));
                            stringBuilder.Append("}\n");
                            return stringBuilder;
                        }
                    case DataType.OldData:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append("      data:\n");
                            stringBuilder.Append("        first:\n");
                            stringBuilder.Append(string.Format("          name: {0}\n", PropertieName));
                            stringBuilder.Append("        second:\n");
                            //
                            stringBuilder.Append("          m_Texture: {");
                            if (!string.IsNullOrEmpty(fileID))
                            {
                                stringBuilder.Append(string.Format("fileID: {0}, guid: {1}, type: {2}", fileID, guid, type));
                            }
                            else
                            {
                                stringBuilder.Append("fileID: 0");
                            }
                            stringBuilder.Append("}\n");
                            //
                            stringBuilder.Append("          m_Scale: {");
                            stringBuilder.Append(string.Format("x: {0}, y: {1}", Scale.x, Scale.y));
                            stringBuilder.Append("}\n");
                            //
                            stringBuilder.Append("          m_Offset: {");
                            stringBuilder.Append(string.Format("x: {0}, y: {1}", Offset.x, Offset.y));
                            stringBuilder.Append("}\n");
                            return stringBuilder;
                        }
                }
                return null;
            }

        }

        /// <summary>
        /// 浮点属性
        /// </summary>
        public class Floats : MatSavedPropertieBase
        {
            /// <summary>
            /// 记录的浮点值
            /// </summary>
            public float FloatValue;

            /// <summary>
            /// 读取.mat数据
            /// </summary>
            /// <param name="str"></param>
            public bool GetData(string str)
            {
                if (str.Contains("[]") || str.Trim().Length == 0)
                {
                    return false;
                }
                if (str.Trim().StartsWith("- "))
                {
                    DataTypeSet = DataType.New;
                    str = str.Trim();
                    str = str.Substring(1, str.Length - 1).Trim();
                    string[] strs = str.Split(':');
                    PropertieName = strs[0].Trim();
                    FloatValue = FloatParse(strs[1].Trim());
                }
                else
                {
                    DataTypeSet = DataType.OldData;
                    string[] strs = str.Split('\n');
                    string line = strs[2].Trim();
                    string[] lines = line.Split(':');
                    PropertieName = lines[1].Trim();
                    line = strs[3].Trim();
                    lines = line.Split(':');
                    FloatValue = FloatParse(lines[1].Trim());
                }
                return true;
            }

            /// <summary>
            /// 转换成字符串
            /// </summary>
            /// <returns></returns>
            public StringBuilder GetString()
            {
                switch (DataTypeSet)
                {
                    case DataType.New:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append(string.Format("    - {0}: {1}\n", PropertieName, FloatValue));
                            return stringBuilder;
                        }
                    case DataType.OldData:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append("      data:\n");
                            stringBuilder.Append("        first:\n");
                            stringBuilder.Append(string.Format("          name: {0}\n", PropertieName));
                            stringBuilder.Append(string.Format("        second: {0}\n", FloatValue));
                            return stringBuilder;
                        }
                }
                return null;
            }
        }

        /// <summary>
        /// 颜色属性
        /// </summary>
        public class Colors : MatSavedPropertieBase
        {
            /// <summary>
            /// 记录的颜色值
            /// </summary>
            public Color ColorVlue;

            /// <summary>
            /// 读取.mat数据
            /// </summary>
            /// <param name="str"></param>
            public bool GetData(string str)
            {
                if (str.Contains("[]") || str.Trim().Length == 0)
                {
                    return false;
                }
                if (str.Trim().StartsWith("- "))
                {
                    DataTypeSet = DataType.New;
                    str = str.Trim();
                    str = str.Substring(1, str.Length - 1).Trim();
                    string[] strs = str.Split('{');
                    PropertieName = strs[0].Replace(":", "").Trim();
                    str = strs[1].Replace("}", "").Trim();
                    strs = str.Split(',');
                    ColorVlue.r = FloatParse(strs[0].Replace("r:", "").Trim());
                    ColorVlue.g = FloatParse(strs[1].Replace("g:", "").Trim());
                    ColorVlue.b = FloatParse(strs[2].Replace("b:", "").Trim());
                    ColorVlue.a = FloatParse(strs[3].Replace("a:", "").Trim());
                }
                else
                {
                    DataTypeSet = DataType.OldData;
                    string[] strs = str.Split('\n');
                    string line = strs[2].Trim();
                    string[] lines = line.Split(':');
                    PropertieName = lines[1].Trim();
                    line = strs[3].Trim();
                    line = line.Replace("second: ", "").Replace("{", "").Replace("}", "").Trim();
                    strs = line.Split(',');
                    ColorVlue.r = FloatParse(strs[0].Replace("r:", "").Trim());
                    ColorVlue.g = FloatParse(strs[1].Replace("g:", "").Trim());
                    ColorVlue.b = FloatParse(strs[2].Replace("b:", "").Trim());
                    ColorVlue.a = FloatParse(strs[3].Replace("a:", "").Trim());
                }
                return true;
            }

            /// <summary>
            /// 转换成字符串
            /// </summary>
            /// <returns></returns>
            public StringBuilder GetString()
            {
                switch (DataTypeSet)
                {
                    case DataType.New:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append(string.Format("    - {0}: ", PropertieName));
                            stringBuilder.Append("{");
                            stringBuilder.Append(string.Format("r: {0}, g: {1}, b: {2}, a: {3}", ColorVlue.r, ColorVlue.g, ColorVlue.b, ColorVlue.a));
                            stringBuilder.Append("}\n");
                            return stringBuilder;
                        }
                    case DataType.OldData:
                        {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.Append("      data:\n");
                            stringBuilder.Append("        first:\n");
                            stringBuilder.Append(string.Format("          name: {0}\n", PropertieName));
                            stringBuilder.Append("        second: ");
                            stringBuilder.Append("{");
                            stringBuilder.Append(string.Format("r: {0}, g: {1}, b: {2}, a: {3}", ColorVlue.r, ColorVlue.g, ColorVlue.b, ColorVlue.a));
                            stringBuilder.Append("}\n");
                            return stringBuilder;
                        }
                }
                return null;
            }
        }

#endif
    }
}




