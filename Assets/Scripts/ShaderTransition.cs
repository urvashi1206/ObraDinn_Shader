using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ShaderTransition : MonoBehaviour
{
    /*    public float transitionTime = 2.0f;
        private float transitionDelay = 5.0f;
        private float timer = 0.0f;
        private bool Transition = false;*/
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

    // Set time
    public float transitionTime = 5.0f;
    private bool startTransition = false;

    private bool isAscent = true;


    private void Awake()
    {
        imageEffect = GetComponent<ImageEffect>();
    }

    // Start is called before the first frame update
    void Start()
    {
/*        cam = GetComponent<Camera>();
        if (cam == null)
        {
            Debug.LogError("ShaderTransition script needs to be attached to a camera.");
            this.enabled = false;
        }*/
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            if (!startTransition)
            {
                //blendvalue = 0.0f;
                startTransition = true;
                Debug.Log("Start Transitioning");
            }
            //imageEffect.SwitchPattern(blendvalue);
        }

        if (startTransition)
        {
            if (blendvalue <= 1.0f && blendvalue >= 0)
            {
                if(isAscent)
                {
                    blendvalue += Time.deltaTime / transitionTime;
                    //Debug.Log("Ascent");
                }
                else
                {
                    blendvalue -= Time.deltaTime / transitionTime;
                    //Debug.Log("Descent");
                }
            }
            else if(blendvalue > 1.0f)
            {
                blendvalue = 1.0f;
                isAscent = false;
                startTransition = false;
            }
            else if (blendvalue < 0.0f)
            {
                blendvalue = 0.0f;
                isAscent = true;
                startTransition = false;
            }

            imageEffect.SwitchPattern(blendvalue);
        }
    }

/*    void SetMaterialOnCamera(Material material)
    {
        Debug.Log(material.mainTexture);
        cam.targetTexture = material.mainTexture as RenderTexture;
    }
*/

/*    void LerpMaterialProperties(Material startMat, Material endMat, float lerpFactor)
    {
        Material tempMaterial = new Material(startMat.shader);
        tempMaterial.CopyPropertiesFromMaterial(startMat);
        tempMaterial.Lerp(startMat, endMat, lerpFactor);

        SetMaterialOnCamera(tempMaterial);
        Destroy(tempMaterial);
    }*/
}

