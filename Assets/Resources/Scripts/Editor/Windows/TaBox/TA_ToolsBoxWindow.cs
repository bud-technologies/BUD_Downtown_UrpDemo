
//using UnityEngine;
//using UnityEditor;
//using System.IO;
//using System.Collections.Generic;
//using System;
//using System.Reflection;
//using System.Linq;

///// <summary>
///// Ta���ߺ���
///// </summary>
//public class TA_ToolsBoxWindow : EditorWindowsBase
//{
//    [MenuItem("ArtTools/TA������/�ٱ���")]
//    static void MenuClick()
//    {
//        SetActive();
//    }

//    /// <summary>
//    /// ������ʾ
//    /// </summary>
//    public static void SetActive()
//    {
//        Init();
//        TA_ToolsBoxWindow newData = new TA_ToolsBoxWindow();
//        newData.ShowWindowTile("�ٱ���");
//    }

//    /// <summary>
//    /// key=����⣬value=UI��ťԪ��
//    /// </summary>
//    static Dictionary<string, List<object>> uiItems = new Dictionary<string, List<object>>();

//    /// <summary>
//    /// key=����⣬key=toggle���֣�value=toggle�ص�
//    /// </summary>
//    static Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>> toggleItems = new Dictionary<string, Dictionary<string, Action<bool, Action<bool>>>>();

//    /// <summary>
//    ///  key=����⣬key=��ť���֣�value=�ص�
//    /// </summary>
//    static Dictionary<string, Dictionary<string, System.Action>> normalButtons = new Dictionary<string, Dictionary<string, Action>>();

//    static float _widthLimit = 200;

//    /// <summary>
//    /// ui��ť�����п����ֵ
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
//    /// ��ʼ��UI����
//    /// </summary>
//    static void Init()
//    {
//        #region//��ť�� �̳���EditorWindowsBase�Ĵ���

//        uiItems.Clear();
//        //ʲôʲô����...
//        List<object> list = new List<object>()
//        {
//            //(��ť��,�رմ���ʱ��TA_ToolsBoxWindow)
//            new TaEditorUiItem<TA_ArtModelWin> ("ģ�͵�����������",false),
//            new TaEditorUiItem<TA_ModelUVWin> ("ģ��UV���",false),
//        };
//        uiItems.Add("ʲôʲô����...", list);

//        #endregion

//        #region//��ѡ��

//        toggleItems.Clear();
//        Dictionary<string, System.Action<bool, System.Action<bool>>> dic = new Dictionary<string, Action<bool, Action<bool>>>();
//        //
//        //<����CUIForm�ķֱ����ڱ༭��ģʽ���Ƿ�����Զ�ˢ��
//        //System.Action<bool, System.Action<bool>> fun = (bl, callBack) => {
//        //    if (callBack != null)
//        //    {
//        //        //��ȡ����
//        //        callBack(EditorGlobal.MatchScreenInEditor);
//        //    }
//        //    else
//        //    {
//        //        //���ñ���
//        //        EditorGlobal.MatchScreenInEditor = bl;
//        //    }
//        //};
//        //dic.Add("����CUIForm�ķֱ����ڱ༭��ģʽ���Ƿ�����Զ�ˢ��", fun);
//        //>
//        toggleItems.Add("ȫ�ֿ���", dic);

//        #endregion

//        #region//������ť��

//        normalButtons.Clear();

//        //��Ч�鹤��...
//        Dictionary<string, System.Action> taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("������ɫ(��ɫ)", TA_URPPossEffectTool.ScenesColorGray);
//        taButtonsDic.Add("������ɫ(��ɫ)", TA_URPPossEffectTool.ScenesColorReset);
//        normalButtons.Add("��Ч�鹤��...", taButtonsDic);

//        //SVN�ļ�������
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("�������SVN����", TA_SvnErrInspectTool.InspectAllErrAssetObject);
//        taButtonsDic.Add("���SVN����(Shader)", TA_SvnErrInspectTool.InspectErrAssetObject_Shader);
//        taButtonsDic.Add("���SVN����(����)", TA_SvnErrInspectTool.InspectErrAssetObject_Material);
//        taButtonsDic.Add("���SVN����(.asset)", TA_SvnErrInspectTool.InspectErrAssetObject_Asset);
//        normalButtons.Add("SVN�ļ�����...", taButtonsDic);

//        //Shader��Ϣ...
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("����Shader�����ļ�", ()=> {
//            EditorWindowsBase.CloseAllEditorWindows();
//            TA_ShaderVariantsTool.ShaderVariantsCreate();
//        });
//        taButtonsDic.Add("��ЩShader��ʹ�ù�(ע��Log)", Ta_UsedShaders.ShaderUseConditio);
//        taButtonsDic.Add("Shader������(ע��Log)", Ta_UsedShaders.ProjectShaderErr);
//        taButtonsDic.Add("UberPost ʹ�����", Ta_UsedShaders.TargetShaderServiceCondition_UberPost);
//        taButtonsDic.Add("Legacy Shaders/VertexLit ʹ�����", Ta_UsedShaders.TargetShaderServiceCondition_Legacy_Shaders_VertexLit);
//        taButtonsDic.Add("Legacy Shaders/Diffuse ʹ�����", Ta_UsedShaders.TargetShaderServiceCondition_Legacy_Shaders_Diffuse);
//        taButtonsDic.Add("Sprites/Default ʹ�����", Ta_UsedShaders.TargetShaderServiceCondition_Sprites_Default);
//        taButtonsDic.Add("Universal Render Pipeline/Lit ʹ�����", Ta_UsedShaders.TargetShaderServiceCondition_UniversalRenderPipeline_Lit);
//        taButtonsDic.Add("Ĭ�ϲ����� Default-Diffuse ʹ�����", Ta_UsedShaders.TargetMatServiceCondition);
//        taButtonsDic.Add("��Щ�������˿ɶ�д", Ta_UsedShaders.ReadWriteOpenTextures);
//        taButtonsDic.Add("��Щ�������Shader��ʧ��", Ta_UsedShaders.NullShaderServiceCondition);
//        normalButtons.Add("Shader��Ϣ...", taButtonsDic);

//        //��������Ϣ
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("��Щ����������Ч����(���� ������ ��ɫ)", TAMatTool.CheckAllMatSavedPropertieData);
//        taButtonsDic.Add("��Щ����������Ч����(����)", TAMatTool.CheckAllMatSavedPropertieData_Texture);
//        taButtonsDic.Add("��Щ����������Ч����(������)", TAMatTool.CheckAllMatSavedPropertieData_Float);
//        taButtonsDic.Add("��Щ����������Ч����(��ɫ)", TAMatTool.CheckAllMatSavedPropertieData_Color);
//        normalButtons.Add("��������Ϣ...", taButtonsDic);

//        //ͼƬ��Ϣ
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("��ЩͼƬ�����˶�д", TA_TextureTool.CheckAllTexture_ReadWrite);
//        taButtonsDic.Add("��ЩͼƬ������Mipmap", TA_TextureTool.CheckAllTexture_Mipmap);
//        taButtonsDic.Add("��ЩͼƬWrapMode����Clamp", TA_TextureTool.CheckAllTexture_NotClamp);
//        taButtonsDic.Add("��ЩͼƬFilterModeΪTrilinear", TA_TextureTool.CheckAllTexture_IsTrilinear);
//        taButtonsDic.Add("��ЩͼƬ�ߴ����2048", TA_TextureTool.CheckAllBigSizeTextures_2048);
//        taButtonsDic.Add("��ЩͼƬ�ߴ����1024", TA_TextureTool.CheckAllBigSizeTextures_1024);
//        normalButtons.Add("ͼƬ��Ϣ...", taButtonsDic);

//        //�ı���Ϣ
//        taButtonsDic = new Dictionary<string, Action>();
//        //CheckResABPrefabDependencies
//        taButtonsDic.Add("ResAB�ļ������������ļ�����", TA_ResourcesTool.CheckResABPrefabDependencies);
//        taButtonsDic.Add("��Щ�ļ������� ���� ", TA_TextTool.CheckAllFileContStr_WangZhe);
//        normalButtons.Add("�ı���Ϣ...", taButtonsDic);

//        //�ظ����.....
//        taButtonsDic = new Dictionary<string, Action>();
//        taButtonsDic.Add("�ظ���Դ���(����)", TA_DuplicationName.Run);
//        taButtonsDic.Add("�ظ���Դ���(xml)", TA_DuplicationName.Run_xml);
//        taButtonsDic.Add("�ظ���Դ���(dll)", TA_DuplicationName.Run_dll);
//        taButtonsDic.Add("�ظ���Դ���(so)", TA_DuplicationName.Run_so);
//        taButtonsDic.Add("�ظ���Դ���(prefab)", TA_DuplicationName.Run_prefab);
//        taButtonsDic.Add("�ظ���Դ���(tga)", TA_DuplicationName.Run_tga);
//        taButtonsDic.Add("�ظ���Դ���(jpg)", TA_DuplicationName.Run_jpg);
//        taButtonsDic.Add("�ظ���Դ���(png)", TA_DuplicationName.Run_png);
//        taButtonsDic.Add("�ظ���Դ���(fbx)", TA_DuplicationName.Run_fbx);
//        taButtonsDic.Add("�ظ���Դ���(cubemap)", TA_DuplicationName.Run_cubemap);
//        taButtonsDic.Add("�ظ���Դ���(shader)", TA_DuplicationName.Run_shader);
//        taButtonsDic.Add("�ظ���Դ���(mat)", TA_DuplicationName.Run_mat);
//        taButtonsDic.Add("�ظ���Դ���(unity)", TA_DuplicationName.Run_unity);
//        taButtonsDic.Add("�ظ���Դ���(asset)", TA_DuplicationName.Run_asset);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(����)", TA_DuplicationName.BeAdoptedDependenciesInfo_All);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(xml)", TA_DuplicationName.BeAdoptedDependenciesInfo_xml);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(prefab)", TA_DuplicationName.BeAdoptedDependenciesInfo_prefab);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(tga)", TA_DuplicationName.BeAdoptedDependenciesInfo_tga);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(jpg)", TA_DuplicationName.BeAdoptedDependenciesInfo_jpg);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(png)", TA_DuplicationName.BeAdoptedDependenciesInfo_png);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(shader)", TA_DuplicationName.BeAdoptedDependenciesInfo_shader);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(mat)", TA_DuplicationName.BeAdoptedDependenciesInfo_mat);
//        taButtonsDic.Add("�ظ���Դ�����ù�ϵ(asset)", TA_DuplicationName.BeAdoptedDependenciesInfo_asset);
//        taButtonsDic.Add("ɾ���ظ���Դ(jpg)", TA_DuplicationName.DeleteDuplicationNameFile_jpg);
//        taButtonsDic.Add("ɾ���ظ���Դ(png)", TA_DuplicationName.DeleteDuplicationNameFile_png);
//        taButtonsDic.Add("ɾ���ظ���Դ(tga)", TA_DuplicationName.DeleteDuplicationNameFile_tga);
//        taButtonsDic.Add("ɾ���ظ���Դ(mat)", TA_DuplicationName.DeleteDuplicationNameFile_mat);
//        taButtonsDic.Add("��ԭ��ɾ����UI��Դ(png)", TA_DuplicationName.DeleteDuplicationNameFileRecover_Png_UI);

//        normalButtons.Add("�ظ����.....", taButtonsDic);

//        #endregion

//    }

//    /// <summary>
//    /// UI��ťԪ��
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
//        /// ��������
//        /// </summary>
//        public Type WindowType;

//        /// <summary>
//        /// ��ť����
//        /// </summary>
//        public string ButtonText;

//        /// <summary>
//        /// �ڴ��ڹرյ�ʱ���Ƿ�Ҫ�� TA_ToolsBoxWindow
//        /// </summary>
//        public bool OpenSgameWinOnClose = true;

//        /// <summary>
//        /// ��ʾ����
//        /// </summary>
//        public void ShowWindow()
//        {
//            EditorWindowsBase window = (EditorWindowsBase)(System.Activator.CreateInstance(WindowType));
//            window.ShowWindow(OpenSgameWinOnClose);
//        }
//    }

//    /// <summary>
//    /// ���ڻ���
//    /// </summary>
//    protected override void OnGUIWindow()
//    {
//        #region//���ư�ť �̳���EditorWindowsBase�Ĵ���

//        //����ÿһ����Ҫ��ʾ�İ�ť����
//        Rect rect = position;
//        float width = rect.width;
//        //ÿһ����Ҫ��ʾ�İ�ť����
//        int count = (int)(width / widthLimit);
//        if (count < 1) { count = 1; }
//        //���ݱ�����ʾ��ť
//        Dictionary<string, List<object>>.Enumerator enumerator = uiItems.GetEnumerator();
//        while (enumerator.MoveNext())
//        {
//            List<object> list = enumerator.Current.Value;
//            //��ʾһ���б�
//            SetTittle(enumerator.Current.Key);
//            //��ʾ��ť
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

//        #region//������ť��

//        Dictionary<string, Dictionary<string, System.Action>>.Enumerator enumeratorButton = normalButtons.GetEnumerator();
//        while (enumeratorButton.MoveNext())
//        {
//            //��ʾһ���б�
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

//        #region//���Ƶ�ѡ��

//        Dictionary<string, Dictionary<string, System.Action<bool, System.Action<bool>>>>.Enumerator enumeratorToggle = toggleItems.GetEnumerator();
//        while (enumeratorToggle.MoveNext())
//        {
//            //��ʾһ���б�
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
