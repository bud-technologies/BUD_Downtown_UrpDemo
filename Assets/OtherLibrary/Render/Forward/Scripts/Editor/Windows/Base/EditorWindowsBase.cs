//using UnityEngine;
//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Threading.Tasks;

//namespace Render
//{
//    /// <summary>
//    /// 用于统一关闭EditorWindow的属性
//    /// </summary>
//    [EditorWindowsTag]
//    public class EditorWindowsBase : EditorWindow
//    {

//        /// <summary>
//        /// 窗口显示
//        /// </summary>
//        public void ShowWindow(bool openSgameWinOnClose = false)
//        {
//            Type type = GetType();
//            MethodInfo mi = type.GetMethod("ShowWindowT").MakeGenericMethod(type);
//            mi.Invoke(this, null);
//            curWindows.OpenSgameWinOnClose = openSgameWinOnClose;
//        }

//        /// <summary>
//        /// 窗口显示
//        /// </summary>
//        public void ShowWindowTile(string titleName, bool openSgameWinOnClose = false)
//        {
//            Type type = GetType();
//            MethodInfo mi = type.GetMethod("ShowWindowTTile").MakeGenericMethod(type);
//            object[] par = new object[] { titleName };
//            mi.Invoke(this, par);
//            curWindows.OpenSgameWinOnClose = openSgameWinOnClose;
//        }

//        public void OnDestroy()
//        {
//            OnCloseWindow();
//            Type type = this.GetType();
//            if (type != typeof(SgameEditorWindows))
//            {
//                EditorWindowsBase item;
//                windows.TryGetValue(type, out item);
//                if (item != null && item.OpenSgameWinOnClose)
//                {
//                    Render.DelayFunHelper delayFunClass = new Render.DelayFunHelper(() =>
//                    {
//                        SgameEditorWindows.SetActive();
//                    }, null, null, 0.05f);
//                    delayFunClass.Run();
//                }

//            }
//            windows.Remove(type);
//        }

//        /// <summary>
//        /// 窗口绘制
//        /// </summary>
//        protected virtual void OnGUIWindow() { }

//        /// <summary>
//        /// 显示窗口的时候触发
//        /// </summary>
//        protected virtual void OnShowWindow() { }

//        /// <summary>
//        /// 关闭窗口的时候触发
//        /// </summary>
//        protected virtual void OnCloseWindow() { }

//        Vector2 scroll;
//        public void OnGUI()
//        {
//            scroll = GUILayout.BeginScrollView(scroll);
//            OnGUIWindow();
//            GUILayout.EndScrollView();
//        }

//        /// <summary>
//        /// 记录的窗口实例
//        /// </summary>
//        protected EditorWindowsBase curWindows;

//        /// <summary>
//        /// 窗口显示
//        /// </summary>
//        /// <typeparam name="T"></typeparam>
//        /// <returns></returns>
//        public void ShowWindowT<T>() where T : EditorWindowsBase
//        {
//            CloseAllEditorWindows();
//            T p = EditorWindow.GetWindow<T>(false, "SgameEditorWindows", true);
//            p.Show();
//            curWindows = p;
//            OnShowWindow();
//            curWindows.Show();
//            windows.Add(typeof(T), curWindows);
//        }

//        /// <summary>
//        /// 窗口显示
//        /// </summary>
//        /// <typeparam name="T"></typeparam>
//        /// <returns></returns>
//        public void ShowWindowTTile<T>(string titleName) where T : EditorWindowsBase
//        {
//            CloseAllEditorWindows();
//            T p = EditorWindow.GetWindow<T>(false, titleName, true);
//            p.Show();
//            curWindows = p;
//            OnShowWindow();
//            curWindows.Show();
//            windows.Add(typeof(T), curWindows);
//        }

//        /// <summary>
//        /// 关闭所有的带有 [EditorWindowsTag] 属性或者继承了 带有 [EditorWindowsTag] 属性的父类的窗口
//        /// </summary>
//        public static void CloseAllEditorWindows()
//        {
//            Type[] types = Assembly.GetExecutingAssembly().GetTypes();
//            for (int i = 0, listCount = types.Length; i < listCount; ++i)
//            {
//                if (types[i].IsClass && typeof(UnityEditor.EditorWindow).IsAssignableFrom(types[i]))
//                {
//                    if (EditorWindowsTag.TypeIsEditorWindowsTag(types[i]))
//                    {
//                        EditorWindow win = EditorWindow.GetWindow(types[i], false);
//                        if (win != null)
//                        {
//                            win.Close();
//                        }
//                    }
//                }
//            }
//        }

//        /// <summary>
//        /// 在窗口关闭的时候是否要打开 SgameEditorWindows
//        /// </summary>
//        public bool OpenSgameWinOnClose = false;

//        /// <summary>
//        /// 用于监控哪个窗口被关闭
//        /// </summary>
//        static Dictionary<Type, EditorWindowsBase> windows = new Dictionary<Type, EditorWindowsBase>();

//        #region//UI相关

//        static GUIStyle fontStyle;

//        /// <summary>
//        /// 通用字体
//        /// </summary>
//        public static GUIStyle FontStyle
//        {
//            get
//            {
//                if (fontStyle == null)
//                {
//                    fontStyle = new GUIStyle();
//                    fontStyle.font = (Font)EditorGUIUtility.Load("EditorFont.TTF");
//                    fontStyle.fontSize = 18;
//                    fontStyle.alignment = TextAnchor.MiddleLeft;
//                    fontStyle.normal.textColor = Color.white;
//                    fontStyle.hover.textColor = Color.green;
//                }
//                return fontStyle;
//            }
//        }

//        /// <summary>
//        /// 显示一个行标
//        /// </summary>
//        public static void SetTittle(string tittle)
//        {
//            using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//            {
//                //设置行标
//                EditorGUILayout.LabelField("", tittle, FontStyle, GUILayout.Height(30));
//            }
//        }

//        /// <summary>
//        /// 水平布局类
//        /// 用法:
//        ///   using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout()){
//        ///     //..................
//        ///   }
//        /// </summary>
//        public class HorizontalLayout : IDisposable
//        {

//            public HorizontalLayout()
//            {
//                GUILayout.BeginHorizontal();
//            }
//            public void Dispose()
//            {
//                GUILayout.EndHorizontal();
//            }
//        }

//        /// <summary>
//        /// 水平布局类
//        /// 用法:
//        ///   using (EditorWindowsBase.VerticalLayout layOut = new VerticalLayout()){
//        ///     //..................
//        ///   }
//        /// </summary>
//        public class VerticalLayout : IDisposable
//        {
//            public VerticalLayout()
//            {
//                GUILayout.BeginVertical();
//            }
//            public void Dispose()
//            {
//                GUILayout.EndVertical();
//            }
//        }

//        #endregion

//    }

//    public class EditorWindowsTag : Attribute
//    {
//        public EditorWindowsTag()
//        {

//        }


//        /// <summary>
//        /// 判断一个类或者他的父类是否具备EditorWindowsTag属性
//        /// </summary>
//        /// <returns></returns>
//        public static bool TypeIsEditorWindowsTag(Type type)
//        {
//            object[] attributes = type.GetCustomAttributes(typeof(EditorWindowsTag), false);
//            if (attributes.Length > 0)
//            {
//                return true;
//            }
//            if (type.BaseType != null && type.BaseType != type)
//            {
//                return TypeIsEditorWindowsTag(type.BaseType);
//            }
//            else
//            {
//                return false;
//            }
//        }
//    }
//}


