shader_type spatial;
varying vec3 pos;
void vertex(){pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float waviness=sin(pos.x*.38+pos.z*.21)*.19+sin(pos.z*1.3)*.04;
 float strata=sin((pos.y+waviness)*2.1)*.028+sin(pos.y*7.7+pos.z*.15)*.012;
 float broad=sin(pos.z*.27+sin(pos.x*.31))*sin(pos.y*.13+pos.z*.08);
 float streak=pow(max(0.0,sin(pos.z*1.1+sin(pos.y*.075)*.6+pos.x*.42)),8.0);
 float weather=sin(pos.x*3.1+pos.z*2.7)*sin(pos.y*4.9)*.012;
 vec3 stone=mix(vec3(.39,.385,.35),vec3(.55,.50,.405),smoothstep(-.7,.8,broad));
 ALBEDO=stone*(1.0+strata+weather-streak*.15);
 ROUGHNESS=.96;
}
