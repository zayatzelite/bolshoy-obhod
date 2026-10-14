shader_type canvas_item;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 uv=UV;
 float edge=.012+.004*sin(uv.y*29.0)+.002*sin(uv.y*67.0);
 float mask=step(edge,uv.x)*step(uv.x,1.0-edge)*step(.025,uv.y)*step(uv.y,.975);
 vec3 col=mix(vec3(.31,.27,.20),vec3(.18,.16,.12),uv.y);
 col+=(hash(floor(uv*vec2(180.0,60.0)))-.5)*.018;
 float rim=step(uv.x,edge+.006)+step(1.0-edge-.006,uv.x)+step(uv.y,.045)+step(.955,uv.y);
 col=mix(col,vec3(.67,.56,.38),clamp(rim,0.0,1.0)*.55);
 COLOR=vec4(col,mask*.68);
}
