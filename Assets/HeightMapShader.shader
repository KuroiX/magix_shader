Shader "CustomRenderTexture/Simple"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Tex("InputTex", 2D) = "white" {}
        _Aether("Aether", 2D) = "white" {}
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

            float4      _Color;
            sampler2D   _Tex;
            float4      _Tex_TexelSize;
            
            sampler2D   _Aether;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                float2 aetherSize = float2(1./7, 1./2);
                int pixelShift = 3;
                int amountOfLayers = 2;

                float2 coord = IN.localTexcoord.xy;
                float size = _Tex_TexelSize.x;

                float4 currentColor;
                float xShift = 0;
                float yShift = 0;
                
                float xOffset = coord.x % aetherSize.x;

                int currentIteration = 1;
                float iterationOffset = aetherSize.x * (float)currentIteration;

                int count = 0;
                int shiftedPixel = 0;
                
                while (iterationOffset < coord.x)
                {
                    float currentX = xOffset + iterationOffset;

                    int currentShift = 0;
                    

                    for(int i = 1; i <= amountOfLayers; i++)
                    {
                        float4 nextColor = tex2D(_Tex, float2(currentX, coord.y) + float2(i*pixelShift*size, 0));

                        if (abs(nextColor.x - (i * 1./amountOfLayers)) < 0.01)
                        {
                            currentShift = pixelShift * i;
                            shiftedPixel = i;
                        }
                    }

                    xShift += currentShift;

                    currentIteration++;
                    iterationOffset += aetherSize.x;
                    if(currentIteration > 8)
                        break;

                    currentColor = tex2D(_Tex, IN.localTexcoord.xy);
                    const bool isShiftedAway = currentColor.x > 0;
                    const bool hasNoShiftedFrom = currentShift == 0;
                    if (isShiftedAway)
                    {
                        count++;
                        //return currentColor;
                    }
                }

                if (count > 1)
                {
                    //return float4(1, 0, 0, 1);
                }
                
                
                return tex2D(_Aether, (coord + float2(xShift*size, 0)) % aetherSize + yShift);
            }
            ENDCG
        }
    }
}