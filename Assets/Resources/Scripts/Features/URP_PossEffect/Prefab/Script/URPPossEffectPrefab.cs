using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Experiemntal.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System;

[ExecuteInEditMode]
/// <summary>
/// 因为unity Volume数据不能通过SVN上传存储，需要用此脚本动态赋值
/// </summary>
public class URPPossEffectPrefab : MonoBehaviour
{
    #region//公用属性

    [Tooltip("Shader URPGroups/GamePossEffect/PossEffect")]
    /// <summary>
    /// 面板显示属性 材质球选择 默认勾选 
    /// </summary>
    public URPPossEffectPrefab.ShaderParameter shaderValue;

    [Tooltip("纹理过滤类型")]
    public URPPossEffectPrefab.RenderTextureFilerModeParameter filterMode;

    [Tooltip("作用范围")]
    public URPPossEffectPrefab.SceneTypeParameter sceneTypeParameter;

    #endregion

    #region//颜色属性

    [Tooltip("颜色模式")]
    public URPPossEffectPrefab.ColorTypeParameter colorTypeParameter;

    [Tooltip("颜色")]
    /// <summary>
    /// 颜色相乘
    /// </summary>
    public URPPossEffectPrefab.ColorParameter ColorSet;

    #endregion

    #region//高斯模糊

    [Tooltip("高斯模糊强度(0,20)")]
    public FloatParameter indensity;
    [Tooltip("(1,4)")]
    public IntParameter blurCount;
    [Tooltip("(1,4)")]
    public IntParameter downSample;

    #endregion

    Volume volume;

    GamePossEffect gamePossEffect;

    /// <summary>
    /// 将此脚本配置的数据拷贝到GamePossEffect
    /// </summary>
    void CopyDataToGamePossEffect()
    {
        if (gamePossEffect==null)
        {
            if (volume == null)
            {
                volume = transform.Find("Volume").GetComponent<Volume>();
            }
            VolumeProfile sharedProfile = volume.sharedProfile;
            sharedProfile.TryGet<GamePossEffect>(out gamePossEffect);
            if (gamePossEffect==null)
            {
                gamePossEffect = sharedProfile.Add<GamePossEffect>();
            }
        }
        if (gamePossEffect!=null)
        {
            //将脚本配置的数据拷贝到gamePossEffect

            #region//公用属性
            //
            gamePossEffect.shaderValue.overrideState = shaderValue.overrideState;
            gamePossEffect.shaderValue.value = shaderValue.value;
            //
            gamePossEffect.filterMode.overrideState = filterMode.overrideState;
            gamePossEffect.filterMode.value = filterMode.value;
            //
            gamePossEffect.sceneTypeParameter.overrideState = sceneTypeParameter.overrideState;
            gamePossEffect.sceneTypeParameter.value = sceneTypeParameter.value;
            #endregion

            #region//颜色属性
            //
            gamePossEffect.colorTypeParameter.overrideState = colorTypeParameter.overrideState;
            gamePossEffect.colorTypeParameter.value = colorTypeParameter.value;
            //
            gamePossEffect.ColorSet.overrideState = ColorSet.overrideState;
            gamePossEffect.ColorSet.value = ColorSet.value;
            #endregion

            #region//高斯模糊
            //
            gamePossEffect.indensity.overrideState = indensity.overrideState;
            gamePossEffect.indensity.value = indensity.value;
            //
            gamePossEffect.blurCount.overrideState = blurCount.overrideState;
            gamePossEffect.blurCount.value = blurCount.value;
            //
            gamePossEffect.downSample.overrideState = downSample.overrideState;
            gamePossEffect.downSample.value = downSample.value;
            #endregion
        }
    }

    private void Update()
    {
        CopyDataToGamePossEffect();
    }

    #region//数据定义 与 GamePossEffect 中的一一对应

    [Serializable]
    public class BaseParameter
    {
        [Header("开启")]
        public bool overrideState;
    }

    [Serializable]
    public class FloatParameter : BaseParameter
    {
        public float value;
    }

    [Serializable]
    public class IntParameter : BaseParameter
    {
        public int value;
    }

    [Serializable]
    public class ColorParameter : BaseParameter
    {
        public Color value;
    }

    [Serializable]
    public class MaterialParameter: BaseParameter
    {
        public Material value;
    }

    [Serializable]
    public class ShaderParameter : BaseParameter
    {
        public Shader value;
    }

    [Serializable]
    public class RenderTextureFilerModeParameter : BaseParameter
    {
        public FilterMode value;
    }

    [Serializable]
    public class ColorTypeParameter : BaseParameter
    {
        public GamePossEffect.ColorType value;
    }

    [Serializable]
    public class SceneTypeParameter : BaseParameter
    {
        public GamePossEffect.SceneType value;
    }

    #endregion
}
