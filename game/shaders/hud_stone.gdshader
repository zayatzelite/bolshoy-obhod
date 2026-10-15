shader_type canvas_item;
uniform vec2 panel_size = vec2(290.0,145.0);
float noise(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float chamfer(vec2 p,vec2 extent,float cut){
 vec2 q=abs(p-extent*0.5)-extent*0.5+vec2(3.0);
 return max(max(q.x,q.y),(q.x+q.y+cut)*0.707106);
}
void fragment(){
 vec2 p=UV*panel_size;
 float d=chamfer(p,panel_size,10.0);
 float mask=1.0-smoothstep(-0.6,0.8,d);
 vec3 base=mix(vec3(0.96,0.84,0.60),vec3(0.72,0.54,0.30),UV.y);
 base+=(noise(floor(p))-.5)*.009;
 float rim=1.0-smoothstep(0.6,1.8,abs(d+1.8));
 float inner=1.0-smoothstep(.4,1.0,abs(d+5.0));
 base=mix(base,vec3(.63,.55,.36),rim*.85);
 base+=vec3(.16,.20,.17)*inner*.28;
 float top=1.0-smoothstep(.4,1.4,abs(p.y-8.0));
 base+=vec3(.18,.19,.12)*top*.35;
 float accents=step(p.x,29.0)*step(7.0,p.x)*step(p.y,10.0)*step(7.0,p.y);
 accents+=step(panel_size.x-29.0,p.x)*step(p.x,panel_size.x-7.0)*step(panel_size.y-10.0,p.y)*step(p.y,panel_size.y-7.0);
 base=mix(base,vec3(.87,.74,.48),clamp(accents,0.0,1.0));
 COLOR=vec4(base,mask*.92);
}
