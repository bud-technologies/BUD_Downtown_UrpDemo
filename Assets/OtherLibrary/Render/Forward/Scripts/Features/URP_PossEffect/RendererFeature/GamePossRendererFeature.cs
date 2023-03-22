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
    public class GamePossRendererFeature : ScriptableRendererFeature
    {
        /// <summary>
        /// Pass执行顺序
        /// </summary>
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;

        /// <summary>
        /// 管线pass  feature被创建时创建
        /// </summary>
        GamePossPass postPass;

        /// <summary>
        /// 效果控制自定义属性
        /// </summary>
        GamePossEffect gamePossEffect;

        /// <summary>
        /// 每一帧都会被调用
        /// </summary>
        /// <param name="renderer"></param>
        /// <param name="renderingData"></param>
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            VolumeStack stack = VolumeManager.instance.stack;
            gamePossEffect = stack.GetComponent<GamePossEffect>();
            if (gamePossEffect == null || !gamePossEffect.IsActive()) return;
            //目标RT
            RenderTargetIdentifier cameraColorTarget = renderer.cameraColorTarget;
            //用于写入Scenes编辑场景中的相机
            RenderTargetHandle cameraTarget = RenderTargetHandle.CameraTarget;
            postPass.Setup(renderPassEvent, cameraColorTarget, cameraTarget, gamePossEffect);
            renderer.EnqueuePass(postPass);
        }

        /// <summary>
        /// feature被创建时调用
        /// </summary>
        public override void Create()
        {
            postPass = new GamePossPass();
        }

        /// <summary>
        /// 一帧渲染完最后调用
        /// </summary>
        /// <param name="disposing"></param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }

    }
    /// <summary>
    /// 对URP屏幕后处理扩展
    /// </summary>
    public class GamePossPass : ScriptableRenderPass
    {
        const string k_RenderPostProcessingTag = "Render GamePossRenderer";

        const string k_RenderFinalPostProcessingTag = "Render Final GamePossRenderer";

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!gamePossEffect.IsActive())
            {
                return;
            }
            CommandBuffer cmd = CommandBufferPool.Get(k_RenderPostProcessingTag);
            Render(cmd, ref renderingData);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        /// <summary>
        /// 获取到的RenderTexture
        /// </summary>
        RenderTargetIdentifier cameraColorTarget;

        /// <summary>
        /// 获取到的深度RenderTexture
        /// </summary>
        //RenderTargetIdentifier cameraDepthTarget;

        //用于写入Scene编辑场景中的相机
        RenderTargetHandle m_Destination;

        /// <summary>
        /// 执行的效果Shader
        /// </summary>
        Shader effectShader;

        /// <summary>
        /// Volume效果
        /// </summary>
        GamePossEffect gamePossEffect;

        /// <summary>
        /// 操作材质
        /// </summary>
        Material material;

        public void Setup(RenderPassEvent @event, RenderTargetIdentifier source, RenderTargetHandle destination, GamePossEffect _gamePossEffect)
        {
            gamePossEffect = _gamePossEffect;
            effectShader = gamePossEffect.shaderValue.value;
            //设置Pass执行顺序
            renderPassEvent = @event;
            // 获取到的RenderTexture
            cameraColorTarget = source;

            m_Destination = destination;

            //设置材质球
            if (material != null && material.shader != effectShader)
            {
                CoreUtils.Destroy(material);
                material = null;
            }
            if (material == null)
            {
                material = CoreUtils.CreateEngineMaterial(effectShader);
            }
        }

        /// <summary>
        /// 临时创建的RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture01;

        /// <summary>
        /// 临时创建的RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture02;

        /// <summary>
        /// 临时创建的RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture03;

        public GamePossPass()
        {
            //临时创建的RenderTexture初始化nameId
            m_TemporaryColorTexture01.Init("_TemporaryColorTexture1");
            m_TemporaryColorTexture02.Init("_TemporaryColorTexture2");
            m_TemporaryColorTexture03.Init("_TemporaryColorTexture3");
        }

        /// <summary>
        /// Profiling上显示
        /// </summary>
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("GamePossPass");

        /// <summary>
        /// 执行渲染Shader
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="renderingData"></param>
        void Render(CommandBuffer cmd, ref RenderingData renderingData)
        {
            //using的做法就是可以在FrameDebug上看到里面的所有渲染
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                //ref CameraData cameraData = ref renderingData.cameraData;
                if (gamePossEffect.IsActive())//!cameraData.isSceneViewCamera
                {
                    SetupRender(cmd, ref renderingData, material);
                }
            }
        }

        int id_MultiplyColor = -1;

        int id_AddColor = -1;

        int id_Offsets = -1;

        /// <summary>
        /// 执行渲染Shader 高斯模糊
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="renderingData"></param>
        /// <param name="blurMaterial"></param>
        public void SetupRender(CommandBuffer cmd, ref RenderingData renderingData, Material blurMaterial)
        {
            if (gamePossEffect.BlurIsOpen())
            {
                blurMaterial.EnableKeyword("_GASBLUR_ON");
            }
            else
            {
                blurMaterial.DisableKeyword("_GASBLUR_ON");
            }
            if (gamePossEffect.ColorSetIsOpen())
            {
                switch (gamePossEffect.colorTypeParameter.value)
                {
                    case GamePossEffect.ColorType.Gray:
                        {
                            blurMaterial.EnableKeyword("_COLORGRAY_ON");
                            blurMaterial.DisableKeyword("_COLORMULTIPLY_ON");
                            blurMaterial.DisableKeyword("_COLORADD_ON");
                        }
                        break;
                    case GamePossEffect.ColorType.Multiply:
                        {
                            blurMaterial.EnableKeyword("_COLORMULTIPLY_ON");
                            if (id_MultiplyColor == -1)
                            {
                                id_MultiplyColor = Shader.PropertyToID("_MultiplyColor");
                            }
                            blurMaterial.SetColor(id_MultiplyColor, ((Color)gamePossEffect.ColorSet));
                            blurMaterial.DisableKeyword("_COLORGRAY_ON");
                            blurMaterial.DisableKeyword("_COLORADD_ON");
                        }
                        break;
                    case GamePossEffect.ColorType.Add:
                        {
                            blurMaterial.EnableKeyword("_COLORADD_ON");
                            if (id_AddColor == -1)
                            {
                                id_AddColor = Shader.PropertyToID("_AddColor");
                            }
                            blurMaterial.SetColor(id_AddColor, ((Color)gamePossEffect.ColorSet));
                            blurMaterial.DisableKeyword("_COLORGRAY_ON");
                            blurMaterial.DisableKeyword("_COLORMULTIPLY_ON");
                        }
                        break;
                }
            }
            else
            {
                blurMaterial.DisableKeyword("_COLORGRAY_ON");
                blurMaterial.DisableKeyword("_COLORADD_ON");
                blurMaterial.DisableKeyword("_COLORMULTIPLY_ON");
            }
            //创建一张RT
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            //创建的临时RenderTexture像素缓冲区位(0,16或24)
            opaqueDesc.depthBufferBits = 0;
            //纹理过滤模式
            FilterMode filterMode = gamePossEffect.filterMode.value;
            if (gamePossEffect.BlurIsOpen())
            {
                //创建的临时RenderTexture像素宽度(-1表示摄像机像素宽度)
                opaqueDesc.width = opaqueDesc.width >> gamePossEffect.downSample.value;
                //创建的临时RenderTexture像素高度(-1表示摄像机像素宽度)
                opaqueDesc.height = opaqueDesc.height >> gamePossEffect.downSample.value;
                //创建的临时RenderTexture，将创建的结果存储在指定ID的RenderTargetHandle中
                cmd.GetTemporaryRT(m_TemporaryColorTexture01.id, opaqueDesc, filterMode);
                cmd.GetTemporaryRT(m_TemporaryColorTexture02.id, opaqueDesc, filterMode);
                cmd.GetTemporaryRT(m_TemporaryColorTexture03.id, opaqueDesc, filterMode);
            }
            else
            {
                //创建的临时RenderTexture，将创建的结果存储在指定ID的RenderTargetHandle中
                cmd.GetTemporaryRT(m_TemporaryColorTexture01.id, opaqueDesc, filterMode);
            }
            //分析作用范围
            //是否在编辑场景起作用
            bool editorScenes = false;
            //否在游戏场景起作用
            bool game = true;
            switch (gamePossEffect.sceneTypeParameter.value)
            {
                case GamePossEffect.SceneType.Game:
                    {
                        game = true;
                    }
                    break;
                case GamePossEffect.SceneType.SceneEditor:
                    {
#if UNITY_EDITOR
                        editorScenes = true;
                        game = false;
#else
                            game = true;
#endif

                    }
                    break;
                case GamePossEffect.SceneType.SceneEditorAndGame:
                    {
#if UNITY_EDITOR
                        editorScenes = true;
#endif
                        game = true;
                    }
                    break;
            }
            //注入分析代码
            //cmd.BeginSample("BeginGamePossPass");
            if (gamePossEffect.BlurIsOpen())
            {
                if (id_Offsets == -1)
                {
                    id_Offsets = Shader.PropertyToID("_Offsets");
                }
                //将cameraColorTarget填充进m_TemporaryColorTexture03
                cmd.Blit(cameraColorTarget, m_TemporaryColorTexture03.Identifier());
                for (int i = 0; i < gamePossEffect.blurCount.value; i++)
                {
                    blurMaterial.SetVector(id_Offsets, new Vector4(0, gamePossEffect.indensity.value, 0, 0));
                    cmd.Blit(m_TemporaryColorTexture03.Identifier(), m_TemporaryColorTexture01.Identifier(), blurMaterial);
                    blurMaterial.SetVector(id_Offsets, new Vector4(gamePossEffect.indensity.value, 0, 0, 0));
                    cmd.Blit(m_TemporaryColorTexture01.Identifier(), m_TemporaryColorTexture02.Identifier(), blurMaterial);
                    cmd.Blit(m_TemporaryColorTexture02.Identifier(), cameraColorTarget);
                }
                if (editorScenes)
                {
                    //将处理后的RT重新渲染到编辑场景相机当前帧的颜色RT上
                    cmd.Blit(m_TemporaryColorTexture03.Identifier(), m_Destination.Identifier());
                }
                if (game)
                {
                    //将处理后的RT重新渲染到Game场景相机当前帧的颜色RT上
                    cmd.Blit(m_TemporaryColorTexture03.Identifier(), cameraColorTarget);
                }
            }
            else
            {
                cmd.Blit(cameraColorTarget, m_TemporaryColorTexture01.Identifier(), blurMaterial);
                if (editorScenes)
                {
                    //将处理后的RT重新渲染到编辑场景相机当前帧的颜色RT上
                    cmd.Blit(cameraColorTarget, m_Destination.Identifier(), blurMaterial);
                }
                if (game)
                {
                    //将处理后的RT重新渲染到Game场景相机当前帧的颜色RT上
                    cmd.Blit(m_TemporaryColorTexture01.Identifier(), cameraColorTarget);
                }
            }
            //cmd.EndSample("EndGamePossPass");
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
            //销毁创建的RT
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture01.id);
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture02.id);
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture03.id);
        }
    }
}


