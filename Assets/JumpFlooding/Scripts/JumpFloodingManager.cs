using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace JumpFlooding
{
    public sealed class JumpFloodingManager : MonoBehaviour
    {
        [SerializeField] Material material;
        [SerializeField] Camera camera;
        [SerializeField] Texture input;
        [SerializeField] RenderTexture output;

        CommandBuffer commandBuffer;

        static readonly int StepLength = Shader.PropertyToID("_StepLength");
        static readonly int RT0 = Shader.PropertyToID("_JFA0");
        static readonly int RT1 = Shader.PropertyToID("_JFA1");

        void Awake()
        {
            var width = input.width;
            var height = input.height;
            commandBuffer = new CommandBuffer();
            commandBuffer.GetTemporaryRT(RT0, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
            commandBuffer.GetTemporaryRT(RT1, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
            commandBuffer.SetGlobalInt(StepLength, 128);
            commandBuffer.Blit(input, RT0, material, 0);
            commandBuffer.SetGlobalInt(StepLength, 64);
            commandBuffer.Blit(RT0, RT1, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 32);
            commandBuffer.Blit(RT1, RT0, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 16);
            commandBuffer.Blit(RT0, RT1, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 8);
            commandBuffer.Blit(RT1, RT0, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 4);
            commandBuffer.Blit(RT0, RT1, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 2);
            commandBuffer.Blit(RT1, RT0, material, 1);
            commandBuffer.SetGlobalInt(StepLength, 1);
            commandBuffer.Blit(RT0, RT1, material, 1);
            commandBuffer.SetGlobalTexture("_InputTex", input);
            commandBuffer.Blit(RT1, output, material, 2);
            commandBuffer.ReleaseTemporaryRT(RT0);
            commandBuffer.ReleaseTemporaryRT(RT1);
        }

        void OnEnable()
        {
            camera.AddCommandBuffer(CameraEvent.AfterEverything, commandBuffer);
        }

        void OnDisable()
        {
            if (camera != null)
            {
                camera.RemoveCommandBuffer(CameraEvent.AfterEverything, commandBuffer);
            }
        }

        void OnDestroy()
        {
            commandBuffer?.Dispose();
        }
    }
}
