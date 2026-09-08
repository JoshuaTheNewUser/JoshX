// SPDX-FileCopyrightText: Copyright 2026 Eden Emulator Project
// SPDX-License-Identifier: GPL-3.0-or-later

texture BackBufferTex : COLOR;
sampler BackBuffer { Texture = BackBufferTex; };

uniform float Radius <
    ui_type = "slider";
    ui_label = "Radius";
    ui_tooltip = "How far the blur reaches, in pixels.";
    ui_min = 1.0; ui_max = 12.0; ui_step = 0.5;
> = 4.0;

uniform float Strength <
    ui_type = "slider";
    ui_label = "Strength";
    ui_tooltip = "Blend between the original image and the blurred one.";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
> = 1.0;

uniform float FocusSize <
    ui_type = "slider";
    ui_label = "Sharp Centre";
    ui_tooltip = "Size of the region left in focus at the centre of the screen. At zero the whole image is blurred evenly.";
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.05;
> = 0.0;

uniform float FocusSoftness <
    ui_type = "slider";
    ui_label = "Focus Falloff";
    ui_tooltip = "How gradually the sharp centre gives way to the blur.";
    ui_min = 0.05; ui_max = 1.0; ui_step = 0.05;
> = 0.4;

static const int TAPS = 17;
static const float3 KERNEL[17] = {
    float3( 0.171499,  0.000000, 0.942873),
    float3(-0.219031,  0.200651, 0.838223),
    float3( 0.033526, -0.382014, 0.745189),
    float3( 0.276075,  0.360090, 0.662480),
    float3(-0.506631, -0.089616, 0.588951),
    float3( 0.479925, -0.305289, 0.523583),
    float3(-0.160526,  0.597147, 0.465471),
    float3(-0.306140, -0.589453, 0.413808),
    float3( 0.664200,  0.242565, 0.367879),
    float3(-0.690990,  0.285231, 0.327048),
    float3( 0.333103, -0.711821, 0.290749),
    float3( 0.246154,  0.784779, 0.258479),
    float3(-0.741912, -0.429953, 0.229790),
    float3( 0.870348, -0.191344, 0.204286),
    float3(-0.531160,  0.755520, 0.181612),
    float3(-0.122710, -0.946946, 0.161455),
    float3( 0.753320,  0.634899, 0.143535)
};

void VS_PostProcess(in uint id : SV_VertexID, out float4 pos : SV_Position, out float2 uv : TEXCOORD)
{
    uv = float2(0.0, 0.0);
    if (id == 2)
    {
        uv.x = 2.0;
    }
    if (id == 1)
    {
        uv.y = 2.0;
    }
    pos = float4(uv * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

float4 PS_Blur(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float2 texel = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float3 original = tex2D(BackBuffer, uv).rgb;

    float2 centred = (uv - 0.5) * float2(BUFFER_WIDTH * BUFFER_RCP_HEIGHT, 1.0) * 2.0;
    float distance_from_centre = length(centred);
    float no_focus = 1.0 - step(0.001, FocusSize);
    float focus = max(smoothstep(FocusSize, FocusSize + FocusSoftness, distance_from_centre), no_focus);
    float amount = Strength * focus;

    float angle = frac(sin(dot(pos.xy, float2(12.9898, 78.233))) * 43758.5453) * 6.2831853;
    float2 rotation = float2(cos(angle), sin(angle));

    float3 sum = float3(0.0, 0.0, 0.0);
    float total = 0.0;
    for (int i = 0; i < TAPS; ++i)
    {
        float3 tap = KERNEL[i];
        float2 spun = float2(tap.x * rotation.x - tap.y * rotation.y,
                             tap.x * rotation.y + tap.y * rotation.x);
        sum += tex2D(BackBuffer, uv + spun * texel * Radius).rgb * tap.z;
        total += tap.z;
    }

    float3 blurred = sum / total;
    return float4(lerp(original, blurred, amount), 1.0);
}

technique Blur <
    ui_label = "Blur";
    ui_tooltip = "Gaussian blur with an optional sharp centre, for softening the picture or faking depth of field.";
>
{
    pass
    {
        VertexShader = VS_PostProcess;
        PixelShader = PS_Blur;
    }
}
