#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random(vec2 st){
  float random=fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
  return random;
}

vec2 random2(vec2 st){
  st=vec2(dot(st,vec2(127.1,311.7)),dot(st,vec2(269.5,183.3)));
  return-1.+2.*fract(sin(st)*43758.5453123);
}

float plot(vec2 st,float pct){
  float length=.005;
  return smoothstep(pct-length,pct,st.y)-smoothstep(pct,pct+length,st.y);
}

float line(vec2 _st){
  vec2 st=_st;
  
  float scale=.1;
  float y=fract(sin(st.x/scale)*1.)*scale;
  // y=mix(random(fract(st)),random(fract(st)+1.),random(fract(st)));
  
  float pct=plot(st,y);
  
  return pct;
}

float valueNoise(in vec2 st){
  vec2 i=floor(st);
  vec2 f=fract(st);
  
  // Four corners in 2D of a tile
  float a=random(i);
  float b=random(i+vec2(1.,0.));
  float c=random(i+vec2(0.,1.));
  float d=random(i+vec2(1.,1.));
  
  // Smooth Interpolation
  
  // Cubic Hermine Curve.  Same as SmoothStep()
  vec2 u=f*f*(3.-2.*f);
  // u = smoothstep(0.,1.,f);
  
  // Mix 4 coorners percentages
  return mix(a,b,u.x)+(c-a)*u.y*(1.-u.x)+(d-b)*u.x*u.y;
}

float gradientNoise(vec2 st){
  vec2 i=floor(st);
  vec2 f=fract(st);
  
  vec2 u=f*f*(3.-2.*f);
  
  return mix(mix(dot(random2(i+vec2(0.,0.)),f-vec2(0.,0.)),
  dot(random2(i+vec2(1.,0.)),f-vec2(1.,0.)),u.x),
  mix(dot(random2(i+vec2(0.,1.)),f-vec2(0.,1.)),
  dot(random2(i+vec2(1.,1.)),f-vec2(1.,1.)),u.x),u.y);
}

vec4 main1(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  // scale
  // st*=10.;
  
  // draw line
  // color+=line(st);
  
  // show random
  // color+=vec3(random(st));
  
  // show random int
  // vec2 ipos=floor(st);
  // vec2 fpos=fract(st);
  // color=vec3(random(ipos));
  
  // noise
  vec2 pos=vec2(st*10.);
  // pos=vec2(st*u_time);
  
  float n=valueNoise(pos);
  n=gradientNoise(pos)*.5+.5;
  
  color=vec3(n);
  
  return vec4(color,1.);
}

void main(){
  gl_FragColor=main1();
}