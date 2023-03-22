using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System;
using System.Text;
using UnityEngine.Experimental.Rendering;

namespace Render
{
#if UNITY_EDITOR
    /// <summary>
    /// �˽ű����ڽ���������Ϊcubemap��6��ͼ���������µ�cubemap
    /// </summary>
    public class RenderCubeMapTool : UnityEditor.ScriptableWizard
    {
        [Header("Ҫ��Ⱦ����պ��б����SrcSkyBoxList��SrcCubemapSkyList��û��ָ���������Ⱦ��ǰ�Ļ�����")]
        public List<Material> SrcSkyBoxList = new List<Material>();

        [Header("Ҫ��Ⱦ����պ��б����SrcSkyBoxList��SrcCubemapSkyList��û��ָ���������Ⱦ��ǰ�Ļ�����")]
        public List<Cubemap> SrcCubemapSkyList = new List<Cubemap>();

        /// <summary>
        /// ������Cubemap��Ӧ�Ĳ��ʣ��ᱻɾ��
        /// </summary>
        static List<Material> CubemapMats = new List<Material>();

        [Header("��ȡͼƬ�ߴ�")]
        public ScreenSizeEnum ScreenSize = ScreenSizeEnum.X_1024;

        public enum ScreenSizeEnum
        {
            X_64 = 64,
            X_128 = 128,
            X_256 = 256,
            X_512 = 512,
            X_1024 = 1024,
            X_2048 = 2048,
        }

        /// <summary>
        /// �ȴ���Ⱦ����ղ���
        /// </summary>
        static List<Material> waitSkyMaterials = new List<Material>();

        /// <summary>
        /// �ȴ��洢��Cubemap
        /// </summary>
        static List<Cubemap> cubemaps = new List<Cubemap>();

        [Header("���ɵ�Cubemap�洢·��(���Զ�����)")]
        public string savePath;

        [Header("��Ⱦ���")]
        public Camera Camera;

        /// <summary>
        /// 360 ȫ�����
        /// </summary>
        static Camera panoramaCamera;

        /// <summary>
        /// ��¼ԭ����SkyBox�������ڻ�ԭ
        /// </summary>
        static Material quondamSkyBox;

        string[] skyBoxImage = new string[] { "_back", "_right", "_front", "_left", "_up", "_bottom" };

        Vector3[] skyDirection = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, -90, 0), new Vector3(0, 180, 0), new Vector3(0, 90, 0), new Vector3(-90, 180, 0), new Vector3(90, 180, 0) };

        Material currentMat;
        void OnWizardUpdate()
        {
            helpString = "Select transform to render from";
            isValid = (panoramaCamera != null);
        }

        void ThisUpdate()
        {
            if (readyOnWizardCreate)
            {
                if (onWizardCreateCount > 0)
                {
                    onWizardCreateCount--;
                    if (onWizardCreateCount == 0)
                    {
                        try
                        {
                            OnWizardCreateRun(currentMat);
                            if (waitSkyMaterials.Count == 0)
                            {
                                readyOnWizardCreate = false;
                                //�洢
                                int index = Application.dataPath.LastIndexOf("/");
                                string saveDir = Application.dataPath.Substring(0, index + 1) + savePath;
                                if (!Directory.Exists(saveDir))
                                {
                                    Directory.CreateDirectory(saveDir);
                                }
                                for (int i = 0, listCount = cubemaps.Count; i < listCount; ++i)
                                {
                                    string fileName = savePath + cubemaps[i].name + ".cubemap";
                                    UnityEditor.AssetDatabase.CreateAsset(cubemaps[i], fileName);
                                }
                            }
                        }
                        catch
                        {
                            UnityEditor.EditorUtility.ClearProgressBar();
                        }
                        UnityEditor.EditorUtility.ClearProgressBar();
                    }
                }
                else
                {
                    if (waitSkyMaterials.Count > 0)
                    {
                        currentMat = waitSkyMaterials[0];
                        if (currentMat == null)
                        {
                            UnityEditor.EditorUtility.DisplayCancelableProgressBar("��Ϣ", "����Cubemap:Null_Cubemap", waitSkyMaterials.Count / (float)allCount);
                        }
                        else
                        {
                            UnityEditor.EditorUtility.DisplayCancelableProgressBar("��Ϣ", string.Format("����Cubemap:{0}", currentMat.name), waitSkyMaterials.Count / (float)allCount);
                        }
                        waitSkyMaterials.RemoveAt(0);
                        RenderSettings.skybox = currentMat;
                        onWizardCreateCount = 3;
                    }
                }
            }
        }

        bool readyOnWizardCreate = false;

        int onWizardCreateCount = 0;

        int allCount = 0;

        void OnWizardCreate()
        {

        }

        void OnWizardOtherButton()
        {
            if (panoramaCamera == null) return;
            try
            {
                for (int i = 0, listCount = SrcSkyBoxList.Count; i < listCount; ++i)
                {
                    waitSkyMaterials.Add(SrcSkyBoxList[i]);
                }
                for (int i = 0, listCount = SrcCubemapSkyList.Count; i < listCount; ++i)
                {
                    Cubemap cubemapData = SrcCubemapSkyList[i];
                    if (cubemapData != null)
                    {
                        Material newMaterial = new Material(Shader.Find("Skybox/Cubemap"));
                        newMaterial.SetTexture("_Tex", cubemapData);
                        newMaterial.name = cubemapData.name;
                    }
                    else
                    {
                        waitSkyMaterials.Add(null);
                    }
                }
                if (waitSkyMaterials.Count == 0)
                {
                    waitSkyMaterials.Add(RenderSettings.skybox);
                }
                readyOnWizardCreate = true;
                onWizardCreateCount = 0;
                allCount = waitSkyMaterials.Count;
            }
            catch
            {
                Clear();
                Close();
            }
        }

        void OnWizardCreateRun(Material skyMat)
        {
            Camera targetCam = panoramaCamera;
            if (this.Camera != null)
            {
                targetCam = this.Camera;
            }
            targetCam.backgroundColor = Color.black;
            targetCam.clearFlags = CameraClearFlags.Skybox;
            targetCam.fieldOfView = 90;
            targetCam.aspect = 1.0f;
            targetCam.transform.rotation = Quaternion.identity;
            for (var orientation = 0; orientation < skyDirection.Length; orientation++)
            {
                renderSkyImage(orientation, targetCam.gameObject);
            }
            Cubemap cubemap = new Cubemap(128, TextureFormat.RGBA32, true);
            if (skyMat != null)
            {
                cubemap.name = skyMat.name;
            }
            else
            {
                cubemap.name = "Null_Cubemap";
            }
            cubemaps.Add(cubemap);
            targetCam.RenderToCubemap(cubemap);
        }

        [UnityEditor.MenuItem("Tools/RenderTool/CubeMap/360 ȫ�� ��Ⱦ6��ͼ", false, 4)]
        static void RenderSkyBox()
        {
            if (panoramaCamera == null)
            {
                GameObject obj = new GameObject("PanoramaCamera");
                panoramaCamera = obj.AddComponent<Camera>();
            }
            cubemaps.Clear();
            CubemapMats.Clear();
            waitSkyMaterials.Clear();
            quondamSkyBox = RenderSettings.skybox;
            RenderCubeMapTool sc = UnityEditor.ScriptableWizard.DisplayWizard<RenderCubeMapTool>("��Ⱦ����ΪCubemap", "�ر�!", "��Ⱦ");
            sc.savePath = "Assets/Standard Assets/TAWork/CreateCubeMap/";
            UnityEditor.EditorApplication.update -= sc.ThisUpdate;
            UnityEditor.EditorApplication.update += sc.ThisUpdate;
            sc.Camera = panoramaCamera;
        }

        void renderSkyImage(int orientation, GameObject go)
        {
            try
            {
                go.transform.eulerAngles = skyDirection[orientation];
                int screenSize = (int)ScreenSize;
                RenderTexture rt = new RenderTexture(screenSize, screenSize, 24);
                go.GetComponent<Camera>().targetTexture = rt;
                Texture2D screenShot = new Texture2D(screenSize, screenSize, TextureFormat.RGBA32, false);
                go.GetComponent<Camera>().Render();
                RenderTexture.active = rt;
                screenShot.ReadPixels(new Rect(0, 0, screenSize, screenSize), 0, 0);
                RenderTexture.active = null;
                byte[] bytes = screenShot.EncodeToPNG();
                string directory = "Assets/Skyboxes";
                if (!System.IO.Directory.Exists(directory))
                    System.IO.Directory.CreateDirectory(directory);
                System.IO.File.WriteAllBytes(System.IO.Path.Combine(directory, skyBoxImage[orientation] + ".png"), bytes);
                DestroyImmediate(rt);
            }
            catch (System.Exception ex)
            {
            }
        }

        void Clear()
        {
            UnityEditor.EditorApplication.update -= ThisUpdate;
            for (int i = 0, listCount = CubemapMats.Count; i < listCount; ++i)
            {
                if (CubemapMats[i] != null)
                {
                    DestroyImmediate(CubemapMats[i]);
                    CubemapMats[i] = null;
                }
            }
            CubemapMats.Clear();
            RenderSettings.skybox = quondamSkyBox;
            if (panoramaCamera != null)
            {
                DestroyImmediate(panoramaCamera.gameObject);
                panoramaCamera = null;
            }
        }

        private void OnDestroy()
        {
            Clear();
        }
    }

#endif
}


