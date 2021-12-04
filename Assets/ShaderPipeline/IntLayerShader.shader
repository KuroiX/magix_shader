Shader "CustomRenderTexture/IntLayerShader"
{
    Properties
    {
        _Heightmap("Heightmap", 2D) = "white" {}
        _Aether("Aether", 2D) = "white" {}
        _Pattern("Pattern", 2D) = "white" {}
        _Layer("Layer", int) = 1
        _PixelShiftDistance("PixelShiftDistance", int) = 1
        _PatternSizeX("PatternSizeX", int) = 7
        _PatternSizeY("PatternSizeY", int) = 2
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
            sampler2D   _Heightmap;
            float4      _Heightmap_TexelSize;

            int         _Layer;
            int         _PixelShiftDistance;
            
            int         _PatternSizeX;
            int         _PatternSizeY;
            
            sampler2D   _Aether;
            sampler2D   _Pattern;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                // Can not be set dynamically as property because of loop unrolling
                const uint amountOfLayers = 20;

                float2 coord = IN.localTexcoord.xy;
                float2 size = _Heightmap_TexelSize.zw;

                const uint2 pixelCoord = floor(coord * size + float2(0.5, 0.5));

                //if (pixelCoord.x == 360)
                {
                    //return float4(1, 0, 0, 1);
                }

                const uint2 patternSize = floor(float2(1./_PatternSizeX, 1./_PatternSizeY) * size + float2(0.5, 0.5));

                uint xShift = 0;
                bool yShift = false;
                
                uint xOffset = pixelCoord.x % patternSize.x;

                uint iterationOffset = patternSize.x * _Layer;
                uint currentX = xOffset + iterationOffset;

                
                
                if (iterationOffset <= pixelCoord.x)
                {
                    uint currentShift = 0;

                    for(uint i = amountOfLayers; i >= 1; i--)
                    {
                        const uint pixelShift = i * _PixelShiftDistance;
                        const uint2 lookUpCoord = int2(currentX, pixelCoord.y) + int2(pixelShift, 0);
                        
                        float4 nextColor = tex2D(_Heightmap, float2(lookUpCoord) * _Heightmap_TexelSize.xy);

                        if (abs(nextColor.x - (i * 1./amountOfLayers)) < 1./amountOfLayers)
                        {
                            currentShift = pixelShift;
                            //return float4(1, 0, 0, 1);
                            break;
                        }
                    }
                    //return float4(0, 1, 0, 1);

                    xShift += currentShift;
                    

                    float4 currentColor = tex2D(_Heightmap, float2(currentX, pixelCoord.y));
                    const bool isShiftedAway = currentColor.x > 0;
                    const bool hasNoShiftedFrom = xShift == 0;
                    yShift = isShiftedAway && hasNoShiftedFrom;

                    if (isShiftedAway)
                    {
                        //return float4(1, 1, 1, 1);
                    }
                    if (yShift)
                    {
                        //return float4(0, 1, 0, 1);
                    }

                    //if (abs(xOffset) < 0.01)
                        //return float4(0, 0, 1, 1);

                    if (hasNoShiftedFrom)
                    {
                        //return float4(1, 0, 0, 1);
                    }

                    if (xShift > 0)
                    {
                        //return float4(1, 0, 1, 1);
                    }

                }

                if (yShift)
                {
                    //return tex2D(_Pattern, float2(currentX, pixelCoord.y) * _Heightmap_TexelSize.xy);
                }
                
                if (xShift > 0)
                {
                    return tex2D(_Aether, float2(currentX + xShift, pixelCoord.y) * _Heightmap_TexelSize.xy);
                }
                else
                {
                    return tex2D(_Aether, IN.localTexcoord.xy);
                }
               
            }
            ENDCG
        }
    }
}