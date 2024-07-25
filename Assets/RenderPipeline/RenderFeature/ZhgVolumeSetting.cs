using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace OWL.Rendering.HRP
{
    [Serializable,VolumeComponentMenu("ZHG_Test/CustomZHG")]
    public class ZhgVolumeSetting : VolumeComponent,IPostProcessComponent
    {
        public FloatParameter amount = new FloatParameter(0,true);
        public bool IsActive()
        {
            return active;
        }

        public bool IsTileCompatible()
        {
            return false;
        }
    }
}

