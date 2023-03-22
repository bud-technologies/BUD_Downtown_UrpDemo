using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class URPPipeLineTool
{
    /// <summary>
    /// 设置管线为目标管线
    /// </summary>
    /// <param name="asset"></param>
    public static void SetPipeLine(RenderPipelineAsset asset)
    {
        GraphicsSettings.renderPipelineAsset = asset;
        QualitySettings.renderPipeline = asset;
    }

}
