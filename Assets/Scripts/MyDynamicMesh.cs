using System.Collections;
using UnityEditor;
using UnityEngine;

public class MyDynamicMesh : MonoBehaviour
    {
        private const string ShaderName = "Unlit/Saidao";
        private const string MeshName = "DynamicMesh";
        private const float MeshDepth = 0f;
        private Mesh _mesh;

        private MeshFilter _meshFilter;
        private MeshRenderer _meshRenderer;

        public ComputeShader computeShader;

        public float length = 1.0f;
        public bool saveMeshB = false;
        [Range(0, 1)] public float scale = 0.5f;
        [SerializeField] [Range(1, 20)] public int segmentsX = 4; // 分段数
        [SerializeField] [Range(1, 20)] public int segmentsY = 4; // 分段数

        private Vector3[] updatedVertices;
        private ComputeBuffer uvBuffer;
        private ComputeBuffer vertexBuffer;

        private void Awake()
        {
            // 确保MeshFilter和MeshRenderer组件已经附加到游戏对象上
            _meshFilter = gameObject.GetComponent<MeshFilter>();
            if (_meshFilter == null) _meshFilter = gameObject.AddComponent<MeshFilter>();

            _meshRenderer = gameObject.GetComponent<MeshRenderer>();
            if (_meshRenderer == null) _meshRenderer = gameObject.AddComponent<MeshRenderer>();

            // 创建网格
            _mesh = new Mesh();
            _meshFilter.mesh = _mesh;
            _meshRenderer.material = new Material(Shader.Find(ShaderName));

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
            for (int x = 0; x <= segmentsX; x++, i++)
            {
                vertices[i] = new Vector3((float)x / segmentsX, (float)y / segmentsY, 0f);
                uv[i] = new Vector2((float)x / segmentsX, (float)y / segmentsY);
            }

            for (int ti = 0, vi = 0, y = 0; y < segmentsY; y++, vi++)
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

            // 更新网格
            _mesh.Clear();
            _mesh.vertices = vertices;
            _mesh.uv = uv;
            _mesh.triangles = triangles;

            // 从GPU中读取修改后的顶点数据
            int meshNumVertices = vertices.Length;
            updatedVertices = new Vector3[meshNumVertices];
            vertexBuffer = new ComputeBuffer(meshNumVertices, 12);
            uvBuffer = new ComputeBuffer(meshNumVertices, 8);
            vertexBuffer.SetData(vertices);
            uvBuffer.SetData(_mesh.uv);
            computeShader.SetBuffer(0, "_VerticesBuffer", vertexBuffer);
            computeShader.SetBuffer(0, "_MeshUV", uvBuffer);
            computeShader.SetInt("NumVertices", meshNumVertices);
            computeShader.SetFloat("_Length", length);
            computeShader.SetFloat("_Scale", scale);
            computeShader.Dispatch(0, Mathf.CeilToInt(meshNumVertices / 64f), 1, 1);
            vertexBuffer.GetData(updatedVertices);
            vertexBuffer.Release();

            _mesh.vertices = updatedVertices;
            _mesh.RecalculateNormals();
            _mesh.RecalculateBounds();
        }

        private void Update()
        {
            GenerateMesh();

            if (saveMeshB)
            {
                SaveMesh("000000000");
                saveMeshB = false;
            }
        }

        // 保存网格

        private void SaveMesh(string MeshName)
        {
            // 应用修改后的顶点数据到保存的Mesh对象
            Mesh savedMesh = new Mesh();
            savedMesh.name = MeshName;
            savedMesh.vertices = updatedVertices;
            savedMesh.uv = _mesh.uv;
            savedMesh.triangles = _mesh.triangles;
            savedMesh.RecalculateNormals();
            savedMesh.RecalculateBounds();

            // 保存为Asset或GameObject的Mesh对象
            AssetDatabase.CreateAsset(savedMesh, "Assets/TA/TA_ZhgTest/Scripts/" + MeshName + ".asset");
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }
