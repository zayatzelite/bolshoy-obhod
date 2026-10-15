shader_type canvas_item;
render_mode unshaded;
void fragment(){COLOR=vec4(0.025,0.045,0.04,0.12+0.64*UV.y*UV.y);}
