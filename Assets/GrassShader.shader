Shader "Custom/GrassShader"
{
    Properties
    {
        _grassMaxHeight("Grass Max Height", Float) = 1.0
        _grassMinHeight("Grass Min Height", Float) = 1.0
        _density("Density", Float) = 100.0
        _planeCount("Plane count", Int) = 16
        _planeIndex("Plane index", Int) = -1
        _thickness("Thickness", Float) = 1.0
        _color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _baseColor("Base color", Color) = (0, 0, 0, 1)
        _seed("Seed", Int) = 0
        _InteractionTexture("Interaction Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
        }
        Pass
        {
            Cull off
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma shader_feature _ALPHATEST_ON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            TEXTURE2D(_InteractionTexture);
            SAMPLER(sampler_InteractionTexture);

            // Parameters
            // If you don't use CBUFFER_START all materials will use the same parameter, usually the last
            // material.Set[TYPE] call
            CBUFFER_START(UnityPerMaterial)
            float _grassMaxHeight;
            float _grassMinHeight;
            float _density;
            int _planeCount;
            int _planeIndex;
            float _thickness;
            float4 _color;
            float4 _baseColor;
            int _seed;
            float4 _InteractionTexture_ST;
            CBUFFER_END

            // Stolen shamelessly from https://github.com/GarrettGunnell/Shell-Texturing/blob/main/Assets/Shell.shader#L63
            // Which was itself stolen from Hugo Elias
            float hash(uint n)
            {
                n = (n << 13U) ^ n;
                n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
                return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
            }

            Varyings vert(Attributes IN)
            {
                float normalizedHeight = (float)_planeIndex / (float)_planeCount;

                IN.positionOS.xyz += IN.normalOS * _grassMaxHeight * normalizedHeight;

                Varyings output;

                output.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                output.uv = TRANSFORM_TEX(IN.uv, _InteractionTexture);
                output.positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                return output;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // SAMPLE_TEXTURE2D(_InteractionTexture, sampler_InteractionTexture, IN.uv);
                
                float2 scaledUVs = IN.uv * _density;
                uint2 id = scaledUVs;
                uint s = _seed + id.x + _density * id.y;

                float2 localUV = frac(scaledUVs) * 2 - 1;
                float distToCenter = length(localUV);
                float rand = hash(s);
                float height = lerp(_grassMinHeight, _grassMaxHeight, rand);
                float normPlaneHeight = (float)_planeIndex / (float)_planeCount;
                float planeHeight = normPlaneHeight * _grassMaxHeight;
                float p = (planeHeight / height);
                if (height < planeHeight || distToCenter > _thickness * (1 - p * p * p)) discard;

                float4 shadowCoord = TransformWorldToShadowCoord(TransformObjectToWorld(IN.positionWS.xyz));
                Light mainLight = GetMainLight(shadowCoord);

                return half4(lerp(_baseColor.rgb, _color.rgb, normPlaneHeight) * mainLight.shadowAttenuation, 1.0);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}