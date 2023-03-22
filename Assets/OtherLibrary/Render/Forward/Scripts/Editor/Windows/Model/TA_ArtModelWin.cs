
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using UnityEditor;
//using UnityEngine;
//using System.IO;

//namespace Render
//{
//    /// <summary>
//    /// 此脚本用于模型的美术规则检测
//    /// </summary>
//    public class TA_ArtModelWin : EditorWindowsBase
//    {

//        [MenuItem("ArtTools/TA工具箱/测试按钮/02")]
//        static void KKKKK()
//        {
//            TA_CheckWin.ShowWin("");
//        }

//        /// <summary>
//        /// 检测所有类型资源
//        /// </summary>
//        [MenuItem("ArtTools/TA工具箱/测试按钮/03")]
//        public static void CheckAllType()
//        {
//            var dir = TACommon.WriteFolderDir + WriteFolderName;
//            var dict = new Dictionary<string, string>();
//            //处理的文件列表
//            dict.Add("/网格过大的对象.txt", "/big_mesh.txt");
//            dict.Add("/局外角色模型检测.txt", "/game_in_fbx.txt");
//            dict.Add("/局内角色模型检测.txt", "/game_out_fbx.txt");
//            dict.Add("/局内怪物模型检测.txt", "/game_in_monster.txt");
//            dict.Add("/局内小兵模型检测.txt", "/game_in_soldider.txt");
//            dict.Add("/粒子检测.txt", "/check_particle.txt");



//            //清空记录
//            foreach (var item in dict)
//            {
//                EditorTool.WriteTxt(dir + item.Key, "");
//            }

//            //检测数据
//            CheckAllBigMesh();
//            Examine_GameOut();
//            Examine_GameIn();
//            Examine_GameInMonster();
//            Examine_GameInOrgan();
//            Examine_Particle();



//            //转换字符编码
//            foreach (var item in dict)
//            {
//                File.Delete(dir + item.Value);
//                if (isFileEmpty(dir + item.Key))
//                {
//                    continue;
//                }
//                UTF8ToGB2312(dir + item.Key, dir + item.Value);
//            }


//        }

//        /// <summary>
//        /// 文件是否为空
//        /// </summary>
//        /// <param name="source"></param>
//        /// <returns></returns>
//        private static bool isFileEmpty(string source)
//        {
//            if (!File.Exists(source))
//            {
//                return true;
//            }

//            System.IO.FileInfo file = new System.IO.FileInfo(source);
//            if (file == null)
//            {
//                return true;
//            }
//            return file.Length == 0;
//        }

//        /// <summary>
//        /// 转换文件编码格式
//        /// </summary>
//        /// <param name="source"></param>
//        /// <param name="dest"></param>
//        private static void UTF8ToGB2312(string source, string dest)
//        {
//            var textInfo = File.ReadAllText(source);
//            File.WriteAllText(dest, textInfo, Encoding.GetEncoding("gb2312"));
//        }

//        protected override void OnShowWindow()
//        {

//        }

//        protected override void OnGUIWindow()
//        {
//            SetTittle("模型规则检查");
//            using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//            {
//                if (GUILayout.Button("查询所有的的大网格"))
//                {
//                    CheckAllBigMesh();
//                }
//                if (GUILayout.Button("角色模型规则检查(局外)"))
//                {
//                    Examine_GameOut();
//                }
//                if (GUILayout.Button("角色模型规则检查(局内)"))
//                {
//                    Examine_GameIn();
//                }
//                if (GUILayout.Button("怪物模型规则检查(局内)"))
//                {
//                    Examine_GameInMonster();
//                }
//                if (GUILayout.Button("小兵模型规则检查(局内)"))
//                {
//                    Examine_GameInOrgan();
//                }
//                if (GUILayout.Button("粒子规则检查"))
//                {
//                    Examine_Particle();
//                }

//            }
//        }

//        /// <summary>
//        /// 写出目录
//        /// </summary>
//        static string WriteFolderName = "ArtModelData";

//        /// <summary>
//        /// 查询所有的的大网格
//        /// </summary>
//        static void CheckAllBigMesh()
//        {
//            TA_ToolsBoxWindow.CloseAllEditorWindows();
//            EditorUtility.ClearProgressBar();
//            //key:引用了大网格的对象 value:大网格数据
//            Dictionary<UnityEngine.Object, List<BigMeshData>> bigMeshDatas = new Dictionary<UnityEngine.Object, List<BigMeshData>>();
//            string[] allFiles = Directory.GetFiles(Application.dataPath, "*.prefab", SearchOption.AllDirectories);
//            for (int i = 0, listCount = allFiles.Length; i < listCount; ++i)
//            {
//                string assetPath = TACommon.PathToAssetPath(allFiles[i]);
//                EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", i, listCount), assetPath, i / (float)listCount);
//                UnityEngine.Object assetObj = AssetDatabase.LoadMainAssetAtPath(assetPath);
//                if (assetObj != null)
//                {
//                    UnityEngine.Object[] decyAssets = EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
//                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
//                    {
//                        UnityEngine.Object obj = decyAssets[j];
//                        if (obj != null)
//                        {
//                            if (obj.GetType() == typeof(Mesh))
//                            {
//                                Mesh mesh = (Mesh)obj;
//                                int trianglesCount = mesh.triangles.Length / 3;
//                                if (trianglesCount > 20000)
//                                {
//                                    BigMeshData bigMeshData = new BigMeshData();
//                                    bigMeshData.User = assetObj;
//                                    bigMeshData.Mesh = mesh;
//                                    bigMeshData.TrianglesCount = trianglesCount;
//                                    List<BigMeshData> list;
//                                    if (!bigMeshDatas.TryGetValue(assetObj, out list))
//                                    {
//                                        list = new List<BigMeshData>();
//                                        bigMeshDatas.Add(assetObj, list);
//                                    }
//                                    list.Add(bigMeshData);
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            //写出
//            StringBuilder stringBuilder = new StringBuilder();
//            Dictionary<UnityEngine.Object, List<BigMeshData>>.Enumerator enumerator = bigMeshDatas.GetEnumerator();
//            int index = 0;
//            int count = bigMeshDatas.Count;
//            while (enumerator.MoveNext())
//            {
//                EditorUtility.DisplayCancelableProgressBar(string.Format("查询{0}/{1}", index, count), "写出", index / (float)count);
//                UnityEngine.Object user = enumerator.Current.Key;
//                stringBuilder.Append(string.Format("使用者:{0} 路径:{1}\n", user.name, AssetDatabase.GetAssetPath(user)));
//                List<BigMeshData> list = enumerator.Current.Value;
//                for (int i = 0, listCount = list.Count; i < listCount; ++i)
//                {
//                    BigMeshData bigMeshData = list[i];
//                    stringBuilder.Append(string.Format("        网格:{0} 三角形数量:{1} 路径:{2}\n", bigMeshData.Mesh.name, bigMeshData.TrianglesCount, AssetDatabase.GetAssetPath(bigMeshData.Mesh)));
//                }
//                index++;
//            }
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/网格过大的对象.txt");
//            EditorTool.WriteTxt(savePath, stringBuilder.ToString());
//            Debug.LogError("网格过大的对象写出路径:" + savePath);

//            EditorUtility.ClearProgressBar();
//        }

//        /// <summary>
//        /// 大网格数据
//        /// </summary>
//        class BigMeshData
//        {
//            /// <summary>
//            /// 使用者
//            /// </summary>
//            public UnityEngine.Object User;

//            /// <summary>
//            /// 目标网格
//            /// </summary>
//            public Mesh Mesh;

//            /// <summary>
//            /// 三角形数量
//            /// </summary>
//            public int TrianglesCount;

//        }

//        /// <summary>
//        /// 角色模型规则检查 局外
//        /// </summary>
//        static void Examine_GameOut()
//        {
//            List<MeshData> meshDatas = GetModelDatas(CharactersConditions[QualityType.Mid]);
//            ResoultData resoultData = ResoultNeaten(new List<List<MeshData>>()
//        {
//            meshDatas
//        });
//            //写出
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/局外角色模型检测.txt");
//            resoultData.Write(savePath);
//        }

//        /// <summary>
//        /// 角色模型规则检查 局内
//        /// </summary>
//        static void Examine_GameIn()
//        {
//            List<MeshData> meshDatasLOD1 = GetModelDatas(CharactersConditions[QualityType.Lod1]);
//            List<MeshData> meshDatasLOD2 = GetModelDatas(CharactersConditions[QualityType.Lod2]);
//            List<MeshData> meshDatasLOD3 = GetModelDatas(CharactersConditions[QualityType.Lod3]);
//            ResoultData resoultData = ResoultNeaten(new List<List<MeshData>>()
//        {
//            meshDatasLOD1,
//            meshDatasLOD2,
//            meshDatasLOD3
//        });
//            //写出
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/局内角色模型检测.txt");
//            resoultData.Write(savePath);
//        }

//        /// <summary>
//        /// 怪物模型规则检测 局内
//        /// </summary>
//        static void Examine_GameInMonster()
//        {
//            ConditionData conditionData1 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Monster/", 4000, 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD1"
//                });
//            ConditionData conditionData2 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Monster/", (int)((4000 * 35) / 100f), 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD2"
//                });
//            ConditionData conditionData3 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Monster/", (int)((4000 * 15) / 100f), 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD3"
//                });
//            List<MeshData> meshDatasLOD1 = GetModelDatas(conditionData1);
//            List<MeshData> meshDatasLOD2 = GetModelDatas(conditionData2);
//            List<MeshData> meshDatasLOD3 = GetModelDatas(conditionData3);
//            ResoultData resoultData = ResoultNeaten(new List<List<MeshData>>()
//        {
//            meshDatasLOD1,
//            meshDatasLOD2,
//            meshDatasLOD3
//        });
//            //写出
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/局内怪物模型检测.txt");
//            resoultData.Write(savePath);
//        }

//        /// <summary>
//        /// 小兵模型规则检测 局内
//        /// </summary>
//        static void Examine_GameInOrgan()
//        {
//            ConditionData conditionData1 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Soldier/", 4000, 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD1"
//                });
//            ConditionData conditionData2 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Soldier/", (int)((4000 * 35) / 100f), 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD2"
//                });
//            ConditionData conditionData3 = new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Soldier/", (int)((4000 * 15) / 100f), 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD3"
//                });
//            List<MeshData> meshDatasLOD1 = GetModelDatas(conditionData1);
//            List<MeshData> meshDatasLOD2 = GetModelDatas(conditionData2);
//            List<MeshData> meshDatasLOD3 = GetModelDatas(conditionData3);
//            ResoultData resoultData = ResoultNeaten(new List<List<MeshData>>()
//        {
//            meshDatasLOD1,
//            meshDatasLOD2,
//            meshDatasLOD3
//        });
//            //写出
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/局内小兵模型检测.txt");
//            resoultData.Write(savePath);
//        }

//        #region//英雄模型检测

//        /// <summary>
//        /// 获得模型检测数据
//        /// </summary>
//        /// <param name="filePath"></param>
//        /// <param name="conditionData"></param>
//        /// <returns></returns>
//        public static MeshData GetModelData(string filePath, ConditionData conditionData)
//        {
//            List<string> nameSuffixs = conditionData.NameSuffixs;
//            List<string> nameSuffixsSet = new List<string>();
//            for (int i = 0, listCount = nameSuffixs.Count; i < listCount; ++i)
//            {
//                nameSuffixsSet.Add(string.Format("{0}.prefab", nameSuffixs[i]));
//            }
//            filePath = filePath.Replace("\\", "/");
//            string assetPath = TACommon.PathToAssetPath(filePath);
//            GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
//            MeshData meshData = GetModelTriangular(obj, conditionData);
//            return meshData;
//        }

//        /// <summary>
//        /// 根据命名后缀 获得模型检测数据
//        /// </summary>
//        /// <param name="nameSuffixs"></param>
//        /// <returns></returns>
//        static List<MeshData> GetModelDatas(ConditionData conditionData)
//        {
//            EditorUtility.ClearProgressBar();
//            List<MeshData> resoultList = new List<MeshData>();
//            List<string> nameSuffixs = conditionData.NameSuffixs;
//            string path = TACommon.AssetPathToPath(conditionData.CheckDirectory);
//            string[] files = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
//            List<string> nameSuffixsSet = new List<string>();
//            for (int i = 0, listCount = nameSuffixs.Count; i < listCount; ++i)
//            {
//                nameSuffixsSet.Add(string.Format("{0}.prefab", nameSuffixs[i]));
//            }
//            for (int i = 0, listCount = files.Length; i < listCount; ++i)
//            {
//                string filePath = files[i].Replace("\\", "/");
//                EditorUtility.DisplayCancelableProgressBar("模型检测(" + i + "/" + listCount + ")", "", i / (float)listCount);
//                bool find = false;
//                for (int j = 0, listCount2 = nameSuffixsSet.Count; j < listCount2; ++j)
//                {
//                    if (filePath.EndsWith(nameSuffixsSet[j]))
//                    {
//                        find = true;
//                        break;
//                    }
//                }
//                if (find)
//                {
//                    string assetPath = TACommon.PathToAssetPath(filePath);
//                    GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
//                    MeshData meshData = GetModelTriangular(obj, conditionData);
//                    resoultList.Add(meshData);
//                }
//            }
//            EditorUtility.ClearProgressBar();
//            return resoultList;
//        }

//        /// <summary>
//        /// 结果整合
//        /// </summary>
//        /// <param name="datas"></param>
//        /// <returns></returns>
//        public static ResoultData ResoultNeaten(List<List<MeshData>> datas)
//        {
//            EditorUtility.ClearProgressBar();
//            ResoultData resoultData = new ResoultData(datas);
//            resoultData.Neaten();
//            EditorUtility.ClearProgressBar();
//            return resoultData;
//        }

//        /// <summary>
//        /// 检测结果
//        /// </summary>
//        public class ResoultData
//        {
//            public ResoultData(List<List<MeshData>> datas)
//            {
//                initDatas = datas;
//                for (int i = 0, listCount = datas.Count; i < listCount; ++i)
//                {
//                    initMeshDataCount = initMeshDataCount + datas[i].Count;
//                }
//            }

//            /// <summary>
//            /// 初始数据
//            /// </summary>
//            List<List<MeshData>> initDatas;

//            /// <summary>
//            /// 初始数据数量
//            /// </summary>
//            int initMeshDataCount = 0;

//            /// <summary>
//            /// 结果存放 key:是否合乎标准 value:结果数据
//            /// </summary>
//            public Dictionary<bool, List<MeshData>> Resoult = new Dictionary<bool, List<MeshData>>();

//            /// <summary>
//            /// 计算结果
//            /// </summary>
//            public void Neaten()
//            {
//                for (int i = 0, listCount = initDatas.Count; i < listCount; ++i)
//                {
//                    List<MeshData> list = initDatas[i];
//                    for (int j = 0, listCount2 = list.Count; j < listCount2; ++j)
//                    {
//                        EditorUtility.DisplayCancelableProgressBar("结果整理(" + j + "/" + listCount2 + ")", "", j / (float)listCount2);
//                        MeshData meshData = list[j];
//                        meshData.Comparison();
//                        List<MeshData> resoultList;
//                        if (!Resoult.TryGetValue(meshData.UpToStandard, out resoultList))
//                        {
//                            resoultList = new List<MeshData>();
//                            Resoult.Add(meshData.UpToStandard, resoultList);
//                        }
//                        resoultList.Add(meshData);
//                    }
//                }
//            }

//            /// <summary>
//            /// 写出
//            /// </summary>
//            /// <param name="savePath"></param>
//            public void Write(string savePath)
//            {
//                StringBuilder sb = GetStringBuilder();
//                EditorTool.WriteTxt(savePath, sb.ToString());
//                Debug.LogError("写出路径:" + savePath);
//            }

//            public StringBuilder GetStringBuilder()
//            {
//                StringBuilder sb = new StringBuilder();
//                if (Resoult.ContainsKey(false))
//                {
//                    sb.Append(string.Format("*********************************不合格：\n"));
//                    List<MeshData> list = Resoult[false];
//                    for (int i = 0, listCount = list.Count; i < listCount; ++i)
//                    {
//                        sb.Append("\n");
//                        sb.Append(list[i].Descriptor.ToString());
//                    }
//                }
//                if (Resoult.ContainsKey(true))
//                {
//                    sb.Append(string.Format("--------->\n"));
//                    sb.Append(string.Format("*********************************合格：\n"));
//                    List<MeshData> list = Resoult[true];
//                    for (int i = 0, listCount = list.Count; i < listCount; ++i)
//                    {
//                        sb.Append("\n");
//                        sb.Append(list[i].Descriptor.ToString());
//                    }
//                }
//                return sb;
//            }

//        }

//        /// <summary>
//        /// 计算模型的面数
//        /// </summary>
//        /// <param name="obj"></param>
//        /// <returns></returns>
//        static MeshData GetModelTriangular(GameObject obj, ConditionData conditionData)
//        {
//            MeshData meshData = new MeshData(conditionData);
//            meshData.Target = obj;

//            //拖尾脚本检查
//            AboutVFXGhostTrail[] aboutVFXGhostTrails = obj.GetComponentsInChildren<AboutVFXGhostTrail>(true);
//            for (int i = 0, listCount = aboutVFXGhostTrails.Length; i < listCount; ++i)
//            {
//                meshData.AboutVFXGhostTrails.Add(aboutVFXGhostTrails[i]);
//            }
//            //查找丢失Prefab
//            List<GameObject> allObjs = GetAllGameObjects(obj);
//            for (int i = 0, listCount = allObjs.Count; i < listCount; ++i)
//            {
//                GameObject ob = allObjs[i];
//                if (ob.name.Contains("(Missing Prefab)"))
//                {
//                    meshData.MissingPrefabList.Add(ob);
//                }
//            }
//            //查找灯光
//            Light[] lights = obj.GetComponentsInChildren<Light>(true);
//            for (int i = 0, listCount = lights.Length; i < listCount; ++i)
//            {
//                meshData.LightObjs.Add(lights[i].gameObject);
//            }
//            ParticleSystem[] particleSystems = obj.GetComponentsInChildren<ParticleSystem>(true);
//            for (int i = 0, listCount = particleSystems.Length; i < listCount; ++i)
//            {
//                ParticleSystem particleSystem = particleSystems[i];
//                if (particleSystem.lights.enabled)
//                {
//                    meshData.ParticleLightObjs.Add(particleSystem.gameObject);
//                }
//            }
//            //
//            System.Action<List<Vector2[]>, Renderer, Dictionary<int, List<Renderer>>> uvCheck = (uvList, renderer, uvNotAtZeroToOneList) =>
//            {
//                for (int i = 0, listCount = uvList.Count; i < listCount; ++i)
//                {
//                    Vector2[] uv = uvList[i];
//                    if (uv != null && uv.Length > 0)
//                    {
//                        for (int j = 0, listCount2 = uv.Length; j < listCount2; ++j)
//                        {
//                            Vector2 v = uv[j];
//                            if (v.x < 0 || v.x > 1 || v.y < 0 || v.y > 1)
//                            {
//                                List<Renderer> list;
//                                if (!uvNotAtZeroToOneList.TryGetValue(i, out list))
//                                {
//                                    list = new List<Renderer>();
//                                    uvNotAtZeroToOneList.Add(i, list);
//                                }
//                                list.Add(renderer);
//                                break;
//                            }
//                        }
//                    }
//                }
//            };

//            SkinnedMeshRenderer[] skinnedMeshRenderers = obj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
//            MeshRenderer[] meshRenderers = obj.GetComponentsInChildren<MeshRenderer>(true);
//            for (int i = 0, listCount = skinnedMeshRenderers.Length; i < listCount; ++i)
//            {
//                SkinnedMeshRenderer skinnedMeshRenderer = skinnedMeshRenderers[i];
//                if (skinnedMeshRenderer.sharedMesh != null)
//                {
//                    meshData.Triangular = meshData.Triangular + skinnedMeshRenderer.sharedMesh.triangles.Length / 3;
//                    meshData.RendererTriangular.Add(skinnedMeshRenderer, skinnedMeshRenderer.sharedMesh.triangles.Length / 3);
//                    //检查UV坐标是否在0-1
//                    List<Vector2[]> list = new List<Vector2[]>();
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv2);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv3);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv4);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv5);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv6);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv7);
//                    list.Add(skinnedMeshRenderer.sharedMesh.uv8);
//                    uvCheck(list, skinnedMeshRenderer, meshData.UVNotAtZeroToOneList);
//                    List<bool> uvList = new List<bool>();
//                    meshData.UvGOneList.Add(skinnedMeshRenderer, uvList);
//                    for (int j = 0, listCount2 = list.Count; j < listCount2; ++j)
//                    {
//                        Vector2[] uv = list[j];
//                        if (uv != null && uv.Length > 0)
//                        {
//                            uvList.Add(true);
//                        }
//                        else
//                        {
//                            uvList.Add(false);
//                        }
//                    }
//                    //
//                    if ((skinnedMeshRenderer.sharedMesh.colors != null && skinnedMeshRenderer.sharedMesh.colors.Length > 0) || (skinnedMeshRenderer.sharedMesh.colors32 != null && skinnedMeshRenderer.sharedMesh.colors32.Length > 0))
//                    {
//                        if (!TA_ResourcesTool.MeshNeedVertexColor(skinnedMeshRenderer.sharedMesh))
//                        {
//                            //判断网格是否需要顶点颜色
//                            meshData.VertexColorList.Add(skinnedMeshRenderer);
//                        }
//                    }
//                }
//                else
//                {
//                    meshData.MeshNullList.Add(skinnedMeshRenderers[i]);
//                }
//                //多维子检测
//                if (skinnedMeshRenderer.sharedMaterials != null && skinnedMeshRenderer.sharedMaterials.Length > 1)
//                {
//                    meshData.MultiMaterialList.Add(skinnedMeshRenderers[i]);
//                }
//                meshData.Renderers.Add(skinnedMeshRenderers[i]);
//            }
//            for (int i = 0, listCount = meshRenderers.Length; i < listCount; ++i)
//            {
//                MeshRenderer meshRenderer = meshRenderers[i];
//                MeshFilter meshFilter = meshRenderer.gameObject.GetComponent<MeshFilter>();
//                if (meshFilter != null && meshFilter.sharedMesh != null)
//                {
//                    meshData.Triangular = meshData.Triangular + meshFilter.sharedMesh.triangles.Length / 3;
//                    meshData.RendererTriangular.Add(meshRenderer, meshFilter.sharedMesh.triangles.Length / 3);
//                    //检查UV坐标是否在0-1
//                    List<Vector2[]> list = new List<Vector2[]>();
//                    list.Add(meshFilter.sharedMesh.uv);
//                    list.Add(meshFilter.sharedMesh.uv2);
//                    list.Add(meshFilter.sharedMesh.uv3);
//                    list.Add(meshFilter.sharedMesh.uv4);
//                    list.Add(meshFilter.sharedMesh.uv5);
//                    list.Add(meshFilter.sharedMesh.uv6);
//                    list.Add(meshFilter.sharedMesh.uv7);
//                    list.Add(meshFilter.sharedMesh.uv8);
//                    uvCheck(list, meshRenderer, meshData.UVNotAtZeroToOneList);
//                    List<bool> uvList = new List<bool>();
//                    meshData.UvGOneList.Add(meshRenderer, uvList);
//                    for (int j = 0, listCount2 = list.Count; j < listCount2; ++j)
//                    {
//                        Vector2[] uv = list[j];
//                        if (uv != null && uv.Length > 0)
//                        {
//                            uvList.Add(true);
//                        }
//                        else
//                        {
//                            uvList.Add(false);
//                        }
//                    }
//                    //
//                    if ((meshFilter.sharedMesh.colors != null && meshFilter.sharedMesh.colors.Length > 0) || (meshFilter.sharedMesh.colors32 != null && meshFilter.sharedMesh.colors32.Length > 0))
//                    {
//                        if (!TA_ResourcesTool.MeshNeedVertexColor(meshFilter.sharedMesh))
//                        {
//                            meshData.VertexColorList.Add(meshRenderer);
//                        }
//                    }
//                }
//                else
//                {
//                    meshData.MeshNullList.Add(meshRenderer);
//                }
//                //多维子检测
//                if (meshRenderer.sharedMaterials != null && meshRenderer.sharedMaterials.Length > 1)
//                {
//                    meshData.MultiMaterialList.Add(meshRenderer);
//                }
//                meshData.Renderers.Add(meshRenderer);
//            }
//            return meshData;
//        }

//        /// <summary>
//        /// 获得所有的GameObject节点
//        /// </summary>
//        /// <param name="obj"></param>
//        /// <returns></returns>
//        static List<GameObject> GetAllGameObjects(GameObject obj)
//        {
//            List<GameObject> list = new List<GameObject>();
//            GetAllGameObjects(obj, list);
//            return list;
//        }

//        /// <summary>
//        /// 获得所有的GameObject节点
//        /// </summary>
//        /// <param name="obj"></param>
//        /// <param name="list"></param>
//        static void GetAllGameObjects(GameObject obj, List<GameObject> list)
//        {
//            list.Add(obj);
//            int childCount = obj.transform.childCount;
//            for (int i = 0; i < childCount; ++i)
//            {
//                Transform child = obj.transform.GetChild(i);
//                GetAllGameObjects(child.gameObject, list);
//            }
//        }

//        /// <summary>
//        /// 网格信息
//        /// </summary>
//        public class MeshData
//        {
//            public MeshData(ConditionData conditionData)
//            {
//                ConditionData = conditionData;
//            }

//            /// <summary>
//            /// 对比条件
//            /// </summary>
//            public ConditionData ConditionData;

//            /// <summary>
//            /// 目标
//            /// </summary>
//            public GameObject Target;

//            /// <summary>
//            /// 三角形面数
//            /// </summary>
//            public int Triangular;

//            /// <summary>
//            /// 拖尾脚本检查
//            /// </summary>
//            public List<AboutVFXGhostTrail> AboutVFXGhostTrails = new List<AboutVFXGhostTrail>();

//            /// <summary>
//            /// 拥有多于一套UV key:目标 value:8套UV是否具备
//            /// </summary>
//            public Dictionary<Renderer, List<bool>> UvGOneList = new Dictionary<Renderer, List<bool>>();

//            /// <summary>
//            /// UV坐标不在0-1的 key:第几套UV value:问题网格
//            /// </summary>
//            public Dictionary<int, List<Renderer>> UVNotAtZeroToOneList = new Dictionary<int, List<Renderer>>();

//            /// <summary>
//            /// 具备顶点颜色的
//            /// </summary>
//            public List<Renderer> VertexColorList = new List<Renderer>();

//            /// <summary>
//            /// key:网格 value:面数
//            /// </summary>
//            public Dictionary<Renderer, int> RendererTriangular = new Dictionary<Renderer, int>();

//            /// <summary>
//            /// 具备的网格
//            /// </summary>
//            public List<Renderer> Renderers = new List<Renderer>();

//            /// <summary>
//            /// 灯光物体
//            /// </summary>
//            public List<GameObject> LightObjs = new List<GameObject>();

//            /// <summary>
//            /// 粒子灯光
//            /// </summary>
//            public List<GameObject> ParticleLightObjs = new List<GameObject>();

//            /// <summary>
//            /// 网格缺失列表
//            /// </summary>
//            public List<Renderer> MeshNullList = new List<Renderer>();

//            /// <summary>
//            /// 多维子列表
//            /// </summary>
//            public List<Renderer> MultiMaterialList = new List<Renderer>();

//            /// <summary>
//            /// Prefab丢失列表
//            /// </summary>
//            public List<GameObject> MissingPrefabList = new List<GameObject>();

//            /// <summary>
//            /// 是否合乎标准
//            /// </summary>
//            public bool UpToStandard = true;

//            /// <summary>
//            /// 描述信息
//            /// </summary>
//            public StringBuilder Descriptor = new StringBuilder();

//            /// <summary>
//            /// 进行比较
//            /// </summary>
//            public void Comparison()
//            {
//                UpToStandard = true;
//                Descriptor.Clear();
//                Descriptor.Append(string.Format("目标模型:{0} 路径:{1}\n", Target, AssetDatabase.GetAssetPath(Target)));

//                #region//拖尾脚本检查
//                if (AboutVFXGhostTrails.Count > 2)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 拖尾脚本数量大于1（AboutVFXGhostTrail）\n"));
//                }
//                for (int i = 0, listCount = AboutVFXGhostTrails.Count; i < listCount; ++i)
//                {
//                    AboutVFXGhostTrail aboutVFXGhostTrail = AboutVFXGhostTrails[i];
//                    List<AboutVFXGhostTrail.VFXData> datas = aboutVFXGhostTrail.Datas;
//                    for (int j = 0, listCount2 = datas.Count; j < listCount2; ++j)
//                    {
//                        AboutVFXGhostTrail.VFXData vfxData = datas[j];
//                        if (string.IsNullOrEmpty(vfxData.OpacityName))
//                        {
//                            UpToStandard = false;
//                            Descriptor.Append(string.Format("   <不合格> 拖尾脚本数据错误（AboutVFXGhostTrail）,OpacityName属性为空,序号:{0}\n", j));
//                        }
//                        if (vfxData.SkinnedMeshRenderer == null)
//                        {
//                            UpToStandard = false;
//                            Descriptor.Append(string.Format("   <不合格> 拖尾脚本数据错误（AboutVFXGhostTrail）,SkinnedMeshRenderer属性为空,序号:{0}\n", j));
//                        }
//                        if (vfxData.GhostMaterial == null)
//                        {
//                            UpToStandard = false;
//                            Descriptor.Append(string.Format("   <不合格> 拖尾脚本数据错误（AboutVFXGhostTrail）,GhostMaterial属性为空,序号:{0}\n", j));
//                        }
//                    }
//                }

//                #endregion

//                #region/uv不在 0-1

//                if (UVNotAtZeroToOneList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现UV坐标不是0-1的模型:\n"));
//                    Dictionary<int, List<Renderer>>.Enumerator enumeratorUv = UVNotAtZeroToOneList.GetEnumerator();
//                    while (enumeratorUv.MoveNext())
//                    {
//                        Descriptor.Append(string.Format("       不合格问题在第{0}套UV，包含节点:\n", enumeratorUv.Current.Key));
//                        List<Renderer> list = enumeratorUv.Current.Value;
//                        for (int i = 0, listCount = list.Count; i < listCount; ++i)
//                        {
//                            Descriptor.Append(string.Format("           节点:{0}\n", list[i].name));
//                        }
//                    }
//                }

//                #endregion

//                #region//具备顶点颜色

//                if (VertexColorList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 网格具备顶点颜色:\n"));
//                    for (int i = 0, listCount = VertexColorList.Count; i < listCount; ++i)
//                    {
//                        Renderer render = VertexColorList[i];
//                        Descriptor.Append(string.Format("           节点:{0} 路径:{1}\n", render.name, AssetDatabase.GetAssetPath(render)));
//                    }
//                }

//                #endregion

//                #region//面数检查

//                //面数检查
//                if (Triangular > ConditionData.MaxTriangularFacet)
//                {
//                    UpToStandard = false;
//                    int percentageInt = (int)(10000 * (Triangular - ConditionData.MaxTriangularFacet) / (float)ConditionData.MaxTriangularFacet);
//                    float percentageFloat = percentageInt / (float)100;
//                    Descriptor.Append(string.Format("   <不合格> 要求面数:{0} 实际面数:{1} 超出比例:{2}%\n", ConditionData.MaxTriangularFacet, Triangular, percentageFloat));
//                    Dictionary<Renderer, int>.Enumerator enu = RendererTriangular.GetEnumerator();
//                    while (enu.MoveNext())
//                    {
//                        Descriptor.Append(string.Format("       网格:{0} 面数:{1}\n", enu.Current.Key, enu.Current.Value));
//                        //8套uv使用情况
//                        List<bool> uvList;
//                        UvGOneList.TryGetValue(enu.Current.Key, out uvList);
//                        UvGOneList.Remove(enu.Current.Key);
//                        if (uvList != null)
//                        {
//                            for (int i = 0, listCount = uvList.Count; i < listCount; ++i)
//                            {
//                                string str = "已使用";
//                                if (!uvList[i])
//                                {
//                                    str = "未使用";
//                                }
//                                Descriptor.Append(string.Format("               第{0}套UV，使用情况为{1}\n", i, str));
//                            }
//                        }
//                    }
//                }
//                else
//                {
//                    Descriptor.Append(string.Format("   <合格> 要求面数:{0} 实际面数:{1}\n", ConditionData.MaxTriangularFacet, Triangular));
//                }

//                if (UvGOneList.Count > 0)
//                {
//                    Descriptor.Append(string.Format("   8套UV的使用情况:\n"));
//                    Dictionary<Renderer, List<bool>>.Enumerator enumeratorUV = UvGOneList.GetEnumerator();
//                    while (enumeratorUV.MoveNext())
//                    {
//                        Renderer renderer = enumeratorUV.Current.Key;
//                        Descriptor.Append(string.Format("       目标节点:{0}\n", renderer.name));
//                        List<bool> uvList = enumeratorUV.Current.Value;
//                        for (int i = 0, listCount = uvList.Count; i < listCount; ++i)
//                        {
//                            Descriptor.Append(string.Format("           第{0}套UV，使用情况{1}\n", i, uvList[i]));
//                        }
//                    }
//                }

//                #endregion

//                #region//检查丢失Prefab

//                if (MissingPrefabList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现丢失Prefab (MissingPrefab):\n"));
//                    for (int i = 0, listCount = MissingPrefabList.Count; i < listCount; ++i)
//                    {
//                        GameObject obj = MissingPrefabList[i];
//                        Descriptor.Append(string.Format("           节点:{0}\n", obj.name));
//                    }
//                }

//                #endregion

//                #region//灯光检查

//                if (LightObjs.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现不该存在的灯光:\n"));
//                    for (int i = 0, listCount = LightObjs.Count; i < listCount; ++i)
//                    {
//                        Descriptor.Append(string.Format("       节点:{0}\n", LightObjs[i]));
//                    }
//                }

//                if (ParticleLightObjs.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现不该存在的粒子灯光:\n"));
//                    for (int i = 0, listCount = ParticleLightObjs.Count; i < listCount; ++i)
//                    {
//                        Descriptor.Append(string.Format("       节点:{0}\n", ParticleLightObjs[i]));
//                    }
//                }

//                #endregion

//                #region//材质检查

//                //Shader检查
//                if (MeshNullList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现缺失网格:\n"));
//                    for (int i = 0, listCount = MeshNullList.Count; i < listCount; ++i)
//                    {
//                        Descriptor.Append(string.Format("      节点:{0}\n", MeshNullList[i].name));
//                    }
//                }
//                //多维子检查 
//                if (MultiMaterialList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Descriptor.Append(string.Format("   <不合格> 发现多维子网格:\n"));
//                    for (int i = 0, listCount = MultiMaterialList.Count; i < listCount; ++i)
//                    {
//                        Descriptor.Append(string.Format("      节点:{0} 材质球数量大于1:{1}\n", MultiMaterialList[i].name, MultiMaterialList[i].sharedMaterials.Length));
//                    }
//                }
//                //key:材质 value:对应的Renderer
//                Dictionary<Material, Renderer> mats = new Dictionary<Material, Renderer>();
//                for (int i = 0, listCount = Renderers.Count; i < listCount; ++i)
//                {
//                    Renderer renderer = Renderers[i];
//                    Material[] matArray = renderer.sharedMaterials;
//                    for (int j = 0, listCount2 = matArray.Length; j < listCount2; ++j)
//                    {
//                        Material mat = matArray[j];
//                        if (mat != null)
//                        {
//                            if (mat.shader == null)
//                            {
//                                UpToStandard = false;
//                                Descriptor.Append(string.Format("   <不合格> 材质Shader丢失:{0} 序号:{1}\n", renderer.name, j));
//                            }
//                            else
//                            {
//                                if (!mats.ContainsKey(mat))
//                                {
//                                    mats.Add(mat, renderer);
//                                }
//                            }
//                        }
//                        else
//                        {
//                            UpToStandard = false;
//                            Descriptor.Append(string.Format("   <不合格> 材质未指定:{0} 序号:{1}\n", renderer.name, j));
//                        }
//                    }
//                }
//                Dictionary<Material, Renderer>.Enumerator enumerator = mats.GetEnumerator();
//                while (enumerator.MoveNext())
//                {
//                    Material mat = enumerator.Current.Key;
//                    Renderer renderer = enumerator.Current.Value;
//                    bool needCheck = false;
//                    if (renderer.name.Contains("wuqi") || renderer.name.Contains("shenti") || renderer.name.Contains("toufa") || renderer.name.Contains("yanjing"))
//                    {
//                        needCheck = true;
//                    }
//                    if (ConditionData.QualityType == QualityType.Lod1 || ConditionData.QualityType == QualityType.Lod2 || ConditionData.QualityType == QualityType.Lod3)
//                    {
//                        needCheck = true;
//                    }
//                    if (needCheck)
//                    {
//                        bool find = false;
//                        for (int i = 0, listCount = ConditionData.ShaderList.Count; i < listCount; ++i)
//                        {
//                            string shaderName = ConditionData.ShaderList[i];
//                            if (mat.shader.name.EndsWith(shaderName))
//                            {
//                                find = true;
//                                break;
//                            }
//                        }
//                        if (!find)
//                        {
//                            UpToStandard = false;
//                            Descriptor.Append(string.Format("   <不合格> 不是指定的Shader:{0}\n", renderer.name));
//                        }
//                    }
//                }

//                #endregion

//                #region//纹理检查

//                List<UnityEngine.Object> checkList = new List<UnityEngine.Object>();
//                List<Texture2D> findTexture2Ds = new List<Texture2D>();
//                checkList.Add(Target);
//                enumerator = mats.GetEnumerator();
//                while (enumerator.MoveNext())
//                {
//                    checkList.Add(enumerator.Current.Key);
//                }
//                for (int i = 0, listCount = checkList.Count; i < listCount; ++i)
//                {
//                    Renderer renderer = null;
//                    if (checkList[i].GetType() == typeof(Material) && mats.ContainsKey((Material)checkList[i]))
//                    {
//                        renderer = mats[(Material)checkList[i]];
//                    }
//                    UnityEngine.Object[] decyAssets = EditorUtility.CollectDependencies(new UnityEngine.Object[] { checkList[i] });
//                    for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
//                    {
//                        if (decyAssets[j] == null) continue;
//                        Type t = decyAssets[j].GetType();
//                        if (t == typeof(Texture2D))
//                        {
//                            Texture2D tex = (Texture2D)decyAssets[j];
//                            if (!findTexture2Ds.Contains(tex))
//                            {
//                                findTexture2Ds.Add(tex);
//                                int maxTextureSize = ConditionData.GetMaxTextureSize(tex.name);
//                                string assetPath = AssetDatabase.GetAssetPath(tex);
//                                //尺寸检查
//                                if (tex.width > maxTextureSize || tex.height > maxTextureSize)
//                                {
//                                    UpToStandard = false;
//                                    Descriptor.Append(string.Format("   <不合格> 纹理尺寸设置超标:\n"));
//                                    Descriptor.Append(string.Format("      路径:{0}\n", AssetDatabase.GetAssetPath(tex)));
//                                    Descriptor.Append(string.Format("      要求尺寸:{0}\n", maxTextureSize));
//                                    Descriptor.Append(string.Format("      实际尺寸:{0}\n", string.Format("{0}X{1}", tex.width, tex.height)));
//                                }
//                                //psd文件检查
//                                string texAssetPath = AssetDatabase.GetAssetPath(tex);
//                                if (texAssetPath != null && texAssetPath.ToLower().EndsWith(".psd"))
//                                {
//                                    Descriptor.Append(string.Format("   <不合格> 纹理格式为:.psd\n"));
//                                }
//                                //4的倍数检查
//                                if (tex.width % 4 != 0 || tex.height % 4 != 0)
//                                {
//                                    UpToStandard = false;
//                                    //非4的倍数
//                                    if (tex.width % 4 != 0)
//                                    {
//                                        Descriptor.Append(string.Format("   <不合格> 纹理宽度不是4的倍数:{0}\n", tex.width));
//                                    }
//                                    if (tex.height % 4 != 0)
//                                    {
//                                        Descriptor.Append(string.Format("   <不合格> 纹理高度不是4的倍数:{0}\n", tex.height));
//                                    }
//                                }
//                                //路径检查
//                                bool needCheckPath = false;
//                                if (renderer != null)
//                                {
//                                    if (renderer.name.Contains("wuqi") || renderer.name.Contains("shenti") || renderer.name.Contains("toufa") || renderer.name.Contains("yanjing"))
//                                    {
//                                        needCheckPath = true;
//                                    }
//                                }
//                                if (ConditionData.QualityType == QualityType.Lod1 || ConditionData.QualityType == QualityType.Lod2 || ConditionData.QualityType == QualityType.Lod3)
//                                {
//                                    needCheckPath = true;
//                                }
//                                if (needCheckPath)
//                                {
//                                    List<string> checkPaths = new List<string>();
//                                    checkPaths.Add("Assets/Art/Effects");
//                                    switch (ConditionData.QualityType)
//                                    {
//                                        case QualityType.Hight:
//                                        case QualityType.Mid:
//                                            {
//                                                checkPaths.Add("Assets/Art/Characters/player/Character_Show/");
//                                            }
//                                            break;
//                                        case QualityType.Lod1:
//                                        case QualityType.Lod2:
//                                        case QualityType.Lod3:
//                                            {
//                                                checkPaths.Add("Assets/Art/Characters/player/Character/");
//                                            }
//                                            break;
//                                    }
//                                    bool findPath = false;
//                                    for (int x = 0, listCount3 = checkPaths.Count; x < listCount3; ++x)
//                                    {
//                                        if (assetPath.StartsWith(checkPaths[x]))
//                                        {
//                                            findPath = true;
//                                            break;
//                                        }
//                                    }
//                                    if (!findPath)
//                                    {
//                                        UpToStandard = false;
//                                        Descriptor.Append(string.Format("   <不合格> 纹理路径异常:\n"));
//                                        Descriptor.Append(string.Format("      应该路径:\n"));
//                                        for (int x = 0, listCount3 = checkPaths.Count; x < listCount3; ++x)
//                                        {
//                                            Descriptor.Append(string.Format("           路径:{0}\n", checkPaths[x]));
//                                        }
//                                        Descriptor.Append(string.Format("      实际路径:{0}\n", assetPath));
//                                        Descriptor.Append(string.Format("      对象:{0}\n", checkList[i].name));
//                                    }
//                                }
//                                //同名文件检查
//                                List<string> list = new List<string>();
//                                list.Add(".tga");
//                                list.Add(".png");
//                                list.Add(".jpg");
//                                int index = assetPath.LastIndexOf(".");
//                                if (index > 0)
//                                {
//                                    string thisSuffix = assetPath.Substring(index, assetPath.Length - index - 1);
//                                    for (int x = 0, listCount3 = list.Count; x < listCount3; ++x)
//                                    {
//                                        string checkAssetPath = assetPath.Replace(thisSuffix, list[x]);
//                                        Texture2D findTex = AssetDatabase.LoadAssetAtPath<Texture2D>(checkAssetPath);
//                                        if (findTex != null && findTex != tex)
//                                        {
//                                            UpToStandard = false;
//                                            Descriptor.Append(string.Format("   <不合格> 发现同名但不同后缀的纹理:\n"));
//                                            Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            Descriptor.Append(string.Format("      同名纹理路径:{0}\n", checkAssetPath));
//                                            Descriptor.Append(string.Format("      对象:{0}\n", checkList[i].name));
//                                        }
//                                    }
//                                    //格式配置检查
//                                    TextureImporter textureImporter = TextureImporter.GetAtPath(assetPath) as TextureImporter;
//                                    if (textureImporter != null)
//                                    {
//                                        bool needIsPng = false;
//                                        string texName = tex.name;
//                                        //法线格式检查
//                                        if (texName.EndsWith("_N"))
//                                        {
//                                            if (textureImporter.textureType != TextureImporterType.NormalMap)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> 未设置为法线:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            needIsPng = true;
//                                        }
//                                        //可读写检查
//                                        if (textureImporter.isReadable)
//                                        {
//                                            Descriptor.Append(string.Format("   <不合格> 纹理开启了可读写,路径:{0}\n", assetPath));
//                                        }
//                                        //M图格式检查
//                                        if (texName.EndsWith("_MSAO"))
//                                        {
//                                            // "Standalone", "Web", "iPhone", "Android", "WebGL", "Windows Store Apps", "Tizen", "PSP2", "PS4", "XboxOne", "Samsung TV", "Nintendo 3DS", "WiiU" and "tvOS".
//                                            TextureImporterPlatformSettings setData = textureImporter.GetDefaultPlatformTextureSettings();
//                                            //if (setData.format != TextureImporterFormat.ASTC_5x5)
//                                            //{
//                                            //    UpToStandard = false;
//                                            //    Descriptor.Append(string.Format("   <不合格> (Default)未设置为ASTC_5x5:\n"));
//                                            //    Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            //}
//                                            if (textureImporter.sRGBTexture)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> 混合图未关闭sRGB:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            if (setData.resizeAlgorithm != TextureResizeAlgorithm.Mitchell)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> (Default)未设置为Mitchell:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            //安卓平台
//                                            setData = textureImporter.GetPlatformTextureSettings("Android");
//                                            if (setData.format != TextureImporterFormat.ASTC_5x5)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> (安卓平台)未设置为ASTC_5x5:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            if (setData.resizeAlgorithm != TextureResizeAlgorithm.Mitchell)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> (安卓平台)未设置为Mitchell:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            //IOS平台
//                                            setData = textureImporter.GetPlatformTextureSettings("iPhone");
//                                            if (setData.format != TextureImporterFormat.ASTC_5x5)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> (IOS平台)未设置为ASTC_5x5:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            if (setData.resizeAlgorithm != TextureResizeAlgorithm.Mitchell)
//                                            {
//                                                UpToStandard = false;
//                                                Descriptor.Append(string.Format("   <不合格> (IOS平台)未设置为Mitchell:\n"));
//                                                Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                            }
//                                            needIsPng = true;
//                                        }
//                                        //自发光贴图检查
//                                        if (texName.EndsWith("_E"))
//                                        {
//                                            needIsPng = true;
//                                        }
//                                        //SSS贴图检查
//                                        if (texName.EndsWith("_SSS"))
//                                        {
//                                            needIsPng = true;
//                                        }
//                                        if (textureImporter.isReadable)
//                                        {
//                                            UpToStandard = false;
//                                            Descriptor.Append(string.Format("   <不合格> 目标开启了可读写:\n"));
//                                            Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                        }
//                                        if (textureImporter.mipmapEnabled)
//                                        {
//                                            UpToStandard = false;
//                                            Descriptor.Append(string.Format("   <不合格> 目标开启了mipmap:\n"));
//                                            Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                        }
//                                        //if (needIsPng)
//                                        //{
//                                        //    if (!assetPath.EndsWith(".png"))
//                                        //    {
//                                        //        UpToStandard = false;
//                                        //        Descriptor.Append(string.Format("   <不合格> 未设置为PNG:\n"));
//                                        //        Descriptor.Append(string.Format("      纹理路径:{0}\n", assetPath));
//                                        //    }
//                                        //}
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

//                #endregion
//            }
//        }

//        static Dictionary<QualityType, ConditionData> charactersConditions;

//        /// <summary>
//        /// 规则条件 英雄角色
//        /// </summary>
//        public static Dictionary<QualityType, ConditionData> CharactersConditions
//        {
//            get
//            {
//                if (charactersConditions == null)
//                {
//                    charactersConditions = new Dictionary<QualityType, ConditionData>();
//                    //Hight
//                    charactersConditions.Add(QualityType.Hight, new ConditionData(QualityType.Hight, "Assets/ResAB/Prefab_Characters/Prefab_Hero/", 15000, 1024, new List<string>() {
//                    "PBRBaseLit",
//                    "PBRBaseLit_FakeMirror",
//                    "PBRBaseLit_Eye",
//                    "PBRBaseLit_Eye_FakeMirror",
//                    "PBRBaseLit_Hair",
//                    "PBRBaseLit_Hair_FakeMirror",
//                    "SubsurfaceScatteringPBR",
//                    "SG_Hair_Default",
//                    "SG_Lit_Default",
//                    "SG_Lit_Emissive",
//                    "SG_Lit_Robot",
//                }, new List<string>()
//                {
//                     "_Show1",
//                     "_Charactershow",
//                }));
//                    //Mid
//                    charactersConditions.Add(QualityType.Mid, new ConditionData(QualityType.Mid, "Assets/ResAB/Prefab_Characters/Prefab_Hero/", 15000, 1024, new List<string>() {
//                    "PBRBaseLit",
//                    "PBRBaseLit_FakeMirror",
//                    "PBRBaseLit_Eye",
//                    "PBRBaseLit_Eye_FakeMirror",
//                    "PBRBaseLit_Hair",
//                    "PBRBaseLit_Hair_FakeMirror",
//                    "SubsurfaceScatteringPBR",
//                     "SG_Hair_Default",
//                    "SG_Lit_Default",
//                    "SG_Lit_Emissive",
//                    "SG_Lit_Robot",
//                }, new List<string>() {
//                     "_Show1",
//                     "_Charactershow",
//                }));
//                    //Lod1
//                    charactersConditions.Add(QualityType.Lod1, new ConditionData(QualityType.Lod1, "Assets/ResAB/Prefab_Characters/Prefab_Hero/", 4000, 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD1"
//                }));
//                    //Lod2
//                    charactersConditions.Add(QualityType.Lod2, new ConditionData(QualityType.Lod2, "Assets/ResAB/Prefab_Characters/Prefab_Hero/", 4000, 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD2"
//                }));
//                    //Lod3
//                    charactersConditions.Add(QualityType.Lod3, new ConditionData(QualityType.Lod3, "Assets/ResAB/Prefab_Characters/Prefab_Hero/", 4000, 1024, new List<string>() {
//                    "Hero_Battle",
//                    "Hero_Battle2",
//                    "Hero_Battle3",
//                    "Hero_Battle4"
//                }, new List<string>() {
//                    "_LOD3"
//                }));
//                }
//                return charactersConditions;
//            }
//        }

//        public static ConditionData GetCharactersConditionByPathNameSuffixs(string assetPath)
//        {
//            if (!assetPath.EndsWith(".prefab"))
//            {
//                return null;
//            }
//            Dictionary<QualityType, ConditionData>.Enumerator enumerator = CharactersConditions.GetEnumerator();
//            while (enumerator.MoveNext())
//            {
//                ConditionData conditionData = enumerator.Current.Value;
//                string fileName = Path.GetFileName(assetPath.ToLower().Replace(".prefab", ""));
//                int id = -1;
//                int.TryParse(fileName, out id);
//                if (id > 0)
//                {
//                    id = id % 100;
//                    switch (id)
//                    {
//                        case 0:
//                            {
//                                fileName = fileName + "_Show1.prefab";
//                            }
//                            break;
//                        case 1:
//                            {
//                                fileName = fileName + "_Show1.prefab";
//                            }
//                            break;
//                        case 2:
//                            {
//                                fileName = fileName + "_Show1.prefab";
//                            }
//                            break;
//                    }
//                    fileName = fileName.ToLower();
//                }
//                else
//                {
//                    fileName = assetPath.ToLower();
//                }
//                for (int i = 0, listCount = conditionData.NameSuffixs.Count; i < listCount; ++i)
//                {
//                    if (fileName.EndsWith(conditionData.NameSuffixs[i].ToLower() + ".prefab"))
//                    {
//                        return conditionData;
//                    }
//                }
//            }
//            return null;
//        }

//        /// <summary>
//        /// 精度要求
//        /// </summary>
//        public enum QualityType
//        {
//            Hight,
//            Mid,
//            Lod1,
//            Lod2,
//            Lod3
//        }

//        /// <summary>
//        /// 规则比较数据
//        /// </summary>
//        public class ConditionData
//        {
//            /// <summary>
//            /// 
//            /// </summary>
//            /// <param name="checkDirectory">检查目录</param>
//            /// <param name="maxTriangularFacet">模型要求最大三角面</param>
//            /// <param name="shaderList">要求的材质列表</param>
//            public ConditionData(QualityType _qualityType, string _checkDirectory, int _maxTriangularFacet, int _maxTextureSize, List<string> _shaderList, List<string> _nameSuffixs)
//            {
//                QualityType = _qualityType;
//                maxTextureSize = _maxTextureSize;
//                CheckDirectory = _checkDirectory;
//                MaxTriangularFacet = _maxTriangularFacet;
//                ShaderList = _shaderList;
//                NameSuffixs = _nameSuffixs;
//            }

//            /// <summary>
//            /// 精度类型
//            /// </summary>
//            public QualityType QualityType;

//            /// <summary>
//            /// 检查目录
//            /// </summary>
//            public string CheckDirectory;

//            /// <summary>
//            /// 模型要求最大三角面
//            /// </summary>
//            public int MaxTriangularFacet = 15000;

//            /// <summary>
//            /// 最大贴图尺寸
//            /// </summary>
//            int maxTextureSize = 1024;

//            /// <summary>
//            /// 最大贴图尺寸
//            /// </summary>
//            /// <returns></returns>
//            public int GetMaxTextureSize(string textureName)
//            {
//                switch (this.QualityType)
//                {
//                    case TA_ArtModelWin.QualityType.Hight:
//                    case TA_ArtModelWin.QualityType.Mid:
//                        {
//                            if (textureName.Contains("_shenti_"))
//                            {
//                                return 2048;
//                            }
//                            if (textureName.Contains("_wuqi_"))
//                            {
//                                return 1024;
//                            }
//                            if (textureName.Contains("_toufa_"))
//                            {
//                                return 1024;
//                            }
//                            if (textureName.Contains("_yanqiu_"))
//                            {
//                                return 1024;
//                            }
//                        }
//                        break;
//                    case TA_ArtModelWin.QualityType.Lod1:
//                    case TA_ArtModelWin.QualityType.Lod2:
//                    case TA_ArtModelWin.QualityType.Lod3:
//                        {
//                            return maxTextureSize;
//                        }
//                        break;
//                }
//                return maxTextureSize;
//            }

//            /// <summary>
//            /// 要求的材质列表
//            /// </summary>
//            public List<string> ShaderList;

//            /// <summary>
//            /// 命名后缀
//            /// </summary>
//            public List<string> NameSuffixs;

//        }

//        #endregion

//        #region//粒子模型检测

//        static List<string> _particleAssetPath;

//        /// <summary>
//        /// 粒子模型目录
//        /// </summary>
//        static List<string> particleAssetPath
//        {
//            get
//            {
//                if (_particleAssetPath == null)
//                {
//                    _particleAssetPath = new List<string>();
//                    _particleAssetPath.Add("Assets/ResAB/Prefab_Skill_Effects/Hero_Skill_Effects/");
//                    _particleAssetPath.Add("Assets/ResAB/Prefab_Skill_Effects/Common_Skill_Effects/Prefab/");
//                }
//                return _particleAssetPath;
//            }
//        }

//        /// <summary>
//        /// 粒子规则检测
//        /// </summary>
//        static void Examine_Particle()
//        {
//            EditorUtility.ClearProgressBar();
//            //key:是否合格 value:检测数据
//            Dictionary<bool, List<ParticleData>> ParticleDatas = new Dictionary<bool, List<ParticleData>>();
//            for (int i = 0, listCount = particleAssetPath.Count; i < listCount; ++i)
//            {
//                Examine_Particle(particleAssetPath[i], ParticleDatas, false);
//            }
//            //写出
//            string savePath = TACommon.WriteFolderDir + WriteFolderName + string.Format("/粒子检测.txt");
//            StringBuilder stringBuilder = new StringBuilder();
//            if (ParticleDatas.ContainsKey(false))
//            {
//                stringBuilder.Append("不合格->\n");
//                List<ParticleData> list = ParticleDatas[false];
//                for (int i = 0, listCount = list.Count; i < listCount; ++i)
//                {
//                    ParticleData particleData = list[i];
//                    stringBuilder.Append("\n");
//                    stringBuilder.Append(particleData.Describe.ToString());
//                }
//            }
//            //if (ParticleDatas.ContainsKey(true))
//            //{
//            //    stringBuilder.Append("---------------------->\n");
//            //    stringBuilder.Append("合格->\n");
//            //    List<ParticleData> list = ParticleDatas[true];
//            //    for (int i = 0, listCount = list.Count; i < listCount; ++i)
//            //    {
//            //        ParticleData particleData = list[i];
//            //        stringBuilder.Append("\n");
//            //        stringBuilder.Append(particleData.Describe.ToString());
//            //    }
//            //}
//            EditorTool.WriteTxt(savePath, stringBuilder.ToString());
//            Debug.LogError("写出路径:" + savePath);
//            EditorUtility.ClearProgressBar();
//        }

//        /// <summary>
//        /// 粒子规则检测
//        /// </summary>
//        /// <param name="dir"></param>
//        /// <param name="ParticleDatas"></param>
//        /// <param name="onlySubstandard">只打印超标的</param>
//        static void Examine_Particle(string dir, Dictionary<bool, List<ParticleData>> ParticleDatas, bool onlySubstandard)
//        {
//            string[] files = Directory.GetFiles(TACommon.AssetPathToPath(dir), "*.prefab", SearchOption.AllDirectories);
//            for (int i = 0, listCount = files.Length; i < listCount; ++i)
//            {
//                string filePath = files[i];
//                string assetPath = TACommon.PathToAssetPath(filePath);
//                EditorUtility.DisplayCancelableProgressBar("粒子规则检测(" + i + "/" + listCount + ")", assetPath, i / (float)listCount);
//                GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
//                if (obj != null)
//                {
//                    ParticleData particleData = new ParticleData(obj, assetPath);

//                    //查找缺失Prefab
//                    List<GameObject> objs = GetAllGameObjects(obj);
//                    for (int j = 0, listCount2 = objs.Count; j < listCount2; ++j)
//                    {
//                        GameObject ob = objs[j];
//                        if (ob.name.Contains("(Missing Prefab)"))
//                        {
//                            particleData.MissingPrefabList.Add(ob);
//                        }
//                    }

//                    //查找灯光
//                    Light[] lights = obj.GetComponentsInChildren<Light>(true);
//                    for (int j = 0, listCount2 = lights.Length; j < listCount2; ++j)
//                    {
//                        particleData.LightList.Add(lights[j].gameObject);
//                    }
//                    //查找粒子中开启的灯光
//                    ParticleSystem[] particleSystems = obj.GetComponentsInChildren<ParticleSystem>(true);
//                    for (int j = 0, listCount2 = particleSystems.Length; j < listCount2; ++j)
//                    {
//                        ParticleSystem particleSystem = particleSystems[j];
//                        if (particleSystem.lights.enabled)
//                        {
//                            particleData.ParticleSystemLightList.Add(particleSystems[j].gameObject);
//                        }
//                        particleData.ParticleSystemList.Add(particleSystem);
//                    }
//                    //查找独立网格
//                    MeshRenderer[] meshRenderers = obj.GetComponentsInChildren<MeshRenderer>(true);
//                    for (int j = 0, listCount2 = meshRenderers.Length; j < listCount2; ++j)
//                    {
//                        particleData.MeshRendererList.Add(meshRenderers[j]);
//                    }
//                    //查找蒙皮网格
//                    SkinnedMeshRenderer[] skinnedMeshRenderers = obj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
//                    for (int j = 0, listCount2 = skinnedMeshRenderers.Length; j < listCount2; ++j)
//                    {
//                        particleData.SkinnedMeshRendererList.Add(skinnedMeshRenderers[j]);
//                    }
//                    //查找动画组件 Animation
//                    Animation[] animations = obj.GetComponentsInChildren<Animation>(true);
//                    for (int j = 0, listCount2 = animations.Length; j < listCount2; ++j)
//                    {
//                        particleData.AnimationList.Add(animations[j]);
//                    }
//                    //查找动画组件 Animator
//                    Animator[] animators = obj.GetComponentsInChildren<Animator>(true);
//                    for (int j = 0, listCount2 = animators.Length; j < listCount2; ++j)
//                    {
//                        particleData.AnimatorList.Add(animators[j]);
//                    }

//                    //执行检测
//                    particleData.Calculate(onlySubstandard);
//                    List<ParticleData> list;
//                    if (!ParticleDatas.TryGetValue(particleData.UpToStandard, out list))
//                    {
//                        list = new List<ParticleData>();
//                        ParticleDatas.Add(particleData.UpToStandard, list);
//                    }
//                    list.Add(particleData);
//                }
//            }
//        }

//        /// <summary>
//        /// 粒子数据
//        /// </summary>
//        public class ParticleData
//        {
//            public ParticleData(GameObject _target, string _assetPath)
//            {
//                AssetPath = _assetPath;
//                Target = _target;
//            }

//            /// <summary>
//            /// 资源路径
//            /// </summary>
//            public string AssetPath;

//            /// <summary>
//            /// 粒子物体
//            /// </summary>
//            public GameObject Target;

//            /// <summary>
//            /// 包含的灯光
//            /// </summary>
//            public List<GameObject> LightList = new List<GameObject>();

//            /// <summary>
//            /// 包含的粒子开启灯光
//            /// </summary>
//            public List<GameObject> ParticleSystemLightList = new List<GameObject>();

//            /// <summary>
//            /// 包含的独立网格
//            /// </summary>
//            public List<MeshRenderer> MeshRendererList = new List<MeshRenderer>();

//            /// <summary>
//            /// 包含的蒙皮网格
//            /// </summary>
//            public List<SkinnedMeshRenderer> SkinnedMeshRendererList = new List<SkinnedMeshRenderer>();

//            /// <summary>
//            /// 包含的动画组件
//            /// </summary>
//            public List<Animation> AnimationList = new List<Animation>();

//            /// <summary>
//            /// 包含的动画组件
//            /// </summary>
//            public List<Animator> AnimatorList = new List<Animator>();

//            /// <summary>
//            /// 包含的粒子特效
//            /// </summary>
//            public List<ParticleSystem> ParticleSystemList = new List<ParticleSystem>();

//            /// <summary>
//            /// 缺失Prefab
//            /// </summary>
//            public List<GameObject> MissingPrefabList = new List<GameObject>();

//            /// <summary>
//            /// 描述信息
//            /// </summary>
//            public StringBuilder Describe = new StringBuilder();

//            /// <summary>
//            /// 是否达到标准
//            /// </summary>
//            public bool UpToStandard = true;

//            /// <summary>
//            /// 开始计算
//            /// </summary>
//            /// <param name="onlySubstandard">只打印不符合标准的</param>
//            public void Calculate(bool onlySubstandard)
//            {
//                UpToStandard = true;
//                Describe.Clear();
//                Describe.Append(string.Format("目标:{0} 路径:{1}\n", Target.name, AssetPath));
//                //缺失Prefab
//                if (MissingPrefabList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Describe.Append("\n");
//                    Describe.Append(string.Format(" <不合格>发现缺失Prefab(MissingPrefab):\n"));
//                    for (int i = 0, listCount = MissingPrefabList.Count; i < listCount; ++i)
//                    {
//                        Describe.Append(string.Format("         节点:{0}\n", MissingPrefabList[i].name));
//                    }
//                }
//                //灯光信息
//                if (LightList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Describe.Append("\n");
//                    Describe.Append(string.Format(" <不合格>发现不该存在的灯光节点:\n"));
//                    for (int i = 0, listCount = LightList.Count; i < listCount; ++i)
//                    {
//                        Describe.Append(string.Format("     节点:{0}\n", LightList[i]));
//                    }
//                }
//                if (ParticleSystemLightList.Count > 0)
//                {
//                    UpToStandard = false;
//                    Describe.Append("\n");
//                    Describe.Append(string.Format(" <不合格>发现不该存在的粒子灯光节点:\n"));
//                    for (int i = 0, listCount = ParticleSystemLightList.Count; i < listCount; ++i)
//                    {
//                        Describe.Append(string.Format("     节点:{0}\n", ParticleSystemLightList[i]));
//                    }
//                }
//                //动画组件检查
//                int animComCount = AnimationList.Count + AnimatorList.Count;
//                if (animComCount > 1)
//                {
//                    Describe.Append("\n");
//                    Describe.Append(" --包含的动画组件--\n");
//                    Describe.Append(string.Format("     <超标> 需要小于1，实际数量:{0}\n", animComCount));
//                    for (int i = 0, listCount = AnimationList.Count; i < listCount; ++i)
//                    {
//                        Animation animation = AnimationList[i];
//                        Describe.Append(string.Format("         节点:{0} 类型:{1}\n", animation.name, "Animation"));
//                    }
//                    for (int i = 0, listCount = AnimatorList.Count; i < listCount; ++i)
//                    {
//                        Animator animator = AnimatorList[i];
//                        Describe.Append(string.Format("         节点:{0} 类型:{1}\n", animator.name, "Animator"));
//                    }
//                }
//                else if (animComCount == 1)
//                {
//                    if (onlySubstandard)
//                    {
//                        Describe.Append("\n");
//                        Describe.Append(" --包含的动画组件--\n");
//                        Describe.Append(string.Format("     动画组件实际数量:{0}\n", animComCount));
//                        for (int i = 0, listCount = AnimationList.Count; i < listCount; ++i)
//                        {
//                            Animation animation = AnimationList[i];
//                            Describe.Append(string.Format("         节点:{0} 类型:{1}\n", animation.name, "Animation"));
//                        }
//                        for (int i = 0, listCount = AnimatorList.Count; i < listCount; ++i)
//                        {
//                            Animator animator = AnimatorList[i];
//                            Describe.Append(string.Format("         节点:{0} 类型:{1}\n", animator.name, "Animator"));
//                        }
//                    }
//                }

//                //网格检查
//                if (MeshRendererList.Count > 0)
//                {
//                    Describe.Append("\n");
//                    Describe.Append(" --独立网格数据--\n");
//                    //总面数
//                    int allFaceNum = 0;
//                    for (int i = 0, listCount = MeshRendererList.Count; i < listCount; ++i)
//                    {
//                        MeshRenderer meshRenderer = MeshRendererList[i];
//                        MeshFilter meshFilter = meshRenderer.gameObject.GetComponent<MeshFilter>();
//                        if (meshFilter == null)
//                        {
//                            UpToStandard = false;
//                            Describe.Append(string.Format("     <不合格> 缺少组件(MeshFilter):{0}\n", meshRenderer.name));
//                        }
//                        else
//                        {
//                            if (meshFilter.sharedMesh == null)
//                            {
//                                UpToStandard = false;
//                                Describe.Append(string.Format("     <不合格> 缺少组件(Mesh):{0}\n", meshRenderer.name));
//                            }
//                            else
//                            {
//                                int faceNum = meshFilter.sharedMesh.triangles.Length / 3;
//                                allFaceNum = allFaceNum + faceNum;
//                                if (faceNum > 500)
//                                {
//                                    Describe.Append(string.Format("     <警告> 面数>500 节点名:{0} 面数:{1}\n", meshRenderer.name, faceNum));
//                                }
//                                else
//                                {
//                                    if (onlySubstandard)
//                                    {
//                                        Describe.Append(string.Format("     节点名:{0} 面数:{1}\n", meshRenderer.name, faceNum));
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    if (allFaceNum >= 900)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("     <不合格> 独立网格总面数过高>900 面数:{0}\n", allFaceNum));
//                    }
//                }
//                if (SkinnedMeshRendererList.Count > 0)
//                {
//                    Describe.Append("\n");
//                    Describe.Append(" --独立蒙皮网格数据--\n");
//                    //总面数
//                    int allFaceNum = 0;
//                    for (int i = 0, listCount = SkinnedMeshRendererList.Count; i < listCount; ++i)
//                    {
//                        SkinnedMeshRenderer skinnedMeshRenderer = SkinnedMeshRendererList[i];
//                        if (skinnedMeshRenderer.sharedMesh == null)
//                        {
//                            UpToStandard = false;
//                            Describe.Append(string.Format("     <不合格> 缺少组件(Mesh):{0}\n", skinnedMeshRenderer.name));
//                        }
//                        else
//                        {
//                            if (skinnedMeshRenderer.rootBone == null)
//                            {
//                                UpToStandard = false;
//                                Describe.Append(string.Format("     <不合格> 未绑定骨骼:{0}\n", skinnedMeshRenderer.name));
//                            }
//                            else
//                            {
//                                int faceNum = skinnedMeshRenderer.sharedMesh.triangles.Length / 3;
//                                int boneNum = GetAllChildCount(skinnedMeshRenderer.rootBone);
//                                allFaceNum = allFaceNum + faceNum;
//                                string strFaceNum = null;
//                                bool find = false;
//                                if (faceNum > 500)
//                                {
//                                    find = true;
//                                    UpToStandard = false;
//                                    strFaceNum = string.Format("面数偏高({0})", faceNum);
//                                }
//                                else
//                                {
//                                    strFaceNum = faceNum.ToString();
//                                }
//                                string strBones = null;
//                                if (skinnedMeshRenderer.bones.Length > 4)
//                                {
//                                    find = true;
//                                    UpToStandard = false;
//                                    strBones = string.Format("绑定骨骼数量大于4({0})", skinnedMeshRenderer.bones.Length);
//                                }
//                                else
//                                {
//                                    strBones = skinnedMeshRenderer.bones.Length.ToString();
//                                }
//                                string strAllBones = null;
//                                if (boneNum > 24)
//                                {
//                                    find = true;
//                                    UpToStandard = false;
//                                    strAllBones = string.Format("总骨骼数量大于24({0})", boneNum);
//                                }
//                                else
//                                {
//                                    strAllBones = boneNum.ToString();
//                                }
//                                if (find)
//                                {
//                                    Describe.Append(string.Format("     <警告> 节点:{0} 面数:{1} 总骨骼数量:{2} 绑定骨骼数量{3}\n", skinnedMeshRenderer.name, strFaceNum, strAllBones, strBones));
//                                }
//                                else
//                                {
//                                    if (onlySubstandard)
//                                    {
//                                        Describe.Append(string.Format("     节点:{0} 面数:{1} 总骨骼数量:{2} 绑定骨骼数量{3}\n", skinnedMeshRenderer.name, strFaceNum, strAllBones, strBones));
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    if (allFaceNum >= 900)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("     <不合格> 独立网格总面数过高>900 面数:{0}\n", allFaceNum));
//                    }
//                }

//                //检查粒子
//                if (ParticleSystemList.Count > 0)
//                {
//                    Describe.Append("\n");
//                    Describe.Append("   --粒子其他检测数据--\n");
//                    if (ParticleSystemList.Count > 10)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <**--超出高标准--**>粒子系统Particle System数量(低>4,中>6,高>10):{0}\n", ParticleSystemList.Count));
//                    }
//                    else if (ParticleSystemList.Count > 6)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出中标准>粒子系统Particle System数量(低>4,中>6,高>10):{0}\n", ParticleSystemList.Count));
//                    }
//                    else if (ParticleSystemList.Count > 4)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出低标准>粒子系统Particle System数量(低>4,中>6,高>10):{0}\n", ParticleSystemList.Count));
//                    }
//                    else
//                    {
//                        if (onlySubstandard)
//                        {
//                            Describe.Append(string.Format("       粒子系统Particle System数量:{0}\n", ParticleSystemList.Count));
//                        }
//                    }
//                    //材质球数量
//                    List<Material> mats = new List<Material>();
//                    int maxParticles = 0;
//                    for (int i = 0, listCount = ParticleSystemList.Count; i < listCount; ++i)
//                    {
//                        ParticleSystem particleSystem = ParticleSystemList[i];
//                        //Describe.Append(string.Format("         节点:{0}\n", particleSystem.name));
//                        Renderer renderer = particleSystem.GetComponent<Renderer>();
//                        if (renderer != null && renderer.sharedMaterials != null && renderer.sharedMaterials.Length > 0)
//                        {
//                            for (int j = 0, listCount2 = renderer.sharedMaterials.Length; j < listCount2; ++j)
//                            {
//                                if (!mats.Contains(renderer.sharedMaterials[j]))
//                                {
//                                    mats.Add(renderer.sharedMaterials[j]);
//                                }
//                            }
//                        }
//                        //检查粒子发射数量
//                        maxParticles = maxParticles + GetParticleSystemMax(particleSystem);
//                        //Describe.Append(string.Format("              粒子发射数量:{0}\n", GetParticleSystemMax(particleSystem)));
//                    }
//                    if (maxParticles > 15)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <**--超出高标准--**>粒子发射总数量(低>8,中>11,高>15):{0}\n", maxParticles));

//                    }
//                    else if (maxParticles > 11)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出中标准>粒子发射总数量(低>8,中>11,高>15):{0}\n", maxParticles));
//                    }
//                    else if (maxParticles > 8)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出低标准>粒子发射总数量(低>8,中>11,高>15):{0}\n", maxParticles));
//                    }
//                    else
//                    {
//                        if (onlySubstandard)
//                        {
//                            Describe.Append(string.Format("       粒子发射总数量:{0}\n", maxParticles));
//                        }
//                    }
//                    //材质球数量
//                    if (mats.Count > 6)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <**--超出高标准--**>粒子Drawcall(不同的材质球数量)偏高(低>3,中>4,高>6):{0}\n", mats.Count));
//                    }
//                    else if (mats.Count > 4)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出中标准>粒子Drawcall(不同的材质球数量)偏高(低>3,中>4,高>6):{0}\n", mats.Count));
//                    }
//                    else if (mats.Count > 3)
//                    {
//                        UpToStandard = false;
//                        Describe.Append(string.Format("       <超出低标准>粒子Drawcall(不同的材质球数量)偏高(低>3,中>4,高>6):{0}\n", mats.Count));
//                    }
//                    else
//                    {
//                        if (onlySubstandard)
//                        {
//                            Describe.Append(string.Format("       粒子Drawcall(不同的材质球数量):{0}\n", mats.Count));
//                        }
//                    }

//                    //检查材质球贴图尺寸
//                    for (int i = 0, listCount = mats.Count; i < listCount; ++i)
//                    {
//                        Material mat = mats[i];
//                        string assetPath = AssetDatabase.GetAssetPath(mat);
//                        if (assetPath != null)
//                        {
//                            UnityEngine.Object assetObj = AssetDatabase.LoadMainAssetAtPath(assetPath);
//                            if (assetObj != null)
//                            {
//                                UnityEngine.Object[] decyAssets = EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObj });
//                                for (int j = 0, listCount2 = decyAssets.Length; j < listCount2; ++j)
//                                {
//                                    UnityEngine.Object findObj = decyAssets[j];
//                                    if (findObj.GetType() == typeof(Texture2D))
//                                    {
//                                        Texture2D tex = (Texture2D)findObj;
//                                        if (tex.width > 512 || tex.height > 512)
//                                        {
//                                            UpToStandard = false;
//                                            Describe.Append(string.Format("       <不合格>材质贴图尺寸超标(小于等于512),实际:{0}X{1}\n", tex.width, tex.height));
//                                            Describe.Append(string.Format("             贴图:{0} 路径:{1}\n", tex.name, AssetDatabase.GetAssetPath(tex)));
//                                        }
//                                        if (tex.width % 4 != 0 || tex.height % 4 != 0)
//                                        {
//                                            UpToStandard = false;
//                                            Describe.Append(string.Format("       <不合格>材质贴图尺寸不等于4的倍数,实际:{0}X{1}\n", tex.width, tex.height));
//                                            Describe.Append(string.Format("             贴图:{0} 路径:{1}\n", tex.name, AssetDatabase.GetAssetPath(tex)));
//                                        }
//                                        if (tex.isReadable)
//                                        {
//                                            UpToStandard = false;
//                                            Describe.Append(string.Format("       <不合格>材质贴图开启了可读写\n"));
//                                            Describe.Append(string.Format("             贴图:{0} 路径:{1}\n", tex.name, AssetDatabase.GetAssetPath(tex)));
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

//                //依赖检测 检查是否有依赖的prefab
//                UnityEngine.Object assetObjTarget = AssetDatabase.LoadMainAssetAtPath(AssetPath);
//                UnityEngine.Object[] decyAssetsTarget = EditorUtility.CollectDependencies(new UnityEngine.Object[] { assetObjTarget });
//                for (int i = 0, listCount = decyAssetsTarget.Length; i < listCount; ++i)
//                {
//                    UnityEngine.Object obj = decyAssetsTarget[i];
//                    if (obj != null && obj.GetType() == typeof(GameObject))
//                    {
//                        string prefabPath = AssetDatabase.GetAssetPath(obj);
//                        if (!string.IsNullOrEmpty(prefabPath) && prefabPath.CompareTo(AssetPath) != 0)
//                        {
//                            UpToStandard = false;
//                            Describe.Append(string.Format("     <不合格> 需要引用到其他的Prefab吗:{0}\n", prefabPath));
//                        }
//                    }
//                }
//            }
//        }

//        /// <summary>
//        /// 获得粒子的发射数量
//        /// </summary>
//        /// <param name="particleSystem"></param>
//        /// <returns></returns>
//        static int GetParticleSystemMax(ParticleSystem particleSystem)
//        {
//            int res = 0;
//            int count = particleSystem.emission.burstCount;
//            for (int i = 0; i < count; ++i)
//            {
//                ParticleSystem.Burst burst = particleSystem.emission.GetBurst(i);
//                res = res + burst.maxCount;
//            }
//            return res;
//        }

//        /// <summary>
//        /// 获得所有的节点数量
//        /// </summary>
//        /// <param name="root"></param>
//        /// <returns></returns>
//        static int GetAllChildCount(Transform root)
//        {
//            int res = 0;
//            GetAllChildCount(root, ref res);
//            return res;
//        }

//        /// <summary>
//        /// 获得所有的节点数量
//        /// </summary>
//        /// <param name="root"></param>
//        /// <param name="childNum"></param>
//        /// <returns></returns>
//        static void GetAllChildCount(Transform root, ref int childNum)
//        {
//            childNum = childNum + 1;
//            int childCount = root.childCount;
//            for (int i = 0; i < childCount; ++i)
//            {
//                Transform childRoot = root.GetChild(i);
//                GetAllChildCount(childRoot, ref childNum);
//            }
//        }

//        #endregion

//    }
//}

