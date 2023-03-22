//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;
//using UnityEditor;
//using System.Text;

//namespace Render
//{
//    /// <summary>
//    /// 用于检查局内模型问题 显示提示信息
//    /// </summary>
//    public class TA_GameInModelCheck
//    {
//        public static void CheckSelect()
//        {
//            UnityEngine.Object[] objs = Selection.objects;
//            System.Text.StringBuilder sb = new StringBuilder();
//            List<GameObject> uv01errList = new List<GameObject>();
//            for (int i = 0, listCount = objs.Length; i < listCount; ++i)
//            {
//                UnityEngine.Object obj = objs[i];
//                if (obj != null && obj.GetType() == typeof(GameObject))
//                {
//                    GameObject gmObj = (GameObject)obj;
//                    string assetPath = AssetDatabase.GetAssetPath(gmObj);
//                    TA_ArtModelWin.ConditionData conditionData = TA_ArtModelWin.GetCharactersConditionByPathNameSuffixs(assetPath);
//                    if (conditionData != null)
//                    {
//                        TA_ArtModelWin.MeshData meshData = TA_ArtModelWin.GetModelData(assetPath, conditionData);
//                        if (meshData != null)
//                        {
//                            List<TA_ArtModelWin.MeshData> meshDataList = new List<TA_ArtModelWin.MeshData>() { meshData };
//                            TA_ArtModelWin.ResoultData resoultData = TA_ArtModelWin.ResoultNeaten(new List<List<TA_ArtModelWin.MeshData>>()
//                        {
//                           meshDataList
//                        });
//                            if (resoultData.Resoult.ContainsKey(false))
//                            {
//                                List<TA_ArtModelWin.MeshData> errList = resoultData.Resoult[false];
//                                TA_ArtModelWin.MeshData errData = errList[0];
//                                if (errData.UVNotAtZeroToOneList.Count > 0)
//                                {
//                                    uv01errList.Add(gmObj);
//                                }
//                                sb.Append(errData.Descriptor.ToString());
//                                sb.Append("\n");
//                            }
//                        }
//                    }
//                }
//            }
//            if (sb.Length > 0)
//            {
//                TA_MaterialCheck.Log(sb.ToString(), Diagnostic.LogColor.Yellow, 2);
//            }
//            if (uv01errList.Count > 0)
//            {
//                TA_CheckWinModel.uv01errList = uv01errList;
//            }
//            else
//            {
//                TA_CheckWinModel.uv01errList = null;
//            }
//        }


//        static int GetTriangles(GameObject obj)
//        {
//            SkinnedMeshRenderer[] smrs = obj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
//            MeshRenderer[] mrs = obj.GetComponentsInChildren<MeshRenderer>(true);
//            int trisCount = 0;
//            for (int j = 0, listCount2 = smrs.Length; j < listCount2; ++j)
//            {
//                SkinnedMeshRenderer smr = smrs[j];
//                trisCount = trisCount + smr.sharedMesh.triangles.Length / 3;
//            }
//            for (int j = 0, listCount2 = mrs.Length; j < listCount2; ++j)
//            {
//                MeshRenderer mr = mrs[j];
//                MeshFilter meshFilter = mr.gameObject.GetComponent<MeshFilter>();
//                trisCount = trisCount + meshFilter.sharedMesh.triangles.Length / 3;
//            }
//            return trisCount;
//        }
//    }
//}

