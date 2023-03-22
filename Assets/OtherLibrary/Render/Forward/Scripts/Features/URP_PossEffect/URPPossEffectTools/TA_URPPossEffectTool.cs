using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// 用于特效组的后期特效效果调试
/// </summary>
public class TA_URPPossEffectTool
{

#if UNITY_EDITOR

    static URPPossEffectPrefab urpPossEffectPrefab;

    [MenuItem("GameObject/美术调试工具/场景颜色/场景颜色(灰色)", false, -1)]
    [MenuItem("Assets/美术调试工具/场景颜色/场景颜色(灰色)")]
    public static void ScenesColorGray()
    {
        if (urpPossEffectPrefab==null)
        {
            urpPossEffectPrefab = GameObject.FindObjectOfType<URPPossEffectPrefab>();
            if (urpPossEffectPrefab==null)
            {
                string assetPath = "Assets/Standard Assets/TAWork/Script/Common/URP_PossEffect/Prefab/URPPossEffectPrefab.prefab";
                GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
                obj = GameObject.Instantiate(obj);
                urpPossEffectPrefab = obj.GetComponent<URPPossEffectPrefab>();
            }
        }
        urpPossEffectPrefab.colorTypeParameter.value = UnityEngine.Experiemntal.Rendering.Universal.GamePossEffect.ColorType.Gray;
        FreshRender();
    }

    [MenuItem("GameObject/美术调试工具/场景颜色/场景颜色(彩色)", false, -1)]
    [MenuItem("Assets/美术调试工具/场景颜色/场景颜色(彩色)")]
    public static void ScenesColorReset()
    {
        if (urpPossEffectPrefab!=null)
        {
            urpPossEffectPrefab.colorTypeParameter.value = UnityEngine.Experiemntal.Rendering.Universal.GamePossEffect.ColorType.None;
            FreshRender();
        }
        else
        {
            urpPossEffectPrefab = GameObject.FindObjectOfType<URPPossEffectPrefab>();
            if (urpPossEffectPrefab != null)
            {
                urpPossEffectPrefab.colorTypeParameter.value = UnityEngine.Experiemntal.Rendering.Universal.GamePossEffect.ColorType.None;
                FreshRender();
            }
        }
    }

    [MenuItem("GameObject/美术调试工具/后期效果/添加一个后期效果")]
    static void AddGlobalVolume()
    {
        string assetPath = "Assets/Standard Assets/TAWork/Script/Common/URP_PossEffect/URPPossEffectTools/ToolScriptCreateGlobalVolume.prefab";
        GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
        string name = obj.name;
        Volume[] volumes = GameObject.FindObjectsOfType<Volume>();
        for (int i=0,listCount= volumes.Length;i< listCount;++i)
        {
            Volume volume = volumes[i];
            if (volume.gameObject.name.CompareTo(name) ==0)
            {
                GameObject.DestroyImmediate(volume.gameObject);
            }
        }
        obj = GameObject.Instantiate(obj);
        obj.name = name;
    }

    /// <summary>
    /// 刷新一下场景渲染
    /// </summary>
    static void FreshRender()
    {
        GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
        GameObject.DestroyImmediate(obj);
    }

#endif

}
