using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MyCurveTool : EditorWindow
{
    private readonly string _titleName = "自定义赛道工具";
    private MyDynamicMesh _mDM;

    private MyCurveTool()
    {
        this.titleContent = new GUIContent(_titleName);
        Debug.Log("----------已启动：自定义赛道工具！----------");
    }

    // Start is called before the first frame update
    private void Start()
    {
        //_mDM.Start();
    }

    // Update is called once per frame
    private void Update()
    {
        //_mDM.SetSegments(4);
        //Debug.Log("----------66666666666666666666666！----------");
    }

    [MenuItem("Tools/自定义赛道工具")]
    private static void ShowCustomCurveToolWindows()
    {
        EditorWindow.GetWindow(typeof(MyCurveTool));
    }

    private void OnGUI()
    {
    }
}
