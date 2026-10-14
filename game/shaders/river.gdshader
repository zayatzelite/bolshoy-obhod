shader_type spatial;
render_mode cull_disabled;
uniform float patrol_time = 0.0;
uniform vec4 shallow_color : source_color = vec4(0.045,0.15,0.17,1.0);
void vertex(){
 VERTEX.y += sin(VERTEX.x*0.5+patrol_time*0.6)*0.025+cos(VERTEX.z*0.6+patrol_time*0.4)*0.018;
}
void fragment(){
 float ripple=sin(UV.x*100.0+patrol_time*.6)*cos(UV.y*160.0-patrol_time*.35);
 ALBEDO=shallow_color.rgb+vec3(ripple*.025);
 ROUGHNESS=.28;
 METALLIC=.12;
}
