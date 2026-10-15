shader_type canvas_item;
uniform float hover=0.0;
uniform bool selected=false;
uniform bool disabled=false;
uniform vec3 active_top = vec3(.96,.84,.60);
uniform vec3 active_bottom = vec3(.72,.54,.30);
uniform vec3 disabled_top = vec3(.90,.83,.70);
uniform vec3 disabled_bottom = vec3(.80,.71,.57);
uniform vec2 panel_size=vec2(300.,48.);
void fragment(){
 vec2 p=UV*panel_size;
 vec2 q=abs(p-panel_size*.5)-panel_size*.5+vec2(2.);
 float d=max(max(q.x,q.y),(q.x+q.y+7.)*.7071);
 float mask=1.-smoothstep(-.5,.6,d);
 vec3 col=mix(active_top,active_bottom,UV.y);
 float rim=1.-smoothstep(.6,1.5,abs(d+1.5));
 col=mix(col,vec3(.58,.5,.32),rim);
 col+=hover*vec3(.055,.065,.045);
 if(selected){col+=vec3(.08,.095,.055);col=mix(col,vec3(.82,.70,.43),step(panel_size.y-5.,p.y));}
 float inner=1.-smoothstep(.35,1.,abs(d+4.5));
 col=mix(col,vec3(.98,.88,.65),inner*.65);
 float diamond=1.-smoothstep(1.4,2.4,abs(p.x-panel_size.x*.5)+abs(p.y-3.));
 col=mix(col,vec3(.52,.36,.16),diamond*.8);
 float corner=step(p.x,22.)*step(8.,p.x)*step(p.y,7.)*step(5.,p.y);
 corner+=step(panel_size.x-22.,p.x)*step(p.x,panel_size.x-8.)*step(panel_size.y-7.,p.y)*step(p.y,panel_size.y-5.);
 col=mix(col,vec3(.46,.33,.18),clamp(corner,0.,1.)*.8);
 col+=vec3(.05)*step(p.y,5.);
 // Disabled controls use opaque matte paper: no hover glow or selected gold stripe.
 // Keep the same geometry, while the muted, high-contrast surface signals inactivity.
 if(disabled){
  col=mix(disabled_top,disabled_bottom,UV.y);
  col=mix(col,vec3(.62,.54,.43),rim*.55);
  col=mix(col,vec3(.94,.88,.76),inner*.4);
 }
 COLOR=vec4(col,mask*(disabled ? 1. : .98));
}
