#include <metal_stdlib>
using namespace metal;

/// Duotone terrain for the map hero. Colours arrive from DesignTokens.
[[ stitchable ]] half4 planeTable(float2 position, half4 color, float time, half4 paper, half4 ground, half4 mark) {
    float2 uv = position / 280.0;
    float ridge = sin(uv.x * 5.5 + time * 0.12) * 0.5 + 0.5;
    float band = smoothstep(0.25, 0.75, sin(uv.y * 9.0 + ridge * 2.0));
    half4 base = mix(paper, ground, half(band));
    float spark = smoothstep(0.62, 0.7, sin(uv.x * 2.4 + uv.y * 1.3 + time * 0.18));
    return mix(base, mark, half(spark * 0.22));
}
