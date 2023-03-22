using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// ������Ч��ĺ�����ЧЧ������
/// </summary>
public class TA_URPPossEffectTool
{

#if UNITY_EDITOR

    static URPPossEffectPrefab urpPossEffectPrefab;

    [MenuItem("GameObject/�������Թ���/������ɫ/������ɫ(��ɫ)", false, -1)]
    [MenuItem("Assets/�������Թ���/������ɫ/������ɫ(��ɫ)")]
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

    [MenuItem("GameObject/�������Թ���/������ɫ/������ɫ(��ɫ)", false, -1)]
    [MenuItem("Assets/�������Թ���/������ɫ/������ɫ(��ɫ)")]
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

    [MenuItem("GameObject/�������Թ���/����Ч��/���һ������Ч��")]
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
    /// ˢ��һ�³�����Ⱦ
    /// </summary>
    static void FreshRender()
    {
        GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
        GameObject.DestroyImmediate(obj);
    }

#endif

}
