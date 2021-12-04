Shader "Custom/ShadowCaster"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        // Pass to render object as a shadow caster, required to write to depth texture
         Pass 
         {
             Name "ShadowCaster"
             Tags { "LightMode" = "ShadowCaster" "RenderType"="Opaque" }
             
             Fog {Mode Off}
             ZWrite On ZTest LEqual Cull Off
             Offset 1, 1
 
             CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
             #pragma multi_compile_shadowcaster
             #include "UnityCG.cginc"
 
             struct v2f 
             { 
                 V2F_SHADOW_CASTER;
             };
 
             v2f vert( appdata_base v )
             {
                 v2f o;
                 TRANSFER_SHADOW_CASTER(o)
                 return o;
             }
 
             float4 frag( v2f i ) : SV_Target
             {
                 SHADOW_CASTER_FRAGMENT(i)
             }
             ENDCG
 
         }
    }
    FallBack "Diffuse"
}
