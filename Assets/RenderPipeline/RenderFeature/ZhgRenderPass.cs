using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace OWL.Rendering.HRP
{
    public class ZhgRenderPass : ScriptableRenderPass
    {
        //标签名，用于FrameDebug中显示缓冲区名称
        private const string CommandBufferTag = "ZhgTestVolume";
        
        //用于后处理的材质，cmd.Bilt()方法需要调用的参数
        public Material ScreenMaterial;

        //将Volume中的参数传递给对应的shader
        private ZhgVolumeSetting m_zhgVolumeSetting;
        
        //颜色标识符，主纹理，结构体
        private RenderTargetIdentifier m_ColorAttachment;
        
        //临时的渲染目标，将RT缓存在这里
        private RenderTargetHandle m_TemporaryColorTexture;

        string passTag = "zhgVolume";
        
        //材质参数和其对应的动画曲线
        private List<string> materialProperties = new List<string>();
        private List<AnimationCurve> materialAnimations = new List<AnimationCurve>();
        private float animTime = 0.0f;
        private bool playAnim = false;
        private float animSpeed = 1.0f;

        private bool enableDebug = false;
        
        //调试模式
        public void EnableDebug(bool debug)
        {
            this.enableDebug = debug;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var stack = VolumeManager.instance.stack;//获取所有继承Volume框架的脚本

            m_zhgVolumeSetting = stack.GetComponent<ZhgVolumeSetting>();

            var cmd = CommandBufferPool.Get(CommandBufferTag);

            if (m_zhgVolumeSetting.IsActive() && !renderingData.cameraData.isSceneViewCamera)
            {
                if (materialProperties.Count != materialAnimations.Count )
                {
                    UnityEngine.Debug.LogWarning(materialProperties.Count+"--" + materialAnimations.Count+"材质属性和动画曲线数量不对应！");
                    return;
                }

                if (ScreenMaterial == null)
                {
                    Debug.LogWarning("后处理材质为空！");
                    return;
                }
                
                //ScreenMaterial.SetFloat("_Amount",m_zhgVolumeSetting.amount.value);

                if (!playAnim)
                {
                    animTime = 0;//重置动画时间
                }
                else
                {
                    animTime += Time.deltaTime;
                }

                if (!enableDebug)
                {
                    for (int i = 0; i < materialProperties.Count; i++)
                    {
                        ScreenMaterial.SetFloat(materialProperties[i],materialAnimations[i].Evaluate(animTime) * animSpeed);
                    }
                }

                //获取目标相机的详细信息结构体，里面包含RenderTexture、深度图等各种参数
                RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;

                //深度缓冲区用不上，所以设置成0
                opaqueDesc.depthBufferBits = 0;

                //根据源相机的RenderTexture，创建新的RT
                cmd.GetTemporaryRT(m_TemporaryColorTexture.id,opaqueDesc);
                
                //通过材质，将计算结果存入临时缓冲区
                cmd.Blit(m_ColorAttachment,m_TemporaryColorTexture.Identifier(),ScreenMaterial);
                
                //再从临时缓冲区存入目标纹理
                cmd.Blit(m_TemporaryColorTexture.Identifier(),m_ColorAttachment);
                
                //执行命令缓冲区
                context.ExecuteCommandBuffer(cmd);
                
                //释放命令缓冲区
                CommandBufferPool.Release(cmd);
                
                //释放临时RT
                //cmd.ReleaseTemporaryRT(m_TemporaryColorTexture.id);
                
            }
            
        }

        public void Setup(RenderTargetIdentifier colorAttachment,Material material,List<AnimationCurve> materialAnimations,List<string> materialProperties,bool EnablePlay,float animSpeed)
        {
            this.m_ColorAttachment = colorAttachment;
            this.ScreenMaterial = material;
            this.materialProperties = materialProperties;
            this.materialAnimations = materialAnimations;
            
            //播放一次动画
            this.playAnim = EnablePlay;

            this.animSpeed = animSpeed;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
        }
    }
}


