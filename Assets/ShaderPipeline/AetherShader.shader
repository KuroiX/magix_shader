Shader "CustomRenderTexture/AetherShader"
{
    Properties
    {
        _Aether("Aether", 2D) = "white" {}
        _AetherSizeX("AetherSizeX", int) = 7
        _AetherSizeY("AetherSizeY", int) = 2
    }
    SubShader
    {
         Lighting Off
        Blend One Zero

        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0
            
            sampler2D   _Aether;

            int         _AetherSizeX;
            int         _AetherSizeY;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float2 aetherSize = float2(1./_AetherSizeX, 1./_AetherSizeY);

                float2 coord = IN.localTexcoord.xy;
                
                return tex2D(_Aether, coord % aetherSize);
            }
            ENDCG
        }
    }
}
