using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System;
using System.Reflection;
using System.Linq;
using System.Text;

namespace Render
{
    public class RenderShaderTool
    {
#if UNITY_EDITOR

        #region//�ض�Shader��ʹ�����

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ����� UberPost")]
        /// <summary>
        /// Shaderʹ����� UberPost
        /// </summary>
        public static void TargetShaderServiceCondition_UberPost()
        {
            TargetShaderServiceCondition("UberPost");
        }

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ����� Legacy Shaders/VertexLit")]
        /// <summary>
        /// Shaderʹ����� Legacy Shaders/VertexLit
        /// </summary>
        public static void TargetShaderServiceCondition_Legacy_Shaders_VertexLit()
        {
            TargetShaderServiceCondition("Legacy Shaders/VertexLit");
        }

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ����� Legacy Shaders/Diffuse")]
        /// <summary>
        /// Shaderʹ����� Legacy Shaders/Diffuse
        /// </summary>
        public static void TargetShaderServiceCondition_Legacy_Shaders_Diffuse()
        {
            TargetShaderServiceCondition("Legacy Shaders/Diffuse");
        }

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ����� Sprites/Default")]
        /// <summary>
        /// Shaderʹ����� Sprites/Default
        /// </summary>
        public static void TargetShaderServiceCondition_Sprites_Default()
        {
            TargetShaderServiceCondition("Sprites/Default");
        }

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ����� Universal Render Pipeline/Lit")]
        /// <summary>
        /// Shaderʹ����� Universal Render Pipeline/Lit
        /// </summary>
        public static void TargetShaderServiceCondition_UniversalRenderPipeline_Lit()
        {
            TargetShaderServiceCondition("Universal Render Pipeline/Lit");
        }

        /// <summary>
        /// �ض�Shader��ʹ�����
        /// </summary>
        /// <param name="shaderName"></param>
        public static void TargetShaderServiceCondition(string shaderName)
        {
            //key:shader value�������˴�shader�Ķ���
            Dictionary<Shader, List<UnityEngine.Object>> res = new Dictionary<Shader, List<UnityEngine.Object>>();
            UnityEditor.EditorUtility.ClearProgressBar();
            Type shaderType = typeof(Shader);
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("prefab", assetPaths);
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            ResourceDetection.GetAllFilesSuffix("asset", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ{0} {1}/{2}", shaderName, i, listCount), assetPath, i / (float)listCount);
                UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                if (assetObj != null)
                {
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        UnityEngine.Object obj = decyAssets[j];
                        if (obj != null && obj.GetType() == shaderType)
                        {
                            Shader shader = (Shader)obj;
                            string shaderNameX = shader.name.Replace(" (UnityEngine.Shader)", "").Trim();
                            if (shaderNameX.CompareTo(shaderName) == 0)
                            {
                                List<UnityEngine.Object> list;
                                if (!res.TryGetValue(shader, out list))
                                {
                                    list = new List<UnityEngine.Object>();
                                    res.Add(shader, list);
                                }
                                if (!list.Contains(assetObj))
                                {
                                    list.Add(assetObj);
                                }
                            }
                        }
                    }
                }
            }
            //д��
            string unUsedSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + string.Format("/˭������Shader{0}.txt", shaderName.Replace("/", "_"));
            StringBuilder stringBuilder = new StringBuilder();
            Dictionary<Shader, List<UnityEngine.Object>>.Enumerator enumerator = res.GetEnumerator();
            int index = 0;
            int allCount = res.Count;
            while (enumerator.MoveNext())
            {
                Shader shader = enumerator.Current.Key;
                string shaderPath = UnityEditor.AssetDatabase.GetAssetPath(shader);
                stringBuilder.Append("--------------------------->\n");
                stringBuilder.Append(string.Format("ShaderName:{0} Path:{1}\n", shader.name, shaderPath));
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("д��{0} {1}/{2}", shader.name, index, allCount), shaderPath, index / (float)allCount);
                List<UnityEngine.Object> list = enumerator.Current.Value;
                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                {
                    UnityEngine.Object obj = list[i];
                    string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                    stringBuilder.Append(string.Format("        ����:{0} Path:{1}\n", obj.name, assetPath));
                }
                index++;
            }
            RenderTool.WriteTxt(unUsedSavePath, stringBuilder.ToString());
            Debug.LogError("˭������Shaderд��·��:" + unUsedSavePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        #endregion

        #region//Shader��ʧ���ʲ���

        [UnityEditor.MenuItem("Tools/RenderTool/Mat/��ʧShader���������")]
        /// <summary>
        /// ���Ҷ�ʧShader�Ĳ���
        /// </summary>
        public static void NullShaderServiceCondition()
        {
            //key:shader value�������˴�shader�Ķ���
            List<Material> resList = new List<Material>();
            UnityEditor.EditorUtility.ClearProgressBar();
            Type matType = typeof(Material);
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("mat", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ{0} {1}/{2}", "��ʧShader�Ĳ�����", i, listCount), assetPath, i / (float)listCount);
                Material matObj = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                if (matObj != null)
                {
                    if (matObj.shader == null || matObj.shader.name.CompareTo("Hidden/InternalErrorShader") == 0)
                    {
                        resList.Add(matObj);
                    }
                }
            }
            //д��
            string unUsedSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + string.Format("/��Щ���ʵ�Shader��ʧ.txt");
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = resList.Count; i < listCount; ++i)
            {
                Material mat = resList[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("д��{0} {1}/{2}", mat.name, i, listCount), mat.name, i / (float)listCount);
                stringBuilder.Append(string.Format("����:{0}\n", UnityEditor.AssetDatabase.GetAssetPath(mat)));
            }
            RenderTool.WriteTxt(unUsedSavePath, stringBuilder.ToString());
            Debug.LogError("��Щ���ʵ�Shader��ʧд��·��:" + unUsedSavePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        #endregion

        #region//����������ȱʧ�Ĳ��� Ҫ�� Shader �������������� [MainTexture]

        /// <summary>
        /// ����ף����ȱʧ���
        /// </summary>
        public static void MainTextureDefiCheck()
        {

        }

        #endregion

        #region//�ɶ�д�������������

        [UnityEditor.MenuItem("Tools/RenderTool/Texture2D/�ɶ�д�������������")]
        /// <summary>
        /// ��ѯ �ɶ�д����������
        /// </summary>
        public static void ReadWriteOpenTextures()
        {
            List<UnityEngine.Object> resList = new List<UnityEngine.Object>();
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("png", assetPaths);
            ResourceDetection.GetAllFilesSuffix("tga", assetPaths);
            ResourceDetection.GetAllFilesSuffix("jpg", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ{0}/{1} {2}", i, listCount, buildInMatName), assetPath, i / (float)listCount);
                UnityEditor.TextureImporter textureImporter = UnityEditor.TextureImporter.GetAtPath(assetPath) as UnityEditor.TextureImporter;
                if (textureImporter != null && textureImporter.isReadable)
                {
                    resList.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath));
                }
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            //д��
            string savePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + string.Format("/��Щ�������˿ɶ�д.txt");
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 0, listCount = resList.Count; i < listCount; ++i)
            {
                stringBuilder.Append(string.Format("����:{0} ·��:{1}\n", resList[i].name, UnityEditor.AssetDatabase.GetAssetPath(resList[i])));
            }
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("�ɶ�д����������д��·��:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        #endregion

        #region//����ʹ�����ڽ����������Դ

        /// <summary>
        /// �ڽ�����������
        /// </summary>
        static string buildInMatName = "Default-Diffuse";

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/�ڽ�����ʹ���������")]
        /// <summary>
        /// ����ʹ�����ڽ����������Դ
        /// </summary>
        public static void TargetMatServiceCondition()
        {
            //key:shader value�������˴�shader�Ķ���
            Dictionary<Material, List<UnityEngine.Object>> res = new Dictionary<Material, List<UnityEngine.Object>>();
            UnityEditor.EditorUtility.ClearProgressBar();
            Type matType = typeof(Material);
            List<string> assetPaths = new List<string>();
            ResourceDetection.GetAllFilesSuffix("prefab", assetPaths);
            ResourceDetection.GetAllFilesSuffix("asset", assetPaths);
            for (int i = 0, listCount = assetPaths.Count; i < listCount; ++i)
            {
                string assetPath = assetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("��ѯ{0}/{1} {2}", i, listCount, buildInMatName), assetPath, i / (float)listCount);
                UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                if (assetObj != null)
                {
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        UnityEngine.Object obj = decyAssets[j];
                        if (obj != null && obj.GetType() == matType)
                        {
                            Material mat = (Material)obj;
                            if (mat.name.CompareTo(buildInMatName) == 0)
                            {
                                string matAssetPath = UnityEditor.AssetDatabase.GetAssetPath(mat);
                                if (!matAssetPath.StartsWith("Assets/"))
                                {
                                    List<UnityEngine.Object> list;
                                    if (!res.TryGetValue(mat, out list))
                                    {
                                        list = new List<UnityEngine.Object>();
                                        res.Add(mat, list);
                                    }
                                    if (!list.Contains(assetObj))
                                    {
                                        list.Add(assetObj);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //д��
            string unUsedSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + string.Format("/˭�������ڽ�������{0}.txt", buildInMatName.Replace("/", "_"));
            StringBuilder stringBuilder = new StringBuilder();
            Dictionary<Material, List<UnityEngine.Object>>.Enumerator enumerator = res.GetEnumerator();
            int index = 0;
            int allCount = res.Count;
            while (enumerator.MoveNext())
            {
                Material mat = enumerator.Current.Key;
                stringBuilder.Append("--------------------------->\n");
                stringBuilder.Append(string.Format("ShaderName:{0}\n", mat.name));
                UnityEditor.EditorUtility.DisplayCancelableProgressBar(string.Format("д��{0} {1}/{2}", mat.name, index, allCount), mat.name, index / (float)allCount);
                List<UnityEngine.Object> list = enumerator.Current.Value;
                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                {
                    UnityEngine.Object obj = list[i];
                    string assetPath = UnityEditor.AssetDatabase.GetAssetPath(obj);
                    stringBuilder.Append(string.Format("        ����:{0} Path:{1}\n", obj.name, assetPath));
                }
                index++;
            }
            RenderTool.WriteTxt(unUsedSavePath, stringBuilder.ToString());
            Debug.LogError("˭������Shaderд��·��:" + unUsedSavePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        #endregion

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shader�������")]
        /// <summary>
        /// ��Ŀ�е�Shader����
        /// </summary>
        public static void ProjectShaderErr()
        {
            //���μ���Shader
            List<string> cullingList = new List<string>();
            cullingList.Add("GUI/Text Shader");
            cullingList.Add("Sprites/Default");
            cullingList.Add("Legacy Shaders/Particles/Alpha Blended Premultiply");
            cullingList.Add("Mobile/Particles/Multiply");
            cullingList.Add("Universal Render Pipeline/Particles/Unlit");
            cullingList.Add("Mobile/Particles/Additive");
            cullingList.Add("Legacy Shaders/Particles/Additive");
            cullingList.Add("Legacy Shaders/Particles/Alpha Blended");
            cullingList.Add("Unlit/Texture");
            //��¼��URP Shader
            List<string> buildInShaderList = new List<string>();
            buildInShaderList.Add("Legacy Shaders/VertexLit");
            buildInShaderList.Add("Legacy Shaders/Transparent/Cutout/VertexLit");
            buildInShaderList.Add("Legacy Shaders/Diffuse");
            buildInShaderList.Add("Mobile/VertexLit");
            buildInShaderList.Add("Legacy Shaders/Transparent/VertexLit");
            //����Shader
            List<string> errShaderList = new List<string>();
            errShaderList.Add("Hidden/Universal Render Pipeline/FallbackError");
            errShaderList.Add("Hidden/InternalErrorShader");

            //���ԣ�������� Value��ʹ�õĹٷ�Shader
            Dictionary<UnityEngine.Object, List<Shader>> dic = new Dictionary<UnityEngine.Object, List<Shader>>();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            for (int i = 0, listCount = allAssetPaths.Length; i < listCount; ++i)
            {
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("��ѯ(" + i + "/" + listCount + ")", "", i / (float)listCount);
                if (allAssetPaths[i].ToLower().EndsWith(".fbx"))
                {
                    continue;
                }
                UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(allAssetPaths[i]);
                if (obj != null && (obj.GetType() == typeof(GameObject) || obj.GetType().BaseType == typeof(UnityEngine.ScriptableObject)))
                {
                    //�鿴��������Դ
                    UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(allAssetPaths[i]);
                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
                    {
                        UnityEngine.Object obj2 = decyAssets[j];
                        if (obj2 != null && obj2.GetType() == typeof(Shader))
                        {
                            Shader shader = (Shader)obj2;
                            if (!cullingList.Contains(shader.name))
                            {
                                string shaderAssetPath = UnityEditor.AssetDatabase.GetAssetPath(shader);
                                if (!shaderAssetPath.StartsWith("Assets/"))
                                {
                                    List<Shader> list;
                                    if (!dic.TryGetValue(obj, out list))
                                    {
                                        list = new List<Shader>();
                                        dic.Add(obj, list);
                                    }
                                    if (!list.Contains(shader))
                                    {
                                        list.Add(shader);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            StringBuilder stringBuilder = new StringBuilder();
            Dictionary<UnityEngine.Object, List<Shader>>.Enumerator enumerator = dic.GetEnumerator();
            int index = 0;
            int allCount = dic.Count;
            while (enumerator.MoveNext())
            {
                UnityEngine.Object obj = enumerator.Current.Key;
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("д��(" + index + "/" + allCount + ")", "", index / (float)allCount);
                List<Shader> list = enumerator.Current.Value;
                stringBuilder.Append("-----------------------------------------\n");
                stringBuilder.Append(string.Format("Obj={0}:\n", UnityEditor.AssetDatabase.GetAssetPath(obj)));
                for (int i = 0, listCount = list.Count; i < listCount; ++i)
                {
                    Shader shader = list[i];
                    if (buildInShaderList.Contains(shader.name))
                    {
                        stringBuilder.Append(string.Format("      (������URP)->ShaderName={0},Path={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shader)));
                    }
                    else if (errShaderList.Contains(shader.name))
                    {
                        stringBuilder.Append(string.Format("      (Shader����)->ShaderName={0},Path={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shader)));
                    }
                    else
                    {
                        stringBuilder.Append(string.Format("      (�ٷ�Shader���������)->ShaderName={0},Path={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shader)));
                    }
                }
                index++;
            }
            string savePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + "/�ٷ�Shader��ʹ�����.txt";
            RenderTool.WriteTxt(savePath, stringBuilder.ToString());
            Debug.LogError("�ٷ�Shader��ʹ�����д��·��:" + savePath);
            UnityEditor.EditorUtility.ClearProgressBar();
        }

        [UnityEditor.MenuItem("Tools/RenderTool/Shader/Shaderʹ�����")]
        /// <summary>
        /// Shader��ʹ����� �������Ѿ�ʹ�õ�shader��Ϣ��Ϊʹ�ù���shader
        /// д����ָ���ļ�
        /// </summary>
        public static void ShaderUseConditio()
        {
            List<UnityEngine.Shader> list1;
            List<UnityEngine.Shader> list2;
            FindAllUsedShaderOrScriptString(false, out list1, out list2);
        }

        static string ShaderWriteFolderName = "ShaderEditorData";

        /// <summary>
        /// ������Ŀ�����е��Ѿ��õ���shader·���ʹ����еĶ�̬�����ֶ�
        /// </summary>
        ///  <param name="inspectObjectSvnErr">�Ƿ���SVN����</param>
        /// <param name="usedShaders">�Ѿ�ʹ�õ�Shader</param>
        /// <param name="unUsedShaders">δʹ�ù���Shader</param>
        public static void FindAllUsedShaderOrScriptString(bool inspectObjectSvnErr, out List<UnityEngine.Shader> usedShaders, out List<UnityEngine.Shader> unUsedShaders)
        {
            usedShaders = new List<Shader>();
            unUsedShaders = new List<Shader>();
            Type shaderType = typeof(UnityEngine.Shader);
            //�����е�Shader�����ַ���
            List<string> shaderFindStringInCs = new List<string>();
            shaderFindStringInCs.Add("Shader.Find");
            shaderFindStringInCs.Add("new Material(Shader");
            //�����е�Shader�����ַ��� ��� key=������� value���������
            Dictionary<UnityEditor.MonoScript, StringBuilder> shaderFindStrings = new Dictionary<UnityEditor.MonoScript, StringBuilder>();
            //���εĲ�������Directory.GetFiles
            List<Type> cullingTyps = new List<Type>();
            cullingTyps.Add(shaderType);
            //���εĲ��Һ�׺
            List<string> cullingSuffix = new List<string>();
            cullingSuffix.Add(".png");
            cullingSuffix.Add(".tga");
            cullingSuffix.Add(".tag");
            cullingSuffix.Add(".jpg");
            cullingSuffix.Add(".fbx");
            cullingSuffix.Add(".meta");
            //��Ŀ�����е�shader
            List<Shader> projectAllShaders = GetAllShaderAssets(false);
            UnityEditor.EditorUtility.ClearProgressBar();
            List<string> list = new List<string>();
            //key:shader value:�������shader�Ķ���
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>> saveShaderUsedDic = new Dictionary<UnityEngine.Object, List<UnityEngine.Object>>();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            int allount = allAssetPaths.Length;
            for (int i = 0; i < allount; ++i)
            {
                string assetPath = allAssetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("��ѯ(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
                if (!assetPath.StartsWith("Assets/"))
                {
                    continue;
                }
                bool findSuffix = false;
                for (int j = 0, listCount = cullingSuffix.Count; j < listCount; ++j)
                {
                    if (assetPath.ToLower().EndsWith(cullingSuffix[j]))
                    {
                        findSuffix = true;
                        break;
                    }
                }
                if (!findSuffix)
                {
                    //
                    bool isSvnErr = false;
                    if (inspectObjectSvnErr && RenderSvnTool.InspectObjectSvnErr(assetPath))
                    {
                        isSvnErr = true;
                    }
                    if (!isSvnErr)
                    {
                        UnityEngine.Object obj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                        if (obj != null)
                        {
                            Type objType = obj.GetType();
                            if (!cullingTyps.Contains(objType))
                            {
                                if (objType == typeof(UnityEditor.MonoScript))
                                {
                                    UnityEditor.MonoScript monoScript = (UnityEditor.MonoScript)obj;
                                    string path = RenderTool.AssetPathToFilePath(assetPath);
                                    string monoScriptText = RenderTool.ReadTxt(path);
                                    if (monoScriptText != null)
                                    {
                                        string[] lines = monoScriptText.Split('\n');
                                        for (int j = 0, listCount = lines.Length; j < listCount; ++j)
                                        {
                                            string str = lines[j];
                                            for (int x = 0, listCount2 = shaderFindStringInCs.Count; x < listCount2; ++x)
                                            {
                                                if (str.Contains(shaderFindStringInCs[x]))
                                                {
                                                    StringBuilder sb;
                                                    if (!shaderFindStrings.TryGetValue(monoScript, out sb))
                                                    {
                                                        sb = new StringBuilder();
                                                        shaderFindStrings.Add(monoScript, sb);
                                                        sb.Append(string.Format("�ű�={0},AssetPath={1}\n", monoScript.name, assetPath));
                                                    }
                                                    sb.Append(string.Format("               Line={0},String={1}\n", j, str));
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    //�鿴��������Դ
                                    UnityEngine.Object assetObj = UnityEditor.AssetDatabase.LoadMainAssetAtPath(assetPath);
                                    UnityEngine.Object[] decyAssets = UnityEditor.EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
                                    for (int j = 0, listCount = decyAssets.Length; j < listCount; ++j)
                                    {
                                        UnityEngine.Object decyObject = decyAssets[j];
                                        if (decyObject != null && shaderType == decyObject.GetType())
                                        {
                                            //����Ƿ���Ҫ����
                                            if (UnityEditor.AssetDatabase.GetAssetPath(decyObject).StartsWith("Assets/"))
                                            {
                                                if (!usedShaders.Contains((UnityEngine.Shader)decyObject))
                                                {
                                                    usedShaders.Add((UnityEngine.Shader)decyObject);
                                                    projectAllShaders.Remove((UnityEngine.Shader)decyObject);
                                                }
                                                List<UnityEngine.Object> targetList;
                                                if (!saveShaderUsedDic.TryGetValue(decyObject, out targetList))
                                                {
                                                    targetList = new List<UnityEngine.Object>();
                                                    saveShaderUsedDic.Add(decyObject, targetList);
                                                }
                                                targetList.Add(obj);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            unUsedShaders = projectAllShaders;
            StringBuilder stringBuilder = new StringBuilder();
            //д������ �Ѿ�ʹ�õ�shader
            stringBuilder.Append("��ʹ��Shader�б�:\n");
            string usedSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + "/�Ѿ�ʹ�õ�Shader.txt";
            allount = usedShaders.Count;
            for (int i = 0, listCount = usedShaders.Count; i < listCount; ++i)
            {
                UnityEngine.Shader shader = usedShaders[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("��ʹ��(" + i + "/" + allount + ")", "Shader:" + shader.name, i / (float)allount);
                stringBuilder.Append(string.Format("ShaderName={0},AssetPath={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shader)));
            }
            stringBuilder.Append("\n----------------------------------------------\n\n");
            Dictionary<UnityEngine.Object, List<UnityEngine.Object>>.Enumerator enumerator = saveShaderUsedDic.GetEnumerator();
            allount = saveShaderUsedDic.Count;
            int index = 0;
            while (enumerator.MoveNext())
            {
                UnityEngine.Object shaderObj = enumerator.Current.Key;
                Shader shader = (Shader)shaderObj;
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("��ʹ��(" + index + "/" + allount + ")", "Shader:" + shader.name, index / (float)allount);
                stringBuilder.Append(string.Format("ShaderName={0},AssetPath={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shaderObj)));
                List<UnityEngine.Object> useshaderObjs = enumerator.Current.Value;
                for (int i = 0, listCount = useshaderObjs.Count; i < listCount; ++i)
                {
                    UnityEngine.Object useshaderObj = useshaderObjs[i];
                    stringBuilder.Append(string.Format("              ����={0},Path={1}\n", useshaderObj.name, UnityEditor.AssetDatabase.GetAssetPath(useshaderObj)));
                }
                index++;
            }
            RenderTool.WriteTxt(usedSavePath, stringBuilder.ToString());
            Debug.LogError("��ʹ��Shaderд��·��:" + usedSavePath);
            //д������ ��δʹ�õ�shader
            stringBuilder.Clear();
            string unUsedSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + "/��δʹ�õ�Shader.txt";
            allount = usedShaders.Count;
            for (int i = 0, listCount = unUsedShaders.Count; i < listCount; ++i)
            {
                UnityEngine.Shader shader = unUsedShaders[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("δʹ��(" + index + "/" + allount + ")", "Shader:" + shader.name, index / (float)allount);
                stringBuilder.Append(string.Format("ShaderName={0},AssetPath={1}\n", shader.name, UnityEditor.AssetDatabase.GetAssetPath(shader)));
            }
            RenderTool.WriteTxt(unUsedSavePath, stringBuilder.ToString());
            Debug.LogError("δʹ��Shaderд��·��:" + unUsedSavePath);
            //
            //Dictionary<UnityEditor.MonoScript, StringBuilder> shaderFindStrings
            //д��������ҵĽ��
            stringBuilder.Clear();
            string shaderFindStringSavePath = RenderTool.WriteFolderDir + ShaderWriteFolderName + "/�����е�Shader����.txt";
            allount = shaderFindStrings.Count;
            index = 0;
            Dictionary<UnityEditor.MonoScript, StringBuilder>.Enumerator shaderFindStringsEn = shaderFindStrings.GetEnumerator();
            while (shaderFindStringsEn.MoveNext())
            {
                UnityEditor.MonoScript monoScript = shaderFindStringsEn.Current.Key;
                StringBuilder sb = shaderFindStringsEn.Current.Value;
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("д�������е�Shader(" + index + "/" + allount + ")", monoScript.name, index / (float)allount);
                stringBuilder.Append(sb.ToString());
                stringBuilder.Append("\n");
                stringBuilder.Append("-------------------------------------------------------------");
                stringBuilder.Append("\n");
                index++;
            }
            RenderTool.WriteTxt(shaderFindStringSavePath, stringBuilder.ToString());
            Debug.LogError("����������Shaderд��·��:" + shaderFindStringSavePath);
            stringBuilder.Clear();
            UnityEditor.EditorUtility.ClearProgressBar();

        }

        /// <summary>
        /// �����Ŀ�����е�shader
        /// </summary>
        /// <param name="inspectObjectSvnErr">�Ƿ���SVN����</param>
        /// <returns></returns>
        public static List<Shader> GetAllShaderAssets(bool inspectObjectSvnErr)
        {
            List<Shader> list = new List<Shader>();
            UnityEditor.EditorUtility.ClearProgressBar();
            string[] allAssetPaths = UnityEditor.AssetDatabase.GetAllAssetPaths();
            int allount = allAssetPaths.Length;
            for (int i = 0; i < allount; ++i)
            {
                string assetPath = allAssetPaths[i];
                UnityEditor.EditorUtility.DisplayCancelableProgressBar("����(" + i + "/" + allount + ")", "assetPath:" + assetPath, i / (float)allount);
                if (assetPath.StartsWith("Assets/"))
                {
                    bool isErr = false;
                    if (inspectObjectSvnErr && RenderSvnTool.InspectObjectSvnErr(assetPath))
                    {
                        isErr = true;
                    }
                    if (!isErr)
                    {
                        UnityEngine.Shader ShaderObj = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Shader>(assetPath);
                        if (ShaderObj != null)
                        {
                            list.Add(ShaderObj);
                        }
                    }
                }
            }
            UnityEditor.EditorUtility.ClearProgressBar();
            return list;
        }

#endif
    }
}



