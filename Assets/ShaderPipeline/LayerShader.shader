Shader "CustomRenderTexture/LayerShader"
{
    Properties
    {
        _Heightmap("Heightmap", 2D) = "white" {}
        _Aether("Aether", 2D) = "white" {}
        _Pattern("Pattern", 2D) = "white" {}
        _Layer("Layer", int) = 1
        _PixelShiftDistance("PixelShiftDistance", int) = 1
        _AetherSizeX("AetherSizeX", int) = 7
        _AetherSizeY("AetherSizeY", int) = 2
    }
    
    CGINCLUDE

    
    
    ENDCG

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
            
            int         _AetherSizeX;
            int         _AetherSizeY;
            
            sampler2D   _Aether;
            sampler2D   _Pattern;

            bool is_limbo_pixel(float4 heightmapValue, uint shift)
            {
                const bool isShiftedAway = heightmapValue.x > 0;
                const bool hasNoShiftedFrom = shift == 0;
                return isShiftedAway && hasNoShiftedFrom;
            }

            int calculate_shift(uint amountOfLayers, float2 pixelPositionInAether)
            {
                int shift = 0;

                for(int i = amountOfLayers; i >= 1; i--)
                {
                    const float2 lookup = pixelPositionInAether + float2(i*_PixelShiftDistance*_Heightmap_TexelSize.x, 0);
                    
                    float4 nextColor = tex2D(_Heightmap, lookup);

                    if (abs(nextColor.x - (i * 1./amountOfLayers)) < 1./amountOfLayers)
                    {
                        shift = _PixelShiftDistance * i;
                        break;
                    }
                }

                return shift;
            }

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const float2 patternSize = float2(1./_AetherSizeX, 1./_AetherSizeY);

                const float aetherOffsetX = patternSize.x * _Layer;

                const float2 currentPositionInAether = float2((IN.localTexcoord.x % patternSize.x) + aetherOffsetX, IN.localTexcoord.y);

                float size = _Heightmap_TexelSize.x;

                int xShiftInPixels = 0;
                
                if (aetherOffsetX < IN.localTexcoord.x)
                {
                    // Can not be set dynamically as property because of loop unrolling
                    const int amountOfLayers = 20;
                    
                    xShiftInPixels += calculate_shift(amountOfLayers, currentPositionInAether);

                    const float lookupPositionXInAether = currentPositionInAether.x + xShiftInPixels * size;

                    const bool isInNextPattern = lookupPositionXInAether > aetherOffsetX + patternSize.x;

                    if (isInNextPattern)
                    {
                        const float2 shiftOriginPositionInAether = float2(lookupPositionXInAether - patternSize.x, IN.localTexcoord.y);

                        const int shiftOriginXShiftInPixels = calculate_shift(amountOfLayers, shiftOriginPositionInAether);                        
                        xShiftInPixels += shiftOriginXShiftInPixels;

                        const float4 shiftOriginHeightmapValue = tex2D(_Heightmap, shiftOriginPositionInAether + float2(size*shiftOriginXShiftInPixels, 0));
                        if (is_limbo_pixel(shiftOriginHeightmapValue, shiftOriginXShiftInPixels))
                        {
                            return tex2D(_Pattern, shiftOriginPositionInAether);
                        }
                    }

                    const float4 currentHeightmapValue = tex2D(_Heightmap, currentPositionInAether);
                    if (is_limbo_pixel(currentHeightmapValue, xShiftInPixels))
                    {
                        return tex2D(_Pattern, currentPositionInAether);
                    }
                }
                
                if (xShiftInPixels != 0)
                {
                    return tex2D(_Aether, currentPositionInAether + float2(xShiftInPixels*size, 0));
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