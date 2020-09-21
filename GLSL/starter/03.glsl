#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution;
  
  st=st*2.-vec2(1.);
  
  float r=smoothstep(st.x,st.x+1.,sin(u_time));
  float g=smoothstep(cos(u_time),cos(u_time)+1.,st.x);
  float b=smoothstep(st.y,st.y+1.,sin(u_time)+cos(u_time));
  // float b=0.;
  
  gl_FragColor=vec4(r,g,b,1.);
  // gl_FragColor=vec4(st.x,st.y,0.,1.);
}
