shader_type spatial;
render_mode unshaded;
varying vec3 world_normal;
void vertex(){world_normal = MODEL_NORMAL_MATRIX * NORMAL;}
void fragment(){
 float light = smoothstep(-0.7,0.8,normalize(world_normal).y);
 ALBEDO = mix(vec3(0.65,0.74,0.73),vec3(0.89,0.90,0.83),light);
}
