shader_type spatial;
render_mode unshaded, cull_front;
uniform vec4 outline_color : source_color = vec4(1.0,0.79,0.30,1.0);
void vertex(){ VERTEX += NORMAL * 0.012; }
void fragment(){ ALBEDO = outline_color.rgb; }
