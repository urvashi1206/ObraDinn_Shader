using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ShaderTransition : MonoBehaviour
{
    public float transitionTime = 2.0f;
    private float transitionDelay = 5.0f;
    private float timer = 0.0f;
    private bool Transition = false;
    /*[SerializeField]
    private DitherEffect effectBayer;
    [SerializeField]
    private DitherEffect effectBlue;*/
/*    public Material BayerNoise;
    public Material BlueNoise;*/

    private Camera cam;

    ImageEffect imageEffect;

    // A value to control 0-1 in the shader
    public float blendvalue;

    private void Awake()
    {
        imageEffect = GetComponent<ImageEffect>();
    }

    // Start is called before the first frame update
    void Start()
    {
        /*effectBayer.OnCreate();
        effectBlue.OnCreate();
        BayerNoise = effectBayer.baseMaterial;
        BlueNoise = effectBlue.baseMaterial;*/

        cam = GetComponent<Camera>();
        if (cam == null)
        {
            Debug.LogError("ShaderTransition script needs to be attached to a camera.");
            this.enabled = false;
        }

/*        // Start with the basic material
        SetMaterialOnCamera(BayerNoise);*/
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            Transition = true;
            Debug.Log("switch");
            imageEffect.SwitchPattern();

            timer += Time.deltaTime;
        }

        if (Input.GetKeyDown(KeyCode.T))
        {
            imageEffect.SwitchPattern(blendvalue);
        }
    }

    void SetMaterialOnCamera(Material material)
    {
        Debug.Log(material.mainTexture);
        cam.targetTexture = material.mainTexture as RenderTexture;
    }


    void LerpMaterialProperties(Material startMat, Material endMat, float lerpFactor)
    {
        Material tempMaterial = new Material(startMat.shader);
        tempMaterial.CopyPropertiesFromMaterial(startMat);
        tempMaterial.Lerp(startMat, endMat, lerpFactor);

        SetMaterialOnCamera(tempMaterial);
        Destroy(tempMaterial);
    }
}

