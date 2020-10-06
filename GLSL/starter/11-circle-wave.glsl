// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

// My own port of this processing code by @beesandbombs
// https://dribbble.com/shots/1696376-Circle-wave

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 random2(vec2 st){
  st=vec2(dot(st,vec2(127.1,311.7)),dot(st,vec2(269.5,183.3)));
  
  return-1.+2.*fract(sin(st)*43758.5453123);
}

// Gradient Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/XdXGW8
float noise(vec2 st){
  vec2 i=floor(st);
  vec2 f=fract(st);
  
  vec2 u=f*f*(3.-2.*f);
  
  return mix(mix(dot(random2(i+vec2(0.,0.)),f-vec2(0.,0.)),
  dot(random2(i+vec2(1.,0.)),f-vec2(1.,0.)),u.x),
  mix(dot(random2(i+vec2(0.,1.)),f-vec2(0.,1.)),
  dot(random2(i+vec2(1.,1.)),f-vec2(1.,1.)),u.x),u.y);
}

mat2 rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
  sin(_angle),cos(_angle));
}

float shape(vec2 st,float radius){
  st=vec2(.5)-st;
  st=rotate2d(u_time*.5)*st;
  
  float r=length(st)*2.;
  float a=atan(st.y-0.,st.x-0.);
  float m=abs(mod(a+u_time*2.,3.14*2.)-3.14)/3.6;
  float f=radius;
  // m+=noise(st+u_time*.1)*.5;
  // a*=1.+abs(atan(u_time*.2))*.1;
  // a*=1.+noise(st+u_time*.1)*.1;
  
  f+=sin(a*5.)*noise(st+u_time*.1)*.1;
  // f+=noise(st+u_time*.1);
  // f+=noise(st+sin(u_time));
  // f+=sin(a*50.);
  
  // f+=(sin(a*20.)*.1*pow(m,2.));
  
  return 1.-smoothstep(f,f+.003,r);
  // return 1.-smoothstep(f,f+.007,r);
}

float shapeBorder(vec2 st,float radius,float width){
  // return shape(st,radius);
  return shape(st,radius)-shape(st,radius-width);
}

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(1.)*shapeBorder(st,.8,.004);
  
  gl_FragColor=vec4(1.*color,1.);
}
