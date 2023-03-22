using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
/// <summary>
/// 镜面物体需要设置为"ReflectionScreen"层级
/// </summary>
public class SSPRRenderGameObject : MonoBehaviour
{

    public Shader baseShadowShader;

    public static List<SSPRRenderGameObject> objs = new List<SSPRRenderGameObject>();

    public static int SSPRRenderGameObjectCount
    {
        get
        {
            return objs.Count;
        }
    }

    Renderer renderer;

    Material shadowMat;

#if UNITY_EDITOR

    private void Update()
    {
        baseShadowShader = Shader.Find("NewRender/Standard/BaseShadowCast");
    }
#endif

    void Start()
    {
        if (baseShadowShader==null)
        {
            baseShadowShader = Shader.Find("NewRender/Standard/BaseShadowCast");
        }
        //设置自身不可见层级
        if (LayerMask.NameToLayer("ReflectionScreen") >= 0)
        {
            gameObject.layer = LayerMask.NameToLayer("ReflectionScreen");
        }
        else
        {
            UnityEngine.Debug.Log("Layer Not Find:ReflectionScreen");
        }

        MeshRenderer meshRenderer = gameObject.GetComponent<MeshRenderer>();
        SkinnedMeshRenderer skinnedMeshRenderer=null;
        if (meshRenderer!=null)
        {
            renderer = meshRenderer;
        }
        else
        {
            skinnedMeshRenderer= gameObject.GetComponent<SkinnedMeshRenderer>();
            renderer = skinnedMeshRenderer;
        }
        if (renderer!=null)
        {
            renderer.enabled = !renderer.enabled;
            renderer.enabled = !renderer.enabled;
            if (!Application.isPlaying)
            {
                Transform shadowObjTrans = transform.Find("ShadowObj");
                if (shadowObjTrans!=null)
                {
                    return;
                }
            }
            //创建阴影物体
            GameObject shadowObj = new GameObject("ShadowObj");
            shadowObj.transform.SetParent(transform,false);
            shadowObj.transform.localPosition = Vector3.zero;
            shadowObj.transform.localScale = Vector3.one;
            shadowObj.transform.localEulerAngles = Vector3.zero;
            if (meshRenderer!=null)
            {
                MeshFilter meshFilter = gameObject.GetComponent<MeshFilter>();
                if (meshFilter!=null)
                {
                    shadowObj.AddComponent<MeshFilter>().sharedMesh= meshFilter.sharedMesh;
                }
                MeshRenderer shadowMeshRenderer = shadowObj.AddComponent<MeshRenderer>();
                shadowMat = new Material(baseShadowShader);
                shadowMeshRenderer.sharedMaterial = shadowMat;
            }
            else
            {
                SkinnedMeshRenderer shadowSkinnedMeshRenderer = shadowObj.AddComponent<SkinnedMeshRenderer>();
                shadowSkinnedMeshRenderer.sharedMesh = skinnedMeshRenderer.sharedMesh;
                shadowSkinnedMeshRenderer.bones = skinnedMeshRenderer.bones;
                shadowSkinnedMeshRenderer.rootBone= skinnedMeshRenderer.rootBone;
                shadowMat = new Material(baseShadowShader);
                shadowSkinnedMeshRenderer.sharedMaterial = shadowMat;
            }
            renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        }
    }

    private void OnBecameInvisible()
    {
        if (Application.isPlaying)
        {
            objs.Remove(this);
        }
    }

    private void OnBecameVisible()
    {
        if (Application.isPlaying)
        {
            objs.Add(this);
        }
    }

    private void OnDestroy()
    {
        if (Application.isPlaying)
        {
            if (shadowMat!=null)
            {
                Destroy(shadowMat);
                shadowMat = null;
            }
            objs.Remove(this);
        }
    }
}
