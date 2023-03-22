using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

/// <summary>
/// 材质闪烁动画控制器
/// </summary>
public class MaterialFlickerController : MonoBehaviour
{

    public static int shaderId_Opacity = -1;

    bool isStartAnim = false;

    public void StartAnim(MatAnimData _matAnimData, Material _cloneMaterial,System.Action<MatAnimData> _animEndCallBack)
    {
        if (shaderId_Opacity == -1)
        {
            shaderId_Opacity = Shader.PropertyToID("_Opacity");
        }
        cloneMaterial = _cloneMaterial;
        matAnimData = _matAnimData;
        animEndCallBack = _animEndCallBack;
        matAnimData.Init();
        isStartAnim = true;
    }

    MatAnimData matAnimData;

    Material cloneMaterial;

    System.Action<MatAnimData> animEndCallBack;

    private void Update()
    {
        if (!isStartAnim) return;
        if (matAnimData.delayTime > 0)
        {
            matAnimData.delayTime = matAnimData.delayTime - Time.deltaTime;
        }
        else
        {
            if (matAnimData.sustainTime >0)
            {
                float opacity = 0;
                matAnimData.sustainTime =Mathf.Max(0, matAnimData.sustainTime - Time.deltaTime);
                float lerp = matAnimData.sustainTime / matAnimData.SustainTime;
                if (lerp>=0.5f)
                {
                    lerp = (lerp - 0.5f) / 0.5f;
                    opacity = Mathf.Lerp(matAnimData.StartOpacityRange.y, matAnimData.StartOpacityRange.x, lerp);
                }
                else
                {
                    lerp= lerp/ 0.5f;
                    opacity = Mathf.Lerp(matAnimData.StartOpacityRange.x, matAnimData.StartOpacityRange.y, lerp);
                }
                cloneMaterial.SetFloat(shaderId_Opacity, opacity);
            }
            else
            {
                matAnimData.animFlickerFrequency = matAnimData.animFlickerFrequency + 1;
                if (matAnimData.animFlickerFrequency>= matAnimData.AnimFlickerFrequency)
                {
                    if (!matAnimData.isAnimEnd)
                    {
                        if (matAnimData.animEndRunTime>0)
                        {
                            matAnimData.animEndRunTime = Mathf.Max(0, matAnimData.animEndRunTime - Time.deltaTime);
                            float lerp = matAnimData.animEndRunTime / matAnimData.animEndTimeLength;
                            float opacity = Mathf.Lerp(matAnimData.EndOpacity, matAnimData.StartOpacityRange.x, lerp);
                            cloneMaterial.SetFloat(shaderId_Opacity, opacity);
                        }
                        else
                        {
                            matAnimData.isAnimEnd = true;
                        }
                    }
                    else
                    {
                        //动画结束
                        if (animEndCallBack != null)
                        {
                            isStartAnim = false;
                            animEndCallBack(matAnimData);
                        }
                    }
                }
                else
                {
                    matAnimData.sustainTime = matAnimData.SustainTime;
                }
            }
        }
    }

    [Serializable]
    /// <summary>
    /// 克隆材质动画 需要有_Opacity控制透明度
    /// </summary>
    public class MatAnimData
    {
        [Header("开始时的透明度")]
        public float StartOpacity = 0;

        [Header("结束时的透明度")]
        public float EndOpacity = 0;

        [Header("延迟")]
        public float Delay = 0;

        [HideInInspector]
        public float delayTime = 0;

        [Header("闪烁动画的次数")]
        public int AnimFlickerFrequency = 1;

        [HideInInspector]
        public int animFlickerFrequency = 0;

        [Header("闪烁频率")]
        public float SustainTime = 1;

        [HideInInspector]
        public float sustainTime;

        [Header("闪烁透明度区间")]
        public Vector2 StartOpacityRange = new Vector2(0, 1);

        [HideInInspector]
        public bool isAnimEnd = false;

        [HideInInspector]
        public float animEndTimeLength = 0;

        [HideInInspector]
        public float animEndRunTime = 0;

        public void Init()
        {
            if (StartOpacityRange.x== StartOpacityRange.y)
            {
                StartOpacityRange.y = StartOpacityRange.x + 1;
            }
            isAnimEnd = false;
            delayTime = Delay;
            animFlickerFrequency = 0;
            sustainTime = SustainTime;
            animEndTimeLength = SustainTime*0.5f* Mathf.Abs(EndOpacity - StartOpacityRange.x) / Mathf.Abs(StartOpacityRange.y- StartOpacityRange.x);
            animEndRunTime = animEndTimeLength;
        }

    }
}
