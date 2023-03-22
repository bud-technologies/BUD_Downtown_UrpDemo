
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Render
{

    /// <summary>
    /// 用于监听材质球是否合规
    /// </summary>
    public class RenderMatCheck
    {

        static Shader _unityURPLitShader;

        static Shader unityURPLitShader
        {
            get
            {
                if (_unityURPLitShader == null)
                {
                    _unityURPLitShader = Shader.Find("Universal Render Pipeline/Lit");
                }
                return _unityURPLitShader;
            }
        }

        static Shader _standardShader;

        static Shader unityStandardShader
        {
            get
            {
                if (_standardShader == null)
                {
                    _standardShader = Shader.Find("Standard");
                }
                return _standardShader;
            }
        }

        static Shader _replaceShader;

        static Shader unityReplaceShader
        {
            get
            {
                if (_replaceShader == null)
                {
                    _replaceShader = Shader.Find("Unlit/Texture2");
                }
                return _replaceShader;
            }
        }

        static List<string> _matPaths;

        static List<string> matPaths
        {
            get
            {
                if (_matPaths == null)
                {
                    _matPaths = new List<string>();
                    //_matPaths.Add("Resources/unity_builtin_extra");//
                    _matPaths.Add("Packages/com.unity.render-pipelines.universal/Runtime/Materials/Lit.mat");
                }
                return _matPaths;
            }
        }

        static bool FinMat(string matPath)
        {
            bool find = false;
            for (int i = 0, listCount = matPaths.Count; i < listCount; ++i)
            {
                if (matPaths[i].StartsWith(matPath))
                {
                    find = true;
                    break;
                }
            }
            return find;
        }

        /// <summary>
        /// 替换fbx中的所有lit材质
        /// </summary>
        /// <param name="fbxAssetPathList"></param>
        public static void FbxLitMatReplace()
        {
            string[] strs = System.IO.Directory.GetFiles(Application.dataPath + "/Art/", "*.fbx", System.IO.SearchOption.AllDirectories);
            List<string> fbxAssetPathList = new List<string>();
            for (int i = 0, listCount = strs.Length; i < listCount; ++i)
            {
                fbxAssetPathList.Add(RenderTool.FilePathToAssetPath(strs[i]));
            }
            FbxLitMatReplace(fbxAssetPathList);
        }


        /// <summary>
        /// 替换fbx中的所有lit材质
        /// </summary>
        /// <param name="fbxAssetPathList"></param>
        static void FbxLitMatReplace(List<string> fbxAssetPathList)
        {
#if UNITY_EDITOR
            bool change = false;
            for (int c = 0, listCountFBX = fbxAssetPathList.Count; c < listCountFBX; ++c)
            {
                GameObject gm =UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(fbxAssetPathList[c]);
                UnityEngine.Renderer[] renders2 = gm.GetComponentsInChildren<UnityEngine.Renderer>();
                for (int j = 0, listCount2 = renders2.Length; j < listCount2; ++j)
                {
                    UnityEngine.Renderer r = renders2[j];
                    Material[] ms = r.sharedMaterials;
                    //替换默认材质
                    Material[] replaceMs = null;
                    for (int z = 0, listCount3 = ms.Length; z < listCount3; ++z)
                    {
                        Material mat = ms[z];
                        if (mat != null)
                        {
                            string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);//
                            Debug.LogError(matAssetPath);
                            if (!string.IsNullOrEmpty(matAssetPath) && FinMat(matAssetPath))
                            {

                                if (replaceMs == null)
                                {
                                    replaceMs = new Material[listCount3];
                                    for (int f = 0; f < z; ++f)
                                    {
                                        replaceMs[f] = ms[f];
                                    }
                                }
                                mat = Resources.Load<Material>("Materials/LitMatReplace");
                            }
                        }
                        if (replaceMs != null)
                        {
                            replaceMs[z] = mat;
                        }
                    }
                    if (replaceMs != null)
                    {
                        change = true;
                        r.sharedMaterials = replaceMs;
                    }
                }
            }
            if (change)
            {
                UnityEditor.AssetDatabase.Refresh();
            }
#endif
        }

        /// <summary>
        /// 检查选择物体
        /// </summary>
        public static void CheckSelect()
        {
#if UNITY_EDITOR
            bool change = false;
            UnityEngine.Object[] objs = UnityEditor.Selection.objects;
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                UnityEngine.Object obj = objs[i];
                if (obj != null)
                {
                    System.Type t = obj.GetType();
                    if (t == typeof(Material))
                    {
                        Material mat = (Material)obj;
                        if (mat.shader == unityURPLitShader || mat.shader == unityStandardShader || mat.shader == null)
                        {
                            mat.shader = unityReplaceShader;
                        }
                    }
                    else if (t == typeof(GameObject))
                    {
                        GameObject gm = (GameObject)obj;
                        string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                        if (string.IsNullOrEmpty(assetPath))
                        {
                            continue;
                        }
                        if (assetPath != null && assetPath.Trim().ToLower().EndsWith(".fbx"))
                        {
                            UnityEngine.Renderer[] renders2 = gm.GetComponentsInChildren<UnityEngine.Renderer>();
                            for (int j = 0, listCount2 = renders2.Length; j < listCount2; ++j)
                            {
                                UnityEngine.Renderer r = renders2[j];
                                Material[] ms = r.sharedMaterials;
                                //替换默认材质
                                Material[] replaceMs = null;
                                for (int z = 0, listCount3 = ms.Length; z < listCount3; ++z)
                                {
                                    Material mat = ms[z];
                                    if (mat != null)
                                    {
                                        string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);//
                                        if (!string.IsNullOrEmpty(matAssetPath) && FinMat(matAssetPath))
                                        {

                                            if (replaceMs == null)
                                            {
                                                replaceMs = new Material[listCount3];
                                                for (int f = 0; f < z; ++f)
                                                {
                                                    replaceMs[f] = ms[f];
                                                }
                                            }
                                            mat = Resources.Load<Material>("Materials/LitMatReplace");
                                        }
                                    }
                                    if (replaceMs != null)
                                    {
                                        replaceMs[z] = mat;
                                    }
                                }
                                if (replaceMs != null)
                                {
                                    change = true;
                                    r.sharedMaterials = replaceMs;
                                }
                            }
                            continue;
                        }

                        if (!assetPath.StartsWith("Assets/Art") || assetPath.StartsWith("Assets/Art/UI/"))
                        {
                            continue;
                        }
                        UnityEngine.Renderer[] renders = gm.GetComponentsInChildren<UnityEngine.Renderer>();
                        for (int j = 0, listCount2 = renders.Length; j < listCount2; ++j)
                        {
                            bool findNullMat = false;
                            UnityEngine.Renderer r = renders[j];
                            Material[] ms = r.sharedMaterials;
                            //替换默认材质
                            Material[] replaceMs = null;
                            for (int z = 0, listCount3 = ms.Length; z < listCount3; ++z)
                            {
                                Material mat = ms[z];
                                if (mat != null)
                                {
                                    string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);//
                                    if (!string.IsNullOrEmpty(matAssetPath) && FinMat(matAssetPath))
                                    {
                                        if (replaceMs == null)
                                        {
                                            replaceMs = new Material[listCount3];
                                            for (int f = 0; f < z; ++f)
                                            {
                                                replaceMs[f] = ms[f];
                                            }
                                        }
                                        mat = null;
                                    }
                                }
                                if (replaceMs != null)
                                {
                                    replaceMs[z] = mat;
                                }
                            }
                            if (replaceMs != null)
                            {
                                change = true;
                                r.sharedMaterials = replaceMs;
                            }
                            for (int z = 0, listCount3 = ms.Length; z < listCount3; ++z)
                            {
                                Material mat = ms[z];
                                if (mat != null)
                                {
                                    if (mat.shader == unityURPLitShader || mat.shader == unityStandardShader || mat.shader == null)
                                    {
                                        change = true;
                                        sb.Append(string.Format("英雄模型路径：{0}\n", assetPath));
                                        sb.Append(string.Format("材质使用了Shader\"Universal Render Pipeline/Lit\",自动替换为\"Unlit/Texture2\""));
                                        sb.Append(string.Format("节点：{0}\n", r.name));
                                        mat.shader = unityReplaceShader;
                                    }
                                    if (!string.IsNullOrEmpty(assetPath))
                                    {
                                        if (assetPath.StartsWith("Assets/ResAB/Prefab_Characters/"))
                                        {
                                            string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);//
                                            if (string.IsNullOrEmpty(matAssetPath) || !matAssetPath.StartsWith("Assets/Art/"))
                                            {
                                                if (!matAssetPath.EndsWith("ParticlesUnlit.mat"))
                                                {
                                                    sb.Append(string.Format("英雄模型路径：{0}\n", assetPath));
                                                    sb.Append(string.Format("节点：{0}\n", r.name));
                                                    sb.Append(string.Format("    错误的材质球路径：{0}\n", matAssetPath));
                                                    sb.Append(string.Format("    请使用指定路径的材质球：{0}\n", "Assets/Art/"));
                                                }
                                            }
                                            if (assetPath.StartsWith("Assets/ResAB/Prefab_Characters/Prefab_Hero") && matAssetPath.Contains("_LOD")
                                                && !mat.shader.name.Contains("Hero_Battle"))
                                            {
                                                sb.Append(string.Format("英雄模型路径：{0}\n", assetPath));
                                                sb.Append(string.Format("节点：{0}\n", r.name));
                                                sb.Append(string.Format("    错误的Shader：{0}\n", mat.shader.name));
                                                sb.Append(string.Format("    需要使用Shader：{0}\n", "Hero_Battle2"));
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    findNullMat = true;
                                }
                            }
                            if (findNullMat && !string.IsNullOrEmpty(assetPath))
                            {
                                sb.Append(string.Format("英雄模型材质球缺失：{0} ---缺失节点:{1} ---\n", assetPath, r.name));
                            }
                            if (ms.Length > 1)
                            {
                                sb.Append(string.Format("发现多维子网格：{0} 材质球数量大于1:{1} ---节点:{2} ---\n", assetPath, ms.Length, r.name));
                            }
                        }
                    }
                }
            }
            if (change)
            {
                UnityEditor.AssetDatabase.Refresh();
            }
            if (sb.Length > 0)
            {
                UnityEngine.Debug.Log(sb.ToString());
            }
#endif
        }

    }
}

