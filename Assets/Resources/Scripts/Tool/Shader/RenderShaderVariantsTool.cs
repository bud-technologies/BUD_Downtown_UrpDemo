using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Linq;
using UnityEngine;
//#if UNITY_EDITOR
//using UnityEditor.SceneManagement;
//using UnityEditor;
//#endif

namespace Render
{

#if UNITY_EDITOR

    /// <summary>
    /// �˹�������������Ŀ��ʹ�õĲ�����ı����ļ�--void ShaderVariantsCreate()��ͨ���ڴ��֮ǰ��Ҫ����һ�飬���е�ʱ����ú���Ԥ���ر���--LoadShaderVariants()
    /// </summary>
    public class RenderShaderVariantsTool
    {
        /// <summary>
        /// ����洢·��
        /// </summary>
        public static string ShaderVariantCollectionPath = "Assets/ShaderVariantCollection.shadervariants";

        /// <summary>
        /// Ԥ����Shader����
        /// </summary>
        public static void LoadShaderVariants()
        {
            ShaderVariantCollection shaderVariantCollection = null;
            if (Application.isPlaying)
            {
                //ɾ��Xasset��������
                //libx.Assets.LoadAsset(ShaderVariantCollectionPath,typeof(ShaderVariantCollection),(data)=> {
                //    if (data!=null)
                //    {
                //        if (data.asset!=null)
                //        {
                //            shaderVariantCollection = data.asset as ShaderVariantCollection;
                //        }
                //        else
                //        {
                //            libx.Assets.UnloadAsset(data);
                //        }
                //    }
                //});
            }
            else
            {
#if UNITY_EDITOR
                shaderVariantCollection = UnityEditor.AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(ShaderVariantCollectionPath);
#endif
            }
            if (shaderVariantCollection != null)
            {
                shaderVariantCollection.WarmUp();
            }
        }

        /// <summary>
        /// LightMap�����⿪�� ����������Ƿ���LightMap����
        /// </summary>
        public static bool LightMap = true;

        /// <summary>
        /// Fog�����⿪��
        /// </summary>
        public static bool Fog = true;

        /// <summary>
        /// AmbientMode�����⿪��
        /// </summary>
        public static bool AmbientMode = true;

#if UNITY_EDITOR

        /// <summary>
        /// ����unity shader�����ļ�
        /// </summary>
        public static void ShaderVariantsCreate()
        {
            UnityEditor.EditorUtility.ClearProgressBar();
            //
            List<string> paths = new List<string>() {
            "Assets/ResAB/",
            "Assets/TextMesh Pro/Resources/",
            "Assets/TextMesh Pro/Examples & Extras/Resources/",
            "Assets/Standard Assets/ToolGroup/RuntimeTools/DebugerPanel/Resources/",
            "Assets/Standard Assets/TAWork/Resources/",
            "Assets/Standard Assets/StompyRobot/SRDebugger/usr/Resources/",
            "Assets/Standard Assets/StompyRobot/SRDebugger/Resources/",
            "Assets/AGE/Action/Prefab/Resources",
            "Assets/XLua/Resources",
            "Assets/Resources",
            "Assets/Plugins/AkSoundEngine.bundle/Contents/Resources",
            "Assets/Art/Shaders/VFX/UI/SSFS_v16/src/Resources",
            "Assets/Art/Shaders/Resources",
            "Assets/Standard Assets/PigeonCoopToolkit/Shared/Generic/Resources",
            "Assets/XLua/Tutorial/LoadLuaScript/ByFile/Resources",
            "Assets/AssetBundles/"
        };
            //
            List<string> assetPaths = new List<string>();
            for (int i = 0, listCount = paths.Count; i < listCount; ++i)
            {
                string path = RenderTool.AssetPathToFilePath(paths[i]);
                ResourceDetection.GetAllFilesSuffix(path, "prefab", assetPaths);
                ResourceDetection.GetAllFilesSuffix(path, "asset", assetPaths);
            }
            //
            UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ"), "", 1);
            if (allMaterials == null)
            {
                allMaterials = new List<Material>();
            }
            else
            {
                allMaterials.Clear();
            }
            string[] dependencies = UnityEditor.AssetDatabase.GetDependencies(assetPaths.ToArray(), true);
            for (int i = 0, listCount = dependencies.Length; i < listCount; ++i)
            {
                string assetPath = dependencies[i];
                if (assetPath.EndsWith(".mat"))
                {
                    Material mat = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                    if (mat != null && mat.shader != null)
                    {
                        allMaterials.Add(mat);
                    }
                }
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            //��¼һ�µ�ǰ�������������֮��ָ�
            activeScenePath = UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene().path;
            StartEditorUpdate();
            //�����µĳ���
            UnityEditor.SceneManagement.EditorSceneManager.NewScene(UnityEditor.SceneManagement.NewSceneSetup.DefaultGameObjects);
        }

        static string activeScenePath;

        static List<Material> allMaterials;

        static void StartEditorUpdate()
        {
            UnityEditor.EditorApplication.update -= EditorUpdate;
            UnityEditor.EditorApplication.update += EditorUpdate;
            isCheckAllMaterials = true;
        }

        static void CloseEditorUpdate()
        {
            UnityEditor.EditorApplication.update -= EditorUpdate;
        }

        static void EditorUpdate()
        {
            if (!isCheckAllMaterials)
            {
                if (checkAllMaterialsCount > 0)
                {
                    //������Ⱦʵ��ǿ�ƿ��� fog �� lightMap
                    switch (checkAllMaterialsCount)
                    {
                        case 9:
                            {
                                //lightMap���ر� ��Ч���ر� AmbientMode:SkyBox
                                if (LightMap)
                                {
                                    OpenLightMap(false);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = false;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
                                }
                            }
                            break;
                        case 8:
                            {
                                //lightMap���ر� ��Ч������  AmbientMode:SkyBox
                                if (LightMap)
                                {
                                    OpenLightMap(false);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = true;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
                                }
                            }
                            break;
                        case 7:
                            {
                                //lightMap������ ��Ч���ر�  AmbientMode:SkyBox
                                if (LightMap)
                                {
                                    OpenLightMap(true);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = false;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
                                }
                            }
                            break;
                        case 6:
                            {
                                //lightMap������ ��Ч������  AmbientMode:SkyBox
                                if (LightMap)
                                {
                                    OpenLightMap(true);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = true;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Skybox;
                                }
                            }
                            break;
                        case 5:
                            {
                                //lightMap���ر� ��Ч���ر� AmbientMode:Flat
                                if (LightMap)
                                {
                                    OpenLightMap(false);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = false;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
                                }
                            }
                            break;
                        case 4:
                            {
                                //lightMap���ر� ��Ч������  AmbientMode:Flat
                                if (LightMap)
                                {
                                    OpenLightMap(false);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = true;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
                                }
                            }
                            break;
                        case 3:
                            {
                                //lightMap������ ��Ч���ر�  AmbientMode:Flat
                                if (LightMap)
                                {
                                    OpenLightMap(true);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = false;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
                                }
                            }
                            break;
                        case 2:
                            {
                                //lightMap������ ��Ч������  AmbientMode:Flat
                                if (LightMap)
                                {
                                    OpenLightMap(true);
                                }
                                if (Fog)
                                {
                                    RenderSettings.fog = true;
                                }
                                if (AmbientMode)
                                {
                                    RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
                                }
                            }
                            break;
                    }
                    checkAllMaterialsCount--;
                }
                else
                {
                    InvokeInternalStaticMethod(typeof(UnityEditor.ShaderUtil), "SaveCurrentShaderVariantCollection", ShaderVariantCollectionPath);
                    UnityEngine.Debug.LogError("Shader�����ռ���ɣ�·����" + ShaderVariantCollectionPath);
                    CloseEditorUpdate();
                    UnityEditor.SceneManagement.EditorSceneManager.OpenScene(activeScenePath, UnityEditor.SceneManagement.OpenSceneMode.Single);
                }
            }
            CheckAllMaterials();
        }

        static bool isCheckAllMaterials = false;

        static int checkAllMaterialsCount = 0;

        static void CheckAllMaterials()
        {
            if (!isCheckAllMaterials) return;
            renders.Clear();
            checkAllMaterialsCount = 10;
            //InvokeInternalStaticMethod(typeof(ShaderUtil), "ClearCurrentShaderVariantCollection");
            RenderTexture rt = new RenderTexture(512, 512, 0);
            //
            Camera camera = Camera.main;
            float aspect = camera.aspect;
            int totalMaterials = allMaterials.Count;
            float height = Mathf.Sqrt(totalMaterials / aspect) + 1;
            float width = Mathf.Sqrt(totalMaterials / aspect) * aspect + 1;
            float halfHeight = Mathf.CeilToInt(height / 2f);
            float halfWidth = Mathf.CeilToInt(width / 2f);
            camera.orthographic = true;
            camera.orthographicSize = halfHeight;
            camera.transform.position = new Vector3(0f, 0f, -10f);
            UnityEditor.Selection.activeGameObject = camera.gameObject;
            UnityEditor.EditorApplication.ExecuteMenuItem("GameObject/Align View to Selected");
            int xMax = (int)(width - 1);
            int x = 0;
            int y = 0;
            //
            for (int i = 0; i < totalMaterials; ++i)
            {
                Material mat = allMaterials[i];
                Vector3 position = new Vector3(x - halfWidth + 1f, y - halfHeight + 1f, 0f);
                CreateSphere(mat, position, x, y, i);
                if (x == xMax)
                {
                    x = 0;
                    y++;
                }
                else
                {
                    x++;
                }
            }
            //camera.targetTexture = rt;
            //camera.RenderDontRestore();
            isCheckAllMaterials = false;
        }

        /// <summary>
        /// ������ر�lightMap
        /// </summary>
        /// <param name="bl"></param>
        static void OpenLightMap(bool bl)
        {
            if (bl)
            {
                LightmapSettings.lightmapsMode = LightmapsMode.NonDirectional;
                LightmapData[] lightmapDatas = new LightmapData[1];
                LightmapData Lightmap = new LightmapData();
                Lightmap.lightmapColor = new Texture2D(512, 512);
                Lightmap.lightmapDir = null;
                lightmapDatas[0] = Lightmap;
                LightmapSettings.lightmaps = lightmapDatas;
                for (int i = 0, listCount = renders.Count; i < listCount; ++i)
                {
                    renders[i].lightmapIndex = 0;
                }
            }
            else
            {
                LightmapSettings.lightmaps = null;
                for (int i = 0, listCount = renders.Count; i < listCount; ++i)
                {
                    renders[i].lightmapIndex = -1;
                }
            }
        }

        static List<Renderer> renders = new List<Renderer>();

        static void CreateSphere(Material material, Vector3 position, int x, int y, int index)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            Renderer renderer = go.GetComponent<Renderer>();
            renders.Add(renderer);
            renderer.material = material;
            //go.GetComponent<Renderer>().lightmapIndex = 0;
            go.transform.position = position;
            go.name = string.Format("Sphere_{0}|{1}_{2}|{3}", index, x, y, material.name);
        }

        /// <summary>
        /// ����һ��˽�еľ�̬������ִ��
        /// </summary>
        /// <param name="type"></param>
        /// <param name="method"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        private static object InvokeInternalStaticMethod(System.Type type, string method, params object[] parameters)
        {
            var methodInfo = type.GetMethod(method, BindingFlags.NonPublic | BindingFlags.Static);
            if (methodInfo == null)
            {
                UnityEngine.Debug.LogError(string.Format("{0} method didn't exist", method));
                return null;
            }
            return methodInfo.Invoke(null, parameters);
        }

#endif
    }

#endif

}

