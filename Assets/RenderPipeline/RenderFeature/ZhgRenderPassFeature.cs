using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ZhgRenderPassFeature : ScriptableRendererFeature
{
    //后处理Pass
    private ZhgRenderPass _zhgPostPass;

    public RenderPassEvent renderPassEvent;

    //根据shader生成的材质
    public Material _material = null;

    //材质参数和其对应的动画曲线
    public List<string> materialProperties = new List<string>();
    public List<AnimationCurve> materialAnimations = new List<AnimationCurve>();

    public bool enablePlay = false;
    public float animSpeed = 1.0f;
    public float animTimeLength = 1.0f;

    [Header("开启Debug模式，本面板参数失效，仅通过材质球面板参数调整")]
    public bool enableDebug = false;

    /// <summary>
    /// 激活进入RPG战斗的RenderFeature动画
    /// </summary>
    public void SetActiveScreenEffect(bool enablePlay)
    {
        this.enablePlay = enablePlay;
    }

    /// <summary>
    /// 获取动画时长
    /// </summary>
    /// <returns></returns>
    public float GetAnimationTimeLength()
    {
        return animTimeLength / animSpeed;
    }
    
    public override void Create()
    {
        _zhgPostPass = new ZhgRenderPass();

        _zhgPostPass.renderPassEvent = renderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (_material == null)
        {
            return;
        }

        //获取当前渲染相机的目标颜色
        var cameraColorTarget = renderer.cameraColorTarget;

        //设置调用后处理pass
        _zhgPostPass.Setup(cameraColorTarget, _material, materialAnimations, materialProperties, enablePlay, animSpeed);
        _zhgPostPass.EnableDebug(enableDebug);

        renderer.EnqueuePass(_zhgPostPass);
    }
}