using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using static Unity.VisualScripting.Member;
using System.IO;
using Unity.VisualScripting;

public class EditorShaderReplace : EditorWindow
{
    public string oldMatPath = string.Empty;
    public string saveKey = "导入路径";
    //public Material oldMat = null;
    //public Material newMat = null;
    public List<Material> matList = new List<Material>();
    public Dictionary<string, int> shaderNames = new Dictionary<string, int>();
    [MenuItem("Shader/ShaderReplace")]
    public static void showWindow()
    {
        EditorWindow.GetWindow<EditorShaderReplace>("替换材质Shader");
    }

    private void OnGUI()
    {
        if (GUILayout.Button("选择old材质球路径"))
        {
            oldMatPath = EditorUtility.OpenFolderPanel("选择old材质球路径", "", "");
            PlayerPrefs.SetString(saveKey, oldMatPath);
            PlayerPrefs.Save();
        }
        GUILayout.Space(10);
        GUILayout.Label(string.IsNullOrEmpty(oldMatPath) ? "路径：" : "路径：" + oldMatPath);
        GUILayout.Space(10);
        //GUILayout.Label("old");
        //oldMat = (Material)EditorGUILayout.ObjectField(oldMat, typeof(Material), true);
        //GUILayout.Space(5);
        //GUILayout.Label("new");
        //newMat = (Material)EditorGUILayout.ObjectField(newMat, typeof(Material), true);
        if (GUILayout.Button("替换"))
        {
            FindMaterial();

            int num = 0;
            for (int i = 0; i < matList.Count; i++)
            {
                if (matList[i].shader.name == "bud/downtown/pbr_02_fog" || matList[i].shader.name == "bud/downtown/pbr_02" ||
                    matList[i].shader.name == "bud/downtown/pbr_03" || matList[i].shader.name == "bud/downtown/pbr_ap_02" ||
                    matList[i].shader.name == "bud/downtown/pbr_03_ap")
                {
                    string path = oldMatPath + "/" + matList[i].name + ".mat";
                    path = path.Substring(path.IndexOf("Assets"));
                    Material mat = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
                    ReplaceShader(mat);
                    num++;
                }
                if (matList[i].shader.name == "bud/downtown/through_02")
                {
                    string path = oldMatPath + "/" + matList[i].name + ".mat";
                    path = path.Substring(path.IndexOf("Assets"));
                    Material mat = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
                    ReplaceShader2(mat);
                    num++;
                }
            }
            Debug.Log("num :  " + num);
        }

        foreach (var nam in shaderNames)
        {
            GUILayout.Label(nam.Value + " :  " + nam.Key);
        }

    }
    private void ReplaceShader(Material mat)
    {
        Material oldMat = new Material(mat);
        //Material newMat = new Material(Shader.Find("NewRender/Standard/BasePBR"));
        mat.shader = Shader.Find("NewRender/Standard/BasePBR");
        mat.SetTexture("_BaseMap", oldMat.GetTexture("_MainTex"));
        Vector4 st = oldMat.GetVector("_MainTex_ST");
        mat.SetTextureOffset("_BaseMap", new Vector2(st.z, st.w));
        mat.SetTextureScale("_BaseMap", new Vector2(st.x, st.y));
        mat.SetTexture("_BumpMap", oldMat.GetTexture("_Normal"));
        mat.SetVector("_BumpMap_ST", oldMat.GetVector("_Normal_ST"));
        mat.SetTexture("_MetallicGlossMap", oldMat.GetTexture("_mra_tex"));
        mat.SetVector("_MetallicGlossMap_ST", oldMat.GetVector("_mra_tex_ST"));
        mat.SetTexture("_EmissionMap", oldMat.GetTexture("_Emisson"));
        mat.SetVector("_EmissionMap_ST", oldMat.GetVector("_Emisson_ST"));
        mat.SetColor("_EmissionColor", oldMat.GetColor("_Emisson_Color") * oldMat.GetFloat("_Emisson_int"));
        mat.SetInt("AOCOLORSET", (int)oldMat.GetFloat("_AO_offon"));
        mat.SetColor("_OcclusionColor", oldMat.GetColor("_AO_Color"));
        mat.SetColor("_OcclusionColor", oldMat.GetColor("_AO_color"));
        mat.SetFloat("_OcclusionStrength", oldMat.GetFloat("_AO_Power") * 0.5f);
        mat.SetFloat("_OcclusionStrength", oldMat.GetFloat("_AO") * 0.5f);
        if (oldMat.GetFloat("_Matallic_offon") == 1)
        {
            mat.SetFloat("_Metallic", oldMat.GetFloat("_metalic"));
        }
        if (oldMat.GetFloat("_Smoothness_offon") == 1)
        {
            mat.SetFloat("_Smoothness", oldMat.GetFloat("_Smoothness"));
        }

        //Color col = oldMat.GetVector("_MainTex_Color");
        mat.SetColor("_BaseColor", oldMat.GetColor("_MainTex_Color"));
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        AssetDatabase.AllowAutoRefresh();
    }
    private void ReplaceShader2(Material mat)
    {
        Material oldMat = new Material(mat);

        mat.shader = Shader.Find("NewRender/Texture/Default");
        mat.SetTexture("_BaseMap", oldMat.GetTexture("_MainTex"));
        mat.SetColor("_BaseColor", oldMat.GetColor("_Color"));

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        AssetDatabase.AllowAutoRefresh();
    }
    private void FindMaterial()
    {
        matList.Clear();
        shaderNames.Clear();
        DirectoryInfo dir = new DirectoryInfo(oldMatPath);
        FileInfo[] files = dir.GetFiles("*");
        foreach (var item in files)
        {
            if (item.Name.EndsWith(".mat"))
            {
                string assetsName = item.FullName;
                assetsName = assetsName.Substring(assetsName.IndexOf("Assets"));
                Material mat = AssetDatabase.LoadAssetAtPath(assetsName, typeof(Material)) as Material;
                matList.Add(mat);
            };
        }
        Debug.Log(matList.ToArray().Length);
        foreach (var tempMat in matList)
        {
            if (CheckShader(tempMat.shader.name, shaderNames))
            {
                shaderNames.Add(tempMat.shader.name, 1);
            }
            else
            {
                shaderNames[tempMat.shader.name] += 1;
            }
        }
        Debug.Log(shaderNames.Count);
    }
    private bool CheckShader(string name, Dictionary<string, int> names)
    {
        if (names.ContainsKey(name))
        {
            return false;
        }
        return true;
    }
}//using System.Collections;
