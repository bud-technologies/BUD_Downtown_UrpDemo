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
    public class GamePossRendererFeature : ScriptableRendererFeature
    {
        /// <summary>
        /// Passִ��˳��
        /// </summary>
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;

        /// <summary>
        /// ����pass  feature������ʱ����
        /// </summary>
        GamePossPass postPass;

        /// <summary>
        /// Ч�������Զ�������
        /// </summary>
        GamePossEffect gamePossEffect;

        /// <summary>
        /// ÿһ֡���ᱻ����
        /// </summary>
        /// <param name="renderer"></param>
        /// <param name="renderingData"></param>
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            VolumeStack stack = VolumeManager.instance.stack;
            gamePossEffect = stack.GetComponent<GamePossEffect>();
            if (gamePossEffect == null || !gamePossEffect.IsActive()) return;
            //Ŀ��RT
            RenderTargetIdentifier cameraColorTarget = renderer.cameraColorTarget;
            //����д��Scenes�༭�����е����
            RenderTargetHandle cameraTarget = RenderTargetHandle.CameraTarget;
            postPass.Setup(renderPassEvent, cameraColorTarget, cameraTarget, gamePossEffect);
            renderer.EnqueuePass(postPass);
        }

        /// <summary>
        /// feature������ʱ����
        /// </summary>
        public override void Create()
        {
            postPass = new GamePossPass();
        }

        /// <summary>
        /// һ֡��Ⱦ��������
        /// </summary>
        /// <param name="disposing"></param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
        }

    }
    /// <summary>
    /// ��URP��Ļ������չ
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
        /// ��ȡ����RenderTexture
        /// </summary>
        RenderTargetIdentifier cameraColorTarget;

        /// <summary>
        /// ��ȡ�������RenderTexture
        /// </summary>
        //RenderTargetIdentifier cameraDepthTarget;

        //����д��Scene�༭�����е����
        RenderTargetHandle m_Destination;

        /// <summary>
        /// ִ�е�Ч��Shader
        /// </summary>
        Shader effectShader;

        /// <summary>
        /// VolumeЧ��
        /// </summary>
        GamePossEffect gamePossEffect;

        /// <summary>
        /// ��������
        /// </summary>
        Material material;

        public void Setup(RenderPassEvent @event, RenderTargetIdentifier source, RenderTargetHandle destination, GamePossEffect _gamePossEffect)
        {
            gamePossEffect = _gamePossEffect;
            effectShader = gamePossEffect.shaderValue.value;
            //����Passִ��˳��
            renderPassEvent = @event;
            // ��ȡ����RenderTexture
            cameraColorTarget = source;

            m_Destination = destination;

            //���ò�����
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
        /// ��ʱ������RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture01;

        /// <summary>
        /// ��ʱ������RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture02;

        /// <summary>
        /// ��ʱ������RenderTexture
        /// </summary>
        RenderTargetHandle m_TemporaryColorTexture03;

        public GamePossPass()
        {
            //��ʱ������RenderTexture��ʼ��nameId
            m_TemporaryColorTexture01.Init("_TemporaryColorTexture1");
            m_TemporaryColorTexture02.Init("_TemporaryColorTexture2");
            m_TemporaryColorTexture03.Init("_TemporaryColorTexture3");
        }

        /// <summary>
        /// Profiling����ʾ
        /// </summary>
        ProfilingSampler m_ProfilingSampler = new ProfilingSampler("GamePossPass");

        /// <summary>
        /// ִ����ȾShader
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="renderingData"></param>
        void Render(CommandBuffer cmd, ref RenderingData renderingData)
        {
            //using���������ǿ�����FrameDebug�Ͽ��������������Ⱦ
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
        /// ִ����ȾShader ��˹ģ��
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
            //����һ��RT
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            //��������ʱRenderTexture���ػ�����λ(0,16��24)
            opaqueDesc.depthBufferBits = 0;
            //�������ģʽ
            FilterMode filterMode = gamePossEffect.filterMode.value;
            if (gamePossEffect.BlurIsOpen())
            {
                //��������ʱRenderTexture���ؿ��(-1��ʾ��������ؿ��)
                opaqueDesc.width = opaqueDesc.width >> gamePossEffect.downSample.value;
                //��������ʱRenderTexture���ظ߶�(-1��ʾ��������ؿ��)
                opaqueDesc.height = opaqueDesc.height >> gamePossEffect.downSample.value;
                //��������ʱRenderTexture���������Ľ���洢��ָ��ID��RenderTargetHandle��
                cmd.GetTemporaryRT(m_TemporaryColorTexture01.id, opaqueDesc, filterMode);
                cmd.GetTemporaryRT(m_TemporaryColorTexture02.id, opaqueDesc, filterMode);
                cmd.GetTemporaryRT(m_TemporaryColorTexture03.id, opaqueDesc, filterMode);
            }
            else
            {
                //��������ʱRenderTexture���������Ľ���洢��ָ��ID��RenderTargetHandle��
                cmd.GetTemporaryRT(m_TemporaryColorTexture01.id, opaqueDesc, filterMode);
            }
            //�������÷�Χ
            //�Ƿ��ڱ༭����������
            bool editorScenes = false;
            //������Ϸ����������
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
            //ע���������
            //cmd.BeginSample("BeginGamePossPass");
            if (gamePossEffect.BlurIsOpen())
            {
                if (id_Offsets == -1)
                {
                    id_Offsets = Shader.PropertyToID("_Offsets");
                }
                //��cameraColorTarget����m_TemporaryColorTexture03
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
                    //��������RT������Ⱦ���༭���������ǰ֡����ɫRT��
                    cmd.Blit(m_TemporaryColorTexture03.Identifier(), m_Destination.Identifier());
                }
                if (game)
                {
                    //��������RT������Ⱦ��Game���������ǰ֡����ɫRT��
                    cmd.Blit(m_TemporaryColorTexture03.Identifier(), cameraColorTarget);
                }
            }
            else
            {
                cmd.Blit(cameraColorTarget, m_TemporaryColorTexture01.Identifier(), blurMaterial);
                if (editorScenes)
                {
                    //��������RT������Ⱦ���༭���������ǰ֡����ɫRT��
                    cmd.Blit(cameraColorTarget, m_Destination.Identifier(), blurMaterial);
                }
                if (game)
                {
                    //��������RT������Ⱦ��Game���������ǰ֡����ɫRT��
                    cmd.Blit(m_TemporaryColorTexture01.Identifier(), cameraColorTarget);
                }
            }
            //cmd.EndSample("EndGamePossPass");
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
            //���ٴ�����RT
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture01.id);
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture02.id);
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture03.id);
        }
    }
}


