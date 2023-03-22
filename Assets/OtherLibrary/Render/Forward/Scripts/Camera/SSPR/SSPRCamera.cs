using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

/// <summary>
/// SSPR镜面发射 反射相机 ,缺点: Draw Call会翻倍
/// 由于SSR对于移动端不太友好，所以使用SSPR作为移动端的镜面反射
/// 适用场景：平面反射
/// 镜面物体需要设置为"ReflectionScreen"层级
/// </summary>
public class SSPRCamera : MonoBehaviour
{
    private Camera reflectionCamera = null;
    private RenderTexture reflectionRT = null;
    private UniversalAdditionalCameraData mainCameraData;
    private UniversalAdditionalCameraData reflectionCameraData;

    /// <summary>
    /// 可以用纯色Shader 用于减少性能损耗
    /// </summary>
    [Header("参与反射的替换Shader")]
    public Shader ReplaceShader;

    [Header("镜面反射平面")]
    public Transform PlantTransform;

    [Header("RT尺寸")]
    public int RTPixSize = 1024;

    private Vector3 normal;

    private Vector3 seaPosition;


    private void Start()
    {

        frameCount = -2;
        normal = PlantTransform.up;
        seaPosition = PlantTransform.position;
        lastAspect = Camera.main.aspect;
        mainCameraData = Camera.main.GetUniversalAdditionalCameraData();

        var go = new GameObject("Reflection Camera");
        reflectionCamera = go.AddComponent<Camera>();
        reflectionCamera.CopyFrom(Camera.main);
        if (LayerMask.NameToLayer("ReflectionScreen")>=0)
        {
            reflectionCamera.cullingMask = (reflectionCamera.cullingMask & ~(1 << LayerMask.NameToLayer("ReflectionScreen")));
        }
        else
        {
            UnityEngine.Debug.Log("Layer Not Find:ReflectionScreen");
        }
        reflectionCameraData = reflectionCamera.GetUniversalAdditionalCameraData();

        //reflectionRT = RenderTexture.GetTemporary(RTPixSize, RTPixSize, 16, RenderTextureFormat.RInt);
        reflectionRT = RenderTexture.GetTemporary(RTPixSize, RTPixSize, 16);

        reflectionCamera.targetTexture = reflectionRT;
        reflectionCamera.enabled = false;
        Shader.SetGlobalTexture("_ReflectionScreenTex", reflectionRT);
    }

    private void OnEnable()
    {
        Shader.EnableKeyword("ENABLE_SSPR");
    }

    private void OnDisable()
    {
        Shader.DisableKeyword("ENABLE_SSPR");
    }

    private void OnDestroy()
    {
        RenderTexture.ReleaseTemporary(reflectionRT);
    }

    int frameCount = 0;

    private void Update()
    {
        if (SSPRRenderGameObject.SSPRRenderGameObjectCount==0)
        {
            frameCount = 0;
            return;
        }
        if (frameCount<=0)
        {
            UpdateCameraParams(Camera.main, reflectionCamera);
            renderReflectionCamera();
        }
        else
        {
            frameCount++;
            if (frameCount>=3)
            {
                frameCount = 0;
            }
        }
    }

    /// <summary>
    /// 相机相对与平面的径向对称矩阵
    /// 由于计算相机相对于平面的对称点位置的矩阵
    /// </summary>
    /// <param name="normal">平面的法线</param>
    /// <param name="positionOnPlane">平面上的任一点</param>
    /// <returns></returns>
    Matrix4x4 CalculateReflectMatrix(Vector3 normal, Vector3 positionOnPlane, float d)
    {
        var reflectM = new Matrix4x4();
        float normalXX = 2 * normal.x * normal.x;
        float normalXY = 2 * normal.x * normal.y;
        float normalXZ = 2 * normal.x * normal.z;
        float normalXD = 2 * d * normal.x;
        float normalYY = 2 * normal.y * normal.y;
        float normalYZ = 2 * normal.y * normal.z;
        float normalYD = 2 * d * normal.y;
        float normalZZ = 2 * normal.z * normal.z;
        float normalZD = 2 * d * normal.z;

        reflectM.m00 = 1 - normalXX;
        reflectM.m01 = -normalXY;
        reflectM.m02 = -normalXZ;
        reflectM.m03 = -normalXD;

        reflectM.m10 = -normalXY;
        reflectM.m11 = 1 - normalYY;
        reflectM.m12 = -normalYZ;
        reflectM.m13 = -normalYD;

        reflectM.m20 = -normalXZ;
        reflectM.m21 = -normalYZ;
        reflectM.m22 = 1 - normalZZ;
        reflectM.m23 = -normalZD;

        reflectM.m30 = 0;
        reflectM.m31 = 0;
        reflectM.m32 = 0;
        reflectM.m33 = 1;

        return reflectM;
    }

    float lastAspect = 0;

    private void UpdateCameraParams(Camera srcCamera, Camera destCamera)
    {
        if (destCamera == null || srcCamera == null)
            return;
        if (reflectionCameraData.renderPostProcessing!= mainCameraData.renderPostProcessing)
        {
            reflectionCameraData.renderPostProcessing = mainCameraData.renderPostProcessing;
        }
        normal = PlantTransform.up;
        seaPosition = PlantTransform.position;
        if (lastAspect != srcCamera.aspect)
        {
            destCamera.orthographic = !destCamera.orthographic;
            lastAspect = srcCamera.aspect;
        }

        destCamera.aspect = srcCamera.aspect;
        destCamera.orthographicSize = srcCamera.orthographicSize;
        destCamera.clearFlags = srcCamera.clearFlags;
        destCamera.backgroundColor = srcCamera.backgroundColor;
        destCamera.farClipPlane = srcCamera.farClipPlane;
        destCamera.nearClipPlane = srcCamera.nearClipPlane;
        destCamera.orthographic = srcCamera.orthographic;
        destCamera.fieldOfView = srcCamera.fieldOfView;

    }

    private void renderReflectionCamera()
    {
        float d = -Vector3.Dot(normal, seaPosition);
        Matrix4x4 reflectM = CalculateReflectMatrix(normal, seaPosition,d);
        //对相机 MV 矩阵进行镜面对称处理
        reflectionCamera.worldToCameraMatrix = Camera.main.worldToCameraMatrix * reflectM;
        Vector4 plane = new Vector4(normal.x, normal.y, normal.z, d);
        reflectionCamera.projectionMatrix = CaculateObliqueViewFrusumMatrix(plane, reflectionCamera);
        GL.invertCulling = true;
        //此处可以对渲染目标进行材质设定
        if(ReplaceShader!=null)
        {
            reflectionCamera.RenderWithShader(ReplaceShader, "UniversalPipeline");
        }
        reflectionCamera.Render();
        GL.invertCulling = false;
    }

    /// <summary>
    /// 将平面作为相机近裁剪面，对平面下的进行剔除
    /// </summary>
    /// <param name="plane"></param>
    /// <param name="camera"></param>
    /// <returns></returns>
    private Matrix4x4 CaculateObliqueViewFrusumMatrix(Vector4 plane, Camera camera)
    {
        Vector4 viewSpacePlane = camera.worldToCameraMatrix.inverse.transpose * plane;
        Matrix4x4 projectionMatrix = camera.projectionMatrix;

        Vector4 clipSpaceFarPanelBoundPoint = new Vector4(Mathf.Sign(viewSpacePlane.x), Mathf.Sign(viewSpacePlane.y), 1, 1);
        Vector4 viewSpaceFarPanelBoundPoint = camera.projectionMatrix.inverse * clipSpaceFarPanelBoundPoint;

        Vector4 m4 = new Vector4(projectionMatrix.m30, projectionMatrix.m31, projectionMatrix.m32, projectionMatrix.m33);
        float u = 2.0f / Vector4.Dot(viewSpacePlane, viewSpaceFarPanelBoundPoint);
        Vector4 newViewSpaceNearPlane = u * viewSpacePlane;

        Vector4 m3 = newViewSpaceNearPlane - m4;

        projectionMatrix.m20 = m3.x;
        projectionMatrix.m21 = m3.y;
        projectionMatrix.m22 = m3.z;
        projectionMatrix.m23 = m3.w;

        return projectionMatrix;
    }
}
