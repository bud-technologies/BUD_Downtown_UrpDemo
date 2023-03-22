
//using UnityEngine;
//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Linq;

///// <summary>
///// Ta工具盒子
///// </summary>
//public class TA_ToolsBoxWindow : EditorWindowsBase
//{
//    [MenuItem("ArtTools/TA工具箱/百宝盒")]
//    static void MenuClick()
//    {
//        SetActive();
//    }

//    /// <summary>
//    /// 窗口显示
//    /// </summary>
//    public static void SetActive()
//    {
//        Init();
//        TA_ToolsBoxWindow newData = new TA_ToolsBoxWindow();
//        newData.ShowWindowTile("百宝箱");
//    }

//    /// <summary>
//    /// key=大标题，value=UI按钮元素
//    /// </summary>
//    static Dictionary<string, List<object>> uiItems = new Dictionary<string, List<object>>();

//    /// <summary>
//    /// key=大标题，key=toggle名字，value=toggle回调
//    /// </summary>
//    static Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>> toggleItems = new Dictionary<string, Dictionary<string, Action<bool, Action<bool>>>>();

//    /// <summary>
//    ///  key=大标题，key=按钮名字，value=回调
//    /// </summary>
//    static Dictionary<string, Dictionary<string, System.Action>> normalButtons = new Dictionary<string, Dictionary<string, Action>>();

//    static float _widthLimit = 200;

//    /// <summary>
//    /// ui按钮行排列宽度阈值
//    /// </summary>
//    static float widthLimit
//    {
//        get
//        {
//            if (_widthLimit < 100) _widthLimit = 100;
//            if (_widthLimit > 500) _widthLimit = 500;
//            return _widthLimit;
//        }
//        set
//        {
//            _widthLimit = value;
//            if (_widthLimit < 100) _widthLimit = 100;
//            if (_widthLimit > 500) _widthLimit = 500;
//        }
//    }

//    /// <summary>
//    /// 初始化UI布局
//    /// </summary>
//    static void Init()
//    {
//        #region//按钮类 继承自EditorWindowsBase的窗口

//        uiItems.Clear();
//        //什么什么窗口...
//        List<object> list = new List<object>()
//        {
//            //(按钮名,关闭窗口时打开TA_ToolsBoxWindow)
//            new TaEditorUiItem<TA_ArtModelWin> ("模型的美术规则检测",false),
//            new TaEditorUiItem<TA_ModelUVWin> ("模型UV检测",false),
//        };
//        uiItems.Add("什么什么窗口...", list);

//        #endregion

//        #region//单选框

//        toggleItems.Clear();
//        Dictionary<string, System.Action<bool, System.Action<bool>>> dic = new Dictionary<string, Action<bool, Action<bool>>>();
//        //
//        //<控制CUIForm的分辨率在编辑器模式下是否进行自动刷新
//        //System.Action<bool, System.Action<bool>> fun = (bl, callBack) => {
//        //    if (callBack != null)
//        //    {
//        //        //获取变量
//        //        callBack(EditorGlobal.MatchScreenInEditor);
//        //    }
//        //    else
//        //    {
//        //        //设置变量
//        //        EditorGlobal.MatchScreenInEditor = bl;
//        //    }
//        //};
//        //dic.Add("控制CUIForm的分辨率在编辑器模式下是否进行自动刷新", fun);
//        //>
//        toggleItems.Add("全局开关", dic);

//        #endregion

//        #region//其他按钮类

//        normalButtons.Clear();

//        //特效组工具...
//        Dictionary<string, System.Action> taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("场景颜色(灰色)", TA_URPPossEffectTool.ScenesColorGray);
//        taButtonsDic.Add("场景颜色(彩色)", TA_URPPossEffectTool.ScenesColorReset);
//        normalButtons.Add("特效组工具...", taButtonsDic);

//        //SVN文件错误检查
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("检查所有SVN错误", TA_SvnErrInspectTool.InspectAllErrAssetObject);
//        taButtonsDic.Add("检查SVN错误(Shader)", TA_SvnErrInspectTool.InspectErrAssetObject_Shader);
//        taButtonsDic.Add("检查SVN错误(材质)", TA_SvnErrInspectTool.InspectErrAssetObject_Material);
//        taButtonsDic.Add("检查SVN错误(.asset)", TA_SvnErrInspectTool.InspectErrAssetObject_Asset);
//        normalButtons.Add("SVN文件错误...", taButtonsDic);

//        //Shader信息...
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("创建Shader变体文件", ()=> {
//            EditorWindowsBase.CloseAllEditorWindows();
//            TA_ShaderVariantsTool.ShaderVariantsCreate();
//        });
//        taButtonsDic.Add("哪些Shader被使用过(注意Log)", Ta_UsedShaders.ShaderUseConditio);
//        taButtonsDic.Add("Shader问题检查(注意Log)", Ta_UsedShaders.ProjectShaderErr);
//        taButtonsDic.Add("UberPost 使用情况", Ta_UsedShaders.TargetShaderServiceCondition_UberPost);
//        taButtonsDic.Add("Legacy Shaders/VertexLit 使用情况", Ta_UsedShaders.TargetShaderServiceCondition_Legacy_Shaders_VertexLit);
//        taButtonsDic.Add("Legacy Shaders/Diffuse 使用情况", Ta_UsedShaders.TargetShaderServiceCondition_Legacy_Shaders_Diffuse);
//        taButtonsDic.Add("Sprites/Default 使用情况", Ta_UsedShaders.TargetShaderServiceCondition_Sprites_Default);
//        taButtonsDic.Add("Universal Render Pipeline/Lit 使用情况", Ta_UsedShaders.TargetShaderServiceCondition_UniversalRenderPipeline_Lit);
//        taButtonsDic.Add("默认材质球 Default-Diffuse 使用情况", Ta_UsedShaders.TargetMatServiceCondition);
//        taButtonsDic.Add("哪些纹理开启了可读写", Ta_UsedShaders.ReadWriteOpenTextures);
//        taButtonsDic.Add("哪些材质球的Shader丢失了", Ta_UsedShaders.NullShaderServiceCondition);
//        normalButtons.Add("Shader信息...", taButtonsDic);

//        //材质球信息
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("哪些材质球有无效数据(纹理 浮点数 颜色)", TAMatTool.CheckAllMatSavedPropertieData);
//        taButtonsDic.Add("哪些材质球有无效数据(纹理)", TAMatTool.CheckAllMatSavedPropertieData_Texture);
//        taButtonsDic.Add("哪些材质球有无效数据(浮点数)", TAMatTool.CheckAllMatSavedPropertieData_Float);
//        taButtonsDic.Add("哪些材质球有无效数据(颜色)", TAMatTool.CheckAllMatSavedPropertieData_Color);
//        normalButtons.Add("材质球信息...", taButtonsDic);

//        //图片信息
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("哪些图片开启了读写", TA_TextureTool.CheckAllTexture_ReadWrite);
//        taButtonsDic.Add("哪些图片开启了Mipmap", TA_TextureTool.CheckAllTexture_Mipmap);
//        taButtonsDic.Add("哪些图片WrapMode不是Clamp", TA_TextureTool.CheckAllTexture_NotClamp);
//        taButtonsDic.Add("哪些图片FilterMode为Trilinear", TA_TextureTool.CheckAllTexture_IsTrilinear);
//        taButtonsDic.Add("哪些图片尺寸过大2048", TA_TextureTool.CheckAllBigSizeTextures_2048);
//        taButtonsDic.Add("哪些图片尺寸过大1024", TA_TextureTool.CheckAllBigSizeTextures_1024);
//        normalButtons.Add("图片信息...", taButtonsDic);

//        //文本信息
//        taButtonsDic = new Dictionary<string, Action>();
//        //CheckResABPrefabDependencies
//        taButtonsDic.Add("ResAB文件夹所依赖的文件数据", TA_ResourcesTool.CheckResABPrefabDependencies);
//        taButtonsDic.Add("哪些文件包含了 王者 ", TA_TextTool.CheckAllFileContStr_WangZhe);
//        normalButtons.Add("文本信息...", taButtonsDic);

//        //重复检测.....
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("重复资源检查(所有)", TA_DuplicationName.Run);
//        taButtonsDic.Add("重复资源检查(xml)", TA_DuplicationName.Run_xml);
//        taButtonsDic.Add("重复资源检查(dll)", TA_DuplicationName.Run_dll);
//        taButtonsDic.Add("重复资源检查(so)", TA_DuplicationName.Run_so);
//        taButtonsDic.Add("重复资源检查(prefab)", TA_DuplicationName.Run_prefab);
//        taButtonsDic.Add("重复资源检查(tga)", TA_DuplicationName.Run_tga);
//        taButtonsDic.Add("重复资源检查(jpg)", TA_DuplicationName.Run_jpg);
//        taButtonsDic.Add("重复资源检查(png)", TA_DuplicationName.Run_png);
//        taButtonsDic.Add("重复资源检查(fbx)", TA_DuplicationName.Run_fbx);
//        taButtonsDic.Add("重复资源检查(cubemap)", TA_DuplicationName.Run_cubemap);
//        taButtonsDic.Add("重复资源检查(shader)", TA_DuplicationName.Run_shader);
//        taButtonsDic.Add("重复资源检查(mat)", TA_DuplicationName.Run_mat);
//        taButtonsDic.Add("重复资源检查(unity)", TA_DuplicationName.Run_unity);
//        taButtonsDic.Add("重复资源检查(asset)", TA_DuplicationName.Run_asset);
//        taButtonsDic.Add("重复资源被引用关系(所有)", TA_DuplicationName.BeAdoptedDependenciesInfo_All);
//        taButtonsDic.Add("重复资源被引用关系(xml)", TA_DuplicationName.BeAdoptedDependenciesInfo_xml);
//        taButtonsDic.Add("重复资源被引用关系(prefab)", TA_DuplicationName.BeAdoptedDependenciesInfo_prefab);
//        taButtonsDic.Add("重复资源被引用关系(tga)", TA_DuplicationName.BeAdoptedDependenciesInfo_tga);
//        taButtonsDic.Add("重复资源被引用关系(jpg)", TA_DuplicationName.BeAdoptedDependenciesInfo_jpg);
//        taButtonsDic.Add("重复资源被引用关系(png)", TA_DuplicationName.BeAdoptedDependenciesInfo_png);
//        taButtonsDic.Add("重复资源被引用关系(shader)", TA_DuplicationName.BeAdoptedDependenciesInfo_shader);
//        taButtonsDic.Add("重复资源被引用关系(mat)", TA_DuplicationName.BeAdoptedDependenciesInfo_mat);
//        taButtonsDic.Add("重复资源被引用关系(asset)", TA_DuplicationName.BeAdoptedDependenciesInfo_asset);
//        taButtonsDic.Add("删除重复资源(jpg)", TA_DuplicationName.DeleteDuplicationNameFile_jpg);
//        taButtonsDic.Add("删除重复资源(png)", TA_DuplicationName.DeleteDuplicationNameFile_png);
//        taButtonsDic.Add("删除重复资源(tga)", TA_DuplicationName.DeleteDuplicationNameFile_tga);
//        taButtonsDic.Add("删除重复资源(mat)", TA_DuplicationName.DeleteDuplicationNameFile_mat);
//        taButtonsDic.Add("还原被删除的UI资源(png)", TA_DuplicationName.DeleteDuplicationNameFileRecover_Png_UI);

//        normalButtons.Add("重复检测.....", taButtonsDic);

//        #endregion

//    }

//    /// <summary>
//    /// UI按钮元素
//    /// </summary>
//    public class TaEditorUiItem<T> where T : EditorWindowsBase
//    {
//        public TaEditorUiItem(string buttonText, bool openSgameWinOnClose)
//        {
//            WindowType = typeof(T);
//            ButtonText = buttonText;
//            OpenSgameWinOnClose = openSgameWinOnClose;
//        }

//        /// <summary>
//        /// 窗口类型
//        /// </summary>
//        public Type WindowType;

//        /// <summary>
//        /// 按钮描述
//        /// </summary>
//        public string ButtonText;

//        /// <summary>
//        /// 在窗口关闭的时候是否要打开 TA_ToolsBoxWindow
//        /// </summary>
//        public bool OpenSgameWinOnClose = true;

//        /// <summary>
//        /// 显示窗口
//        /// </summary>
//        public void ShowWindow()
//        {
//            EditorWindowsBase window = (EditorWindowsBase)(System.Activator.CreateInstance(WindowType));
//            window.ShowWindow(OpenSgameWinOnClose);
//        }
//    }

//    /// <summary>
//    /// 窗口绘制
//    /// </summary>
//    protected override void OnGUIWindow()
//    {
//        #region//绘制按钮 继承自EditorWindowsBase的窗口

//        //计算每一行需要显示的按钮数量
//        Rect rect = position;
//        float width = rect.width;
//        //每一行需要显示的按钮数量
//        int count = (int)(width / widthLimit);
//        if (count < 1) { count = 1; }
//        //根据标题显示按钮
//        Dictionary<string, List<object>>.Enumerator enumerator = uiItems.GetEnumerator();
//        while (enumerator.MoveNext())
//        {
//            List<object> list = enumerator.Current.Value;
//            //显示一个行标
//            SetTittle(enumerator.Current.Key);
//            //显示按钮
//            if (list.Count > 0)
//            {
//                int index = 0;
//                for (int i = 0, listCount = list.Count; i < listCount;)
//                {
//                    index = 0;
//                    using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//                    {
//                        while (index < count && i < listCount)
//                        {
//                            object obj = list[i];
//                            Type type = obj.GetType();
//                            FieldInfo fieldInfo = type.GetField("ButtonText");
//                            MethodInfo methodInfo = type.GetMethod("ShowWindow");
//                            if (GUILayout.Button(fieldInfo.GetValue(obj).ToString()))
//                            {
//                                methodInfo.Invoke(obj, null);
//                            }
//                            index++;
//                            i++;
//                        }
//                    }
//                }
//            }
//        }

//        #endregion

//        #region//其他按钮类

//        Dictionary<string, Dictionary<string, System.Action>>.Enumerator enumeratorButton = normalButtons.GetEnumerator();
//        while (enumeratorButton.MoveNext())
//        {
//            //显示一个行标
//            SetTittle(enumeratorButton.Current.Key);
//            Dictionary<string, System.Action> dic = enumeratorButton.Current.Value;
//            if (dic.Count > 0)
//            {
//                int index = 0;
//                List<string> keys = dic.Keys.ToList<string>();
//                for (int i = 0, listCount = keys.Count; i < listCount;)
//                {
//                    index = 0;
//                    using (EditorWindowsBase.HorizontalLayout layOut = new HorizontalLayout())
//                    {
//                        while (index < count && i < listCount)
//                        {
//                            System.Action callBack = dic[keys[i]];
//                            if (GUILayout.Button(keys[i]))
//                            {
//                                if (callBack != null)
//                                {
//                                    callBack();
//                                }
//                            }
//                            index++;
//                            i++;
//                        }
//                    }
//                }
//            }
//        }

//        #endregion

//        #region//绘制单选框

//        Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>>.Enumerator enumeratorToggle = toggleItems.GetEnumerator();
//        while (enumeratorToggle.MoveNext())
//        {
//            //显示一个行标
//            SetTittle(enumeratorToggle.Current.Key);
//            Dictionary<string, System.Action<bool, System.Action<bool>>>.Enumerator enumeratorChild = enumeratorToggle.Current.Value.GetEnumerator();
//            while (enumeratorChild.MoveNext())
//            {
//                using (EditorWindowsBase.VerticalLayout layOut = new VerticalLayout())
//                {
//                    System.Action<bool, System.Action<bool>> fun = enumeratorChild.Current.Value;
//                    bool value = false;
//                    fun(false, (bl) => {
//                        value = bl;
//                    });
//                    value = GUILayout.Toggle(value, enumeratorChild.Current.Key);
//                    fun(value, null);
//                }
//            }
//        }

//        #endregion

//    }
//}
