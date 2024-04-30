using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ImageEffect : MonoBehaviour
{
    [SerializeField]
    public DitherEffect effect;


    public DitherEffect blueNoise;
    public DitherEffect bayerNoise;

    private void Awake()
    {
        effect.OnCreate();
    }


    // Used to edit render effect on the screen (be called every frame)
    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        effect.Render(src, dst);
    }

    public void SwitchPattern()
    {
        if(effect == blueNoise)
        {
            effect = bayerNoise;
            effect.OnCreate();
            Debug.Log("Switch to bayer ");
        }
        else
        {
            effect = blueNoise;
            effect.OnCreate();
            Debug.Log("Switch to blue noise ");
        }
    }
}
