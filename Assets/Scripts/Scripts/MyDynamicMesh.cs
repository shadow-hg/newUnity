using System;
using UnityEditor;
using UnityEngine;

public class MyDynamicMesh : MonoBehaviour
{
    private const string shaderName = "Standard";
    private const string meshName = "DynamicMesh";
    private const float meshDepth = 0f;

    [SerializeField] [Range(1,20)] public int segmentsX = 4; // 分段数
    [SerializeField] [Range(1,20)] public int segmentsY = 4; // 分段数

    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private Mesh mesh;

    public ComputeShader CpuShader;
    public bool saveMeshB = false;

    private void Awake()
    {
        // 确保MeshFilter和MeshRenderer组件已经附加到游戏对象上
        meshFilter = gameObject.GetComponent<MeshFilter>();
        if (meshFilter == null)
        {
            meshFilter = gameObject.AddComponent<MeshFilter>();
        }

        meshRenderer = gameObject.GetComponent<MeshRenderer>();
        if (meshRenderer == null)
        {
            meshRenderer = gameObject.AddComponent<MeshRenderer>();
        }

        // 创建网格
        mesh = new Mesh();
        meshFilter.mesh = mesh;
        meshRenderer.material = new Material(Shader.Find(shaderName));

        // 生成网格
        GenerateMesh();
    }
    private void GenerateMesh()
    {
        // 定义网格形状
        int numVertices = (segmentsX + 1) * (segmentsY + 1);
        int numTriangles = segmentsX * segmentsY * 2 * 3; // 2 * 3 = 6，一个矩形由两个三角形组成
        Vector3[] vertices = new Vector3[numVertices];
        Vector2[] uv = new Vector2[numVertices];
        int[] triangles = new int[numTriangles];

        for (int i = 0, y = 0; y <= segmentsY; y++)
        {
            for (int x = 0; x <= segmentsX; x++, i++)
            {
                vertices[i] = new Vector3((float)x / segmentsX, (float)y / segmentsY, 0f);
                uv[i] = new Vector2((float)x / segmentsX, (float)y / segmentsY);
            }
        }

        for (int ti = 0, vi = 0, y = 0; y < segmentsY; y++, vi++)
        {
            for (int x = 0; x < segmentsX; x++, ti += 6, vi++)
            {
                // 划分矩形为2个三角形
                triangles[ti] = vi;
                triangles[ti + 1] = vi + segmentsX + 1;
                triangles[ti + 2] = vi + 1;
                triangles[ti + 3] = vi + 1;
                triangles[ti + 4] = vi + segmentsX + 1;
                triangles[ti + 5] = vi + segmentsX + 2;
            }
        }

        // 更新网格
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }

    private void Update()
    {
        if (segmentsX > 0 && segmentsY > 0)
        {
            GenerateMesh();
        }
        else
        {
            Debug.LogError("细分数不能小于0");
        }

        if (saveMeshB)
        {
            SaveMesh("000000000");
            saveMeshB = false;
        }
        
    }

    // 保存网格
    
    private void SaveMesh(string meshName)
    {
        // 从GPU中读取修改后的顶点数据
        int numVertices = mesh.vertexCount;
        Vector3[] updatedVertices = new Vector3[numVertices];
        ComputeBuffer vertexBuffer = new ComputeBuffer(numVertices, 12);
        vertexBuffer.SetData(mesh.vertices);
        ComputeShader computeShader = CpuShader;
        computeShader.SetBuffer(0, "_VerticesBuffer", vertexBuffer);
        computeShader.SetInt("NumVertices", numVertices);
        computeShader.Dispatch(0, Mathf.CeilToInt(numVertices / 64f), 1, 1);
        vertexBuffer.GetData(updatedVertices);
        vertexBuffer.Release();

        // 应用修改后的顶点数据到保存的Mesh对象
        Mesh savedMesh = new Mesh();
        savedMesh.name = meshName;
        savedMesh.vertices = updatedVertices;
        savedMesh.uv = mesh.uv;
        savedMesh.triangles = mesh.triangles;
        savedMesh.RecalculateNormals();
        savedMesh.RecalculateBounds();

        // 保存为Asset或GameObject的Mesh对象
        AssetDatabase.CreateAsset(savedMesh, "Assets/Arts/" + meshName + ".asset");
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    
}