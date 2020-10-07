#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  vec2 bl=step(vec2(.1),st);
  vec2 tr=step(vec2(.1),1.-st);
  
  float left=step(.1,st.x);
  float right=1.-step(.9,st.x);
  float top=1.-step(.9,st.y);
  float bottom=step(.1,st.y);
  
  // color = vec3((left * right * top * bottom));
  color=vec3(bl.x*bl.y*tr.x*tr.y);
  vec3 color2=vec3(bl.x*bl.y*tr.x*tr.y+2.);
  vec3 color3=vec3(bl.x*bl.y*tr.x*tr.y+2.);
  
  gl_FragColor=vec4(color*color2,1.);
}