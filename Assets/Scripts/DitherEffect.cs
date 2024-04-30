using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Image Effects Ultra/Dither", order = 1)]
public class DitherEffect : ScriptableObject
{

    protected Material baseMaterial;

    //The texture of implement the bayer pattern
    [SerializeField]
    private Texture2D ditherTex1;
    [SerializeField]
    private Texture2D ditherTex2;

    //For color gradient ramp
    [SerializeField]
    private Texture2D rampTex;

    //Make texture scrolling
    [SerializeField]
    private bool useScrolling = false;

    //Point is for pixel style
    [SerializeField]
    private FilterMode filterMode = FilterMode.Point;

    // Find the Dither shader source.
    public void OnCreate(float blendValue)
    {
        // Create a new dither shader
        baseMaterial = new Material(Resources.Load<Shader>("Shaders/Dither"));
        // Set texture value in shader
        baseMaterial.SetTexture("_NoiseTex1", ditherTex1);
        baseMaterial.SetTexture("_NoiseTex2", ditherTex2);

        baseMaterial.SetFloat("_Blend", blendValue);

        baseMaterial.SetTexture("_ColorRampTex", rampTex);
    }

    public void Render(RenderTexture src, RenderTexture dst)
    {
        var xOffset = 0.0f;
        var yOffset = 0.0f;

        if (useScrolling)
        {
            var camEuler = Camera.main.transform.eulerAngles;
            xOffset = 4.0f * camEuler.y / Camera.main.fieldOfView;
            yOffset = -2.0f * Camera.main.aspect * camEuler.x / Camera.main.fieldOfView;
        }

        //Used to change the position/offsets of the texture
        baseMaterial.SetFloat("_XOffset", xOffset);
        baseMaterial.SetFloat("_YOffset", yOffset);


        // Super Sampling
        // Less noisy
        // Get temp texture
        RenderTexture super = RenderTexture.GetTemporary(src.width * 2, src.height * 2);
        RenderTexture half = RenderTexture.GetTemporary(src.width / 2, src.height / 2);

        super.filterMode = filterMode;
        half.filterMode = filterMode;

        // Copy texture
        Graphics.Blit(src, super);
        Graphics.Blit(super, half, baseMaterial);
        Graphics.Blit(half, dst);

        // Release temp texture
        RenderTexture.ReleaseTemporary(half);
        RenderTexture.ReleaseTemporary(super);
    }
}
