using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Scripts.EditorScripts
{
    public class LODTool : MonoBehaviour
    {
        // Start is called before the first frame update
        public bool disableLODToon = false;
        void Start()
        {
            
        }

        // Update is called once per frame
        void Update()
        {
            if (disableLODToon)
            {
                LODGroup lodGroup = GetComponent<LODGroup>();
                if (lodGroup)
                {
                    
                }
            }
        }
    }
}
