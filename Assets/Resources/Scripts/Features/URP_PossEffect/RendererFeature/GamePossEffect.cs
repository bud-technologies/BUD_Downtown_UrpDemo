using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.ProjectWindowCallback;
#endif

/// <summary>
/// �Զ������Ч��
/// ʹ�÷�����
/// 1.�����м���Ԥ���� URPPossEffectPrefab.prefab
/// 2.�����м��� GamePossRendererFeature
///     a.���URP�����������ã���� Add Renderer Feature
///     b.ѡ��Game Poss Renderer Feature
/// </summary>
namespace UnityEngine.Experiemntal.Rendering.Universal
{
    /// <summary>
    /// ��ʾ��Urp�������Volume��ѡ���б���
    /// </summary>
    [System.Serializable, VolumeComponentMenu("CustomVolume/GamePossEffect")]
    public sealed class GamePossEffect : VolumeComponent, IPostProcessComponent
    {

        #region//��������

        [Tooltip("Shader URPGroups/GamePossEffect/PossEffect")]
        /// <summary>
        /// �����ʾ���� ������ѡ�� Ĭ�Ϲ�ѡ //Shader "URPGroups/GamePossEffect/PossEffect"
        /// </summary>
        public ShaderParameter shaderValue = new ShaderParameter(null, true);

        [Tooltip("�����������")]
        public RenderTextureFilerModeParameter filterMode = new RenderTextureFilerModeParameter(FilterMode.Bilinear);

        [Tooltip("���÷�Χ")]
        public SceneTypeParameter sceneTypeParameter = new SceneTypeParameter(SceneType.SceneEditorAndGame);

        #endregion

        #region//��ɫ����

        [Tooltip("��ɫģʽ")]
        public ColorTypeParameter colorTypeParameter = new ColorTypeParameter(ColorType.None);

        [Tooltip("��ɫ")]
        /// <summary>
        /// ��ɫ��� //FloatParameter��IntParameter��ClampParameter
        /// </summary>
        public ColorParameter ColorSet = new ColorParameter(Color.white, false);

        #endregion

        #region//��˹ģ��

        [Tooltip("��˹ģ��ǿ��")]
        public ClampedFloatParameter indensity = new ClampedFloatParameter(0f, 0, 20);
        public ClampedIntParameter blurCount = new ClampedIntParameter(1, 1, 4);
        public ClampedIntParameter downSample = new ClampedIntParameter(1, 1, 4);

        #endregion

        /// <summary>
        /// �����ʾ���� ������ѡ�� Ĭ�Ϲ�ѡ
        /// </summary>
        //public MaterialParameter material = new MaterialParameter(null, true);

        /// <summary>
        /// �Ƿ�������Shader
        /// </summary>
        /// <returns></returns>
        public bool ShaderIsOpen()
        {
            if (shaderValue.value != null && shaderValue.value.isSupported && shaderValue.overrideState )
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// �Ƿ����˸�˹ģ��
        /// </summary>
        /// <returns></returns>
        public bool BlurIsOpen()
        {
            if (indensity.value != 0 && indensity.overrideState)
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// �Ƿ�������ɫģʽ
        /// </summary>
        /// <returns></returns>
        public bool ColorSetIsOpen()
        {
            if (colorTypeParameter.overrideState && colorTypeParameter.value!=ColorType.None)
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// ��������
        /// </summary>
        /// <returns></returns>
        public bool IsActive()
        {
            if (!active || !ShaderIsOpen()) return false;
            if (ColorSetIsOpen() || BlurIsOpen())
            {
                return true;
            }
            return false;
        }

        public bool IsTileCompatible()
        {
            return false;
        }

        public override void Override(VolumeComponent state, float interpFactor)
        {
            base.Override(state, interpFactor);
        }

        #region

        /// <summary>
        /// �Զ���������ʾ����
        /// </summary>
        [Serializable]
        public sealed class MaterialParameter : VolumeParameter<Material>
        {
            /// <summary>
            /// ��ʾ������е�����
            /// </summary>
            /// <param name="value">����������</param>
            /// <param name="overrideState">��ѡ��Ĭ���Ƿ�ѡ</param>
            public MaterialParameter(Material value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// �Զ���������ʾ����
        /// </summary>
        [Serializable]
        public sealed class ShaderParameter : VolumeParameter<Shader>
        {
            /// <summary>
            /// ��ʾ������е�����
            /// </summary>
            /// <param name="value">����������</param>
            /// <param name="overrideState">��ѡ��Ĭ���Ƿ�ѡ</param>
            public ShaderParameter(Shader value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// �����������
        /// </summary>
        [Serializable]
        public sealed class RenderTextureFilerModeParameter : VolumeParameter<FilterMode>
        {
            public RenderTextureFilerModeParameter(FilterMode value, bool overrideState = false) : base(value, overrideState)
            {
            }
        }

        /// <summary>
        /// ��ɫģʽ
        /// </summary>
        public enum ColorType
        {
            /// <summary>
            /// ԭʼ��ɫ
            /// </summary>
            None,
            /// <summary>
            /// ȥɫ
            /// </summary>
            Gray,
            /// <summary>
            /// ��ɫ���
            /// </summary>
            Multiply,
            /// <summary>
            /// ��ɫ���
            /// </summary>
            Add,
        }

        /// <summary>
        /// �Զ���������ʾ����
        /// </summary>
        [Serializable]
        public sealed class ColorTypeParameter : VolumeParameter<ColorType>
        {
            /// <summary>
            /// ��ʾ������е�����
            /// </summary>
            /// <param name="value">��ɫģʽ</param>
            /// <param name="overrideState">��ѡ��Ĭ���Ƿ�ѡ</param>
            public ColorTypeParameter(ColorType value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// ���õĳ���
        /// </summary>
        public enum SceneType
        {
            /// <summary>
            /// ����Game����������
            /// </summary>
            Game,
            /// <summary>
            /// ���ڱ༭����������
            /// </summary>
            SceneEditor,
            /// <summary>
            /// ͬʱ������
            /// </summary>
            SceneEditorAndGame,
        }

        /// <summary>
        /// �Զ���������ʾ����
        /// </summary>
        [Serializable]
        public sealed class SceneTypeParameter : VolumeParameter<SceneType>
        {
            /// <summary>
            /// ��ʾ������е�����
            /// </summary>
            /// <param name="value">���õĳ���</param>
            /// <param name="overrideState">��ѡ��Ĭ���Ƿ�ѡ</param>
            public SceneTypeParameter(SceneType value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        #endregion

    }

}


