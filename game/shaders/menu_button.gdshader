shader_type canvas_item;
uniform vec4 top_color : source_color;
uniform vec4 bottom_color : source_color;
uniform float hover = 0.0;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 uv=UV;
 float edge=0.022+0.008*sin(uv.y*25.0);
 float mask=step(edge,uv.x)*step(uv.x,1.0-edge)*step(0.07,uv.y)*step(uv.y,0.93);
 vec3 col=mix(top_color.rgb,bottom_color.rgb,uv.y);
 col+=(hash(floor(uv*vec2(180.0,35.0)))-0.5)*0.055;
 col+=hover*0.10;
 col+=0.075*step(uv.y,0.13);
 col-=0.10*step(0.83,uv.y);
 float seam=sin(uv.x*18.0+uv.y*2.0)*0.012;
 col-=0.035*(1.0-smoothstep(0.0,0.012,abs(uv.y-0.65-seam)));
 COLOR=vec4(col,mask*0.96);
}
