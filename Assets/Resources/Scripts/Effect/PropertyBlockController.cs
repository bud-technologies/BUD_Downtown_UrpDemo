using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

/// <summary>
/// 用于控制材质的属性
/// </summary>
public class PropertyBlockController : MonoBehaviour
{
    [Header("每帧刷新?")]
    public bool UpdateFresh = false;

    public List<Data> Datas = new List<Data>();

    private void Start()
    {
        Fresh();
    }

    private void Update()
    {
        if (UpdateFresh)
        {
            Fresh();
        }
    }

    void Fresh()
    {
        for (int i=0,listCount= Datas.Count;i< listCount;++i)
        {
            Data data = Datas[i];
            data.SetValue();
        }
    }

    [Serializable]
    public class Data
    {
        [Header("目标渲染器")]
        public Renderer Render;

        [HideInInspector]
        public MaterialPropertyBlock Block;

        public List<ChildData> Childs = new List<ChildData>();

        public void SetValue()
        {
            for (int i=0,listCount= Childs.Count;i< listCount;++i)
            {
                ChildData childData = Childs[i];
                if (Render != null && !string.IsNullOrEmpty(childData.PropertiesName))
                {
                    if (Block == null)
                    {
                        Block = new MaterialPropertyBlock();
                    }
                    switch (childData.DataType)
                    {
                        case DataType.Vector:
                            {
                                Block.SetVector(childData.PropertiesName, childData.Vector4Value);
                            }
                            break;
                        case DataType.Int:
                            {
                                Block.SetInt(childData.PropertiesName, childData.IntValue);
                            }
                            break;
                        case DataType.Float:
                            {
                                Block.SetFloat(childData.PropertiesName, childData.FloatValue);
                            }
                            break;
                        case DataType.Texture:
                            {
                                Block.SetTexture(childData.PropertiesName, childData.TextureValue);
                            }
                            break;
                        case DataType.Color:
                            {
                                Block.SetColor(childData.PropertiesName, childData.ColorValue);
                            }
                            break;
                    }
                    Render.SetPropertyBlock(Block);
                }
            }
            
        }

        [Serializable]
        public class ChildData
        {
            [Header("数据类型")]
            public DataType DataType;

            [Header("Properties名称")]
            public string PropertiesName = "_MainTexTilingOffset";

            public Vector4 Vector4Value;

            public Texture2D TextureValue;

            public float FloatValue;

            public int IntValue;

            public Color ColorValue;
        }
    }

    [Serializable]
    public enum DataType
    {
        Vector,
        Int,
        Float,
        Texture,
        Color,
    }

}
