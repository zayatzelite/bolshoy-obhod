shader_type canvas_item;
render_mode unshaded;
uniform float strength=0.0;
void fragment(){
 vec2 p=abs(UV-vec2(0.5))-vec2(0.425,0.40)+vec2(0.035);
 float d=length(max(p,vec2(0.0)))+min(max(p.x,p.y),0.0)-0.035;
 float outside=smoothstep(-0.002,0.003,d);
 float rim=1.0-smoothstep(0.001,0.005,abs(d));
 float vignette=pow(length((UV-0.5)*vec2(1.1,0.85)),2.0)*0.13;
 // Neutral charcoal surround and sand rim; keep the lens centre transparent.
 COLOR=vec4(mix(vec3(0.035,0.039,0.043),vec3(0.84,0.73,0.52),rim*0.7),strength*max(outside*0.82,max(rim*0.42,vignette)));
}
