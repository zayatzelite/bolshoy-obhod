shader_type spatial;
varying vec3 world_position;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 p=world_position.xz;
 float patch=noise(p*.09)*.65+noise(p*.32)*.35;
 vec3 grass=mix(vec3(.19,.27,.09),vec3(.31,.37,.16),patch);
 float earth=smoothstep(.72,.91,noise(p*.15+vec2(38.0)));
 ALBEDO=mix(grass,vec3(.39,.34,.20),earth*.25)+(noise(p*15.0)-.5)*.018;
 ROUGHNESS=.97;
}
