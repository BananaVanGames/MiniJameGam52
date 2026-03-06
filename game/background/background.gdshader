shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float noise_strength = 0.25;
uniform float noise_scale = 0.5;

void fragment() {
    vec2 uv = UV * noise_scale;
    float noise = texture(noise_texture, uv).r;
    vec4 col = COLOR;
    col.rgb += (noise - 0.5) * noise_strength;

    COLOR = col;
}