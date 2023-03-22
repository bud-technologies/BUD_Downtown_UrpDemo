using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
#endif

/// <summary>
/// URP管线下 多相机渲染会有问题，UI相机的背景会遮挡主相机，
/// 需要将主相机设置为CameraRenderType.Base，
/// 其他相机设置为CameraRenderType.Overlay，并加入到主相机的堆栈中
/// “MainCamera”会设置为base
/// 其他的会设置为Overlay
/// 如果没有“MainCamera”，会将深度最小相机设置为base
/// </summary>
public class URPCamera : MonoBehaviour
{

#if UNITY_EDITOR

    //[MenuItem("XASSET/PrefabFindCamera(URPCamera)")]
    /// <summary>
    /// 查找没有URPCamera的预制体
    /// </summary>
    public static void PrefabFindCamera()
    {
        StringBuilder stringBuilder = new StringBuilder();
        string[] strs = AssetDatabase.GetAllAssetPaths();
        for (int i = 0, listCount = strs.Length; i < listCount; ++i)
        {
            string path = strs[i];
            if (EditorUtility.DisplayCancelableProgressBar(string.Format("进度:{0}/{1}", i, listCount), path,
         i / (float)listCount)) break;
            if (path.EndsWith(".prefab"))
            {
                GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (obj != null)
                {
                    Camera[] cams = obj.GetComponentsInChildren<Camera>(true);
                    bool find = false;
                    for (int j = 0, listCount2 = cams.Length; j < listCount2; ++j)
                    {
                        Camera cam = cams[j];
                        URPCamera[] urpCameras = cam.gameObject.GetComponents<URPCamera>();
                        if (urpCameras.Length == 0 || urpCameras.Length > 1)
                        {
                            //发现不合规
                            if (!find)
                            {
                                find = true;
                                stringBuilder.Append("Path:" + path);
                                stringBuilder.Append("\n");
                            }
                            stringBuilder.Append("        Cam:" + cams[j]);
                            stringBuilder.Append("\n");
                        }
                    }
                    URPCamera[] allUrpCameras = obj.GetComponentsInChildren<URPCamera>(true);
                    for (int j = 0, listCount2 = allUrpCameras.Length; j < listCount2; ++j)
                    {
                        Camera cam = allUrpCameras[j].gameObject.GetComponent<Camera>();
                        //发现不合规
                        if (cam == null)
                        {
                            if (!find)
                            {
                                find = true;
                                stringBuilder.Append("Path:" + path);
                                stringBuilder.Append("\n");
                            }
                            stringBuilder.Append("        URPCamera:" + allUrpCameras[j]);
                            stringBuilder.Append("\n");
                        }
                    }
                    //if (cams.Length > 0)
                    //{
                    //    stringBuilder.Append("Path:" + path);
                    //    stringBuilder.Append("\n");
                    //    for (int j = 0, listCount2 = cams.Length; j < listCount2; ++j)
                    //    {
                    //        stringBuilder.Append("        Cam:" + cams[j]);
                    //        stringBuilder.Append("\n");
                    //    }
                    //}
                }

            }
        }
        EditorUtility.ClearProgressBar();
        Debug.LogError(stringBuilder.ToString());
    }

#endif

    public static string TAGrabCameraPath = "TAWork/TAGrabCameraPrefab";

    /// <summary>
    /// 用于抓图的相机
    /// </summary>
    static Camera taGrabCamera = null;

    static UniversalAdditionalCameraData taCameraData;

    /// <summary>
    /// 用于抓图的相机 此相机要求 关闭post processing,clear depth,render shadows,occlusion culling,culling mask=nothing
    /// </summary>
    public static Camera TAGrabCamera
    {
        get
        {
            //if (taGrabCamera==null)
            //{
            //    taGrabCamera = Resources.Load<Camera>(TAGrabCameraPath);
            //    taGrabCamera = Instantiate(taGrabCamera.gameObject).GetComponent<Camera>();
            //    taGrabCamera.transform.eulerAngles = new Vector3(90,0,0);
            //    taGrabCamera.transform.position = new Vector3(0,-1000,0);
            //    taCameraData = taGrabCamera.GetUniversalAdditionalCameraData();
            //    while (taCameraData==null)
            //    {
            //        taCameraData = taGrabCamera.GetUniversalAdditionalCameraData();
            //    }
            //}
            //taCameraData.renderPostProcessing = false;
            //taCameraData.renderShadows = false;
            //taGrabCamera.cullingMask = 0;
            return taGrabCamera;
        }
    }

    public static Camera ResourcesTAGrabCamera
    {
        get
        {
            return taGrabCamera;
        }
    }
    public static void FreshAll()
    {
        Camera[] cams = GameObject.FindObjectsOfType<Camera>(true);
        for (int i = 0, listCount = cams.Length; i < listCount; ++i)
        {
            if (cams[i].gameObject.GetComponent<URPCamera>() == null && taGrabCamera != cams[i])
            {
                cams[i].gameObject.AddComponent<URPCamera>();
            }
        }
        FreshCamerasStack();
    }

    UniversalAdditionalCameraData cameraData;

    /// <summary>
    /// 相机的URP数据
    /// </summary>
    public UniversalAdditionalCameraData CameraData
    {
        get
        {
            if (cameraData == null && thisCamera != null)
            {
                cameraData = thisCamera.GetUniversalAdditionalCameraData();
                while (cameraData == null)
                {
                    cameraData = thisCamera.GetUniversalAdditionalCameraData();
                }
                //用于渲染抓屏扭曲
                //cameraData.renderPostProcessing = true;
            }
            return cameraData;
        }
    }

    Camera _camera;

    /// <summary>
    /// 相机组件
    /// </summary>
    public Camera thisCamera
    {
        get
        {
            if (_camera == null)
            {
                _camera = gameObject.GetComponent<Camera>();
            }
            return _camera;
        }
    }

    /// <summary>
    /// 设置相机的类型 ，只能通过此函数设置，public变量CameraRenderType是无效的
    /// </summary>
    /// <param name="type"></param>
    public void SetRenderType(CameraRenderType type, bool fresh)
    {
        CameraData.renderType = type;
        if (CameraData.renderType == CameraRenderType.Overlay)
        {
            if (enableBaseCamList.Contains(this))
            {
                enableBaseCamList.Remove(this);
                enableOverlayCamList.Add(this);
            }
            else
            {
                if (!enableOverlayCamList.Contains(this))
                {
                    enableOverlayCamList.Add(this);
                }
            }
        }
        else
        {
            if (enableOverlayCamList.Contains(this))
            {
                enableOverlayCamList.Remove(this);
                enableBaseCamList.Add(this);
            }
            else
            {
                if (!enableBaseCamList.Contains(this))
                {
                    enableBaseCamList.Add(this);
                }
            }
        }
        if (fresh)
        {
            FreshCamerasStack();
        }
    }

    /// <summary>
    /// key=检测到的相机 value=是否启用
    /// </summary>
    static Dictionary<URPCamera, bool> cameras = new Dictionary<URPCamera, bool>();

    /// <summary>
    /// 当前正在使用的主相机
    /// </summary>
    static List<URPCamera> enableBaseCamList = new List<URPCamera>();

    /// <summary>
    /// 当前正在使用叠加相机
    /// </summary>
    static List<URPCamera> enableOverlayCamList = new List<URPCamera>();

    /// <summary>
    /// 添加一个相机
    /// </summary>
    /// <param name="urpCamera"></param>
    /// <param name="enable"></param>
    static void AddOneCamera(URPCamera urpCamera, bool enable)
    {
        if (cameras.ContainsKey(urpCamera))
        {
            cameras[urpCamera] = enable;
        }
        else
        {
            cameras.Add(urpCamera, enable);
        }
        if (enable)
        {
            if (urpCamera.CameraData.renderType != CameraRenderType.Overlay)
            {
                if (!enableBaseCamList.Contains(urpCamera))
                {
                    enableBaseCamList.Add(urpCamera);
                }
            }
            else
            {
                if (!enableOverlayCamList.Contains(urpCamera))
                {
                    enableOverlayCamList.Add(urpCamera);
                }
            }
        }
        else
        {
            enableBaseCamList.Remove(urpCamera);
            enableOverlayCamList.Remove(urpCamera);
        }
        FreshCamerasStack();
    }

    /// <summary>
    /// 移除一个相机
    /// </summary>
    /// <param name="urpCamera"></param>
    static void RemoveOneCamera(URPCamera urpCamera)
    {
        cameras.Remove(urpCamera);
        enableBaseCamList.Remove(urpCamera);
        enableOverlayCamList.Remove(urpCamera);
        FreshCamerasStack();
    }

    /// <summary>
    /// 刷新相机的堆栈设置
    /// </summary>
    static void FreshCamerasStack()
    {
        //查找主相机标签
        URPCamera mainCam = null;
        URPCamera norCam = null;
        for (int i = 0, listCount = enableBaseCamList.Count; i < listCount; ++i)
        {
            if (enableBaseCamList[i] == null)
            {
                enableBaseCamList.RemoveAt(i);
                i--;
                listCount--;
                continue;
            }
            if (enableBaseCamList[i].gameObject.CompareTag("MainCamera"))
            {
                if (mainCam == null)
                {
                    mainCam = enableBaseCamList[i];
                }
                else
                {
                    if (mainCam.thisCamera.depth > enableBaseCamList[i].thisCamera.depth)
                    {
                        mainCam = enableBaseCamList[i];
                    }
                }
            }
            else
            {
                if (norCam == null)
                {
                    norCam = enableBaseCamList[i];
                }
                else
                {
                    if (norCam.thisCamera.depth > enableBaseCamList[i].thisCamera.depth)
                    {
                        norCam = enableBaseCamList[i];
                    }
                }
            }
            if (enableBaseCamList[i].CameraData.renderType == CameraRenderType.Base && enableBaseCamList[i].CameraData.cameraStack != null)
            {
                enableBaseCamList[i].CameraData.cameraStack.Clear();
            }
        }
        for (int i = 0, listCount = enableOverlayCamList.Count; i < listCount; ++i)
        {
            if (enableOverlayCamList[i] == null)
            {
                enableOverlayCamList.RemoveAt(i);
                i--;
                listCount--;
                continue;
            }
            if (enableOverlayCamList[i].gameObject.CompareTag("MainCamera"))
            {
                if (mainCam == null)
                {
                    mainCam = enableOverlayCamList[i];
                }
                else
                {
                    if (mainCam.thisCamera.depth > enableOverlayCamList[i].thisCamera.depth)
                    {
                        mainCam = enableOverlayCamList[i];
                    }
                }
            }
            else
            {
                if (norCam == null)
                {
                    norCam = enableOverlayCamList[i];
                }
                else
                {
                    if (norCam.thisCamera.depth > enableOverlayCamList[i].thisCamera.depth)
                    {
                        norCam = enableOverlayCamList[i];
                    }
                }
            }
            if (enableOverlayCamList[i].CameraData.renderType == CameraRenderType.Base && enableOverlayCamList[i].CameraData.cameraStack != null)
            {
                enableOverlayCamList[i].CameraData.cameraStack.Clear();
            }
        }
        if (mainCam == null)
        {
            //找一个深度最低的

            if (norCam != null)
            {
                enableBaseCamList.Remove(norCam);
                for (int i = 0, listCount = enableBaseCamList.Count; i < listCount; ++i)
                {
                    enableBaseCamList[i].SetRenderType(CameraRenderType.Overlay, false);
                }
                norCam.SetRenderType(CameraRenderType.Base, false);
            }
        }
        else
        {
            enableBaseCamList.Remove(mainCam);
            for (int i = 0, listCount = enableBaseCamList.Count; i < listCount; ++i)
            {
                enableBaseCamList[i].SetRenderType(CameraRenderType.Overlay, false);
            }
            mainCam.SetRenderType(CameraRenderType.Base, false);
        }
        if (enableOverlayCamList.Count > 0)
        {
            //将所有的Overlay相机加入到主相机的堆栈
            for (int i = 0, listCount = enableOverlayCamList.Count; i < listCount; ++i)
            {
                for (int j = 0, listCount2 = enableBaseCamList.Count; j < listCount2; ++j)
                {
                    enableBaseCamList[j].CameraData.cameraStack.Add(enableOverlayCamList[i].thisCamera);
                    if (i == listCount - 1)
                    {
                        enableBaseCamList[j].CameraData.cameraStack.Sort(
                            (A, B) =>
                            {
                                return A.gameObject.GetComponent<URPCamera>().thisCamera.depth.CompareTo(B.gameObject.GetComponent<URPCamera>().thisCamera.depth);
                            }
                            );
                        enableBaseCamList[j].CameraData.cameraStack.Add(TAGrabCamera);
                    }
                }
            }
        }
        else
        {
            for (int j = 0, listCount2 = enableBaseCamList.Count; j < listCount2; ++j)
            {
                enableBaseCamList[j].CameraData.cameraStack.Add(TAGrabCamera);
            }
        }
    }
    private void Start()
    {
        if (thisCamera != taGrabCamera)
        {
            URPCamera urpCamera = gameObject.GetComponent<URPCamera>();
            if (urpCamera != null && urpCamera != this)
            {
                Destroy(this);
                return;
            }
            if (thisCamera.activeTexture == null||thisCamera.CompareTag("CameraCapRT"))
                FreshCamerasStack();
            thisCamera.allowHDR = true;
            CameraData.renderPostProcessing = false;
            //CameraData.requiresColorOption = UnityEngine.Rendering.Universal.CameraOverrideOption.UsePipelineSettings;
        }
        else
        {
            Destroy(this);
        }
    }

    bool thisEnble = false;
    private void OnEnable()
    {
        thisEnble = true;
        Fresh();
    }

    private void OnDisable()
    {
        thisEnble = false;
        Fresh();
    }

    private void OnDestroy()
    {
        RemoveOneCamera(this);
    }

    void Fresh()
    {
        if (gameObject.layer == UnityEngine.LayerMask.NameToLayer("GrabPassCamera"))
        {
            Destroy(this);
            return;
        }
        if (thisCamera.activeTexture != null || thisCamera.CompareTag("CameraCapRT"))
            return;
        if (thisEnble && camIsEnable)
        {
            AddOneCamera(this, true);
        }
        else
        {
            AddOneCamera(this, false);
        }

    }

    bool camIsEnable = false;

    private void Update()
    {
        if (camIsEnable != thisCamera.enabled)
        {
            camIsEnable = thisCamera.enabled;
            Fresh();
        }
        //if (CameraData!=null)
        //{
        //    CameraData.renderPostProcessing = true;
        //}
    }
}
