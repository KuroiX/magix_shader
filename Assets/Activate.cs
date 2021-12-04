using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Activate : MonoBehaviour
{
    public Shader shader;
    
    private void Awake()
    {
        Camera camera = GetComponent<Camera>();

        //camera.depthTextureMode = DepthTextureMode.Depth;
        //camera.SetReplacementShader(shader, "");
    }
}
