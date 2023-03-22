using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Render
{
    public class RenderPipeLineTool
    {
        /// <summary>
        /// 设置管线为目标管线
        /// </summary>
        /// <param name="asset"></param>
        public static void SetPipeLine(RenderPipelineAsset asset)
        {
            GraphicsSettings.renderPipelineAsset = asset;
        }
    }
}


