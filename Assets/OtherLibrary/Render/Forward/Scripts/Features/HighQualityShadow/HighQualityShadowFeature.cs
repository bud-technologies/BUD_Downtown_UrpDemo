//using LGame;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.Universal.Internal;

/// <summary>
/// 生成可控区域的ShadowMap ( HighQualityShadow.cs ) 
/// </summary>
public class HighQualityShadowFeature : ScriptableRendererFeature
{
    protected HighQualityShadowPass m_pass;

    protected List<Vector3> m_renderBoundVertexs;
    /// <summary>
    /// 灯光View矩阵 作为相机使用 需要翻转Z轴
    /// </summary>
    protected Matrix4x4 m_lightViewMatrix;
    /// <summary>
    /// Project矩阵
    /// </summary>
    protected Matrix4x4 m_shadowProjectMatrix;

    /// <summary>
    /// 用于确定Project矩阵范围
    /// </summary>
    public static Bounds m_renderBounds;

    /// <summary>
    /// 当前开启状态
    /// </summary>
    public static bool IsFeatureEnable=false;

    public LayerMask LayerMask;

    /// <summary>
    /// ShadowMap尺寸
    /// </summary>
    public UnityEngine.ShadowResolution ShadowResolution = UnityEngine.ShadowResolution.Medium;

    public override void Create()
    {
        //在Unity的ShadowCast之后使用
        m_pass = new HighQualityShadowPass(RenderPassEvent.AfterRenderingShadows);
        m_renderBoundVertexs = new List<Vector3>();
    }
    
    void UpdateShadowMatrices(ref RenderingData renderingData)
    {
        int shadowLightIndex = renderingData.lightData.mainLightIndex;
        if (shadowLightIndex == -1)
            return;
        VisibleLight shadowLight = renderingData.lightData.visibleLights[shadowLightIndex];

        Transform lightTransform = shadowLight.light.transform;
        m_lightViewMatrix = lightTransform.worldToLocalMatrix;
        //if (SystemInfo.usesReversedZBuffer)
        //{
        //    m_lightViewMatrix.m20 = -m_lightViewMatrix.m20;
        //    m_lightViewMatrix.m21 = -m_lightViewMatrix.m21;
        //    m_lightViewMatrix.m22 = -m_lightViewMatrix.m22;
        //    m_lightViewMatrix.m23 = -m_lightViewMatrix.m23;
        //}

        //var extents = m_renderBounds.extents;
        Vector3 min = m_renderBounds.min;
        Vector3 max = m_renderBounds.max;
        Vector3 size = m_renderBounds.size;
        m_renderBoundVertexs.Clear();
        m_renderBoundVertexs.Add(min);
        m_renderBoundVertexs.Add(max);
        m_renderBoundVertexs.Add(min + new Vector3(size.x, 0, 0));
        m_renderBoundVertexs.Add(min + new Vector3(0, size.y, 0));
        m_renderBoundVertexs.Add(min + new Vector3(0, 0, size.z));
        m_renderBoundVertexs.Add(min + new Vector3(size.x, 0, size.z));
        m_renderBoundVertexs.Add(min + new Vector3(size.x, size.y, 0));
        m_renderBoundVertexs.Add(min + new Vector3(0, size.y, size.z));
        float xmin = float.MaxValue;
        float ymin = float.MaxValue;
        float zmin = float.MaxValue;
        float xmax = float.MinValue;
        float ymax = float.MinValue;
        float zmax = float.MinValue;
        foreach(Vector3 vertex in m_renderBoundVertexs)
        {
            Vector3 vertexLS = m_lightViewMatrix.MultiplyPoint(vertex);
            xmin = Mathf.Min(xmin, vertexLS.x);
            ymin = Mathf.Min(ymin, vertexLS.y);
            zmin = Mathf.Min(zmin, vertexLS.z);

            xmax = Mathf.Max(xmax, vertexLS.x);
            ymax = Mathf.Max(ymax, vertexLS.y);
            zmax = Mathf.Max(zmax, vertexLS.z);
        }

        float xSize = (xmax - xmin) * 0.5f;
        float ySize = (ymax - ymin) * 0.5f;
        float zSize = (zmax - zmin);
        float nearPlane = 0.1f;
        // P 矩阵
        m_shadowProjectMatrix = Matrix4x4.Ortho(-xSize, xSize, -ySize, ySize, nearPlane, nearPlane + zSize + 100.0f);

        Vector3 lightCamerWSPos = m_renderBounds.center - lightTransform.forward * (zSize * 0.5f + nearPlane);
        // V 矩阵
        //此处逆矩阵  https://docs.unity3d.com/cn/2019.4/ScriptReference/Rendering.CommandBuffer.SetViewProjectionMatrices.html
        // Final view matrix is inverse of the LookAt matrix, and then mirrored along Z.
        m_lightViewMatrix = Matrix4x4.TRS(lightCamerWSPos, lightTransform.rotation, Vector3.one).inverse;

        //相机Z轴反转
        Matrix4x4 reverseMatrix = Matrix4x4.identity;
        reverseMatrix.m22 = -1;//mirrored along Z.
        m_lightViewMatrix = reverseMatrix * m_lightViewMatrix;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (!IsFeatureEnable) return;
        int shadowLightIndex = renderingData.lightData.mainLightIndex;
        if (shadowLightIndex == -1)
            return;

        Vector3 boundSize = m_renderBounds.size;
        if (m_pass != null)
        {
            bool isBoundValid = boundSize.x > 0 && boundSize.y > 0 && boundSize.z > 0;
            if(isBoundValid) 
                UpdateShadowMatrices(ref renderingData); // VP矩阵
            int shadowResolution = 1024;
            switch(ShadowResolution)
            {
                case UnityEngine.ShadowResolution.Low:
                    shadowResolution = 512;
                    break;
                case UnityEngine.ShadowResolution.Medium:
                    shadowResolution = 1024;
                    break;
                case UnityEngine.ShadowResolution.High:
                    shadowResolution = 2048;
                    break;
                case UnityEngine.ShadowResolution.VeryHigh:
                    shadowResolution = 4096;
                    break;
            }

            m_pass.SetUp(shadowResolution,
                LayerMask.value,
                true,
                ref renderingData,
                ref m_lightViewMatrix,
                ref m_shadowProjectMatrix);
            
            renderer.EnqueuePass(m_pass);
        }
    }
}
