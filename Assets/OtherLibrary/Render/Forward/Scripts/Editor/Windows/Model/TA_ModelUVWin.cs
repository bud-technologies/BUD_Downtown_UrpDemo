
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
//    /// ������ʾģ�͵�UV
//    /// </summary>
//    public class TA_ModelUVWin : EditorWindowsBase
//    {
//        static GameObject staticTarget;

//        [MenuItem("GameObject/�������Թ���/ģ��/ģ��UV�鿴", false, -1)]
//        [MenuItem("Assets/�������Թ���/ģ��/ģ��UV�鿴")]
//        static void ModelUVWinOpen()
//        {
//            GameObject obj = Selection.activeGameObject;
//            if (obj == null) return;
//            staticTarget = obj;
//            EditorWindowsBase.CloseAllEditorWindows();
//            EditorWindowsBase window = (EditorWindowsBase)(System.Activator.CreateInstance(typeof(TA_ModelUVWin)));
//            window.ShowWindow();
//        }

//        public static void TargetModelUVWinOpen(GameObject obj)
//        {
//            if (obj == null) return;
//            staticTarget = obj;
//            EditorWindowsBase.CloseAllEditorWindows();
//            EditorWindowsBase window = (EditorWindowsBase)(System.Activator.CreateInstance(typeof(TA_ModelUVWin)));
//            window.ShowWindow();
//        }

//        protected override void OnShowWindow()
//        {

//        }

//        protected override void OnGUIWindow()
//        {
//            SetTittle("ģ��UV���");
//            GUIStyle fontStyle = new GUIStyle();
//            fontStyle.font = (Font)EditorGUIUtility.Load("EditorFont.TTF");
//            fontStyle.fontSize = 24;
//            fontStyle.alignment = TextAnchor.LowerLeft;
//            fontStyle.normal.textColor = Color.red;
//            fontStyle.hover.textColor = Color.yellow;
//            if (staticTarget != null)
//            {
//                targetObj = staticTarget;
//            }
//            using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//            {
//                targetObj = EditorGUILayout.ObjectField("Ŀ��ģ��:", targetObj, typeof(GameObject), true) as GameObject;
//                uvColor = EditorGUILayout.ColorField("UV��ɫ:", uvColor);
//                uvErrColor = EditorGUILayout.ColorField("UV��ɫ(�����߽�):", uvErrColor);
//                if (GUILayout.Button("UVˢ��") || staticTarget != null)
//                {
//                    meshUvBaseMaps.Clear();
//                    FreshUV();
//                }
//            }
//            if (meshUvs.Count > 0)
//            {
//                bool fresh = false;
//                Dictionary<Renderer, Dictionary<int, UVData>>.Enumerator enumerator = meshUvs.GetEnumerator();
//                while (enumerator.MoveNext())
//                {
//                    Renderer renderer = enumerator.Current.Key;
//                    GUILayout.Label(string.Format("����ڵ�:{0}", renderer.name));
//                    Dictionary<int, UVData> dic = enumerator.Current.Value;
//                    Dictionary<int, UVData>.Enumerator enumerator2 = dic.GetEnumerator();
//                    while (enumerator2.MoveNext())
//                    {
//                        using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//                        {
//                            GUILayout.Label(string.Format("     UV:{0}", enumerator2.Current.Key));
//                            meshUvBaseMaps[renderer][enumerator2.Current.Key] = EditorGUILayout.ObjectField("��ͼ����:", meshUvBaseMaps[renderer][enumerator2.Current.Key], typeof(Texture2D), true) as Texture2D;
//                            if (meshUvBaseMaps[renderer][enumerator2.Current.Key] == null)
//                            {
//                                meshUvBaseMaps[renderer][enumerator2.Current.Key] = BaseMap;
//                            }
//                            if (GUILayout.Button("���"))
//                            {
//                                if (meshUvBaseMaps[renderer][enumerator2.Current.Key] != BaseMap)
//                                {
//                                    meshUvBaseMaps[renderer][enumerator2.Current.Key] = BaseMap;
//                                    fresh = true;
//                                }
//                            }
//                            if (GUILayout.Button("���ģ������"))
//                            {
//                                Material[] mats = renderer.sharedMaterials;
//                                Texture2D findTexture = null;
//                                for (int i = 0, listCount = mats.Length; i < listCount; ++i)
//                                {
//                                    Material mat = mats[i];
//                                    if (mat != null)
//                                    {
//                                        if (mat.mainTexture != null)
//                                        {
//                                            string assetPath = AssetDatabase.GetAssetPath(mat.mainTexture);
//                                            if (!string.IsNullOrEmpty(assetPath) && assetPath.StartsWith("Assets/"))
//                                            {
//                                                findTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
//                                                break;
//                                            }
//                                        }
//                                    }
//                                }
//                                if (findTexture != null)
//                                {
//                                    meshUvBaseMaps[renderer][enumerator2.Current.Key] = findTexture;
//                                    fresh = true;
//                                }
//                                else
//                                {
//                                    Debug.LogError(string.Format("������δ�ҵ�,�ڵ�:{0}", renderer.name));
//                                }
//                            }
//                            if (GUILayout.Button("ˢ�µ�ͼ����"))
//                            {
//                                fresh = true;
//                            }
//                        }
//                        UVData uvData = enumerator2.Current.Value;
//                        if (uvData.UVMaxOffset != 0)
//                        {
//                            GUILayout.Label(string.Format("UVƫ����:{0}", uvData.UVMaxOffset), fontStyle);
//                        }
//                        else
//                        {
//                            GUILayout.Label(string.Format("UVƫ����:{0}", uvData.UVMaxOffset));
//                        }
//                        Texture2D texture2D = uvData.UVTexture2D;
//                        GUILayout.Box(texture2D);
//                    }
//                }
//                if (fresh)
//                {
//                    FreshUV();
//                }
//            }
//            staticTarget = null;
//        }

//        Texture2D _baseMap;

//        /// <summary>
//        /// Ĭ�ϵ�ͼ
//        /// </summary>
//        Texture2D BaseMap
//        {
//            get
//            {
//                if (_baseMap == null)
//                {
//                    _baseMap = new Texture2D(Texture2DSize, Texture2DSize);
//                    Color color = Color.black;
//                    Color[] colors = new Color[Texture2DSize * Texture2DSize];
//                    for (int i = 0, listCount = colors.Length; i < listCount; ++i)
//                    {
//                        colors[i] = color;
//                    }
//                    _baseMap.SetPixels(0, 0, Texture2DSize, Texture2DSize, colors);
//                    _baseMap.Apply();
//                    _baseMap.name = "black";
//                }
//                return _baseMap;
//            }
//        }

//        /// <summary>
//        /// UV������ɫ
//        /// </summary>
//        Color uvColor = new Color(0, 1, 0, 0.3f);

//        /// <summary>
//        /// UV������ɫ ���߽�
//        /// </summary>
//        Color uvErrColor = new Color(1, 0, 0, 1f);

//        /// <summary>
//        /// ����ߴ�
//        /// </summary>
//        int Texture2DSize = 512;

//        /// <summary>
//        /// Ŀ��ģ��
//        /// </summary>
//        GameObject targetObj;

//        /// <summary>
//        /// Ŀ��ģ�͵�����UV key:��Ⱦ�� key:��N��UV Value:UV
//        /// </summary>
//        Dictionary<Renderer, Dictionary<int, UVData>> meshUvs = new Dictionary<Renderer, Dictionary<int, UVData>>();

//        /// <summary>
//        /// ��ʹ�õĵ�ͼ
//        /// </summary>
//        Dictionary<Renderer, Dictionary<int, Texture2D>> meshUvBaseMaps = new Dictionary<Renderer, Dictionary<int, Texture2D>>();

//        /// <summary>
//        /// �����UV����
//        /// </summary>
//        class UVData
//        {
//            public UVData(int uvIndex)
//            {
//                UVIndex = uvIndex;
//            }

//            /// <summary>
//            /// �ڼ���UV
//            /// </summary>
//            public int UVIndex = 0;

//            /// <summary>
//            /// UV������
//            /// </summary>
//            public Texture2D UVTexture2D;

//            /// <summary>
//            /// ���ƫ����
//            /// </summary>
//            public float UVMaxOffset;

//        }

//        /// <summary>
//        /// ���һ����ͼ
//        /// </summary>
//        /// <param name="renderer"></param>
//        /// <param name="uvIndex"></param>
//        /// <returns></returns>
//        Texture2D GetBaseMap(Renderer renderer, int uvIndex)
//        {
//            Dictionary<int, Texture2D> dic;
//            if (!meshUvBaseMaps.TryGetValue(renderer, out dic))
//            {
//                dic = new Dictionary<int, Texture2D>();
//                meshUvBaseMaps.Add(renderer, dic);
//            }
//            Texture2D res;
//            if (!dic.TryGetValue(uvIndex, out res))
//            {
//                res = BaseMap;
//                dic.Add(uvIndex, res);
//            }
//            return res;
//        }

//        /// <summary>
//        /// ˢ��ģ�͵���������
//        /// </summary>
//        void FreshUV()
//        {
//            meshUvs.Clear();
//            if (targetObj == null) return;
//            SkinnedMeshRenderer[] skinnedMeshRenderers = targetObj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
//            for (int i = 0, listCount = skinnedMeshRenderers.Length; i < listCount; ++i)
//            {
//                SkinnedMeshRenderer renderer = skinnedMeshRenderers[i];
//                if (renderer.sharedMesh != null)
//                {
//                    Dictionary<int, UVData> dic = GetMeshUvs(renderer, renderer.sharedMesh);
//                    if (dic.Count > 0)
//                    {
//                        meshUvs.Add(renderer, dic);
//                    }
//                }
//            }
//            MeshRenderer[] meshRenderers = targetObj.GetComponentsInChildren<MeshRenderer>(true);
//            for (int i = 0, listCount = meshRenderers.Length; i < listCount; ++i)
//            {
//                MeshRenderer meshRenderer = meshRenderers[i];
//                MeshFilter meshFilter = meshRenderer.gameObject.GetComponent<MeshFilter>();
//                if (meshFilter != null && meshFilter.sharedMesh != null)
//                {
//                    Dictionary<int, UVData> dic = GetMeshUvs(meshRenderer, meshFilter.sharedMesh);
//                    if (dic.Count > 0)
//                    {
//                        meshUvs.Add(meshRenderer, dic);
//                    }
//                }
//            }
//            ParticleSystem[] particleSystems = targetObj.GetComponentsInChildren<ParticleSystem>(true);
//            for (int i = 0, listCount = particleSystems.Length; i < listCount; ++i)
//            {
//                ParticleSystem particleSystem = particleSystems[i];
//                Renderer renderer = particleSystem.GetComponent<Renderer>();
//                ParticleSystemRenderer rendererModule = particleSystem.gameObject.GetComponent<ParticleSystemRenderer>();
//                Mesh mesh = rendererModule.mesh;
//                if (mesh != null)
//                {
//                    string assetPath = AssetDatabase.GetAssetPath(mesh);
//                    if (!string.IsNullOrEmpty(assetPath) && assetPath.StartsWith("Assets/"))
//                    {
//                        Dictionary<int, UVData> dic = GetMeshUvs(renderer, mesh);
//                        if (dic.Count > 0)
//                        {
//                            meshUvs.Add(renderer, dic);
//                        }
//                    }
//                }
//            }
//        }

//        /// <summary>
//        /// �����������ݻ��UV����
//        /// </summary>
//        /// <param name="mesh"></param>
//        /// <returns></returns>
//        Dictionary<int, UVData> GetMeshUvs(Renderer renderer, Mesh mesh)
//        {
//            Dictionary<int, UVData> res = new Dictionary<int, UVData>();
//            Vector3[] vertices = mesh.vertices;
//            int[] triangles = mesh.triangles;
//            //1
//            Vector2[] uv = mesh.uv;
//            UVData uvData = new UVData(1);
//            GetUVTextureByUv(uvData, vertices, triangles, uv, GetBaseMap(renderer, 1));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(1, uvData);
//            }
//            //2
//            Vector2[] uv2 = mesh.uv2;
//            uvData = new UVData(2);
//            GetUVTextureByUv(uvData, vertices, triangles, uv2, GetBaseMap(renderer, 2));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(2, uvData);
//            }
//            //3
//            Vector2[] uv3 = mesh.uv3;
//            uvData = new UVData(3);
//            GetUVTextureByUv(uvData, vertices, triangles, uv3, GetBaseMap(renderer, 3));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(3, uvData);
//            }
//            //4
//            Vector2[] uv4 = mesh.uv4;
//            uvData = new UVData(4);
//            GetUVTextureByUv(uvData, vertices, triangles, uv4, GetBaseMap(renderer, 4));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(4, uvData);
//            }
//            //5
//            Vector2[] uv5 = mesh.uv5;
//            uvData = new UVData(5);
//            GetUVTextureByUv(uvData, vertices, triangles, uv5, GetBaseMap(renderer, 5));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(5, uvData);
//            }
//            //6
//            Vector2[] uv6 = mesh.uv6;
//            uvData = new UVData(6);
//            GetUVTextureByUv(uvData, vertices, triangles, uv6, GetBaseMap(renderer, 6));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(6, uvData);
//            }
//            //7
//            Vector2[] uv7 = mesh.uv7;
//            uvData = new UVData(7);
//            GetUVTextureByUv(uvData, vertices, triangles, uv7, GetBaseMap(renderer, 7));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(7, uvData);
//            }
//            //8
//            Vector2[] uv8 = mesh.uv8;
//            uvData = new UVData(8);
//            GetUVTextureByUv(uvData, vertices, triangles, uv8, GetBaseMap(renderer, 8));
//            if (uvData.UVTexture2D != null)
//            {
//                res.Add(8, uvData);
//            }
//            return res;
//        }

//        /// <summary>
//        /// UV����
//        /// </summary>
//        /// <param name="vertices"></param>
//        /// <param name="triangles"></param>
//        /// <param name="uv"></param>
//        /// <param name="baseMap">��ͼ</param>
//        /// <returns></returns>
//        void GetUVTextureByUv(UVData uvData, Vector3[] vertices, int[] triangles, Vector2[] uv, Texture2D baseMap)
//        {
//            if (uv != null && uv.Length > 0)
//            {
//                if (baseMap == null)
//                {
//                    baseMap = BaseMap;
//                }
//                Texture2D res = new Texture2D(Texture2DSize, Texture2DSize);
//                float minU = float.MaxValue;
//                float maxU = float.MinValue;
//                float minV = float.MaxValue;
//                float maxV = float.MinValue;
//                //key:��������ţ��ڼ��������� value:������������
//                Dictionary<int, TrianglesData> trianglesLines = new Dictionary<int, TrianglesData>();
//                for (int i = 0, listCount = uv.Length; i < listCount; ++i)
//                {
//                    Vector2 uvValue = uv[i];
//                    if (minU > uvValue.x)
//                    {
//                        minU = uvValue.x;
//                    }
//                    if (maxU < uvValue.x)
//                    {
//                        maxU = uvValue.x;
//                    }
//                    if (minV > uvValue.y)
//                    {
//                        minV = uvValue.y;
//                    }
//                    if (maxV < uvValue.y)
//                    {
//                        maxV = uvValue.y;
//                    }
//                }
//                //X����
//                float offsetX = 0;
//                if (minU <= 0)
//                {
//                    offsetX = -minU;
//                    if (maxU >= 1)
//                    {
//                        if ((maxU - 1) > offsetX)
//                        {
//                            offsetX = maxU - 1;
//                        }
//                    }
//                }
//                else
//                {
//                    if (maxU > 1)
//                    {
//                        offsetX = maxU - 1;
//                    }
//                }
//                //Y����
//                float offsetY = 0;
//                if (minV <= 0)
//                {
//                    offsetY = -minV;
//                    if (maxV > 1)
//                    {
//                        if ((maxV - 1) > offsetY)
//                        {
//                            offsetY = maxV - 1;
//                        }
//                    }
//                }
//                else
//                {
//                    if (maxV > 1)
//                    {
//                        offsetY = maxV - 1;
//                    }
//                }
//                if (offsetX > offsetY)
//                {
//                    offsetY = offsetX;
//                }
//                else if (offsetY > offsetX)
//                {
//                    offsetX = offsetY;
//                }

//                int trianglesIndex = 0;
//                for (int i = 0, listCount = triangles.Length; i < listCount; ++i)
//                {
//                    Vector2 uv1 = uv[triangles[i]];
//                    i++;
//                    Vector2 uv2 = uv[triangles[i]];
//                    i++;
//                    Vector2 uv3 = uv[triangles[i]];
//                    TrianglesData trianglesData = new TrianglesData();
//                    trianglesData.lines.Add(new LineData(uv1, uv2));
//                    trianglesData.lines.Add(new LineData(uv2, uv3));
//                    trianglesData.lines.Add(new LineData(uv3, uv1));
//                    trianglesLines.Add(trianglesIndex, trianglesData);
//                    trianglesIndex++;
//                }

//                //ͼƬ���� �����߶�
//                //�Ȼ���0-1����
//                {
//                    int minX = 0;
//                    int minY = 0;
//                    int maxX = Texture2DSize - 1;
//                    int maxY = Texture2DSize - 1;
//                    if (offsetX > 0)
//                    {
//                        minX = (int)(Texture2DSize * (offsetX / (2 * offsetX + 1f)));
//                        maxX = (int)(Texture2DSize * ((offsetX + 1) / (2 * offsetX + 1f)));
//                        if (maxX >= Texture2DSize)
//                        {
//                            maxX = Texture2DSize - 1;
//                        }
//                    }
//                    if (offsetY > 0)
//                    {
//                        minY = (int)(Texture2DSize * (offsetY / (2 * offsetY + 1f)));
//                        maxY = (int)(Texture2DSize * ((offsetY + 1) / (2 * offsetY + 1f)));
//                        if (maxY >= Texture2DSize)
//                        {
//                            maxY = Texture2DSize - 1;
//                        }
//                    }
//                    Color color = Color.blue;
//                    bool isReadable = baseMap.isReadable;
//                    if (!baseMap.isReadable)
//                    {
//                        TA_TextureMetaSetTool.SetTexture_Readable(baseMap, true);
//                        AssetDatabase.Refresh();
//                        baseMap = AssetDatabase.LoadAssetAtPath<Texture2D>(AssetDatabase.GetAssetPath(baseMap));
//                    }
//                    for (int i = 0; i < Texture2DSize; ++i)
//                    {
//                        for (int j = 0; j < Texture2DSize; ++j)
//                        {
//                            if (i < minX || i > maxX || j < minY || j > maxY)
//                            {
//                                res.SetPixel(i, j, Color.black);
//                            }
//                            else
//                            {
//                                float scaleX = (float)(i - minX) / (maxX - minX);
//                                float scaleY = (float)(j - minY) / (maxY - minY);
//                                int findX = (int)(baseMap.width * scaleX);
//                                if (findX >= baseMap.width)
//                                {
//                                    findX = baseMap.width - 1;
//                                }
//                                int findY = (int)(baseMap.height * scaleY);
//                                if (findY >= baseMap.height)
//                                {
//                                    findY = baseMap.height - 1;
//                                }
//                                res.SetPixel(i, j, baseMap.GetPixel(findX, findY));
//                            }
//                        }
//                    }
//                    if (!isReadable)
//                    {
//                        TA_TextureMetaSetTool.SetTexture_Readable(baseMap, false);
//                        AssetDatabase.Refresh();
//                    }
//                    Color[] colors = new Color[maxY - minY];
//                    for (int i = 0, listCount = colors.Length; i < listCount; ++i)
//                    {
//                        colors[i] = color;
//                    }
//                    res.SetPixels(minX, minY, 1, maxY - minY, colors);
//                    res.SetPixels(maxX, minY, 1, maxY - minY, colors);
//                    colors = new Color[maxX - minX];
//                    for (int i = 0, listCount = colors.Length; i < listCount; ++i)
//                    {
//                        colors[i] = color;
//                    }
//                    res.SetPixels(minX, minY, maxX - minX, 1, colors);
//                    res.SetPixels(minX, maxY, maxX - minX, 1, colors);
//                }
//                //�ٻ����߶�
//                Dictionary<int, TrianglesData>.Enumerator enumerator = trianglesLines.GetEnumerator();
//                while (enumerator.MoveNext())
//                {
//                    trianglesIndex = enumerator.Current.Key;
//                    TrianglesData trianglesData = enumerator.Current.Value;
//                    for (int i = 0, listCount = trianglesData.lines.Count; i < listCount; ++i)
//                    {
//                        LineData lineData = trianglesData.lines[i];
//                        DrawOnTexture2D(res, lineData, offsetX, offsetY);
//                    }
//                }
//                res.Apply();
//                uvData.UVTexture2D = res;
//                uvData.UVMaxOffset = offsetX;
//            }
//            else
//            {
//                uvData.UVTexture2D = null;
//            }
//        }

//        /// <summary>
//        /// ��UV�����ϻ����߶�
//        /// </summary>
//        /// <param name="texture2D"></param>
//        /// <param name="lineData"></param>
//        /// <param name="offsetX">X����</param>
//        /// <param name="offsetY">Y����</param>
//        void DrawOnTexture2D(Texture2D texture2D, LineData lineData, float offsetX, float offsetY)
//        {
//            //�������ر߽�����
//            int minPixelX = (int)(Texture2DSize * (offsetX / (2 * offsetX + 1)));
//            int maxPixelX = (int)(Texture2DSize * ((offsetX + 1) / (2 * offsetX + 1)));
//            int minPixelY = (int)(Texture2DSize * (offsetY / (2 * offsetY + 1)));
//            int maxPixelY = (int)(Texture2DSize * ((offsetY + 1) / (2 * offsetY + 1)));
//            //
//            float minX = 0 - offsetX;
//            float maxX = 1 + offsetX;
//            float minY = 0 - offsetY;
//            float maxY = 1 + offsetY;
//            //���껻��
//            Vector2 start = lineData.Start;
//            Vector2 end = lineData.End;
//            int[] startInt = new int[2];
//            startInt[0] = (int)(Texture2DSize * (start.x - minX) / (maxX - minX));
//            if (startInt[0] >= Texture2DSize)
//            {
//                startInt[0] = Texture2DSize - 1;
//            }
//            startInt[1] = (int)(Texture2DSize * (start.y - minY) / (maxY - minY));
//            if (startInt[1] >= Texture2DSize)
//            {
//                startInt[1] = Texture2DSize - 1;
//            }
//            int[] endInt = new int[2];
//            endInt[0] = (int)(Texture2DSize * (end.x - minX) / (maxX - minX));
//            if (endInt[0] >= Texture2DSize)
//            {
//                endInt[0] = Texture2DSize - 1;
//            }
//            endInt[1] = (int)(Texture2DSize * (end.y - minY) / (maxY - minY));
//            if (endInt[1] >= Texture2DSize)
//            {
//                endInt[1] = Texture2DSize - 1;
//            }

//            //X������
//            float intervalX = Mathf.Abs(endInt[0] - startInt[0]);
//            //Y������
//            float intervalY = Mathf.Abs(endInt[1] - startInt[1]);
//            if (intervalX == 0 && intervalY == 0)
//            {
//                //��
//                texture2D.SetPixel(startInt[0], startInt[1], Color.red);
//            }
//            else
//            {
//                //��������
//                int count = 0;
//                //��������ϵ��
//                float coefficient = 1;
//                //������ʼ��
//                Vector2 startV = new Vector2(startInt[0], startInt[1]);
//                //����
//                Vector2 v2 = (new Vector2(endInt[0], endInt[1]) - new Vector2(startInt[0], startInt[1])).normalized;
//                if (intervalY == 0)
//                {
//                    //ƽ��
//                    count = Mathf.Abs(endInt[0] - startInt[0]);
//                    coefficient = 1;
//                }
//                else if (intervalX == 0)
//                {
//                    //��ֱ
//                    count = Mathf.Abs(endInt[1] - startInt[1]);
//                    coefficient = 1;
//                }
//                else
//                {
//                    float slope = (float)(Mathf.Abs(endInt[1] - startInt[1])) / Mathf.Abs(endInt[0] - startInt[0]);
//                    if (slope >= 1)
//                    {
//                        slope = 1f / slope;
//                        slope = Mathf.Sqrt(slope * slope + 1);
//                        count = Mathf.Abs(endInt[1] - startInt[1]);
//                        coefficient = slope;
//                    }
//                    else
//                    {
//                        slope = Mathf.Sqrt(slope * slope + 1);
//                        count = Mathf.Abs(endInt[0] - startInt[0]);
//                        coefficient = slope;
//                    }
//                }
//                for (int i = 0; i < count; ++i)
//                {
//                    Vector2 resoult = startV + coefficient * (i + 1) * v2;
//                    int resoultX = (int)resoult.x;
//                    int resoultY = (int)resoult.y;
//                    if (resoultX <= minPixelX || resoultX >= maxPixelX || resoultY <= minPixelY || resoultY >= maxPixelY)
//                    {
//                        texture2D.SetPixel(resoultX, resoultY, ColorOverlay(uvErrColor, texture2D.GetPixel(resoultX, resoultY)));
//                    }
//                    else
//                    {
//                        texture2D.SetPixel(resoultX, resoultY, ColorOverlay(uvColor, texture2D.GetPixel(resoultX, resoultY)));
//                    }
//                }
//            }
//        }

//        /// <summary>
//        /// ��ɫ����
//        /// </summary>
//        /// <param name="srcColor"></param>
//        /// <param name="oldColor"></param>
//        /// <returns></returns>
//        Color ColorOverlay(Color srcColor, Color oldColor)
//        {
//            Vector3 src = new Vector3(srcColor.r, srcColor.g, srcColor.b);
//            Vector3 old = new Vector3(oldColor.r, oldColor.g, oldColor.b);
//            Vector3 res = src * srcColor.a + (1 - srcColor.a) * old;
//            return new Color(res.x, res.y, res.z, 1);
//        }

//        /// <summary>
//        /// ����������
//        /// </summary>
//        public class TrianglesData
//        {
//            /// <summary>
//            /// ������
//            /// </summary>
//            public List<LineData> lines = new List<LineData>();
//        }

//        /// <summary>
//        /// �߶�
//        /// </summary>
//        public class LineData
//        {
//            public LineData(Vector2 start, Vector2 end)
//            {
//                Start = start;
//                End = end;
//            }

//            /// <summary>
//            /// ��ʼ��
//            /// </summary>
//            public Vector2 Start;

//            /// <summary>
//            /// ������
//            /// </summary>
//            public Vector2 End;
//        }

//    }
//}

