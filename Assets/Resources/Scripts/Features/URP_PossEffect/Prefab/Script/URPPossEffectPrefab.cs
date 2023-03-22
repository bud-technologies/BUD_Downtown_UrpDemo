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
/// ��Ϊunity Volume���ݲ���ͨ��SVN�ϴ��洢����Ҫ�ô˽ű���̬��ֵ
/// </summary>
public class URPPossEffectPrefab : MonoBehaviour
{
    #region//��������

    [Tooltip("Shader URPGroups/GamePossEffect/PossEffect")]
    /// <summary>
    /// �����ʾ���� ������ѡ�� Ĭ�Ϲ�ѡ 
    /// </summary>
    public URPPossEffectPrefab.ShaderParameter shaderValue;

    [Tooltip("�����������")]
    public URPPossEffectPrefab.RenderTextureFilerModeParameter filterMode;

    [Tooltip("���÷�Χ")]
    public URPPossEffectPrefab.SceneTypeParameter sceneTypeParameter;

    #endregion

    #region//��ɫ����

    [Tooltip("��ɫģʽ")]
    public URPPossEffectPrefab.ColorTypeParameter colorTypeParameter;

    [Tooltip("��ɫ")]
    /// <summary>
    /// ��ɫ���
    /// </summary>
    public URPPossEffectPrefab.ColorParameter ColorSet;

    #endregion

    #region//��˹ģ��

    [Tooltip("��˹ģ��ǿ��(0,20)")]
    public FloatParameter indensity;
    [Tooltip("(1,4)")]
    public IntParameter blurCount;
    [Tooltip("(1,4)")]
    public IntParameter downSample;

    #endregion

    Volume volume;

    GamePossEffect gamePossEffect;

    /// <summary>
    /// ���˽ű����õ����ݿ�����GamePossEffect
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
            //���ű����õ����ݿ�����gamePossEffect

            #region//��������
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

            #region//��ɫ����
            //
            gamePossEffect.colorTypeParameter.overrideState = colorTypeParameter.overrideState;
            gamePossEffect.colorTypeParameter.value = colorTypeParameter.value;
            //
            gamePossEffect.ColorSet.overrideState = ColorSet.overrideState;
            gamePossEffect.ColorSet.value = ColorSet.value;
            #endregion

            #region//��˹ģ��
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

    #region//���ݶ��� �� GamePossEffect �е�һһ��Ӧ

    [Serializable]
    public class BaseParameter
    {
        [Header("����")]
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
