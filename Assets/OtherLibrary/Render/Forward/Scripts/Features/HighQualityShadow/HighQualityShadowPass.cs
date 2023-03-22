using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class HighQualityShadowPass : ScriptableRenderPass
{
    protected int HightQualityShadowMap = Shader.PropertyToID(string.Intern("_HighQualityShadowMap"));
    protected int HightQualityShadowmapSize = Shader.PropertyToID(string.Intern("_HighQualityShadowmapSize"));
    protected int HightQualityWorldToShadow = Shader.PropertyToID(string.Intern("_HighQualityWorldToShadow"));
    protected int HighQualityShadowParams = Shader.PropertyToID(string.Intern("_HighQualityShadowParams"));
    protected int HighQualityShadowOffset0 = Shader.PropertyToID(string.Intern("_HighQualityShadowOffset0"));
    protected int HighQualityShadowOffset1 = Shader.PropertyToID(string.Intern("_HighQualityShadowOffset1"));
    protected int HighQualityShadowOffset2 = Shader.PropertyToID(string.Intern("_HighQualityShadowOffset2"));
    protected int HighQualityShadowOffset3 = Shader.PropertyToID(string.Intern("_HighQualityShadowOffset3"));

    protected int m_shadowMapReslution;
    protected RenderTexture m_shadowMapTexture;
    protected Matrix4x4 m_lightView;
    protected Matrix4x4 m_lightProject;
    protected ProfilingSampler m_ProfilingSampler;
    protected const string ProfilerID = "HighQualityShadow";
    float m_MaxShadowDistanceSq;
    const int k_ShadowmapBufferBits = 16;
    FilteringSettings m_FilteringSettings;

    protected bool m_isValid;

    List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
    public HighQualityShadowPass(RenderPassEvent passEvent)
    {
        renderPassEvent = passEvent;
        m_ProfilingSampler = new ProfilingSampler(ProfilerID);
        m_ShaderTagIdList.Add(new ShaderTagId("ShadowCaster"));
    }

    public bool SetupForEmptyRendering(ref RenderingData renderingData)
    {
        m_shadowMapTexture = ShadowUtils.GetTemporaryShadowTexture(1, 1, k_ShadowmapBufferBits);
        m_isValid = false;
        return true;
    }

    public bool SetUp(int shadowMapResolution, int layerMask, 
        bool isFeatureEnable,
        ref RenderingData renderingData, ref Matrix4x4 lightView, ref Matrix4x4 lightProject)
    {
        if(!isFeatureEnable)
        {
            SetupForEmptyRendering(ref renderingData);
            return true;
        }
        m_isValid = true;
        m_shadowMapReslution = shadowMapResolution;
        m_lightView = lightView;
        m_lightProject = lightProject;
        if (!renderingData.shadowData.supportsMainLightShadows || renderingData.lightData.mainLightIndex==-1)
            return SetupForEmptyRendering(ref renderingData);

        //ScriptableRenderContext.DrawRenderers 的过滤设置。
        m_FilteringSettings = new FilteringSettings(RenderQueueRange.all, layerMask);
        //RT
        m_shadowMapTexture = ShadowUtils.GetTemporaryShadowTexture(shadowMapResolution, shadowMapResolution, k_ShadowmapBufferBits);
        m_shadowMapTexture.wrapMode = TextureWrapMode.Clamp;

        m_MaxShadowDistanceSq = renderingData.cameraData.maxShadowDistance * renderingData.cameraData.maxShadowDistance;
        return true;
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        //ConfigureTarget(new RenderTargetIdentifier(m_shadowMapTexture), m_shadowMapTexture.depthStencilFormat, 
        //    m_shadowMapReslution, m_shadowMapReslution, 1, true);
        //ConfigureClear(ClearFlag.All, Color.black);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        //if (!m_isValid)
        //{
        //    CommandBuffer cbTemp = CommandBufferPool.Get();
        //    context.ExecuteCommandBuffer(cbTemp);
        //    cbTemp.Clear();
        //    cbTemp.SetGlobalTexture(HightQualityShadowMap, new RenderTargetIdentifier(m_shadowMapTexture));
        //    cbTemp.SetGlobalVector(HighQualityShadowParams, new Vector4(0, 0, 0, 0));
        //    context.ExecuteCommandBuffer(cbTemp);
        //    CommandBufferPool.Release(cbTemp);
        //    return;
        //}
        //var lightData = renderingData.lightData;
        //int shadowLightIndex = lightData.mainLightIndex;
        //if (shadowLightIndex == -1)
        //    return;
        //var visibleLight = lightData.visibleLights[shadowLightIndex];
        //var light = visibleLight.light;
        //CommandBuffer cmd = CommandBufferPool.Get();
        //using (new ProfilingScope(cmd, m_ProfilingSampler))
        //{
        //    context.ExecuteCommandBuffer(cmd);
        //    cmd.Clear();
        //    Vector4 shadowBias = ShadowUtils.GetShadowBias(ref visibleLight, shadowLightIndex, 
        //        ref renderingData.shadowData, m_lightProject, m_shadowMapReslution);

        //    cmd.SetGlobalVector(string.Intern("_ShadowBias"), shadowBias);
        //    Vector3 lightDirection = -m_lightView.GetColumn(2);
        //    cmd.SetGlobalVector(string.Intern("_LightDirection"), new Vector4(lightDirection.x, lightDirection.y, lightDirection.z, 0.0f));
        //    Vector3 lightPosition = m_lightView.GetColumn(3);
        //    cmd.SetGlobalVector(string.Intern("_LightPosition"), new Vector4(lightPosition.x, lightPosition.y, lightPosition.z, 1.0f));
        //    DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData, SortingCriteria.CommonOpaque);

        //    cmd.SetGlobalDepthBias(1.0f, 2.5f); // these values match HDRP defaults (see https://github.com/Unity-Technologies/Graphics/blob/9544b8ed2f98c62803d285096c91b44e9d8cbc47/com.unity.render-pipelines.high-definition/Runtime/Lighting/Shadow/HDShadowAtlas.cs#L197 )

        //    cmd.SetViewport(new Rect(0, 0, m_shadowMapReslution, m_shadowMapReslution));
        //    cmd.SetViewProjectionMatrices(m_lightView, m_lightProject);
        //    context.ExecuteCommandBuffer(cmd);
        //    cmd.Clear();
        //    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings);

        //    //https://www.freesion.com/article/5119745093/
        //    cmd.DisableScissorRect();
        //    context.ExecuteCommandBuffer(cmd);
        //    cmd.Clear();
        //    cmd.SetGlobalDepthBias(0.0f, 0.0f); // Restore previous depth bias values

        //    cmd.SetGlobalMatrix(HightQualityWorldToShadow, ShadowUtils.GetShadowTransform(m_lightProject, m_lightView));
        //    bool softShadows = light.shadows == LightShadows.Soft && renderingData.shadowData.supportsSoftShadows;
        //    ShadowUtils.GetScaleAndBiasForLinearDistanceFade(m_MaxShadowDistanceSq, renderingData.shadowData.mainLightShadowCascadeBorder,
        //        out float shadowFadeScale, out float shadowFadeBias);

        //    cmd.SetGlobalVector(HighQualityShadowParams, new Vector4(light.shadowStrength, softShadows ? 1 : 0, shadowFadeScale, shadowFadeBias));

        //    float invShadowAtlasWidth = 1.0f / m_shadowMapReslution;
        //    var invHalfShadowAtlasWidth = 0.5f * invShadowAtlasWidth;
        //    cmd.SetGlobalVector(HightQualityShadowmapSize, new Vector4(invShadowAtlasWidth,
        //            invShadowAtlasWidth,
        //            m_shadowMapReslution, m_shadowMapReslution));
        //    cmd.SetGlobalTexture(HightQualityShadowMap, new RenderTargetIdentifier(m_shadowMapTexture));
        //    if (renderingData.shadowData.supportsSoftShadows)
        //    {
        //        cmd.SetGlobalVector(HighQualityShadowOffset0,
        //            new Vector4(-invHalfShadowAtlasWidth, -invHalfShadowAtlasWidth, 0.0f, 0.0f));
        //        cmd.SetGlobalVector(HighQualityShadowOffset1,
        //            new Vector4(invHalfShadowAtlasWidth, -invHalfShadowAtlasWidth, 0.0f, 0.0f));
        //        cmd.SetGlobalVector(HighQualityShadowOffset2,
        //            new Vector4(-invHalfShadowAtlasWidth, invHalfShadowAtlasWidth, 0.0f, 0.0f));
        //        cmd.SetGlobalVector(HighQualityShadowOffset3,
        //            new Vector4(invHalfShadowAtlasWidth, invHalfShadowAtlasWidth, 0.0f, 0.0f));
        //    }
        //}
        //context.ExecuteCommandBuffer(cmd);
        //CommandBufferPool.Release(cmd);
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (cmd == null)
            throw new System.Exception("cmd");
        if (m_shadowMapTexture)
        {
            RenderTexture.ReleaseTemporary(m_shadowMapTexture);
            m_shadowMapTexture = null;
        }
        cmd.SetGlobalVector(HighQualityShadowParams, new Vector4(0, 0, 0, 0));
    }

    static class LitePostParams
    {
        public static readonly int _ShadowBias = Shader.PropertyToID(string.Intern("_ShadowBias"));
    }
}
