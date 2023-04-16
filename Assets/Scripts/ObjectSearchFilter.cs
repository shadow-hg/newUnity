using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.yoozoo.gta.Art
{
    public class ObjectSearchFilter
    {
        [Header("该范围区间数量")] public int lowCountNum = 0;
        [Header("数量汇总")] public List<GameObject> lowCount;

#if UNITY_EDITOR
        public void BeginGetLowMesh(GameObject obj, int min, int max, int Fun, List<Shader> shaders)
        {
            if (Fun == 0)
            {
                lowCount = new List<GameObject>();
                lowCount.Clear();

                foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
                {
                    var meshFilter = lowMesh.GetComponent<MeshFilter>();
                    if (meshFilter)
                    {
                        if (meshFilter.sharedMesh.vertexCount > min && meshFilter.sharedMesh.vertexCount <= max)
                        {
                            lowCount.Add(lowMesh.gameObject);
                        }
                    }
                }

                lowCountNum = lowCount.Count;
            }

            if (Fun == 1)
            {
                lowCount = new List<GameObject>();
                lowCount.Clear();

                foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
                {
                    var meshFilter = lowMesh.GetComponent<MeshFilter>();
                    if (meshFilter)
                    {
                        if (meshFilter.sharedMesh.triangles.Length > min &&
                            meshFilter.sharedMesh.triangles.Length <= max)
                        {
                            lowCount.Add(lowMesh.gameObject);
                        }
                    }
                }

                lowCountNum = lowCount.Count;
            }

            if (Fun == 2)
            {
                lowCount = new List<GameObject>();
                lowCount.Clear();

                foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
                {
                    var meshFilter = lowMesh.GetComponent<MeshFilter>();
                    if (meshFilter)
                    {
                        if (min > 0)
                        {
                            if (meshFilter.sharedMesh.subMeshCount >= min && meshFilter.sharedMesh.subMeshCount <= max)
                            {
                                lowCount.Add(lowMesh.gameObject);
                            }
                        }
                        else
                        {
                            UnityEngine.Debug.LogWarning("————————————超级低模查找器：最小值不能小于'1'————————————");
                        }
                    }
                }

                lowCountNum = lowCount.Count;
            }

            if (Fun >= 3 && Fun <= 6 && shaders.Count != 0 && shaders != null)
            {
                lowCount = new List<GameObject>();
                lowCount.Clear();

                foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
                {
                    var meshRender = lowMesh.GetComponent<MeshRenderer>();
                    if (meshRender && meshRender.sharedMaterial)
                    {
                        foreach (var material in meshRender.sharedMaterials)
                        {
                            foreach (var shader in shaders)
                            {
                                if (material.shader == shader)
                                {
                                    lowCount.Add(lowMesh.gameObject);
                                }
                            }
                        }
                    }
                }

                lowCountNum = lowCount.Count;
            }
        }

        public void FindObjByMaterial(GameObject obj,Material customMat)
        {
            lowCount = new List<GameObject>();
            lowCount.Clear();

            foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
            {
                var meshRender = lowMesh.GetComponent<MeshRenderer>();
                if (meshRender && meshRender.sharedMaterial)
                {
                    foreach (var material in meshRender.sharedMaterials)
                    {
                        if (material == customMat)
                        {
                            lowCount.Add(lowMesh.gameObject);
                        }
                    }
                }
            }

            lowCountNum = lowCount.Count;
        }

        public void FindObjByMesh(GameObject obj, Mesh customMesh)
        {
            lowCount = new List<GameObject>();
            lowCount.Clear();

            foreach (var lowMesh in obj.GetComponentsInChildren<Transform>())
            {
                var meshFilter = lowMesh.GetComponent<MeshFilter>();
                if (meshFilter && meshFilter.sharedMesh)
                {
                    if (meshFilter.sharedMesh == customMesh)
                    {
                        lowCount.Add(lowMesh.gameObject);
                    }
                }
            }

            lowCountNum = lowCount.Count;
        }

        public void ClearAll()
        {
            if (lowCount.Count > 0)
            {
                lowCount.Clear();
                lowCountNum = 0;
            }
        }

#endif
    }
}