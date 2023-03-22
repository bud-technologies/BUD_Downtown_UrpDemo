#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Linq;
using System.Diagnostics;
using UnityEditor.SceneManagement;
using System.Threading.Tasks;
using Debug = UnityEngine.Debug;
using System.Runtime.InteropServices;
using System.Text;
using UnityEditor;
using Unity.Mathematics;

namespace Render
{
    /// <summary>
    /// 纹理操作工具
    /// </summary>
    public class RenderTexture2DTool
    {

#if UNITY_EDITOR

        #region//通道反相

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道反相 R")]
        static void ChannelInversion_R()
        {
            ChannelInversion_editor(RenderTexture2DFun.ColorChannel.R);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道反相 G")]
        static void ChannelInversion_G()
        {
            ChannelInversion_editor(RenderTexture2DFun.ColorChannel.G);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道反相 B")]
        static void ChannelInversion_B()
        {
            ChannelInversion_editor(RenderTexture2DFun.ColorChannel.B);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道反相 A")]
        static void ChannelInversion_A()
        {
            ChannelInversion_editor(RenderTexture2DFun.ColorChannel.A);
        }

        static void ChannelInversion_editor(RenderTexture2DFun.ColorChannel from)
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            //
            for (int i = 0; i < list.Count; ++i)
            {
                Texture2D tex = list[i];
                Color[] colors = tex.GetPixels();
                RenderTexture2DFun.ChannelInversion(colors, from);
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                string filePath = RenderTool.AssetPathToFilePath(assetPath);
                TextureType textureType = TextureType.Png;
                assetPath = assetPath.ToLower();
                if (assetPath.EndsWith(".jpg"))
                {
                    textureType = TextureType.Jpg;
                }
                else if (assetPath.EndsWith(".tga"))
                {
                    textureType = TextureType.Tga;
                }              
                string suffix = RenderTool.GetSuffix(filePath);
                filePath = RenderTool.DeleteSuffix(filePath);
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            filePath = filePath + "_ChannelInversion_" + from.ToString() + ".jpg";
                        }
                        break;
                    case TextureType.Png:
                        {
                            filePath = filePath + "_ChannelInversion_" + from.ToString() + ".png";
                        }
                        break;
                    case TextureType.Tga:
                        {
                            filePath = filePath + "_ChannelInversion_" + from.ToString() + ".tga";
                        }
                        break;
                }
                Texture2D newText = new Texture2D(tex.width, tex.height);
                newText.SetPixels(colors);
                newText.Apply();
                byte[] b = null;
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            b = newText.EncodeToJPG();
                        }
                        break;
                    case TextureType.Png:
                        {
                            b = newText.EncodeToPNG();
                        }
                        break;
                    case TextureType.Tga:
                        {
                            b = newText.EncodeToTGA();
                        }
                        break;
                }
                File.WriteAllBytes(filePath, b);
                UnityEditor.AssetDatabase.Refresh();
                //
                SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
            }
            //
            CloseTexture2DRead(openReadList);
        }

        #endregion

        #region//通道交换

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 R->G")]
        static void ChannelTransformation_RG()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.R, RenderTexture2DFun.ColorChannel.G);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 R->B")]
        static void ChannelTransformation_RB()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.R, RenderTexture2DFun.ColorChannel.B);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 R->A")]
        static void ChannelTransformation_RA()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.R, RenderTexture2DFun.ColorChannel.A);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 G->B")]
        static void ChannelTransformation_GB()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.G, RenderTexture2DFun.ColorChannel.B);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 G->A")]
        static void ChannelTransformation_GA()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.G, RenderTexture2DFun.ColorChannel.A);
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/通道交换 B->A")]
        static void ChannelTransformation_BA()
        {
            ChannelTransformation_editor(RenderTexture2DFun.ColorChannel.B, RenderTexture2DFun.ColorChannel.A);
        }

        static void ChannelTransformation_editor(RenderTexture2DFun.ColorChannel from, RenderTexture2DFun.ColorChannel to)
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            //
            for (int i = 0; i < list.Count; ++i)
            {
                Texture2D tex = list[i];
                Color[] colors = tex.GetPixels();
                RenderTexture2DFun.ChannelTransformation(colors, from, to);
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                string filePath = RenderTool.AssetPathToFilePath(assetPath);
                string suffix = RenderTool.GetSuffix(filePath);
                filePath = RenderTool.DeleteSuffix(filePath);
                TextureType textureType = TextureType.Png;
                assetPath = assetPath.ToLower();
                if (assetPath.EndsWith(".jpg"))
                {
                    textureType = TextureType.Jpg;
                }
                else if (assetPath.EndsWith(".tga"))
                {
                    textureType = TextureType.Tga;
                }
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            filePath = filePath + "_ChannelTransformation_" + from.ToString() + to.ToString() + ".jpg";
                        }
                        break;
                    case TextureType.Png:
                        {
                            filePath = filePath + "_ChannelTransformation_" + from.ToString() + to.ToString() + ".png";
                        }
                        break;
                    case TextureType.Tga:
                        {
                            filePath = filePath + "_ChannelTransformation_" + from.ToString() + to.ToString() + ".tga";
                        }
                        break;
                }
                Texture2D newText = new Texture2D(tex.width, tex.height);
                newText.SetPixels(colors);
                newText.Apply();
                byte[] b = null;
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            b = newText.EncodeToJPG();
                        }
                        break;
                    case TextureType.Png:
                        {
                            b = newText.EncodeToPNG();
                        }
                        break;
                    case TextureType.Tga:
                        {
                            b = newText.EncodeToTGA();
                        }
                        break;
                }
                File.WriteAllBytes(filePath, b);
                UnityEditor.AssetDatabase.Refresh();
                //
                SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
            }
            //
            CloseTexture2DRead(openReadList);
        }

        #endregion

        #region//法线贴图转换为高度贴图

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/法线到高度")]
        static void NormalToHeight_Editor()
        {
            NormalToHeight();
        }

        static void NormalToHeight()
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            //
            for (int i = 0; i < list.Count; ++i)
            {
                Texture2D tex = list[i];
                Color[] colors = tex.GetPixels();
                NormalToHeight(colors);
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                string filePath = RenderTool.AssetPathToFilePath(assetPath);
                string suffix = RenderTool.GetSuffix(filePath);
                filePath = RenderTool.DeleteSuffix(filePath);
                TextureType textureType = TextureType.Png;
                assetPath = assetPath.ToLower();
                if (assetPath.EndsWith(".jpg"))
                {
                    textureType = TextureType.Jpg;
                }
                else if (assetPath.EndsWith(".tga"))
                {
                    textureType = TextureType.Tga;
                }
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            filePath = filePath + "_NormalToHeight.jpg";
                        }
                        break;
                    case TextureType.Png:
                        {
                            filePath = filePath + "_NormalToHeight.png";
                        }
                        break;
                    case TextureType.Tga:
                        {
                            filePath = filePath + "_NormalToHeight.tga";
                        }
                        break;
                }
                Texture2D newText = new Texture2D(tex.width, tex.height);
                newText.SetPixels(colors);
                newText.Apply();
                byte[] b = null;
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            b = newText.EncodeToJPG();
                        }
                        break;
                    case TextureType.Png:
                        {
                            b = newText.EncodeToPNG();
                        }
                        break;
                    case TextureType.Tga:
                        {
                            b = newText.EncodeToTGA();
                        }
                        break;
                }
                File.WriteAllBytes(filePath, b);
                UnityEditor.AssetDatabase.Refresh();
                //
                SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
            }
            //
            CloseTexture2DRead(openReadList);
        }

        static Color[] NormalToHeight(Color[] normalColors)
        {
            Vector3 up = new Vector3(0,0,1f);
            for (int i=0;i< normalColors.Length;++i)
            {
                Color oldColor = normalColors[i];
                float r = oldColor.r * 2f - 1f;
                float g = oldColor.g * 2f - 1f;
                float b = oldColor.b * 2f - 1f;
                float dot = Vector3.Dot(new Vector3 (r, g,b).normalized, up);
                float v = dot * 0.5f + 0.5f;
                normalColors[i] = new Color(v, v, v,1f);
            }
            return normalColors;
        }

        #endregion

        #region//设置

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/关闭纹理的Alpha")]
        static void CloseTextureAlpha()
        {
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                Texture2D tex = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
                if (tex != null)
                {
                    UnityEditor.TextureImporter textureImporter = UnityEditor.TextureImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                    textureImporter.alphaSource = UnityEditor.TextureImporterAlphaSource.None;
                    textureImporter.SaveAndReimport();
                }
            }
            UnityEditor.AssetDatabase.Refresh();
        }

        #endregion

        enum TextureType
        {
            Jpg,
            Png,
            Tga,
        }

        public static void SetImporter(string oldAssetPath,string newAssetPath)
        {
            //
            UnityEditor.TextureImporter textureImporterOld = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(oldAssetPath);
            //
            UnityEditor.TextureImporter textureImporterNew = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(newAssetPath);
            textureImporterNew.isReadable = false;
            textureImporterNew.alphaIsTransparency = textureImporterOld.alphaIsTransparency;
            textureImporterNew.textureType = textureImporterOld.textureType;
            textureImporterNew.textureShape = textureImporterOld.textureShape;
            textureImporterNew.sRGBTexture = textureImporterOld.sRGBTexture;
            textureImporterNew.alphaSource = textureImporterOld.alphaSource;
            textureImporterNew.ignorePngGamma = textureImporterOld.ignorePngGamma;
            textureImporterNew.streamingMipmaps = textureImporterOld.streamingMipmaps;
            textureImporterNew.vtOnly = textureImporterOld.vtOnly;
            textureImporterNew.borderMipmap = textureImporterOld.borderMipmap;
            textureImporterNew.mipmapFilter = textureImporterOld.mipmapFilter;
            textureImporterNew.normalmapFilter = textureImporterOld.normalmapFilter;
            textureImporterNew.convertToNormalmap = textureImporterOld.convertToNormalmap;
            textureImporterNew.mipmapEnabled = textureImporterOld.mipmapEnabled;
            textureImporterNew.wrapMode = textureImporterOld.wrapMode;
            textureImporterNew.filterMode = textureImporterOld.filterMode;
            textureImporterNew.anisoLevel = textureImporterOld.anisoLevel;
            UnityEditor.AssetDatabase.ImportAsset(newAssetPath);
            UnityEditor.AssetDatabase.Refresh();
        }

        public static void SelectTexture2DList(System.Action<List<Texture2D>> texture2dListCallBack, System.Action<List<Texture2D>> openTexture2dListCallBack)
        {
            List<Texture2D> list = new List<Texture2D>();
            List<Texture2D> openReadList = new List<Texture2D>();
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            for (int i = 0; i < objs.Length; ++i)
            {
                UnityEngine.Object obj = objs[i];
                if (obj.GetType() == typeof(Texture2D))
                {
                    Texture2D tex = obj as Texture2D;
                    string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                    if (!string.IsNullOrEmpty(assetPath) && assetPath.StartsWith("Assets/"))
                    {
                        if (tex.isReadable)
                        {
                            list.Add(tex);
                        }
                        else
                        {
                            UnityEditor.TextureImporter textureImporter = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(assetPath);
                            textureImporter.isReadable = true;
                            UnityEditor.AssetDatabase.ImportAsset(assetPath);
                            Texture2D texture = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
                            list.Add(tex);
                            openReadList.Add(tex);
                        }
                    }
                }
            }
            texture2dListCallBack(list);
            openTexture2dListCallBack(openReadList);
        }

        public static void CloseTexture2DRead(List<Texture2D> openReadList)
        {
            for (int i = 0; i < openReadList.Count; ++i)
            {
                string texAssetPath = UnityEditor.AssetDatabase.GetAssetPath(openReadList[i]);
                UnityEditor.TextureImporter textureImporter = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(texAssetPath);
                textureImporter.isReadable = false;
                UnityEditor.AssetDatabase.ImportAsset(texAssetPath);
            }
        }


        #region//资源管理器

        /// <summary>
        /// 打开文件 单选
        /// </summary>
        /// <param name="callBack">获得文件回调</param>
        /// <param name="fileter">文件类型 "Excel文件(*.xlsx)\0*.xlsx;*.xlsx" </param>
        public static void SelectFile(Action<string> callBack, string fileter = "所有文件(*.*)\0*.*", string title = null)
        {
            try
            {
                OpenFileName openFileName = new OpenFileName();
                openFileName.structSize = Marshal.SizeOf(openFileName);
                openFileName.filter = fileter;
                openFileName.file = new string(new char[1024]);
                openFileName.maxFile = openFileName.file.Length;
                openFileName.fileTitle = new string(new char[64]);
                openFileName.maxFileTitle = openFileName.fileTitle.Length;
                openFileName.initialDir = Application.streamingAssetsPath.Replace('/', '\\');//默认路径
                if (!string.IsNullOrEmpty(title))
                {
                    openFileName.title = title + " " + fileter;
                }
                else
                {
                    openFileName.title = "选择文件" + fileter;
                }
                //openFileName.defExt = "FBX";
                //0x00080000 | ==  OFN_EXPLORER |对于旧风格对话框，目录 和文件字符串是被空格分隔的，函数为带有空格的文件名使用短文件名
                //OFN_EXPLORER |OFN_FILEMUSTEXIST|OFN_PATHMUSTEXIST| OFN_ALLOWMULTISELECT|OFN_NOCHANGEDIR    
                openFileName.flags = 0x00080000 | 0x00001000 | 0x00000800 | 0x00000008;

                if (LocalDialog.GetFile(openFileName))
                {
                    string filePath = openFileName.file;
                    if (File.Exists(filePath))
                    {
                        callBack?.Invoke(filePath);
                        return;
                    }
                    else
                    {
                        callBack?.Invoke(null);
                    }
                }
                else
                {
                    callBack?.Invoke(null);
                }
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
                callBack?.Invoke(null);
            }
        }

        /// <summary>
        /// 文件另存为
        /// </summary>
        /// <param name="callBack"></param>
        /// <param name="fileter">文件类型 FBX文件(*.fbx)\0*.fbx\0</param>
        public static void SaveFile(Action<string> callBack, string fileter = "所有文件(*.*)\0*.*", string title = null)
        {
            try
            {
                OpenFileName openFileName = new OpenFileName();
                openFileName.structSize = Marshal.SizeOf(openFileName);
                openFileName.filter = fileter;
                openFileName.file = new string(new char[1024]);
                openFileName.maxFile = openFileName.file.Length;
                openFileName.fileTitle = new string(new char[64]);
                openFileName.maxFileTitle = openFileName.fileTitle.Length;
                openFileName.initialDir = Application.streamingAssetsPath.Replace('/', '\\');//默认路径
                if (!string.IsNullOrEmpty(title))
                {
                    openFileName.title = title + " " + fileter;
                }
                else
                {
                    openFileName.title = "另存为" + fileter;
                }
                //openFileName.defExt = "FBX";
                //openFileName.flags = 0x00001000 | 0x00001000 | 0x00000800 | 0x00000200 | 0x00000008;
                openFileName.flags = 0x00080000 | 0x00001000 | 0x00000800 | 0x00000008;

                if (LocalDialog.SaveFile(openFileName))
                {
                    string filePath = openFileName.file;
                    if (!filePath.Contains('.'))
                    {
                        int index = fileter.IndexOf('*');
                        fileter = fileter.Substring(index + 1 + 1, fileter.Length - index - 1 - 1);
                        index = fileter.IndexOf(')');
                        fileter = fileter.Substring(0, index);
                        if (fileter.CompareTo("*") != 0)
                        {
                            filePath = filePath + "." + fileter;
                        }
                    }
                    callBack?.Invoke(filePath);
                }
                else
                {
                    callBack?.Invoke(null);
                }
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogException(ex);
                callBack?.Invoke(null);
            }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public class OpenFileName
        {
            public int structSize = 0;       //结构的内存大小
            public IntPtr dlgOwner = IntPtr.Zero;       //设置对话框的句柄
            public IntPtr instance = IntPtr.Zero;       //根据flags标志的设置，确定instance是谁的句柄，不设置则忽略
            public string filter = null;         //调取文件的过滤方式
            public string customFilter = null;  //一个静态缓冲区 用来保存用户选择的筛选器模式
            public int maxCustFilter = 0;     //缓冲区的大小
            public int filterIndex = 0;                 //指向的缓冲区包含定义过滤器的字符串对
            public string file = null;                  //存储调取文件路径
            public int maxFile = 0;                     //存储调取文件路径的最大长度 至少256
            public string fileTitle = null;             //调取的文件名带拓展名
            public int maxFileTitle = 0;                //调取文件名最大长度
            public string initialDir = null;            //最初目录
            public string title = null;                 //打开窗口的名字
            public int flags = 0;                       //初始化对话框的一组位标志  参数类型和作用查阅官方API
            public short fileOffset = 0;                //文件名前的长度
            public short fileExtension = 0;             //拓展名前的长度
            public string defExt = null;                //默认的拓展名
            public IntPtr custData = IntPtr.Zero;       //传递给lpfnHook成员标识的钩子子程的应用程序定义的数据
            public IntPtr hook = IntPtr.Zero;           //指向钩子的指针。除非Flags成员包含OFN_ENABLEHOOK标志，否则该成员将被忽略。
            public string templateName = null;          //模块中由hInstance成员标识的对话框模板资源的名称
            public IntPtr reservedPtr = IntPtr.Zero;
            public int reservedInt = 0;
            public int flagsEx = 0;                     //可用于初始化对话框的一组位标志

        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        internal class OpenDialogDir
        {
            public IntPtr hwndOwner = IntPtr.Zero;
            public IntPtr pidlRoot = IntPtr.Zero;
            public String pszDisplayName = null;
            public String lpszTitle = null;
            public UInt32 ulFlags = 0;
            public IntPtr lpfn = IntPtr.Zero;
            public IntPtr lParam = IntPtr.Zero;
            public int iImage = 0;
        }

        internal class LocalDialog
        {
            //链接指定系统函数       打开文件对话框
            [DllImport("Comdlg32.dll", SetLastError = true, ThrowOnUnmappableChar = true, CharSet = CharSet.Auto)]
            public static extern bool GetOpenFileName([In, Out] OpenFileName ofn);

            //链接指定系统函数        另存为对话框
            [DllImport("Comdlg32.dll", SetLastError = true, ThrowOnUnmappableChar = true, CharSet = CharSet.Auto)]
            public static extern bool GetSaveFileName([In, Out] OpenFileName ofn);


            [DllImport("shell32.dll", SetLastError = true, ThrowOnUnmappableChar = true, CharSet = CharSet.Auto)]
            private static extern IntPtr SHBrowseForFolder([In, Out] OpenDialogDir ofn);

            [DllImport("shell32.dll", SetLastError = true, ThrowOnUnmappableChar = true, CharSet = CharSet.Auto)]
            private static extern bool SHGetPathFromIDList([In] IntPtr pidl, [In, Out] char[] fileName);

            /// <summary>
            /// 获取文件
            /// </summary>
            /// <param name="ofn"></param>
            /// <returns></returns>
            public static bool GetFile([In, Out] OpenFileName ofn)
            {
                return GetOpenFileName(ofn);
            }

            /// <summary>
            /// 另存为
            /// </summary>
            /// <param name="ofn"></param>
            /// <returns></returns>
            public static bool SaveFile([In, Out] OpenFileName ofn)
            {
                return GetSaveFileName(ofn);
            }


            /// <summary>
            ///  获取文件夹路径
            /// </summary>
            public static IntPtr GetFolder([In, Out] OpenDialogDir ofn)
            {
                return SHBrowseForFolder(ofn);
            }
            /// <summary>
            /// 获取文件夹路径
            /// </summary>
            public static bool GetPathFormIDList([In] IntPtr pidl, [In, Out] char[] fileName)
            {
                return SHGetPathFromIDList(pidl, fileName);
            }
        }

        #endregion

        #region//检测

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/色块/尝试修复变暗差异色块(使用R修复G通道)")]
        static void TryRepairHBlock_G()
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            if (list.Count>0)
            {
                Texture2D tex = list[0];
                SelectFile((imagePath) =>
                {
                    byte[] bytes = File.ReadAllBytes(imagePath);
                    Texture2D newTex = new Texture2D(64, 64);
                    newTex.LoadImage(bytes);
                    newTex.Apply();
                    TryRepairHBlock(tex, newTex, RenderTexture2DFun.ColorChannel.R, RenderTexture2DFun.ColorChannel.G);
                }, "png图片(*.png)\0*.png", "尝试修复变暗差异色块,选择RGB色块纹理");
            }
            //
            CloseTexture2DRead(openReadList);
        }

        public static int GetColorIndex(int widthOiriginal, int indexU, int indexV)
        {
            int index = indexU + widthOiriginal * indexV;
            return index;
        }

        class RepairHBlockData
        {
            public int Index;

            public int IndexW;

            public int IndexH;

            public Color NowColor;
        }

        /// <summary>
        /// 尝试修复变暗差异色块
        /// //将使用from色块中的像素修复to色块颜色
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="blockTex"></param>
        /// <param name="from"></param>
        /// <param name="to"></param>
        static void TryRepairHBlock(Texture2D tex,Texture2D blockTex, RenderTexture2DFun.ColorChannel from, RenderTexture2DFun.ColorChannel to)
        {
            int w = tex.width;
            int h = tex.height;
            Color[] colors = tex.GetPixels();
            Color[] blockTexColors= blockTex.GetPixels();
            //
            Dictionary<float, Dictionary<float, Dictionary<float, Color>>> dicSave = new Dictionary<float, Dictionary<float, Dictionary<float, Color>>>();
            List<Color> fromList = new List<Color>();
            List<RepairHBlockData> toList = new List<RepairHBlockData>();

            for (int i=0;i<w;++i)
            {
                for (int j = 0; j < h; ++j)
                {
                    int index = GetColorIndex(w,i,j);
                    Color blockTexColor = blockTexColors[index];
                    switch (from)
                    {
                        case RenderTexture2DFun.ColorChannel.R:
                            {
                                if ( System.Math.Abs(blockTexColor.r-1.0f) <0.1f)
                                {
                                    fromList.Add(colors[index]);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.G:
                            {
                                if (System.Math.Abs(blockTexColor.g - 1.0f) < 0.1f)
                                {
                                    fromList.Add(colors[index]);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.B:
                            {
                                if (System.Math.Abs(blockTexColor.b - 1.0f) < 0.1f)
                                {
                                    fromList.Add(colors[index]);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.A:
                            {
                                if (System.Math.Abs(blockTexColor.a - 1.0f) < 0.1f)
                                {
                                    fromList.Add(colors[index]);
                                }
                            }
                            break;
                    }
                    switch (to)
                    {
                        case RenderTexture2DFun.ColorChannel.R:
                            {
                                if (System.Math.Abs(blockTexColor.r - 1.0f) < 0.1f)
                                {
                                    RepairHBlockData newData = new RepairHBlockData();
                                    newData.Index = index;
                                    newData.IndexW = i;
                                    newData.IndexH = j;
                                    newData.NowColor= colors[index];
                                    toList.Add(newData);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.G:
                            {
                                if (System.Math.Abs(blockTexColor.g - 1.0f) < 0.1f)
                                {
                                    RepairHBlockData newData = new RepairHBlockData();
                                    newData.Index = index;
                                    newData.IndexW = i;
                                    newData.IndexH = j;
                                    newData.NowColor = colors[index];
                                    toList.Add(newData);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.B:
                            {
                                if (System.Math.Abs(blockTexColor.b - 1.0f) < 0.1f)
                                {
                                    RepairHBlockData newData = new RepairHBlockData();
                                    newData.Index = index;
                                    newData.IndexW = i;
                                    newData.IndexH = j;
                                    newData.NowColor = colors[index];
                                    toList.Add(newData);
                                }
                            }
                            break;
                        case RenderTexture2DFun.ColorChannel.A:
                            {
                                if (System.Math.Abs(blockTexColor.a - 1.0f) < 0.1f)
                                {
                                    RepairHBlockData newData = new RepairHBlockData();
                                    newData.Index = index;
                                    newData.IndexW = i;
                                    newData.IndexH = j;
                                    newData.NowColor = colors[index];
                                    toList.Add(newData);
                                }
                            }
                            break;
                    }
                }
            }

            for (int i=0;i< toList.Count;++i)
            {
                RepairHBlockData repairHBlockData = toList[i];
                Color nowColor = repairHBlockData.NowColor;
                Dictionary<float, Dictionary<float, Color>> dicR = null;
                if (!dicSave.TryGetValue(nowColor.r,out dicR))
                {
                    dicR = new Dictionary<float, Dictionary<float, Color>>();
                    dicSave.Add(nowColor.r, dicR);
                }
                Dictionary<float, Color> dicG = null;
                if (!dicR.TryGetValue(nowColor.g,out dicG))
                {
                    dicG = new Dictionary<float, Color>();
                    dicR.Add(nowColor.g, dicG);
                }
                Color findColor = Color.white;
                if (!dicG.TryGetValue(nowColor.b, out findColor))
                {
                    Color lastColor = Color.white;
                    float lastDot = float.MaxValue;
                    for (int j = 0; j < fromList.Count; ++j)
                    {
                        Color fromColor = fromList[j];
                        float absR = System.Math.Abs(fromColor.r - repairHBlockData.NowColor.r);
                        float absG = System.Math.Abs(fromColor.g - repairHBlockData.NowColor.g);
                        float absB = System.Math.Abs(fromColor.b - repairHBlockData.NowColor.b);
                        float abs = System.Math.Max(System.Math.Max(absR, absG), absB);
                        if (abs < lastDot)
                        {
                            lastDot = abs;
                            lastColor = fromColor;
                        }
                    }
                    dicG.Add(nowColor.b, lastColor);
                    colors[repairHBlockData.Index] = new Color(lastColor.r, lastColor.g, lastColor.b, colors[repairHBlockData.Index].a);
                }
                else
                {
                    colors[repairHBlockData.Index] = new Color(findColor.r, findColor.g, findColor.b, colors[repairHBlockData.Index].a);
                }
            }
            //
            string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
            string filePath = RenderTool.AssetPathToFilePath(assetPath);
            string suffix = RenderTool.GetSuffix(filePath);
            filePath = RenderTool.DeleteSuffix(filePath);
            TextureType textureType = TextureType.Png;
            assetPath = assetPath.ToLower();
            if (assetPath.EndsWith(".jpg"))
            {
                textureType = TextureType.Jpg;
            }
            else if (assetPath.EndsWith(".tga"))
            {
                textureType = TextureType.Tga;
            }
            switch (textureType)
            {
                case TextureType.Jpg:
                    {
                        filePath = filePath + "_ColorsBlock_Repair.jpg";
                    }
                    break;
                case TextureType.Png:
                    {
                        filePath = filePath + "_ColorsBlock_Repair.png";
                    }
                    break;
                case TextureType.Tga:
                    {
                        filePath = filePath + "_ColorsBlock_Repair.tga";
                    }
                    break;
            }
            Texture2D newText = new Texture2D(tex.width, tex.height);
            newText.SetPixels(colors);
            newText.Apply();
            byte[] b = null;
            switch (textureType)
            {
                case TextureType.Jpg:
                    {
                        b = newText.EncodeToJPG();
                    }
                    break;
                case TextureType.Png:
                    {
                        b = newText.EncodeToPNG();
                    }
                    break;
                case TextureType.Tga:
                    {
                        b = newText.EncodeToTGA();
                    }
                    break;
            }
            File.WriteAllBytes(filePath, b);
            UnityEditor.AssetDatabase.Refresh();
            //
            SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
        }

        /// <summary>
        /// 获取色相变暗差异色块
        /// </summary>
        /// <param name="colors"></param>
        /// <returns></returns>
        static Color[] GetXYZ_H_Colors(Color[] colors)
        {
            Color[] newColors = new Color[colors.Length];
            for (int i=0;i< colors.Length;++i)
            {
                Color setColor=Color.white;
                Color oldColor = colors[i];
                Vector3 v3 = new Vector3(oldColor.r, oldColor.g, oldColor.b);
                Vector3 xyzColor = C_RGBtoXYZ(v3);


                if ( (xyzColor.x >= 0 && xyzColor.x < 1.0f / 6f) || (xyzColor.x>=5.0f/6.0f && xyzColor.x <= 1.0f))
                {
                    setColor = Color.red;
                }else if (xyzColor.x >= 1.0f / 6f && xyzColor.x<0.5f)
                {
                    setColor = Color.green;
                }else if (xyzColor.x >= 0.5f && xyzColor.x < 5.0f / 6f) 
                {
                    setColor = Color.blue;
                }
                else
                {
                    UnityEngine.Debug.Log(xyzColor.x);
                }
                //setColor = Color.Lerp( setColor, Color.white, xyzColor.y);
                newColors[i] = setColor;
            }
            return newColors;
        }

        static int GetXYZ_H_Colors(Color oldColor)
        {
            Vector3 v3 = new Vector3(oldColor.r, oldColor.g, oldColor.b);
            Vector3 xyzColor = C_RGBtoXYZ(v3);
            if ((xyzColor.x >= 0 && xyzColor.x < 1.0f / 6f) || (xyzColor.x >= 5.0f / 6.0f && xyzColor.x <= 1.0f))
            {
                return 0;
            }
            else if (xyzColor.x >= 1.0f / 6f && xyzColor.x < 0.5f)
            {
                return 1;
            }
            else if (xyzColor.x >= 0.5f && xyzColor.x < 5.0f / 6f)
            {
                return 2;
            }
            return -1;
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/色块/变暗差异色块")]
        static void Create_XYZ_H_Colors_Textures_editor()
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            //
            for (int i = 0; i < list.Count; ++i)
            {
                Texture2D tex = list[i];
                Color[] colors = tex.GetPixels();

                colors = GetXYZ_H_Colors(colors);

                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                string filePath = RenderTool.AssetPathToFilePath(assetPath);
                string suffix = RenderTool.GetSuffix(filePath);
                filePath = RenderTool.DeleteSuffix(filePath);
                TextureType textureType = TextureType.Png;
                assetPath = assetPath.ToLower();
                if (assetPath.EndsWith(".jpg"))
                {
                    textureType = TextureType.Jpg;
                }
                else if (assetPath.EndsWith(".tga"))
                {
                    textureType = TextureType.Tga;
                }
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            filePath = filePath + "_H_ColorsBlock.jpg";
                        }
                        break;
                    case TextureType.Png:
                        {
                            filePath = filePath + "_H_ColorsBlock.png";
                        }
                        break;
                    case TextureType.Tga:
                        {
                            filePath = filePath + "_H_ColorsBlock.tga";
                        }
                        break;
                }
                Texture2D newText = new Texture2D(tex.width, tex.height);
                newText.SetPixels(colors);
                newText.Apply();
                byte[] b = null;
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            b = newText.EncodeToJPG();
                        }
                        break;
                    case TextureType.Png:
                        {
                            b = newText.EncodeToPNG();
                        }
                        break;
                    case TextureType.Tga:
                        {
                            b = newText.EncodeToTGA();
                        }
                        break;
                }
                File.WriteAllBytes(filePath, b);
                UnityEditor.AssetDatabase.Refresh();
                //
                SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
            }
            //
            CloseTexture2DRead(openReadList);
        }

        /// <summary>
        /// 获取色相差异
        /// </summary>
        /// <param name="colors"></param>
        /// <returns></returns>
        static Color[] GetXYZ_H_Values(Color[] colors)
        {
            Color[] newColors = new Color[colors.Length];
            for (int i = 0; i < colors.Length; ++i)
            {
                Color oldColor = colors[i];
                Vector3 v3 = new Vector3(oldColor.r, oldColor.g, oldColor.b);
                Vector3 xyzColor = C_RGBtoXYZ(v3);
                newColors[i] = new Color(xyzColor.x, xyzColor.x, xyzColor.x,1f);
            }
            return newColors;
        }

        [UnityEditor.MenuItem("Assets/RenderTool/Texture2D/色块/色相")]
        static void Create_XYZ_H_Values_Textures_editor()
        {
            List<Texture2D> list = null;
            List<Texture2D> openReadList = null;
            SelectTexture2DList((l) => {
                list = l;
            }, (o) => {
                openReadList = o;
            });
            //
            for (int i = 0; i < list.Count; ++i)
            {
                Texture2D tex = list[i];
                Color[] colors = tex.GetPixels();

                colors = GetXYZ_H_Values(colors);

                string assetPath = UnityEditor.AssetDatabase.GetAssetPath(tex);
                string filePath = RenderTool.AssetPathToFilePath(assetPath);
                string suffix = RenderTool.GetSuffix(filePath);
                filePath = RenderTool.DeleteSuffix(filePath);
                TextureType textureType = TextureType.Png;
                assetPath = assetPath.ToLower();
                if (assetPath.EndsWith(".jpg"))
                {
                    textureType = TextureType.Jpg;
                }
                else if (assetPath.EndsWith(".tga"))
                {
                    textureType = TextureType.Tga;
                }
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            filePath = filePath + "_H_Values.jpg";
                        }
                        break;
                    case TextureType.Png:
                        {
                            filePath = filePath + "_H_Values.png";
                        }
                        break;
                    case TextureType.Tga:
                        {
                            filePath = filePath + "_H_Values.tga";
                        }
                        break;
                }
                Texture2D newText = new Texture2D(tex.width, tex.height);
                newText.SetPixels(colors);
                newText.Apply();
                byte[] b = null;
                switch (textureType)
                {
                    case TextureType.Jpg:
                        {
                            b = newText.EncodeToJPG();
                        }
                        break;
                    case TextureType.Png:
                        {
                            b = newText.EncodeToPNG();
                        }
                        break;
                    case TextureType.Tga:
                        {
                            b = newText.EncodeToTGA();
                        }
                        break;
                }
                File.WriteAllBytes(filePath, b);
                UnityEditor.AssetDatabase.Refresh();
                //
                SetImporter(assetPath, RenderTool.FilePathToAssetPath(filePath));
            }
            //
            CloseTexture2DRead(openReadList);
        }

        ////如果value <a  则返回0 如果value>=a 则返回1
        static float Step(float a, float value)
        {
            if (value < a)
            {
                return 0;
            }
            return 1;
        }

        static Vector3 C_RGBtoXYZ(Vector3 arg1)
        {
            Vector4 K = new Vector4(0.0f, -1.0f / 3.0f, 2.0f / 3.0f, -1.0f);
            Vector4 P = Vector4.Lerp(new Vector4(arg1.z, arg1.y, K.w, K.z), new Vector4(arg1.y, arg1.z, K.x, K.y), Step(arg1.z, arg1.y));
            Vector4 Q = Vector4.Lerp(new Vector4(P.x, P.y, P.w, arg1.x), new Vector4(arg1.x, P.y, P.y, P.x), Step(P.x, arg1.x));
            float D = Q.x - System.Math.Min(Q.w, Q.y);
            float E = 0.0001f;
            Vector3 res = new Vector3((float)System.Math.Abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
            if (res.x<0)
            {
                res.x = 0;
            }else if (res.x >1)
            {
                res.x = 1;
            }
            if (res.y < 0)
            {
                res.y = 0;
            }
            else if (res.y > 1)
            {
                res.y = 1;
            }
            if (res.z < 0)
            {
                res.z = 0;
            }
            else if (res.z > 1)
            {
                res.z = 1;
            }
            return res;
        }

        static float Frac(float v)
        {
            return v - (int)v;
        }

        static double Frac(double v)
        {
            return v - (int)v;
        }

        static Vector3 Frac(Vector3 v)
        {
            return new Vector3(Frac(v.x), Frac(v.y), Frac(v.z));
        }

        static Vector3 Saturate(Vector3 s)
        {
            return new Vector3(UnityEngine.Mathf.Clamp(s.x, 0, 1), UnityEngine.Mathf.Clamp(s.y, 0, 1), UnityEngine.Mathf.Clamp(s.z, 0, 1));
        }

        static Vector3 C_XYZtoRGB(Vector3 arg1)
        {
            Vector4 K = new Vector4(1.0f, 2.0f / 3.0f, 1.0f / 3.0f, 3.0f);
            float P_X = (float)System.Math.Abs(Frac((arg1.x + K.x) * 6.0 - K.w));
            float P_Y = (float)System.Math.Abs(Frac((arg1.y + K.y) * 6.0 - K.w));
            float P_Z = (float)System.Math.Abs(Frac((arg1.z + K.z) * 6.0 - K.w));
            Vector3 P = new Vector3(P_X, P_Y, P_Z);
            Vector3 lerpValue = P - new Vector3(K.x, K.x, K.x);
            lerpValue = Saturate(lerpValue);
            lerpValue = Vector3.Lerp(new Vector3(K.x, K.x, K.x), lerpValue, arg1.y);
            return arg1.z * lerpValue;
        }

        #endregion

#endif
    }

}

#endif

