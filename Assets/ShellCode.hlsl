//
// Code is shared between ShadowCaster pass and Forward pass
//

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : INTERP1;
    float3 normalWS : NORMAL;
    float2 uv : TEXCOORD0;
};

TEXTURE2D(_InteractionTexture);
SAMPLER(sampler_InteractionTexture);

// Parameters
CBUFFER_START(UnityPerMaterial)
float _maxHeight;
float _minHeight;
float _density;
int _planeCount;
int _planeIndex;
float _thickness;
float4 _color;
float4 _baseColor;
int _seed;
float4 _InteractionTexture_ST;
float _PlaneHeightExp;
float _curvature;
float _ambientOcclusionFactor;
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

    float normalizedExpHeight = 1 - pow(1 - normalizedHeight, _PlaneHeightExp);

    IN.positionOS.xyz += IN.normalOS * _maxHeight * normalizedExpHeight;

    Varyings output;

    output.normalWS = TransformObjectToWorldNormal(IN.normalOS, true);
    output.uv = TRANSFORM_TEX(IN.uv, _InteractionTexture);
    output.positionWS = TransformObjectToWorld(IN.positionOS.xyz);

    output.positionWS += pow(_maxHeight * normalizedExpHeight, _curvature) * float3(0, -1, 0);
    output.positionCS = TransformWorldToHClip(output.positionWS.xyz);

    return output;
}

float4 frag(Varyings IN) : SV_Target
{
    // SAMPLE_TEXTURE2D(_InteractionTexture, sampler_InteractionTexture, IN.uv);
    float2 scaledUVs = IN.uv * _density;
    uint2 id = scaledUVs;
    uint s = _seed * id.x + _density * id.y;

    float2 localUV = frac(scaledUVs) * 2 - 1;
    // In order to make the grass less "flat", we add a random offset to the center
    float offset_x =  hash(s + 10000) * 2 - 1;
    float offset_y =  hash(s + 30000) * 2 - 1;
    float distToCenter = length(localUV + float2(offset_x, offset_y));
    // float distToCenter = length(localUV);
    float rand = hash(s);
    float bladeHeight = lerp(_minHeight, _maxHeight, rand);
    
    float normalizedHeight = (float)_planeIndex / (float)_planeCount;
    float normalizedExpHeight = 1 - pow(1 - normalizedHeight, _PlaneHeightExp);
    
    float planeHeight = normalizedExpHeight * _maxHeight;
    float p = (planeHeight / bladeHeight);

    if (bladeHeight < planeHeight || distToCenter > _thickness * (1 - p * p * p)) discard;

    #ifndef SHADOW_CASTER_PASS
    float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS.xyz);
    Light mainLight = GetMainLight(shadowCoord);

    float ndotl = dot(IN.normalWS, mainLight.direction) * 0.5 + 0.5;
    ndotl = ndotl * ndotl;

    float ao = pow(p, _ambientOcclusionFactor);
    #endif

    #ifndef SHADOW_CASTER_PASS
    // We clamp the shadow attenuation to avoid having too dark grass
    // This could be solved by taking ambient light into account
    return float4(lerp(_baseColor.rgb, _color.rgb, p) * clamp(mainLight.shadowAttenuation, .1, 1.0) * mainLight.color * ndotl * ao, 1.0);
    // return float4(ndotl.xxx, 1.0);
    #else
    return (0).xxxx;
    #endif
}
