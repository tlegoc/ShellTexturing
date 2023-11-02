Shader "Custom/ShellShader"
{
    Properties
    {
        _maxHeight("Max Height", Float) = 1.0
        _minHeight("Min Height", Float) = 1.0
        _density("Density", Float) = 100.0
        _planeCount("Plane count", Int) = 16
        _planeIndex("Plane index", Int) = -1
        _thickness("Thickness", Float) = 1.0
        _color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _baseColor("Base color", Color) = (0, 0, 0, 1)
        _seed("Seed", Int) = 0
        _PlaneHeightExp("Plane Height Exp", Float) = 2.0
        _InteractionTexture("Interaction Texture", 2D) = "black" {}
        _curvature("Curvature", Float) = 4.0
        _ambientOcclusionFactor("Ambient Occlusion Factor", Float) = 2.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }
        Pass
        {      
            Tags
            {
                "LightMode"="UniversalForward"
            }      
            Cull Off
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            // #pragma shader_feature _ALPHATEST_ON
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Assets/ShellCode.hlsl"
            
            ENDHLSL
        }
//        Pass
//        {      
//            Tags
//            {
//                "LightMode"="ShadowCaster"
//            }      
//            Cull off
//            ZTest LEqual
//            ZWrite On
//
//            HLSLPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//
//            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
//            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
//            #pragma multi_compile _ _SHADOWS_SOFT
//            // #pragma shader_feature _ALPHATEST_ON
//            #pragma multi_compile _ SHADOWS_SHADOWMASK
//            #define SHADOW_CASTER_PASS
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
//            #include "Assets/ShellCode.hlsl"
//            
//            ENDHLSL
//        }
    }
}