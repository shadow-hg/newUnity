using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature
{
    public enum Target
    {
        Color,
        Texture
    }
    
    [Serializable]
    public class Filters
    {
        public enum RenderQueue
        {
            Opaque = 2000,
            Transparent = 3000
        }
        
        public RenderQueue queue; 
        public LayerMask layerMask;
        public List<string> lightModeTags;

    }

    [Serializable]
    public class HlSettings
    {
        public Material mMat;
        public Target destination = Target.Color;
        public int passIndex = -1;

        public string textureId = "_MainTex";
        public float contrast = 0.5f;
    }

    public RenderPassEvent renderPassEvent;
    public HlSettings hlSettings;

    private RenderTargetHandle m_renderTargetHandle;
    
    //public Filters filters = new Filters();
    
    class CustomRenderPass : ScriptableRenderPass
    {
        private Material _mat;
        private string _profileName;
        private RenderPassEvent _renderPassEvent;
        private float _contrast;

        public FilterMode filterMode;
        public RenderTargetIdentifier Source { get;set; }
        public RenderTargetHandle Destination { get; set; }
        private RenderTargetHandle m_temporaryColorTexture;
        
        public CustomRenderPass(string passName,RenderPassEvent renderPassEvent,Material material,float contrast)
        {
            _profileName = passName;
            _renderPassEvent = renderPassEvent;
            _mat = material;
            _contrast = contrast;
            _mat.SetFloat("_clip",_contrast);
            m_temporaryColorTexture.Init("temporaryColorTexture");
        }
        
        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(_profileName);
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            if (Destination == RenderTargetHandle.CameraTarget)
            {
                cmd.GetTemporaryRT(m_temporaryColorTexture.id,opaqueDesc,filterMode);
                Blit(cmd,Source,m_temporaryColorTexture.Identifier(),_mat,);
            }
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(this.name,renderPassEvent,hlSettings.mMat,hlSettings.contrast);

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        
        m_renderTargetHandle.Init(hlSettings.textureId);
        
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var src = renderer.cameraColorTarget;
        var dest = hlSettings.destination == Target.Color ? RenderTargetHandle.CameraTarget : m_renderTargetHandle;

        if (hlSettings.mMat == null)
        {
            Debug.LogWarning("没有材质球");
            return;
        }
        m_ScriptablePass.Destination = dest;
        m_ScriptablePass.Source = src;

        renderer.EnqueuePass(m_ScriptablePass);
    }
}


