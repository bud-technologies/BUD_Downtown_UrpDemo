#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text;

namespace Render
{

    /// <summary>
    /// 此脚本用于修改纹理设置 因为使用 void OnPreprocessTexture(Texture2D texture) 可能会有错误异常
    /// </summary>
    public class TA_TextureMetaSetTool
    {
        ///// <summary>
        ///// 关闭纹理的Alpha
        ///// </summary>
        ///// <param name="textureAssetPath"></param>
        //public static bool CloseTextureAlpha(string textureAssetPath)
        //{
        //    TextureMetaData data = GetData(textureAssetPath);
        //    if (data == null) return;
        //    ;
        //    if(data.SetTextureAlpha(false)){
        //      Save(data);
        //      return true;
        //    }
        //    return false;
        //}

        /// <summary>
        /// 存储修改
        /// </summary>
        /// <param name="data"></param>
        public static void Save(TextureMetaData data)
        {
            StringBuilder stringBuilder = data.GetString();
            RenderTool.WriteTxt(RenderTool.AssetPathToFilePath(data.AssetPath + ".meta"), stringBuilder.ToString());
            stringBuilder.Clear();
        }

        /// <summary>
        /// 设置纹理配置 大类
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isReadable"></param>
        public static bool SetTexture_TextureImporterType(Texture2D texture, TextureImporterType textureImporterType)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_TextureImporterType(textureImporterType))
            {
                Save(data);
                return true;
            }
            //
            return false;
        }

        /// <summary>
        /// 设置纹理配置 大类
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isReadable"></param>
        public static bool SetTexture_TextureImporterType(string textureAssetPath, TextureImporterType textureImporterType)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_TextureImporterType(textureImporterType))
            {
                Save(data);
                return true;
            }
            //
            return false;
        }

        /// <summary>
        /// 设置纹理透明通道
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="alphaIsTransparency"></param>
        /// <returns></returns>
        public static bool SetTexture_AlphaIsTransparency(Texture2D texture, bool alphaIsTransparency)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_AlphaIsTransparency(alphaIsTransparency))
            {
                Save(data);
                return true;
            }
            //
            return false;
        }

        /// <summary>
        /// 设置纹理透明通道
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="alphaIsTransparency"></param>
        /// <returns></returns>
        public static bool SetTexture_AlphaIsTransparency(string textureAssetPath, bool alphaIsTransparency)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_AlphaIsTransparency(alphaIsTransparency))
            {
                Save(data);
                return true;
            }
            //
            return false;
        }

        /// <summary>
        /// 设置纹理配置 读写
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isReadable"></param>
        public static bool SetTexture_Readable(Texture2D texture, bool isReadable)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_Readable(isReadable))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 读写
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isReadable"></param>
        public static bool SetTexture_Readable(string textureAssetPath, bool isReadable)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_Readable(isReadable))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 NonPower
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isNonPower"></param>
        public static bool SetTexture_NonPower(Texture2D texture, bool isNonPower)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_NonPower(isNonPower))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 NonPower
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="isNonPower"></param>
        public static bool SetTexture_NonPower(string textureAssetPath, bool isNonPower)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_NonPower(isNonPower))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 enableMipMap
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="enableMipMap"></param>
        public static bool SetTexture_EnableMipMap(Texture2D texture, bool enableMipMap)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_EnableMipMap(enableMipMap))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 enableMipMap
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="enableMipMap"></param>
        public static bool SetTexture_EnableMipMap(string textureAssetPath, bool enableMipMap)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_EnableMipMap(enableMipMap))
            {
                Save(data);
                return true;
            }
            return false;
        }

        //

        /// <summary>
        /// 设置纹理配置 sRGB
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="enableMipMap"></param>
        public static bool SetTexture_sRGB(Texture2D texture, bool enableSRGB)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTexture_sRGB(enableSRGB))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 sRGB
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="enableMipMap"></param>
        public static bool SetTexture_sRGB(string textureAssetPath, bool enableSRGB)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTexture_sRGB(enableSRGB))
            {
                Save(data);
                return true;
            }
            return false;
        }
        //

        /// <summary>
        /// 设置纹理配置 覆盖
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="plantEnum"></param>
        /// <param name="overridden"></param>
        public static bool SetTextureByPlant_Overridden(Texture2D texture, TextureMetaData.PlantEnum plantEnum, bool overridden)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Overridden(plantEnum, overridden))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 覆盖
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="plantEnum"></param>
        /// <param name="overridden"></param>
        public static bool SetTextureByPlant_Overridden(string textureAssetPath, TextureMetaData.PlantEnum plantEnum, bool overridden)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Overridden(plantEnum, overridden))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 尺寸
        /// </summary>
        /// <param name="plantEnum"></param>
        /// <param name="maxTextureSize"></param>
        public static bool SetTextureByPlant_Size(Texture2D texture, TextureMetaData.PlantEnum plantEnum, int maxTextureSize)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Size(plantEnum, maxTextureSize))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 尺寸
        /// </summary>
        /// <param name="plantEnum"></param>
        /// <param name="maxTextureSize"></param>
        public static bool SetTextureByPlant_Size(string textureAssetPath, TextureMetaData.PlantEnum plantEnum, int maxTextureSize)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Size(plantEnum, maxTextureSize))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 TextureImporterFormat
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="plantEnum"></param>
        /// <param name="textureImporterFormat"></param>
        public static bool SetTextureByPlant_Format(Texture2D texture, TextureMetaData.PlantEnum plantEnum, TextureImporterFormat textureImporterFormat)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Format(plantEnum, textureImporterFormat))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 TextureImporterFormat
        /// </summary>
        /// <param name="texture"></param>
        /// <param name="plantEnum"></param>
        /// <param name="textureImporterFormat"></param>
        public static bool SetTextureByPlant_Format(string textureAssetPath, TextureMetaData.PlantEnum plantEnum, TextureImporterFormat textureImporterFormat)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_Format(plantEnum, textureImporterFormat))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 AndroidETC2FallbackOverride
        /// </summary>
        /// <param name="plantEnum"></param>
        /// <param name="androidETC2FallbackOverride"></param>
        public static bool SetTextureByPlant_AndroidETC2Override(Texture2D texture, TextureMetaData.PlantEnum plantEnum, AndroidETC2FallbackOverride androidETC2FallbackOverride)
        {
            TextureMetaData data = GetData(texture);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_AndroidETC2Override(plantEnum, androidETC2FallbackOverride))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 设置纹理配置 AndroidETC2FallbackOverride
        /// </summary>
        /// <param name="plantEnum"></param>
        /// <param name="androidETC2FallbackOverride"></param>
        public static bool SetTextureByPlant_AndroidETC2Override(string textureAssetPath, TextureMetaData.PlantEnum plantEnum, AndroidETC2FallbackOverride androidETC2FallbackOverride)
        {
            TextureMetaData data = GetData(textureAssetPath);
            if (data == null) return false;
            //
            if (data.SetTextureByPlant_AndroidETC2Override(plantEnum, androidETC2FallbackOverride))
            {
                Save(data);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 获得纹理数据
        /// </summary>
        /// <param name="texture"></param>
        /// <returns></returns>
        public static TextureMetaData GetData(Texture2D texture)
        {
            if (texture == null) return null;
            string assetPath = AssetDatabase.GetAssetPath(texture);
            return GetData(assetPath);
        }

        /// <summary>
        /// 获得纹理数据
        /// </summary>
        /// <param name="assetPath"></param>
        /// <returns></returns>
        public static TextureMetaData GetData(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath) || !assetPath.StartsWith("Assets/"))
            {
                return null;
            }
            TextureMetaData data = new TextureMetaData();
            data.ReadMeta(assetPath);
            return data;
        }

        /// <summary>
        /// Texture Meta 数据
        /// </summary>
        public class TextureMetaData
        {
            /// <summary>
            /// key：属性名 value：属性值
            /// </summary>
            public List<MetaDataBase> Datas = new List<MetaDataBase>();

            /// <summary>
            /// 纹理路径
            /// </summary>
            public string AssetPath;

            /// <summary>
            /// 解析图片meta
            /// </summary>
            /// <param name="assetPath"></param>
            public void ReadMeta(string assetPath)
            {
                AssetPath = assetPath;
                Datas.Clear();
                string metaFilePath = RenderTool.AssetPathToFilePath(assetPath) + ".meta";
                string metaFileTxt = RenderTool.ReadTxt(metaFilePath);
                if (metaFileTxt == null) return;
                metaFileTxt = metaFileTxt.Trim();
                if (metaFileTxt.Length == 0) return;
                string[] lines = metaFileTxt.Split('\n');
                //各个层级的父节点
                Dictionary<int, MetaDataBase> lastLevelData = new Dictionary<int, MetaDataBase>();
                //特殊数据 以字符串"-"开头
                MetaDataBase speMetaDataBase = null;
                for (int i = 0, listCount = lines.Length; i < listCount; ++i)
                {
                    string line = lines[i];
                    MetaDataBase data = new MetaDataBase(line, assetPath);
                    Datas.Add(data);
                    line = line.Trim();
                    if (line.StartsWith("- "))
                    {
                        speMetaDataBase = data;
                        MetaDataBase parentData;
                        lastLevelData.TryGetValue(data.Level, out parentData);
                        if (parentData != null)
                        {
                            parentData.Datas.Add(data);
                            data.ParentData = parentData;
                        }
                        if (data.Level == 0)
                        {
                            data.Level = 1;
                        }
                    }
                    else
                    {
                        if (data.Level == 1)
                        {
                            speMetaDataBase = null;
                        }
                        if (speMetaDataBase != null)
                        {
                            if (speMetaDataBase.Level == data.Level - 1)
                            {
                                speMetaDataBase.Datas.Add(data);
                                data.ParentData = speMetaDataBase;
                            }
                            else
                            {
                                MetaDataBase parentData;
                                lastLevelData.TryGetValue(data.Level - 1, out parentData);
                                if (parentData != null)
                                {
                                    parentData.Datas.Add(data);
                                    data.ParentData = parentData;
                                }
                            }
                            if (lastLevelData.ContainsKey(data.Level))
                            {
                                lastLevelData[data.Level] = data;
                            }
                            else
                            {
                                lastLevelData.Add(data.Level, data);
                            }
                        }
                        else
                        {
                            MetaDataBase parentData;
                            lastLevelData.TryGetValue(data.Level - 1, out parentData);
                            if (parentData != null)
                            {
                                parentData.Datas.Add(data);
                                data.ParentData = parentData;
                            }
                            if (lastLevelData.ContainsKey(data.Level))
                            {
                                lastLevelData[data.Level] = data;
                            }
                            else
                            {
                                lastLevelData.Add(data.Level, data);
                            }
                        }
                    }
                }
            }

            /// <summary>
            /// 生成图片meta
            /// </summary>
            /// <returns></returns>
            public StringBuilder GetString()
            {
                StringBuilder stringBuilder = new StringBuilder();
                for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                {
                    if (Datas[i].Level == 0)
                    {
                        StringBuilder newStringBuilder = new StringBuilder();
                        Datas[i].GetString(newStringBuilder);
                        stringBuilder.Append(newStringBuilder.ToString());
                    }
                }
                return stringBuilder;
            }

            #region//纹理设置

            /// <summary>
            /// 根据 key value 查找数据
            /// </summary>
            /// <param name="key"></param>
            /// <param name="value"></param>
            /// <returns></returns>
            public MetaDataBase FindDataByKeyAndValue(string key, string value, List<MetaDataBase> datas)
            {
                for (int i = 0, listCount = datas.Count; i < listCount; ++i)
                {
                    if (datas[i].Key != null)
                    {
                        if (datas[i].Key.CompareTo(key) == 0 && datas[i].Value != null && datas[i].Value.CompareTo(value) == 0)
                        {
                            return datas[i];
                        }
                    }
                }
                return null;
            }

            /// <summary>
            /// 是否正常的meta文件
            /// </summary>
            /// <returns></returns>
            public bool isRight()
            {

                Dictionary<string, bool> check = new Dictionary<string, bool>();

                for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                {
                    if (Datas[i].Key != "buildTarget")
                    {
                        continue;
                    }

                    if (check.ContainsKey(Datas[i].Value))
                    {
                        //有重复的平台
                        return false;
                    }

                    check.Add(Datas[i].Value, true);
                }
                return true;
            }

            /// <summary>
            /// 修正meta重复平台的错误
            /// </summary>
            public void fixMeta()
            {
                //记录所有平台，下标最后的index
                var lastSamePlatform = new Dictionary<string, int>();
                var jumpInfo = new Dictionary<int, int>();

                for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                {
                    if (Datas[i].Key != "buildTarget")
                    {
                        continue;
                    }

                    string platFormKey = Datas[i].Value;
                    if (lastSamePlatform.ContainsKey(platFormKey))
                    {
                        lastSamePlatform[platFormKey] = i;
                    }
                    else
                    {
                        lastSamePlatform.Add(platFormKey, i);
                    }
                }
                //
                for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                {
                    if (Datas[i].Key != "buildTarget")
                    {
                        continue;
                    }

                    string platFormKey = Datas[i].Value;
                    if (i >= lastSamePlatform[platFormKey])
                    {
                        continue;
                    }

                    if (Datas[i].ParentData == null)
                    {
                        continue;
                    }

                    Datas[i].ParentData.Disable = true;

                }
            }

            /// <summary>
            /// 根据 key 查找数据
            /// </summary>
            /// <param name="key"></param>
            /// <param name="value"></param>
            /// <returns></returns>
            public MetaDataBase FindDataByKey(string key, List<MetaDataBase> datas)
            {
                for (int i = 0, listCount = datas.Count; i < listCount; ++i)
                {
                    if (datas[i].Key != null && datas[i].Key.CompareTo(key) == 0)
                    {
                        return datas[i];
                    }
                }
                return null;
            }

            /// <summary>
            /// 设置纹理的Alpha读取
            /// </summary>
            /// <param name="alpha"></param>
            public bool SetTextureAlpha(bool alpha)
            {
                MetaDataBase data = FindDataByKey("alphaUsage", Datas);
                string targetValue = null;
                if (alpha)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 大类
            /// </summary>
            /// <param name="isReadable"></param>
            public bool SetTexture_TextureImporterType(TextureImporterType textureImporterType)
            {
                MetaDataBase data = FindDataByKey("textureType", Datas);
                string targetValue = ((int)textureImporterType).ToString();
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                if (textureImporterType == TextureImporterType.Sprite)
                {
                    data = FindDataByKey("spriteMode", Datas);
                    data.Value = "1";
                }
                return true;
            }

            /// <summary>
            /// 设置纹理透明通道
            /// </summary>
            /// <param name="isReadable"></param>
            public bool SetTexture_AlphaIsTransparency(bool alphaIsTransparency)
            {
                MetaDataBase data = FindDataByKey("alphaIsTransparency", Datas);
                string targetValue = null;
                if (alphaIsTransparency)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 Readable
            /// </summary>
            /// <param name="isReadable"></param>
            public bool SetTexture_Readable(bool isReadable)
            {
                MetaDataBase data = FindDataByKey("isReadable", Datas);
                string targetValue = null;
                if (isReadable)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 NonPowwer
            /// </summary>
            /// <param name="isNonPowwer"></param>
            public bool SetTexture_NonPower(bool isNonPowwer)
            {
                MetaDataBase data = FindDataByKey("nPOTScale", Datas);
                string targetValue = null;
                if (isNonPowwer)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 sRGB
            /// </summary>
            /// <param name="isSRGB"></param>
            /// <returns></returns>
            public bool SetTexture_sRGB(bool isSRGB)
            {
                MetaDataBase data = FindDataByKey("sRGBTexture", Datas);
                string targetValue = null;
                if (isSRGB)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 enableMipMap
            /// </summary>
            /// <param name="isReadable"></param>
            public bool SetTexture_EnableMipMap(bool enableMipMap)
            {
                MetaDataBase data = FindDataByKey("enableMipMap", Datas);
                string targetValue = null;
                if (enableMipMap)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (data.Value != null && data.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                data.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 创建一个指定平台数据
            /// </summary>
            /// <param name="plantEnum"></param>
            /// <returns></returns>
            MetaDataBase CreateOnePlantData(PlantEnum plantEnum)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    plantName = PlantEnum.DefaultTexturePlatform.ToString();
                    data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                    if (data == null)
                    {
                        return null;
                    }
                    data = data.ParentData;
                    MetaDataBase resData = data.Clone();
                    data = FindDataByKey("buildTarget", resData.Datas);
                    data.Value = plantEnum.ToString();
                    return resData;
                }
                else
                {
                    data = data.ParentData;
                    return data.Clone();
                }
            }

            /// <summary>
            /// 设置纹理属性 平台覆盖
            /// </summary>
            /// <param name="plantEnum"></param>
            public bool SetTextureByPlant_Overridden(PlantEnum plantEnum, bool overridden)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                    data = CreateOnePlantData(plantEnum);
                    if (data != null)
                    {
                        Datas.Add(data);
                        foreach (var item in data.Datas)
                        {
                            Datas.Add(item);
                        }
                    }
                    else
                    {
                        Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                        return false;
                    }
                }
                else
                {
                    data = data.ParentData;
                }
                //
                MetaDataBase sizeData = FindDataByKey("overridden", data.Datas);
                string targetValue = null;
                if (overridden)
                {
                    targetValue = "1";
                }
                else
                {
                    targetValue = "0";
                }
                if (sizeData.Value != null && sizeData.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                sizeData.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 尺寸
            /// </summary>
            /// <param name="plantEnum"></param>
            public bool SetTextureByPlant_Size(PlantEnum plantEnum, int maxTextureSize)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                    data = CreateOnePlantData(plantEnum);
                    if (data != null)
                    {
                        Datas.Add(data);
                        foreach (var item in data.Datas)
                        {
                            Datas.Add(item);
                        }
                    }
                    else
                    {
                        Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                        return false;
                    }

                }
                else
                {
                    data = data.ParentData;
                }
                //
                MetaDataBase sizeData = FindDataByKey("maxTextureSize", data.Datas);
                string targetValue = maxTextureSize.ToString();
                if (sizeData.Value != null && sizeData.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                sizeData.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 获得纹理尺寸
            /// </summary>
            /// <param name="plantEnum"></param>
            /// <param name="maxTextureSize"></param>
            /// <returns></returns>
            public int GetTextureByPlant_Size(PlantEnum plantEnum)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                    return 0;
                }
                data = data.ParentData;
                //
                MetaDataBase sizeData = FindDataByKey("maxTextureSize", data.Datas);
                return int.Parse(sizeData.Value);
            }

            /// <summary>
            /// 设置纹理属性 格式
            /// </summary>
            /// <param name="plantEnum"></param>
            public bool SetTextureByPlant_Format(PlantEnum plantEnum, TextureImporterFormat textureImporterFormat)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                    data = CreateOnePlantData(plantEnum);
                    if (data != null)
                    {
                        Datas.Add(data);
                        foreach (var item in data.Datas)
                        {
                            Datas.Add(item);
                        }
                    }
                    else
                    {
                        Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                        return false;
                    }

                }
                else
                {
                    data = data.ParentData;
                }
                //
                MetaDataBase formatData = FindDataByKey("textureFormat", data.Datas);
                string targetValue = ((int)textureImporterFormat).ToString();
                if (formatData.Value != null && formatData.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                formatData.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 设置纹理属性 安卓配置
            /// </summary>
            /// <param name="plantEnum"></param>
            public bool SetTextureByPlant_AndroidETC2Override(PlantEnum plantEnum, AndroidETC2FallbackOverride androidETC2FallbackOverride)
            {
                string plantName = plantEnum.ToString();
                MetaDataBase data = FindDataByKeyAndValue("buildTarget", plantName, Datas);
                if (data == null)
                {
                    Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                    data = CreateOnePlantData(plantEnum);
                    if (data != null)
                    {
                        Datas.Add(data);
                        foreach (var item in data.Datas)
                        {
                            Datas.Add(item);
                        }
                    }
                    else
                    {
                        Debug.LogWarning(string.Format("平台未发现:{0} 路径:{1}", plantEnum, AssetPath));
                        return false;
                    }

                }
                else
                {
                    data = data.ParentData;
                }
                //
                MetaDataBase androidETC2FallbackOverrideData = FindDataByKey("androidETC2FallbackOverride", data.Datas);
                string targetValue = ((int)androidETC2FallbackOverride).ToString();
                if (androidETC2FallbackOverrideData.Value != null && androidETC2FallbackOverrideData.Value.CompareTo(targetValue) == 0)
                {
                    return false;
                }
                androidETC2FallbackOverrideData.Value = targetValue;
                return true;
            }

            /// <summary>
            /// 平台类别
            /// </summary>
            public enum PlantEnum
            {
                DefaultTexturePlatform,
                Android,
                iPhone,
                WebGL,
                Standalone
            }

            #endregion

        }

        /// <summary>
        /// 属性值
        /// </summary>
        public class MetaDataBase
        {
            public MetaDataBase(string line, string assetPath)
            {
                AssetPath = assetPath;
                if (line == null)
                {
                    return;
                }
                if (line.StartsWith(" "))
                {
                    int lastLevel = 0;
                    Dictionary<int, string>.Enumerator enumerator = levels.GetEnumerator();
                    while (enumerator.MoveNext())
                    {
                        if (line.StartsWith(enumerator.Current.Value))
                        {
                            Level = enumerator.Current.Key;
                        }
                        lastLevel = enumerator.Current.Key;
                    }
                    if (Level == 0)
                    {
                        Level = lastLevel;
                    }
                }
                line = line.Trim();
                if (line.EndsWith(":"))
                {
                    HasChild = true;
                    Key = line.Substring(0, line.Length - 1);
                }
                else
                {
                    if (!line.Contains(":"))
                    {
                        NotKey = true;
                        Value = line.Trim();
                    }
                    else
                    {
                        int index = line.IndexOf(':');
                        Key = line.Substring(0, index).Trim();
                        Value = line.Substring(index + 1, line.Length - index - 1).Trim();
                    }
                }
            }

            /// <summary>
            /// 无效字段，为了修复错误的meta文件而增加
            /// </summary>
            public bool Disable = false;

            /// <summary>
            /// 资源路径
            /// </summary>
            public string AssetPath;

            /// <summary>
            /// 父级
            /// </summary>
            public MetaDataBase ParentData;

            /// <summary>
            /// 属性名
            /// </summary>
            public string Key;

            /// <summary>
            /// 属性值
            /// </summary>
            public string Value;

            /// <summary>
            /// 当没有发现 : 的时候将会判定为非Key
            /// </summary>
            public bool NotKey = false;

            /// <summary>
            /// 是否可以拥有子节点
            /// </summary>
            public bool HasChild = false;

            /// <summary>
            /// 所在的层级
            /// </summary>
            public int Level = 0;

            static Dictionary<int, string> _levels;

            static Dictionary<int, string> levels
            {
                get
                {
                    if (_levels == null)
                    {
                        _levels = new Dictionary<int, string>();
                        _levels.Add(1, "  ");
                        _levels.Add(2, "    ");
                        _levels.Add(3, "      ");
                    }
                    return _levels;
                }
            }

            /// <summary>
            /// 子属性
            /// </summary>
            public List<MetaDataBase> Datas = new List<MetaDataBase>();

            /// <summary>
            /// 生成meta
            /// </summary>
            /// <param name="stringBuilder"></param>
            public void GetString(StringBuilder stringBuilder)
            {
                if (NotKey)
                {
                    stringBuilder.Append(string.Format("{0}\n", Value));
                }
                else
                {
                    if (Disable)
                    {
                        return;
                    }

                    if (levels.ContainsKey(Level))
                    {
                        stringBuilder.Append(levels[Level]);
                    }
                    if (string.IsNullOrEmpty(Value))
                    {
                        stringBuilder.Append(string.Format("{0}:\n", Key));
                    }
                    else
                    {
                        stringBuilder.Append(string.Format("{0}: {1}\n", Key, Value));
                    }

                    for (int i = 0, listCount = Datas.Count; i < listCount; ++i)
                    {
                        Datas[i].GetString(stringBuilder);
                    }
                }
            }

            /// <summary>
            /// 数据克隆
            /// </summary>
            /// <returns></returns>
            public MetaDataBase Clone()
            {
                MetaDataBase data = Clone(ParentData, this);
                return data;
            }

            static MetaDataBase Clone(MetaDataBase parentD, MetaDataBase targetD)
            {
                MetaDataBase newData = new MetaDataBase(null, targetD.AssetPath);
                newData.AssetPath = targetD.AssetPath;
                newData.Key = targetD.Key;
                newData.Value = targetD.Value;
                newData.NotKey = targetD.NotKey;
                newData.HasChild = targetD.HasChild;
                newData.Level = targetD.Level;
                newData.ParentData = parentD;
                if (parentD != null)
                {
                    parentD.Datas.Add(newData);
                }
                for (int i = 0, listCount = targetD.Datas.Count; i < listCount; ++i)
                {
                    MetaDataBase metaDataBase = targetD.Datas[i];
                    MetaDataBase resData = Clone(newData, metaDataBase);
                }
                return newData;
            }

        }

    }
}
#endif
