shader_type spatial;
render_mode cull_disabled;
uniform float patrol_time = 0.0;
uniform vec4 grass_color : source_color = vec4(0.26,0.36,0.10,1.0);
varying float tip;
void vertex(){
 // The exported ribbons are a single mesh; use local ground level rather than
 // mesh origin to avoid moving roots on the sloping terrain.
 float ground=.12*sin(VERTEX.x*.12)*sin(-VERTEX.z*.08)+max(0.0,(-VERTEX.x-15.0)*.025)*(.5+.5*sin(-VERTEX.z*.025));
 float height=max(0.0,VERTEX.y-ground);
 tip=clamp(height/.75,0.0,1.0);
 float gust=sin(patrol_time*1.3+VERTEX.x*.31+VERTEX.z*.18);
 VERTEX.x+=gust*height*height*.13;
 VERTEX.z+=sin(patrol_time*.9+VERTEX.x*.21)*height*height*.07;
}
void fragment(){
 ALBEDO=grass_color.rgb*mix(.78,1.12,tip);
 ROUGHNESS=.95;
}
