using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace Render
{
    /// <summary>
    /// 网格工具
    /// </summary>
    public class RenderModelTool
    {
        static float t = 0;

#if UNITY_EDITOR

        [UnityEditor.MenuItem("GameObject/RenderTool/模型/合并网格")]
        static void MeshCombine()
        {
            if ((Time.time - t) < 0.5f)
            {
                return;
            }
            t = Time.time;
            Dictionary<Material, Dictionary<Mesh, List<MeshFilter>>> meshList = new Dictionary<Material, Dictionary<Mesh, List<MeshFilter>>>();
            GameObject[] objs = UnityEditor.Selection.gameObjects;
            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
            {
                GameObject obj = objs[i];
                MeshFilter mf = obj.GetComponent<MeshFilter>();
                if (mf != null && mf.sharedMesh != null)
                {
                    MeshRenderer mr = obj.GetComponent<MeshRenderer>();
                    if (mr != null && mr.sharedMaterial != null)
                    {
                        Dictionary<Mesh, List<MeshFilter>> dic;
                        if (!meshList.TryGetValue(mr.sharedMaterial, out dic))
                        {
                            dic = new Dictionary<Mesh, List<MeshFilter>>();
                            meshList.Add(mr.sharedMaterial, dic);
                        }
                        List<MeshFilter> list;
                        if (!dic.TryGetValue(mf.sharedMesh, out list))
                        {
                            list = new List<MeshFilter>();
                            dic.Add(mf.sharedMesh, list);
                        }
                        list.Add(mf);
                    }
                }
            }
            Dictionary<Material, Dictionary<Mesh, List<MeshFilter>>>.Enumerator enumerator = meshList.GetEnumerator();
            List<Material> removeList1 = new List<Material>();
            while (enumerator.MoveNext())
            {
                Dictionary<Mesh, List<MeshFilter>> dic = enumerator.Current.Value;
                if (dic.Count <= 1)
                {
                    removeList1.Add(enumerator.Current.Key);
                }
            }
            for (int i = 0, listCount = removeList1.Count; i < listCount; ++i)
            {
                meshList.Remove(removeList1[i]);
            }
            if (meshList.Count > 0)
            {
                enumerator = meshList.GetEnumerator();
                while (enumerator.MoveNext())
                {
                    Material mat = enumerator.Current.Key;
                    //开始一个批次
                    GameObject newRoot = new GameObject("TempRoot");
                    newRoot.transform.position = Vector3.zero;
                    newRoot.transform.eulerAngles = Vector3.zero;
                    newRoot.transform.localScale = Vector3.one;
                    GameObject newMesh = new GameObject(mat.name + " MeshCombine");
                    newMesh.transform.position = Vector3.zero;
                    newMesh.transform.eulerAngles = Vector3.zero;
                    newMesh.transform.localScale = Vector3.one;
                    string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);
                    Dictionary<Mesh, List<MeshFilter>> dic = enumerator.Current.Value;
                    Dictionary<Mesh, List<MeshFilter>>.Enumerator enumerator2 = dic.GetEnumerator();
                    Dictionary<MeshFilter, Transform> oldParents = new Dictionary<MeshFilter, Transform>();
                    while (enumerator2.MoveNext())
                    {
                        List<MeshFilter> list = enumerator2.Current.Value;
                        for (int i = 0, listCount = list.Count; i < listCount; ++i)
                        {
                            oldParents.Add(list[i], list[i].transform.parent);
                            list[i].transform.SetParent(newRoot.transform, true);
                        }
                    }
                    string meshSavePath = GetCombineMeshSaveName(mat);
                    CombineMeshTo(newRoot, newMesh, meshSavePath);
                    Dictionary<MeshFilter, Transform>.Enumerator en = oldParents.GetEnumerator();
                    while (en.MoveNext())
                    {
                        en.Current.Key.transform.SetParent(en.Current.Value, true);
                    }
                    if (newRoot.transform.childCount == 0)
                    {
                        GameObject.DestroyImmediate(newRoot);
                    }
                    Debug. Log(string.Format("合并网格:{0}", meshSavePath));
                }
            }
        }

        static string GetCombineMeshSaveName(Material mat)
        {
            string assetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);
            if (string.IsNullOrEmpty(assetPath) || !assetPath.StartsWith("Assets/"))
            {
                assetPath = "Assets/MeshCombine/" + mat.name + ".mat";
            }
            string dir = Path.GetDirectoryName(assetPath) + "/CombineMesh/";
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
            string meshSavePath = dir + "CombineMesh_" + mat.name + "_0.mesh";
            string meshSaveFilePath = RenderTool.AssetPathToFilePath(meshSavePath);
            int index = 1;
            while (File.Exists(meshSaveFilePath))
            {
                meshSavePath = dir + "CombineMesh_" + mat.name + "_" + index + ".mesh";
                meshSaveFilePath = RenderTool.AssetPathToFilePath(meshSavePath);
                index++;
            }
            return meshSavePath;
        }

        static Mesh CombineMeshTo(GameObject meshesRoot, GameObject meshSave, string meshSavePath)
        {
            MeshFilter[] componentsInChildren = meshesRoot.GetComponentsInChildren<MeshFilter>();
            CombineInstance[] combine = new CombineInstance[componentsInChildren.Length];
            List<Material> materialList = new List<Material>();
            for (int index = 0; index < componentsInChildren.Length; ++index)
            {
                combine[index].mesh = componentsInChildren[index].sharedMesh;
                combine[index].transform =
                    Matrix4x4.TRS(componentsInChildren[index].transform.position - meshesRoot.transform.position,
                        componentsInChildren[index].transform.rotation,
                        componentsInChildren[index].transform.lossyScale);
                foreach (Material sharedMaterial in componentsInChildren[index].GetComponent<MeshRenderer>()
                             .sharedMaterials)
                {
                    if (!materialList.Contains(sharedMaterial))
                    {
                        materialList.Add(sharedMaterial);
                    }
                }

            }

            Mesh asset = new Mesh();
            asset.CombineMeshes(combine, true);
            asset.Optimize();
            MeshFilter meshFilter = meshSave.GetComponent<MeshFilter>();
            if ((UnityEngine.Object)meshFilter == (UnityEngine.Object)null)
                meshFilter = meshSave.AddComponent<MeshFilter>();
            MeshRenderer meshRenderer = meshSave.GetComponent<MeshRenderer>();
            if ((UnityEngine.Object)meshRenderer == (UnityEngine.Object)null)
                meshRenderer = meshSave.AddComponent<MeshRenderer>();
            MeshCollider meshCollider = meshSave.GetComponent<MeshCollider>();
            if ((UnityEngine.Object)meshCollider == (UnityEngine.Object)null)
                meshCollider = meshSave.AddComponent<MeshCollider>();
            meshFilter.sharedMesh = asset;
            meshCollider.sharedMesh = asset;
            meshRenderer.sharedMaterials = materialList.ToArray();
            UnityEditor.AssetDatabase.CreateAsset((UnityEngine.Object)asset, meshSavePath);
            UnityEditor.AssetDatabase.Refresh();
            return asset;
        }

#endif


    }
}

