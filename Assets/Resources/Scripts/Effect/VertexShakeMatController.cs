using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// <summary>
/// Shader "FB/GameHero/VertexShake" 
/// 模型震动演示
/// 空格
/// </summary>
public class VertexShakeMatController : MonoBehaviour
{

    public Material TargetMat;

    public List<ShakeData> Datas = new List<ShakeData>();

    int index = 0;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (TargetMat!=null)
            {
                TargetMat.SetFloat("_ShakeStrength", 0);
                targetData = null;
                PlayAnim(ref index);
            }
        }
        AnimRun();
    }

    void PlayAnim(ref int index)
    {
        if (index >= Datas.Count)
        {
            index = 0;
        }
        if (index >= Datas.Count) return;
        targetData = Datas[index];
        targetData.InitMat(TargetMat);
        index++;
    }

    ShakeData targetData;

    void AnimRun()
    {
        if (targetData == null) return;
        targetData.FrameUpdateStrength(TargetMat);
        if (targetData.CurAnimTime > 1)
        {
            targetData = null;
        }
    }

    [Serializable]
    public class ShakeData
    {
        [Header("震动采样")]
        public Texture2D Tex;

        [Header("强度控制范围(min,max)")]
        public Vector2 StrengthRange = new Vector2(0, 1);

        [Header("动画时间长度")]
        public float AnimTime = 1;

        [HideInInspector]
        public float CurAnimTime = 0;

        [Header("采样频率")]
        [Range(0.1f, 10)]
        public float Frequency = 4;

        [Header("顶点扭动程度")]
        [Range(0, 1)]
        public float VertexTwist = 1;

        [Header("水平震动程度")]
        [Range(0, 1)]
        public float HorizontalStrength = 0.15f;

        [Header("垂直震动程度")]
        [Range(0, 1)]
        public float VerticalStrength = 0.05f;

        public void InitMat(Material mat)
        {
            if (Tex != null)
            {
                mat.SetTexture("_ShakeNoiseMap", Tex);
            }
            mat.SetFloat("_ShakeStrength", StrengthRange.y);
            mat.SetFloat("_ShakeFrequency", Frequency);
            mat.SetFloat("_ShakeVertexTwist", VertexTwist);
            mat.SetFloat("_ShakeHorizontalStrength", HorizontalStrength);
            mat.SetFloat("_ShakeVerticalStrength", VerticalStrength);
            CurAnimTime = 0;
        }

        public void FrameUpdateStrength(Material mat)
        {
            CurAnimTime = CurAnimTime + Time.deltaTime / AnimTime;
            float strength = Mathf.Lerp(StrengthRange.y, StrengthRange.x, CurAnimTime);
            mat.SetFloat("_ShakeStrength", strength);
        }
    }
}
