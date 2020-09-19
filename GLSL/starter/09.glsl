#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random(vec2 st){
  float random=fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
  
  // float delta=u_time*.5;
  // random=fract(sin(dot(st.xy,vec2(delta,delta)))*(43758.5453123/3.));
  // random=fract(sin(dot(st.xy,vec2(u_mouse.x,u_mouse.y)))*(u_mouse.x / 10000.));
  return random;
}

float plot(vec2 st,float pct){
  float length=.005;
  return smoothstep(pct-length,pct,st.y)-smoothstep(pct,pct+length,st.y);
}

float line(vec2 _st){
  vec2 st=_st;
  // st.x = 1.0;
  // vec2 st=_st-.5;
  
  float scale=.1;
  float y=fract(sin(st.x/scale)*1.)*scale;
  
  float pct=plot(st,y);
  
  return pct;
}

vec4 main1(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  // scale
  st*=10.;
  
  // draw line
  // color+=line(st);
  
  // show random
  // color+=vec3(random(st));
  
  // show random int
  vec2 ipos=floor(st);
  vec2 fpos=fract(st);
  
  color=vec3(random(ipos));
  
  return vec4(color,1.);
}

void main(){
  gl_FragColor=main1();
}