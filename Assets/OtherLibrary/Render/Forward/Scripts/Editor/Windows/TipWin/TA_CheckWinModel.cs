//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Threading.Tasks;
//using UnityEngine;

//public class TA_CheckWinModel : TA_CheckWin
//{
//    /// <summary>
//    /// 有UV问题的模型
//    /// </summary>
//    public static List<GameObject> uv01errList;

//    public static new void ShowWin(string str)
//    {
//        instance = EditorWindow.GetWindow<TA_CheckWinModel>();
//        instance.showTxt = str;
//        instance.Show();
//    }

//    public new void OnGUI()
//    {
//        if (instance==null)
//        {
//            return;
//        }
//        instance.scroll = GUILayout.BeginScrollView(instance.scroll);

//        EditorGUILayout.TextArea("模型规则异常！");
//        if (uv01errList != null)
//        {
//            EditorGUILayout.TextArea("模型UV异常查看！");
//            for (int i = 0, listCount = uv01errList.Count; i < listCount; ++i)
//            {
//                GameObject obj = uv01errList[i];
//                if (GUILayout.Button(obj.name))
//                {
//                    TA_ModelUVWin.TargetModelUVWinOpen(obj);
//                }
//            }
//        }
//        EditorGUILayout.TextArea(showTxt);

//        GUILayout.EndScrollView();
//    }
//}
