using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace MyScripts.Editor
{
    public class MyCurveTool : EditorWindow
    {
        private readonly string _titleName = "自定义赛道工具";
        private MyDynamicMesh _mDM ;

        MyCurveTool()
        {
            this.titleContent = new GUIContent(_titleName);
            Debug.Log("----------已启动：自定义赛道工具！----------");
        }
        
        // Start is called before the first frame update
        void Start()
        {
            //_mDM.Start();
        }

        // Update is called once per frame
        void Update()
        {
            //_mDM.SetSegments(4);
            Debug.Log("----------66666666666666666666666！----------");
        }

        [MenuItem("Tools/自定义赛道工具")]
        static void ShowCustomCurveToolWindows()
        {
            EditorWindow.GetWindow(typeof(MyCurveTool));
            
        }

        private void OnGUI()
        {
            
        }
    }
}
