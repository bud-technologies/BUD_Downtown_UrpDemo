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
/// 自定义后踢效果
/// 使用方法：
/// 1.场景中加入预制体 URPPossEffectPrefab.prefab
/// 2.管线中加入 GamePossRendererFeature
///     a.点击URP管线数据配置，点击 Add Renderer Feature
///     b.选择Game Poss Renderer Feature
/// </summary>
namespace UnityEngine.Experiemntal.Rendering.Universal
{
    /// <summary>
    /// 显示在Urp后期组件Volume的选择列表中
    /// </summary>
    [System.Serializable, VolumeComponentMenu("CustomVolume/GamePossEffect")]
    public sealed class GamePossEffect : VolumeComponent, IPostProcessComponent
    {

        #region//公用属性

        [Tooltip("Shader URPGroups/GamePossEffect/PossEffect")]
        /// <summary>
        /// 面板显示属性 材质球选择 默认勾选 //Shader "URPGroups/GamePossEffect/PossEffect"
        /// </summary>
        public ShaderParameter shaderValue = new ShaderParameter(null, true);

        [Tooltip("纹理过滤类型")]
        public RenderTextureFilerModeParameter filterMode = new RenderTextureFilerModeParameter(FilterMode.Bilinear);

        [Tooltip("作用范围")]
        public SceneTypeParameter sceneTypeParameter = new SceneTypeParameter(SceneType.SceneEditorAndGame);

        #endregion

        #region//颜色属性

        [Tooltip("颜色模式")]
        public ColorTypeParameter colorTypeParameter = new ColorTypeParameter(ColorType.None);

        [Tooltip("颜色")]
        /// <summary>
        /// 颜色相乘 //FloatParameter、IntParameter、ClampParameter
        /// </summary>
        public ColorParameter ColorSet = new ColorParameter(Color.white, false);

        #endregion

        #region//高斯模糊

        [Tooltip("高斯模糊强度")]
        public ClampedFloatParameter indensity = new ClampedFloatParameter(0f, 0, 20);
        public ClampedIntParameter blurCount = new ClampedIntParameter(1, 1, 4);
        public ClampedIntParameter downSample = new ClampedIntParameter(1, 1, 4);

        #endregion

        /// <summary>
        /// 面板显示属性 材质球选择 默认勾选
        /// </summary>
        //public MaterialParameter material = new MaterialParameter(null, true);

        /// <summary>
        /// 是否启动了Shader
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
        /// 是否开启了高斯模糊
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
        /// 是否开启了颜色模式
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
        /// 开启条件
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
        /// 自定义的面板显示属性
        /// </summary>
        [Serializable]
        public sealed class MaterialParameter : VolumeParameter<Material>
        {
            /// <summary>
            /// 显示在面板中的属性
            /// </summary>
            /// <param name="value">材质球区域</param>
            /// <param name="overrideState">单选框默认是否勾选</param>
            public MaterialParameter(Material value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// 自定义的面板显示属性
        /// </summary>
        [Serializable]
        public sealed class ShaderParameter : VolumeParameter<Shader>
        {
            /// <summary>
            /// 显示在面板中的属性
            /// </summary>
            /// <param name="value">材质球区域</param>
            /// <param name="overrideState">单选框默认是否勾选</param>
            public ShaderParameter(Shader value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// 纹理过滤类型
        /// </summary>
        [Serializable]
        public sealed class RenderTextureFilerModeParameter : VolumeParameter<FilterMode>
        {
            public RenderTextureFilerModeParameter(FilterMode value, bool overrideState = false) : base(value, overrideState)
            {
            }
        }

        /// <summary>
        /// 颜色模式
        /// </summary>
        public enum ColorType
        {
            /// <summary>
            /// 原始颜色
            /// </summary>
            None,
            /// <summary>
            /// 去色
            /// </summary>
            Gray,
            /// <summary>
            /// 颜色相乘
            /// </summary>
            Multiply,
            /// <summary>
            /// 颜色相加
            /// </summary>
            Add,
        }

        /// <summary>
        /// 自定义的面板显示属性
        /// </summary>
        [Serializable]
        public sealed class ColorTypeParameter : VolumeParameter<ColorType>
        {
            /// <summary>
            /// 显示在面板中的属性
            /// </summary>
            /// <param name="value">颜色模式</param>
            /// <param name="overrideState">单选框默认是否勾选</param>
            public ColorTypeParameter(ColorType value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        /// <summary>
        /// 作用的场景
        /// </summary>
        public enum SceneType
        {
            /// <summary>
            /// 仅在Game场景起作用
            /// </summary>
            Game,
            /// <summary>
            /// 仅在编辑场景起作用
            /// </summary>
            SceneEditor,
            /// <summary>
            /// 同时起作用
            /// </summary>
            SceneEditorAndGame,
        }

        /// <summary>
        /// 自定义的面板显示属性
        /// </summary>
        [Serializable]
        public sealed class SceneTypeParameter : VolumeParameter<SceneType>
        {
            /// <summary>
            /// 显示在面板中的属性
            /// </summary>
            /// <param name="value">作用的场景</param>
            /// <param name="overrideState">单选框默认是否勾选</param>
            public SceneTypeParameter(SceneType value, bool overrideState = false)
                : base(value, overrideState) { }
        }

        #endregion

    }

}


