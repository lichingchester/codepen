#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359

// Plot a line on Y using a value between 0.0-1.0
float line(vec2 st,float pct){
  return smoothstep(pct-.01,pct,st.y)-smoothstep(pct,pct+.01,st.y);
}

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution;
  
  st=st*2.-vec2(1.);
  
  float y=sin((st.x*PI*sin(u_time)));
  
  float pct=line(st,y);
  
  vec3 color=vec3(y);
  color=pct*vec3(0.,1.,0.);
  
  gl_FragColor=vec4(color,1.);
}
