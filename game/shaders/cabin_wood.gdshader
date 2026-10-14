shader_type spatial;
render_mode cull_disabled;
uniform vec4 wood_color : source_color = vec4(.38,.27,.14,1.0);
varying vec3 pos;
varying vec3 surface_normal;
void vertex(){pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;surface_normal=MODEL_NORMAL_MATRIX*NORMAL;}
void fragment(){
 vec2 p=abs(surface_normal.y)>.6?pos.xz:vec2(abs(surface_normal.x)>.6?pos.z:pos.x,pos.y);
 float grain=sin(p.x*41.0+sin(p.y*2.4)*3.0)*.012+sin(p.x*93.0+p.y*3.0)*.004;
 float board=fract(p.y/.22);
 float seam=1.0-smoothstep(.0,.012,min(board,1.0-board));
 ALBEDO=wood_color.rgb*(1.0+grain-seam*.10);
 ROUGHNESS=.9;
}
