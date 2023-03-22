using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectUniversal
{

    static Mesh plantMesh;

    /// <summary>
    /// 单位网格
    /// </summary>
    public static Mesh UnitMesh
    {
        get
        {
            if (plantMesh==null)
            {
                plantMesh = new Mesh();
                plantMesh.name = "UnitMesh";
                //
                Vector3[] vertices = new Vector3[6];
                vertices[0] = new Vector3(0.5f,0.5f,0);
                vertices[1] = new Vector3(-0.5f, 0.5f, 0);
                vertices[2] = new Vector3(-0.5f, -0.5f, 0);
                vertices[3] = new Vector3(0.5f, 0.5f, 0);
                vertices[4] = new Vector3(-0.5f, -0.5f, 0);
                vertices[5] = new Vector3(0.5f, -0.5f, 0);
                plantMesh.vertices = vertices;
                //
                int[] triangles = new int[6];
                triangles[0] = 0;
                triangles[1] = 1;
                triangles[2] = 2;
                triangles[3] = 3;
                triangles[4] = 4;
                triangles[5] = 5;
                plantMesh.triangles = triangles;
                //UV
                Vector2[] uv = new Vector2[6];
                uv[0] = new Vector2 (1,1);
                uv[1] = new Vector2(0,1);
                uv[2] = new Vector2 (0,0);
                uv[3] = new Vector2 (1,1);
                uv[4] = new Vector2 (0,0);
                uv[5] = new Vector2 (1,0);
                plantMesh.uv = uv;
                //
                plantMesh.RecalculateNormals();
            }
            return plantMesh;
        }
    }

    static MeshRenderer unitMeshRenderer;

    /// <summary>
    /// 一个单位网格
    /// </summary>
    public static MeshRenderer UnitMeshRenderer
    {
        get
        {
            if (unitMeshRenderer==null)
            {
                GameObject obj = new GameObject();
                unitMeshRenderer = obj.AddComponent<MeshRenderer>();
                MeshFilter meshFilter= obj.AddComponent<MeshFilter>();
                meshFilter.sharedMesh = UnitMesh;
                unitMeshRenderer.gameObject.hideFlags = HideFlags.HideAndDontSave;
                unitMeshRenderer.gameObject.SetActive(false);
            }
            return unitMeshRenderer;
        }
    }

    /// <summary>
    /// 获得一个单位网格节点
    /// </summary>
    /// <returns></returns>
    public static GameObject GetOneUnitMeshRenderer()
    {
        GameObject obj = new GameObject();
        MeshRenderer meshRenderer = obj.AddComponent<MeshRenderer>();
        MeshFilter meshFilter = obj.AddComponent<MeshFilter>();
        meshFilter.sharedMesh = UnitMesh;
        return obj;
    }
}
