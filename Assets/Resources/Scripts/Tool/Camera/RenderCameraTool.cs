using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Render
{
    /// <summary>
    /// ���ڼ�������URPCamera.cs����Ƿ����
    /// </summary>
    public class RenderCameraTool
    {
#if UNITY_EDITOR

        /// <summary>
        /// ���Hierachy
        /// </summary>
        public static void CheckHierachyView()
        {
            Camera[] cams = GameObject.FindObjectsOfType<Camera>(true);
            for (int i = 0, listCount = cams.Length; i < listCount; ++i)
            {
                Camera cam = cams[i];
                if (cam != URPCamera.ResourcesTAGrabCamera)
                {
                    URPCamera urpCamera = cam.gameObject.GetComponent<URPCamera>();
                    if (urpCamera == null)
                    {
                        urpCamera = cam.gameObject.AddComponent<URPCamera>();
                    }
                }
            }
        }

        /// <summary>
        /// ���ѡ������
        /// </summary>
        public static void CheckSelect()
        {
            bool find = false;
            GameObject[] objs =UnityEditor.Selection.gameObjects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                if (CheckPrefab(objs[i], false))
                {
                    find = true;
                }
            }
            if (find)
            {
                UnityEditor.AssetDatabase.Refresh();
            }
        }

        /// <summary>
        /// ���ָ������
        /// </summary>
        /// <param name="obj"></param>
        public static bool CheckPrefab(GameObject obj, bool freshAsset)
        {
            bool find = false;
            Camera[] cams = obj.GetComponentsInChildren<Camera>(true);
            for (int i = 0, listCount = cams.Length; i < listCount; ++i)
            {
                Camera cam = cams[i];
                if (cam != URPCamera.ResourcesTAGrabCamera && cam != Resources.Load<Camera>(URPCamera.TAGrabCameraPath))
                {
                    URPCamera urpCamera = cam.gameObject.GetComponent<URPCamera>();
                    if (urpCamera == null)
                    {
                        find = true;
                        urpCamera = cam.gameObject.AddComponent<URPCamera>();
                    }
                    else
                    {
                        URPCamera[] urpCameras = cam.gameObject.GetComponents<URPCamera>();
                        if (urpCameras.Length > 0)
                        {
                            for (int j = 1, listCount2 = urpCameras.Length; j < listCount2; ++j)
                            {
                                if (Application.isPlaying)
                                {
                                    GameObject.Destroy(urpCameras[j]);
                                }
                                else
                                {
                                    GameObject.DestroyImmediate(urpCameras[j]);
                                }
                            }
                        }
                    }
                }
                else
                {
                    URPCamera urpCamera = cam.gameObject.GetComponent<URPCamera>();
                    while (urpCamera != null)
                    {
                        if (Application.isPlaying)
                        {
                            GameObject.Destroy(urpCamera);
                        }
                        else
                        {
                            GameObject.DestroyImmediate(urpCamera);
                        }
                        urpCamera = cam.gameObject.GetComponent<URPCamera>();
                    }
                }
            }
            if (find && freshAsset)
            {
                UnityEditor.AssetDatabase.Refresh();
            }
            return find;
        }

#endif
    }
}

