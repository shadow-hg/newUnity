using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/*
 * 工具位置：Unity菜单栏：HRP/物体批量筛选查找工具
 * 作用：批量筛选物体
 * 时间 2023.04.13
 */

namespace com.yoozoo.gta.Art.Editor
{
    [CustomEditor(typeof(ObjectSearchFilter))]
    public class ObjectSearchFilterGUI : EditorWindow
    {
        [Header("最小值")] private int _minCount = 0;
        [Header("最大值")] private int _maxCount = 4;
        
        [Header("该范围区间数量")] public int lowCountNum = 0;

        private readonly List<string> _displayedOptions = new List<string>()
        {
            "顶点",
            "三角面",
            "SubMesh",
            "Draw Dynamic",
            "GPU Instancing",
            "SRP Batching",
            "自定义Shader",
            "材质球",
            "Mesh网格",
        };

        private readonly List<int> _displayedOptionsIndex = new List<int>()
        {
            0, 1, 2, 3, 4, 5, 6, 7 ,8,
        };

        private ObjectSearchFilter glm;

        public ObjectSearchFilter GLM
        {
            get
            {
                if (glm == null)
                {
                    glm = new ObjectSearchFilter();
                }

                return glm;
            }
        }

        private int selectMenu = 0;

        public GameObject rootObject;
        private SerializedObject _shaderObj;
        private SerializedProperty _shaderPro;

        public List<Shader> allShaders = new List<Shader>();//搜索合批方式和自定义shader时，用来在面板显示预存的默认shader。
        public List<GameObject> sceneLowMeshes = new List<GameObject>();//搜索结果全存在这个列表里
        private SerializedObject _spObj;
        private SerializedProperty _spPro;

        private Vector2 _scrollViewVector = new Vector2();//用于在面板展示大量搜索结果时，可以滑动列表查看结果
        private Dictionary<string, Shader> _shaderDictionary = new Dictionary<string, Shader>();//用来存查找shader时预设的shader列表，对比防止重复添加

        public Shader customShader;
        public Material customMaterial;
        public Mesh customMesh;

        //为防止搜索结果数量较大导致面板卡顿，所以设定好结果的显示范围：
        public int displayIndexMin = 0;
        public int displayIndexMax = 100;
        private List<GameObject> _cacheObjs = new List<GameObject>();
        
        private bool _hasObj = false;

        [MenuItem("HRP/物体批量筛选查找工具")]
        public static void ShowWindow()
        {
            ObjectSearchFilterGUI window =
                (ObjectSearchFilterGUI) GetWindow(typeof(ObjectSearchFilterGUI));
            window.titleContent.text = "超级查找器";
            window.Show();
            window.Focus();
        }

        private void OnEnable()
        {
            _spObj = new SerializedObject(this);
            _spPro = _spObj.FindProperty("sceneLowMeshes");

            _shaderObj = new SerializedObject(this);
            _shaderPro = _shaderObj.FindProperty("allShaders");
        }

        void DisplayIndex()
        {
            //if (displayIndexMin <= lowCountNum && displayIndexMax <= lowCountNum)
            {
                sceneLowMeshes.Clear();
                for (int i = displayIndexMin; i < displayIndexMax; i++)
                {
                    sceneLowMeshes.Add(_cacheObjs[i]);
                }
            }
        }
        
        public void OnGUI()
        {
            GUILayout.Space(10);
            GUI.skin.label.fontSize = 24;
            GUI.skin.label.alignment = TextAnchor.MiddleCenter;
            GUILayout.Label("物 体 筛 选 工 具");
            GUI.skin.label.fontSize = 12;
            GUI.skin.label.alignment = TextAnchor.MiddleLeft;

            GUILayout.Space(12);

            rootObject = EditorGUILayout.ObjectField("指定场景父节点:", rootObject, typeof(GameObject), true) as GameObject;
            GUILayout.Space(8);
            selectMenu = EditorGUILayout.IntPopup("选择筛选类型：", selectMenu, _displayedOptions.ToArray(),
                _displayedOptionsIndex.ToArray());

            GUILayout.Space(8);
            //当查找合批类型时不需要显示输入数量
            if (selectMenu < 3)
            {
                GUILayout.Label("根据选择类型输入查找的数量范围：");
                if (selectMenu == 2)
                {
                    GUILayout.Label("(搜索SubMesh数量时最小值不能小于 '1' )");
                }

                _minCount = EditorGUILayout.IntField("最小值:", _minCount);
                _maxCount = EditorGUILayout.IntField("最大值:", _maxCount);
            }

            if (selectMenu >= 3 && selectMenu <= 5)
            {
                _shaderObj.Update();
                EditorGUILayout.PropertyField(_shaderPro);

                //创建一个缓存shader列表
                List<Shader> defaultShaderList = new List<Shader>();

                switch (selectMenu)
                {
                    case 3:
                        _shaderDictionary.Clear();
                        allShaders.Clear();
                        defaultShaderList.Clear();

                        //增加默认的Shader
                        defaultShaderList.Add(Shader.Find("HRP/TA/GTA/Common/PBRRT(Dynamic)"));

                        foreach (var defaultShader in defaultShaderList)
                        {
                            if (!_shaderDictionary.ContainsValue(defaultShader)) //结果是3时会反复执行，所以防止反复向列表添加这俩默认shader
                            {
                                _shaderDictionary.Add(defaultShader.name, defaultShader);
                                allShaders.Add(defaultShader);
                            }
                        }

                        break;
                    case 4:
                        _shaderDictionary.Clear();
                        allShaders.Clear();
                        defaultShaderList.Clear();

                        //增加默认的Shader
                        defaultShaderList.Add(Shader.Find("HRP/TA/GTA/Common/PBRRT(Instance)"));
                        defaultShaderList.Add(Shader.Find("HRP/TA/GTA/Common/PBRRTAlphaTest(Instance)"));

                        foreach (var defaultShader in defaultShaderList)
                        {
                            if (!_shaderDictionary.ContainsValue(defaultShader)) //结果是4时会反复执行，所以防止反复向列表添加这俩默认shader
                            {
                                _shaderDictionary.Add(defaultShader.name, defaultShader);
                                allShaders.Add(defaultShader);
                            }
                        }

                        break;
                    case 5:
                        _shaderDictionary.Clear();
                        allShaders.Clear();
                        defaultShaderList.Clear();

                        //增加默认的Shader
                        defaultShaderList.Add(Shader.Find("HRP/TA/GTA/Common/PBRRT(Mixed)"));

                        foreach (var defaultShader in defaultShaderList)
                        {
                            if (!_shaderDictionary.ContainsValue(defaultShader)) //结果是5时会反复执行，所以防止反复向列表添加这俩默认shader
                            {
                                _shaderDictionary.Add(defaultShader.name, defaultShader);
                                allShaders.Add(defaultShader);
                            }
                        }

                        break;
                }

                _shaderObj.ApplyModifiedProperties(); //把列表数据存下来
            }

            if (selectMenu == 6)
            {
                customShader = EditorGUILayout.ObjectField("shader", customShader, typeof(Shader), true) as Shader;

                if (customShader)
                {
                    _shaderObj.Update();
                    _shaderDictionary.Clear();
                    allShaders.Clear();
                    if (!_shaderDictionary.ContainsValue(customShader))
                    {
                        _shaderDictionary.Add(customShader.name, customShader);
                        allShaders.Add(customShader);
                    }

                    _shaderObj.ApplyModifiedProperties();
                }
            }

            if (selectMenu == 7)
            {
                customMaterial = EditorGUILayout.ObjectField("材质球:",customMaterial,typeof(Material),true) as Material;
            }
            
            if (selectMenu == 8)
            {
                customMesh = EditorGUILayout.ObjectField("网格Mesh:",customMesh,typeof(Mesh),true) as Mesh;
            }

            GUILayout.Space(8);
            if (GUILayout.Button("超级查找器，启动！！",GUILayout.Height(24)))
            {
                if (rootObject == null)
                {
                    UnityEngine.Debug.LogWarning("————————物体筛选工具：请指定场景父节点！————————");
                    return;
                }
                
                if (selectMenu <= 6)
                {
                    GLM.BeginGetLowMesh(rootObject, _minCount, _maxCount, selectMenu, allShaders);
                }

                if (selectMenu == 7)
                {
                    if (customMaterial)
                    {
                        GLM.FindObjByMaterial(rootObject,customMaterial);
                    }
                }
                
                if (selectMenu == 8)
                {
                    if (customMesh)
                    {
                        GLM.FindObjByMesh(rootObject,customMesh);
                    }
                }

                if (GLM.lowCount.Count > 0 && GLM.lowCount != null)
                {
                    _cacheObjs = GLM.lowCount;
                    _hasObj = true;

                    DisplayIndex();
                    _spObj.Update();
                    _spObj.ApplyModifiedProperties();
                }
                else
                {
                    _hasObj = false;
                }
                
            }

            GUILayout.Space(8);
            if (GUILayout.Button("清除列表",GUILayout.Height(24)))
            {
                if (_cacheObjs.Count > 0)
                {
                    _hasObj = false;
                    _cacheObjs.Clear();
                    sceneLowMeshes.Clear();
                    _spObj.Update();
                    _shaderDictionary.Clear();
                    GLM.ClearAll();
                }
            }
            
            GUILayout.Space(8);
            GUILayout.Label(
                "________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________");

            GUILayout.Space(8);
            
            lowCountNum = GLM.lowCountNum;

            if (_cacheObjs.Count > 0)
            {
                GUILayout.Label("为防止搜索结果数量过多导致卡顿，请根据索引值输入需要显示的范围：");
                EditorGUILayout.HelpBox("筛选类型总数量 : " + lowCountNum,MessageType.Info);
                displayIndexMin = EditorGUILayout.IntField("最小显示范围：",displayIndexMin);
                displayIndexMax = EditorGUILayout.IntField("最大显示范围：",displayIndexMax);
                if (displayIndexMin > lowCountNum || displayIndexMax > lowCountNum )
                {
                    EditorGUILayout.HelpBox("显示范围设置有误，范围值需要小于搜索结果的总数量！",MessageType.Error);
                }
                if (displayIndexMin > displayIndexMax )
                {
                    EditorGUILayout.HelpBox("显示范围设置有误，最大范围值需大于最小范围值！",MessageType.Error);
                }
                
                if (GUILayout.Button("刷新列表",GUILayout.Height(24)))
                {
                    if (displayIndexMin <= lowCountNum && displayIndexMax <= lowCountNum)
                    {
                        DisplayIndex();
                        _spObj.Update();
                        _spObj.ApplyModifiedProperties();
                    }
                    else
                    {
                        UnityEngine.Debug.LogWarning("——————————物体筛选工具：请根据类型总数量设置显示范围！——————————");
                    }
                }
            }

            if (!_hasObj)
            {
                EditorGUILayout.HelpBox("未执行搜索操作，或当前搜索结果为空！",MessageType.Warning);
            }
            _scrollViewVector = EditorGUILayout.BeginScrollView(_scrollViewVector);
            EditorGUILayout.PropertyField(_spPro);
            EditorGUILayout.EndScrollView();
        }
    }
}