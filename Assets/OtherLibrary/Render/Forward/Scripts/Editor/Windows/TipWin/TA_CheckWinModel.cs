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
//    /// ��UV�����ģ��
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

//        EditorGUILayout.TextArea("ģ�͹����쳣��");
//        if (uv01errList != null)
//        {
//            EditorGUILayout.TextArea("ģ��UV�쳣�鿴��");
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
