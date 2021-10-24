float4 _Color;
samplerCUBE _RefractTex;
samplerCUBE ReflectionCube;
half _ReflectionStrength;
half _ReflectionMultiply;
half _EnvironmentLight;
sampler2D _BackgroundTex_;
sampler2D _GrabTexture;

float _BackFrontOpasity;
float _Dispersion;
float _DispersionPower;
float _Brightness;
float _ReflectionMultiplyFront;
float _MaxLightRefract;
float _MinLightRefract;
float4 bgcolorArray[10];
float Saturation;
float Saturation2;
float Contrast;
float4 XColor;
float _Range;
float DiamondPower;
//float _XColorToggle;




float Remap(float value, float min1, float max1, float min2, float max2)
{
    return (min2 + (value - min1) * (max2 - min2) / (max1 - min1));
}




half rgb2hsv(half3 c)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
    half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return abs(q.z + (q.w - q.y) / (6.0 * d + e));
}





uint rand(int rng_state)
{
						// Xorshift algorithm from George Marsaglia's paper
    rng_state ^= (rng_state << 13);
    rng_state ^= (rng_state >> 17);
    rng_state ^= (rng_state << 5);
    rng_state ^= (rng_state << 9);
    rng_state ^= (rng_state >> 28);
    rng_state ^= (rng_state << 3);
    rng_state ^= (rng_state << 6);
    rng_state ^= (rng_state >> 15);
    rng_state ^= (rng_state << 11);
    return rng_state;
}





float4 DisaturateColor(float4 ColorValue, float4 _XColor, float Disaturate, float Range)
{
    half ColorValueDisaturate = dot(clamp(ColorValue, 0, 1), float4(0.299, 0.587, 0.114, 0.114) / 1);

    float distColor = 1;

    distColor = distance(rgb2hsv(ColorValue.rgb), rgb2hsv(_XColor.rgb));

    if (distColor > 0.5)
    {
        distColor = 1 - distColor;
    }

    if (distColor > 0.1)
    {
        distColor = distColor * Disaturate;
    }

    distColor = Remap(distColor, 0, 0.5, 1, 0);

    distColor = pow(clamp(distColor, 0, 1), Range);

    return lerp(ColorValue, float4(ColorValueDisaturate.xxx, ColorValue.a), distColor);

}



float4 Overlay(float4 blend1, float4 blend2, float _Alpha)
{
    float4 lerpBlend = clamp(lerp(blend1, (1.0 - ((1.0 - blend1) / max(blend2, 0.00001))), _Alpha), 0, 1);
    return lerpBlend;
}





float Overlay2(float blend1, float blend2, float _Alpha)
{
    float lerpBlend = clamp(lerp(blend1, (1.0 - ((1.0 - blend1) / max(blend2, 0.00001))), _Alpha), 0, 1);
    return lerpBlend;
}