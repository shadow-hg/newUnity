using System.Collections;
using UnityEngine;

namespace com.yoozoo.gta
{
    public class CubeCreator : MonoBehaviour
    {
        public Material cubeMaterial;

        void Start()
        {
            // 创建一个游戏对象并添加MeshFilter和MeshRenderer组件
            GameObject cube = new GameObject("Cube");
            MeshFilter meshFilter = cube.AddComponent<MeshFilter>();
            MeshRenderer meshRenderer = cube.AddComponent<MeshRenderer>();

            // 创建一个立方体的顶点、法线和UV坐标
            Vector3[] vertices = {
                new Vector3(0f, 0f, 0f),
                new Vector3(1f, 0f, 0f),
                new Vector3(1f, 1f, 0f),
                new Vector3(0f, 1f, 0f),
                new Vector3(1f, 0f, 1f),
                new Vector3(1f, 1f, 1f),
                new Vector3(0f, 1f, 1f),
                new Vector3(0f, 0f, 1f)
            };

            Color[] colors =
            {
                Color.green,
                Color.blue,
                Color.cyan,
                Color.red,
                Color.white,
                Color.yellow,
                Color.blue,
                Color.cyan
            };

            int[] triangles = {
                0, 1, 2,  
                2, 3, 0,  
                4, 5, 6,  
                6, 7, 4,  
                0, 1, 4,  
                4, 7, 0,  
                2, 3, 6,  
                6, 5, 2,  
                0, 3, 6,  
                6, 7, 0,  
                1, 2, 5,  
                5, 4, 0   
            };
            int[] triangles2 = {
                0, 3, 2,  
                2, 1, 0,
                
                1, 2, 5,  
                5, 4, 1, 
                
                4, 5, 6,  
                6, 7, 4,  
                
                7, 6, 3,  
                3, 0, 7, 
                
                2, 3, 6,  
                6, 5, 2,  
                
                0, 1, 4,  
                4, 7, 0   
            };

            // 创建Mesh对象并设置顶点和三角形
            Mesh mesh = new Mesh();
            mesh.vertices = vertices;
            mesh.triangles = triangles2;
            mesh.colors = colors;
            mesh.RecalculateNormals();

            // 设置MeshFilter的Mesh
            meshFilter.mesh = mesh;

            // 设置MeshRenderer的材质
            meshRenderer.material = cubeMaterial;
        }
    }

}
