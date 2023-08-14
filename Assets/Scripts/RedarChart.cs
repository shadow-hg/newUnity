using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace com.yoozoo.gta
{
    /// <summary>
    /// 雷达图
    /// </summary>
    [RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
    public class RedarChart : MonoBehaviour
    {
        [Header("雷达图半径")]
        public float redarRadius = 1.0f;
        [Header("雷达材质")]
        public Material mat;
        [Header("雷达图参数值(逆时针，右上角是第一个)")]
        public List<float> redarValues = new List<float>();
        
        private Vector3 centerPoint;
        private List<Vector3> RedarVertexs;

        private MeshFilter _meshFilter;
        private MeshRenderer _meshRenderer;
        
        private void Awake()
        {
            Init();
        }

        private void Update()
        {
            CreateRedarMesh();
        }

        void Init()
        {
            _meshFilter = this.GetComponent<MeshFilter>();
            Mesh redarMesh = new Mesh();
            redarMesh.name = "RedarMesh";
            _meshFilter.mesh = redarMesh;
            _meshFilter.name = "redarMeshFilter";
            
            _meshRenderer = this.GetComponent<MeshRenderer>();
            _meshRenderer.material = mat;
            
            //生成的位置
            centerPoint = (Vector3)this.transform.position;
            centerPoint.z = 0;

            //根据位置确定六边形边界
            RedarVertexs = new List<Vector3>();
            for (int i = 0; i < 7; i++)
            {
                Vector3 RP = (new Vector3(Mathf.Cos(i * Mathf.PI / 3), Mathf.Sin(i * Mathf.PI / 3),0) + centerPoint);
                RedarVertexs.Add(RP);
                //Debug.Log("第" + i + "个:" + RP);
            }
            RedarVertexs[0] = centerPoint;
        }

        void CreateRedarMesh()
        {
            Vector3[] newRedarVertexs = new Vector3[7];
            for (int i = 0; i < 6; i++)
            {
                newRedarVertexs[i+1] = Vector3.Lerp(centerPoint,RedarVertexs[i+1],Mathf.Clamp01(redarValues[i])) * redarRadius;
                //Debug.LogWarning(newRedarVertexs[0]);
            }

            Mesh mesh = _meshFilter.mesh;
            mesh.Clear();
            
            mesh.vertices = newRedarVertexs.ToArray();
            mesh.uv = new[]
            {
                new Vector2(0.5f,0.5f),
                new Vector2(1,1),
                new Vector2(0,1),
                new Vector2(0,0.5f),
                new Vector2(0,0),
                new Vector2(1,0),
                new Vector2(1,0.5f)
            };
            mesh.triangles = new int[] 
            {
                1,2,0,
                2,3,0,
                3,4,0,
                4,5,0,
                5,6,0,
                6,1,0,
            };
            mesh.RecalculateNormals();

        }
    }
}