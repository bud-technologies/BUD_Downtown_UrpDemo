
//using UnityEngine;
//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Linq;

//namespace Render
//{

//    /// <summary>
//    /// 通用编辑器窗口 其中包含了多数的编辑器窗口
//    /// </summary>
//    public class SgameEditorWindows : EditorWindowsBase
//    {

//        [MenuItem("SGameTools/WindowsBox")]
//        static void MenuClick()
//        {
//            SetActive();
//        }

//        /// <summary>
//        /// 窗口显示
//        /// </summary>
//        public static void SetActive()
//        {
//            Init();
//            SgameEditorWindows newData = new SgameEditorWindows();
//            newData.ShowWindow();
//        }

//        /// <summary>
//        /// key=大标题，value=UI按钮元素
//        /// </summary>
//        static Dictionary<string, List<object>> uiItems = new Dictionary<string, List<object>>();

//        /// <summary>
//        /// key=大标题，key=toggle名字，value=toggle回调
//        /// </summary>
//        static Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>> toggleItems = new Dictionary<string, Dictionary<string, Action<bool, Action<bool>>>>();

//        /// <summary>
//        ///  key=大标题，key=按钮名字，value=回调
//        /// </summary>
//        static Dictionary<string, Dictionary<string, System.Action>> normalButtons = new Dictionary<string, Dictionary<string, Action>>();

//        static float _widthLimit = 200;

//        /// <summary>
//        /// ui按钮行排列宽度阈值
//        /// </summary>
//        static float widthLimit
//        {
//            get
//            {
//                if (_widthLimit < 100) _widthLimit = 100;
//                if (_widthLimit > 500) _widthLimit = 500;
//                return _widthLimit;
//            }
//            set
//            {
//                _widthLimit = value;
//                if (_widthLimit < 100) _widthLimit = 100;
//                if (_widthLimit > 500) _widthLimit = 500;
//            }
//        }

//        /// <summary>
//        /// 初始化UI布局
//        /// </summary>
//        static void Init()
//        {
//            #region//按钮类 继承自EditorWindowsBase的窗口

//            uiItems.Clear();
//            //通用资源类
//            List<object> list = new List<object>()
//            {
//                //(按钮名,关闭窗口时打开SgameEditorWindows)
//                //new SgameEditorUiItem<ObjectReferencesWindow> ("资源的关联数据",true),
//                //new SgameEditorUiItem<PrefabCheckerBatchWindowNew> ("Prefab规范检查",true),
//                //new SgameEditorUiItem<ParticleCheckerBatchWindowNew> ("粒子规范检查",true),
//                //new SgameEditorUiItem<UpdatePrefabWindow> ("UpdatePrefab",true),
//                //new SgameEditorUiItem<ToolBoxWindow> ("工具箱",true)
//            };
//            uiItems.Add("通用资源类", list);
//            //内存类
//            list = new List<object>()
//            {
//            };
//            uiItems.Add("内存类", list);
//            //美术资源类
//            list = new List<object>()
//            {
//                //new SgameEditorUiItem<FBXCheckWindow> ("FBX检查",true),
//                //new SgameEditorUiItem<SimilarTextureWindow> ("相似纹理检测",true),
//                //new SgameEditorUiItem<UIImageCompressWindow> ("图片批量压缩",true)
//            };
//            uiItems.Add("美术资源类", list);

//            #endregion

//            #region//单选框

//            toggleItems.Clear();
//            //Dictionary<string, System.Action<bool, System.Action<bool>>> dic = new Dictionary<string, Action<bool, Action<bool>>>();
//            //

//            //dic.Add("控制CUIForm的分辨率在编辑器模式下是否进行自动刷新", fun);
//            //>
//            //toggleItems.Add("全局开关", dic);

//            #endregion

//            #region//其他按钮类

//            normalButtons.Clear();
//            //打包
//            Dictionary<string, System.Action> normalButtonsDic = new Dictionary<string, Action>();
//            //功能按钮
//            normalButtonsDic = new Dictionary<string, Action>();
//            //normalButtonsDic.Add("打开DOTween窗口", DOTweenEX.DOTweenWin);
//            normalButtonsDic.Add("查找没有URPCamera的预制体", URPCamera.PrefabFindCamera);

//            normalButtons.Add("功能按钮", normalButtonsDic);
//            //


//            #endregion
//        }

//        /// <summary>
//        /// UI按钮元素
//        /// </summary>
//        public class SgameEditorUiItem<T> where T : EditorWindowsBase
//        {
//            public SgameEditorUiItem(string buttonText, bool openSgameWinOnClose)
//            {
//                WindowType = typeof(T);
//                ButtonText = buttonText;
//                OpenSgameWinOnClose = openSgameWinOnClose;
//            }

//            /// <summary>
//            /// 窗口类型
//            /// </summary>
//            public Type WindowType;

//            /// <summary>
//            /// 按钮描述
//            /// </summary>
//            public string ButtonText;

//            /// <summary>
//            /// 在窗口关闭的时候是否要打开 SgameEditorWindows
//            /// </summary>
//            public bool OpenSgameWinOnClose = true;

//            /// <summary>
//            /// 显示窗口
//            /// </summary>
//            public void ShowWindow()
//            {
//                EditorWindowsBase window = (EditorWindowsBase)(System.Activator.CreateInstance(WindowType));
//                window.ShowWindow(OpenSgameWinOnClose);
//            }
//        }

//        /// <summary>
//        /// 窗口绘制
//        /// </summary>
//        protected override void OnGUIWindow()
//        {
//            #region//绘制按钮 继承自EditorWindowsBase的窗口

//            //计算每一行需要显示的按钮数量
//            Rect rect = position;
//            float width = rect.width;
//            //每一行需要显示的按钮数量
//            int count = (int)(width / widthLimit);
//            if (count < 1) { count = 1; }
//            //根据标题显示按钮
//            Dictionary<string, List<object>>.Enumerator enumerator = uiItems.GetEnumerator();
//            while (enumerator.MoveNext())
//            {
//                List<object> list = enumerator.Current.Value;
//                //显示一个行标
//                SetTittle(enumerator.Current.Key);
//                //显示按钮
//                if (list.Count > 0)
//                {
//                    int index = 0;
//                    for (int i = 0, listCount = list.Count; i < listCount;)
//                    {
//                        index = 0;
//                        using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//                        {
//                            while (index < count && i < listCount)
//                            {
//                                object obj = list[i];
//                                Type type = obj.GetType();
//                                FieldInfo fieldInfo = type.GetField("ButtonText");
//                                MethodInfo methodInfo = type.GetMethod("ShowWindow");
//                                if (GUILayout.Button(fieldInfo.GetValue(obj).ToString()))
//                                {
//                                    methodInfo.Invoke(obj, null);
//                                }
//                                index++;
//                                i++;
//                            }
//                        }
//                    }
//                }
//            }

//            #endregion

//            #region//其他按钮类

//            Dictionary<string, Dictionary<string, System.Action>>.Enumerator enumeratorButton = normalButtons.GetEnumerator();
//            while (enumeratorButton.MoveNext())
//            {
//                //显示一个行标
//                SetTittle(enumeratorButton.Current.Key);
//                Dictionary<string, System.Action> dic = enumeratorButton.Current.Value;
//                if (dic.Count > 0)
//                {
//                    int index = 0;
//                    List<string> keys = dic.Keys.ToList<string>();
//                    for (int i = 0, listCount = keys.Count; i < listCount;)
//                    {
//                        index = 0;
//                        using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//                        {
//                            while (index < count && i < listCount)
//                            {
//                                System.Action callBack = dic[keys[i]];
//                                if (GUILayout.Button(keys[i]))
//                                {
//                                    if (callBack != null)
//                                    {
//                                        callBack();
//                                    }
//                                }
//                                index++;
//                                i++;
//                            }
//                        }
//                    }
//                }
//            }

//            #endregion

//            #region//绘制单选框

//            Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>>.Enumerator enumeratorToggle = toggleItems.GetEnumerator();
//            while (enumeratorToggle.MoveNext())
//            {
//                //显示一个行标
//                SetTittle(enumeratorToggle.Current.Key);
//                Dictionary<string, System.Action<bool, System.Action<bool>>>.Enumerator enumeratorChild = enumeratorToggle.Current.Value.GetEnumerator();
//                while (enumeratorChild.MoveNext())
//                {
//                    using (EditorWindowsBase.VerticalLayout layOut = new VerticalLayout())
//                    {
//                        System.Action<bool, System.Action<bool>> fun = enumeratorChild.Current.Value;
//                        bool value = false;
//                        fun(false, (bl) => {
//                            value = bl;
//                        });
//                        value = GUILayout.Toggle(value, enumeratorChild.Current.Key);
//                        fun(value, null);
//                    }
//                }
//            }

//            #endregion

//        }

//    }
//}

