shader_type spatial;
render_mode unshaded, cull_front;
uniform vec4 outline_color : source_color = vec4(1.0,0.79,0.30,1.0);
// The old 12 mm LOCAL expansion inherited every asset/placement scale.
// Bound the shell in metres and pixels so small stems retain their shape.
uniform float outline_width_m : hint_range(0.0, 0.005, 0.0005) = 0.002;
uniform float outline_width_px : hint_range(0.0, 3.0, 0.25) = 2.0;
void vertex() {
	vec3 view_vertex = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 view_normal = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	vec4 original_clip = PROJECTION_MATRIX * vec4(view_vertex, 1.0);
	vec4 shell_clip = PROJECTION_MATRIX * vec4(view_vertex + view_normal * outline_width_m, 1.0);
	if (original_clip.w > 0.0001 && shell_clip.w > 0.0001) {
		vec2 pixel_delta = (shell_clip.xy / shell_clip.w - original_clip.xy / original_clip.w) * VIEWPORT_SIZE * 0.5;
		float blend = min(1.0, outline_width_px / max(length(pixel_delta), 0.0001));
		POSITION = original_clip;
		POSITION.xy += pixel_delta * (2.0 / VIEWPORT_SIZE) * original_clip.w * blend;
	} else {
		POSITION = original_clip;
	}
}
void fragment() { ALBEDO = outline_color.rgb; }
