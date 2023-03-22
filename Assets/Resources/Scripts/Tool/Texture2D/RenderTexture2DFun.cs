
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
    /// 此脚本用于对纹理资源进行检测
    /// </summary>
    public class RenderTexture2DFun
    {

#if UNITY_EDITOR

        /// <summary>
        /// 查询所有的尺寸过大的纹理 1024
        /// </summary>
        public static void CheckAllBigSizeTextures_1024()
        {
            CheckAllBigSizeTextures(1024);
        }

        /// <summary>
        /// 查询所有的尺寸过大的纹理 2048
        /// </summary>
        public static void CheckAllBigSizeTextures_2048()
        {
            CheckAllBigSizeTextures(2048);
        }

        static byte[] GetHH(string imagePath)
        {
            FileStream files = new FileStream(imagePath, FileMode.Open);
            byte[] imgByte = new byte[files.Length];
            files.Read(imgByte, 0, imgByte.Length);
            files.Close();
            return imgByte;
        }

        /// <summary>
        /// 查询所有的尺寸过大的纹理
        /// </summary>
        static void CheckAllBigSizeTextures(int size)
        {
            List<Texture2D> textureList = new List<Texture2D>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                TA_TextureMetaSetTool.TextureMetaData textureMetaData = TA_TextureMetaSetTool.GetData(assetPath);
                if (textureMetaData != null)
                {
                    //获得纹理尺寸
                    int texTureSizeDefault = textureMetaData.GetTextureByPlant_Size(TA_TextureMetaSetTool.TextureMetaData.PlantEnum.DefaultTexturePlatform);
                    int texTureSizeAndroid = textureMetaData.GetTextureByPlant_Size(TA_TextureMetaSetTool.TextureMetaData.PlantEnum.Android);
                    int texTureSizeiPhone = textureMetaData.GetTextureByPlant_Size(TA_TextureMetaSetTool.TextureMetaData.PlantEnum.iPhone);
                    if (texTureSizeDefault >= size || texTureSizeAndroid >= size || texTureSizeiPhone >= size)
                    {
                        //获得纹理真是尺寸
                        Texture2D tex = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
                        if (tex.width >= size || tex.height >= size)
                        {
                            textureList.Add(tex);
                        }
                    }
                }
            }

            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("纹理:{0} 路径:{1}\n", textureList[i], UnityEditor.AssetDatabase.GetAssetPath(textureList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些纹理尺寸过大{0}.txt", size);
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些纹理尺寸过大:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        static string WriteFolderName = "TextureEditorData";

        /// <summary>
        /// 检查所有的图片 找出所有的开启读写
        /// </summary>
        public static void CheckAllTexture_ReadWrite()
        {
            List<Texture2D> textureList = new List<Texture2D>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                UnityEditor.TextureImporter assetImporter = UnityEditor.AssetImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                if (assetImporter.isReadable)
                {
                    textureList.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath));
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("纹理:{0} 路径:{1}\n", textureList[i], UnityEditor.AssetDatabase.GetAssetPath(textureList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些纹理开启了可读写.txt");
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些纹理开启了可读写:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查所有的图片 找出所有的开启Mipmap
        /// </summary>
        public static void CheckAllTexture_Mipmap()
        {
            List<Texture2D> textureList = new List<Texture2D>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                UnityEditor.TextureImporter assetImporter = UnityEditor.AssetImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                if (assetImporter.mipmapEnabled)
                {
                    textureList.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath));
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("纹理:{0} 路径:{1}\n", textureList[i], UnityEditor.AssetDatabase.GetAssetPath(textureList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些纹理开启了Mipmap.txt");
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些纹理开启了Mipmap:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查所有的图片 找出所有的WrapMode不是Clamp
        /// </summary>
        public static void CheckAllTexture_NotClamp()
        {
            List<Texture2D> textureList = new List<Texture2D>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                UnityEditor.TextureImporter assetImporter = UnityEditor.AssetImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                if (assetImporter.wrapMode != TextureWrapMode.Clamp)
                {
                    textureList.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath));
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("纹理:{0} 路径:{1}\n", textureList[i], UnityEditor.AssetDatabase.GetAssetPath(textureList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些纹理WrapMode不是Clamp.txt");
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些纹理WrapMode不是Clamp:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 检查所有的图片 找出所有的FilterMode为Trilinear
        /// </summary>
        public static void CheckAllTexture_IsTrilinear()
        {
            List<Texture2D> textureList = new List<Texture2D>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
                UnityEditor.TextureImporter assetImporter = UnityEditor.AssetImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                if (assetImporter.filterMode == FilterMode.Trilinear)
                {
                    textureList.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath));
                }
            }
            //写出
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = textureList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("纹理:{0} 路径:{1}\n", textureList[i], UnityEditor.AssetDatabase.GetAssetPath(textureList[i])));
            }
            string savePath = RenderTool.WriteFolderDir + WriteFolderName + string.Format("/哪些纹理FilterMode为Trilinear.txt");
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("哪些纹理FilterMode为Trilinear:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        /// <summary>
        /// 判断纹理是否为纯色纹理 主线程
        /// 返回Null表明不是纯色纹理或者出错
        /// 返回的PureColorTexture2DData需要手动回收 PureColorTexture2DData.PutBackPureColorTexture2D
        /// </summary>
        /// <param name="texture2D"></param>
        /// <param name="precision">检测精度 0.001-1</param>
        /// <returns></returns>
        public static PureColorTexture2DData IsPureColor( Texture2D texture2D, float precision = 0.1f)
        {
            try
            {
                if (texture2D == null)
                {
                    return null;
                }

                int width = 0;
                int height = 0;
                UnityEngine.Color[] colors = null;
                string imagePath = "";

                bool isReadable = texture2D.isReadable;
                imagePath = UnityEditor.AssetDatabase.GetAssetPath(texture2D);
                if (!isReadable)
                {
#if UNITY_EDITOR
                    string texAssetPath = imagePath;
                    if (texAssetPath.Contains("."))
                    {
                        UnityEditor.TextureImporter textureImporter = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(texAssetPath);
                        textureImporter.isReadable = true;
                        UnityEditor.AssetDatabase.ImportAsset(texAssetPath);
                        texture2D = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(texAssetPath);
                    }
                    else
                    {
                        UnityEngine.Debug.LogError("图片不可读:" + texture2D);
                        return null;
                    }
#else
                    UnityEngine.Debug.LogError("图片不可读:"+ texture2D);
                    return null;
#endif
                }

                width = texture2D.width;
                height = texture2D.height;
                colors = texture2D.GetPixels();

                if (!isReadable)
                {
#if UNITY_EDITOR
                    string texAssetPath = imagePath;
                    UnityEditor.TextureImporter textureImporter = (UnityEditor.TextureImporter)UnityEditor.TextureImporter.GetAtPath(texAssetPath);
                    textureImporter.isReadable = false;
                    UnityEditor.AssetDatabase.ImportAsset(texAssetPath);
#endif
                }

                bool isPure = true;
                Color targetColor = Color.green;
                bool initTargetColor = false;
                precision = Mathf.Clamp(precision, 0.001f, 0.9999f);
                while (precision < 1f)
                {
                    int r = (int)(width * precision);
                    int c = (int)(height * precision);
                    for (int j = 0; j < 2; ++j)
                    {
                        for (int i = 0; i < height; ++i)
                        {
                            Color findColor;
                            if (j == 0)
                            {
                                findColor = colors[i * width + r];
                            }
                            else
                            {
                                findColor = colors[i * width + (width - r - 1)];
                            }
                            if (!initTargetColor)
                            {
                                initTargetColor = true;
                                targetColor = findColor;
                            }
                            else
                            {
                                if (targetColor != findColor)
                                {
                                    isPure = false;
                                    break;
                                }
                            }
                        }
                        if (!isPure)
                        {
                            break;
                        }
                    }

                    if (!isPure)
                    {
                        break;
                    }
                    for (int j = 0; j < 2; ++j)
                    {
                        for (int i = 0; i < width; ++i)
                        {
                            Color findColor;
                            if (j == 0)
                            {
                                findColor = colors[c * width + i];
                            }
                            else
                            {
                                findColor = colors[(height - c - 1) * width + i];
                            }
                            if (!initTargetColor)
                            {
                                initTargetColor = true;
                                targetColor = findColor;
                            }
                            else
                            {
                                if (targetColor != findColor)
                                {
                                    isPure = false;
                                    break;
                                }
                            }
                        }
                        if (!isPure)
                        {
                            break;
                        }
                    }
                    if (!isPure)
                    {
                        break;
                    }
                    precision = precision * 2f;
                }
                if (isPure && IsPureColorConfirmation(colors, width, height))
                {
                    PureColorTexture2DData pureColorTexture2D = new PureColorTexture2DData();
                    pureColorTexture2D.Texture2D = texture2D;
                    pureColorTexture2D.PureColor = targetColor;
                    pureColorTexture2D.Path = imagePath;
                    return pureColorTexture2D;
                }
                else
                {
                    return null;
                }
            }
            catch (System.Exception e)
            {
                UnityEngine.Debug.LogException(e);
                return null;
            }
        }

        static bool IsPureColorConfirmation(Color[] colors, int width, int height)
        {
            bool isPure = true;
            Color targetColor = Color.green;
            bool initTargetColor = false;
            for (int i = 0; i < width; ++i)
            {
                for (int j = 0; j < height; ++j)
                {
                    Color findColor = colors[j * width + i];
                    if (!initTargetColor)
                    {
                        targetColor = findColor;
                    }
                    else
                    {
                        if (targetColor != findColor)
                        {
                            isPure = false;
                            break;
                        }
                    }
                }
                if (!isPure)
                {
                    break;
                }
            }
            return isPure;
        }

        /// <summary>
        /// 纯色纹理
        /// </summary>
        public class PureColorTexture2DData
        {
          
            public PureColorTexture2DData()
            {

            }

            public PureColorTexture2DData(Texture2D texture2D, Color pureColor)
            {
                Texture2D = texture2D;
                PureColor = pureColor;
            }

            /// <summary>
            /// 图片路径/url 可能为空
            /// </summary>
            public string Path;

            /// <summary>
            /// 纯色纹理
            /// </summary>
            public Texture2D Texture2D;

            /// <summary>
            /// 颜色
            /// </summary>
            public Color PureColor;

        }

        /// <summary>
        /// 纹理通道反相
        /// </summary>
        /// <param name="colors"></param>
        /// <param name="from"></param>
        public static void ChannelInversion(Color[] colors, ColorChannel from)
        {
            for (int i = 0; i < colors.Length; ++i)
            {
                colors[i] = ChannelInversion(colors[i], from);
            }
        }

        /// <summary>
        /// 纹理通道反相
        /// </summary>
        /// <param name="color"></param>
        /// <param name="from"></param>
        public static Color ChannelInversion(Color color, ColorChannel from)
        {
            Color resColor = color;
            switch (from)
            {
                case ColorChannel.R:
                    {
                        resColor.r = 1f - resColor.r;
                    }
                    break;
                case ColorChannel.G:
                    {
                        resColor.g = 1f - resColor.g;
                    }
                    break;
                case ColorChannel.B:
                    {
                        resColor.b = 1f - resColor.b;
                    }
                    break;
                case ColorChannel.A:
                    {
                        resColor.a = 1f - resColor.a;
                    }
                    break;
            }
            return resColor;
        }

        /// <summary>
        /// 纹理通道交换
        /// </summary>
        /// <param name="colors"></param>
        /// <param name="from"></param>
        /// <param name="to"></param>
        /// <returns></returns>
        public static void ChannelTransformation(Color[] colors, ColorChannel from, ColorChannel to)
        {
            for (int i = 0; i < colors.Length; ++i)
            {
                colors[i] = ChannelTransformation(colors[i], from, to);
            }
        }

        /// <summary>
        /// 纹理通道交换
        /// </summary>
        /// <param name="color"></param>
        /// <param name="from"></param>
        /// <param name="to"></param>
        /// <returns></returns>
        public static Color ChannelTransformation(Color color, ColorChannel from, ColorChannel to)
        {
            Color newColor = color;
            float fromValue = GetChannelValue(color, from);
            float toValue = GetChannelValue(color, to);
            SetChannelValue(ref newColor, toValue, from);
            SetChannelValue(ref newColor, fromValue, to);
            return newColor;
        }

        static float GetChannelValue(Color color, ColorChannel channel)
        {
            switch (channel)
            {
                case ColorChannel.R:
                    {
                        return color.r;
                    }
                case ColorChannel.G:
                    {
                        return color.g;
                    }
                case ColorChannel.B:
                    {
                        return color.b;
                    }
                case ColorChannel.A:
                    {
                        return color.a;
                    }
            }
            return 0;
        }

        static void SetChannelValue(ref Color color, float v, ColorChannel channel)
        {
            switch (channel)
            {
                case ColorChannel.R:
                    {
                        color.r = v;
                    }
                    break;
                case ColorChannel.G:
                    {
                        color.g = v;
                    }
                    break;
                case ColorChannel.B:
                    {
                        color.b = v;
                    }
                    break;
                case ColorChannel.A:
                    {
                        color.a = v;
                    }
                    break;
            }
        }

        public enum ColorChannel
        {
            R,
            G,
            B,
            A,
        }

#endif
    }

}
