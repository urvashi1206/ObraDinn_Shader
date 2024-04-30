using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ImageEffect : MonoBehaviour
{
    [SerializeField]
    public DitherEffect effect;

    private void Awake()
    {
        effect.OnCreate();
    }


    // Used to edit render effect on the screen (be called every frame)
    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        effect.Render(src, dst);
    }
}
