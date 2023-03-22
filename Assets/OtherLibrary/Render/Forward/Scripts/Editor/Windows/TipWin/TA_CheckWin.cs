//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Threading.Tasks;
//using UnityEngine;

//public class TA_CheckWin : EditorWindow
//{
//    public static TA_CheckWin instance;

//    public static void ShowWin(string str)
//    {
//        instance = EditorWindow.GetWindow<TA_CheckWin>();
//        instance.showTxt = str;
//        instance.Show();
//    }

//    public string showTxt;

//    public Vector2 scroll;


//    public void OnGUI()
//    {
//        if (instance == null)
//        {
//            return;
//        }
//        scroll = GUILayout.BeginScrollView(scroll);

//        EditorGUILayout.TextArea("模型规则异常！");
//        EditorGUILayout.TextArea(showTxt);

//        GUILayout.EndScrollView();
//    }
//}
