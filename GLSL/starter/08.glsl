#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

float box(in vec2 _st,in vec2 _size){
  
  _size=vec2(.51)-_size;
  
  vec2 uv=smoothstep(_size,_size+vec2(.001),_st);
  
  uv*=smoothstep(_size,_size+vec2(.001),vec2(1.)-_st);
  
  return uv.x*uv.y;
}

float cross(in vec2 _st,float _size){
  return box(_st,vec2(_size,_size/4.))+box(_st,vec2(_size/4.,_size));
}

mat2 scale(vec2 _scale){
  return mat2(_scale.x,0.,
  0.,_scale.y);
}

mat2 rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
  sin(_angle),cos(_angle));
}

vec4 main1(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  // addon
  // st*=10.;
  // st=fract(st);
  
  // To move the cross we move the space
  vec2 translate=vec2(cos(u_time),sin(u_time));
  st+=translate*.25;
  
  // move space from the center to the vec2(0.0)
  st-=vec2(.5);
  
  // scale the space
  st=scale(vec2(sin(u_time)+1.))*st;
  
  // rotate the space
  st=rotate2d(sin(u_time)*PI)*st;
  // st=rotate2d(sin(u_time)*PI)*st;
  
  // move it back to the original place
  st+=vec2(.5);
  
  // Show the coordinates of the space on the background
  color=vec3(st.x,st.y,0.);
  
  // Add the shape on the foreground
  color+=vec3(cross(st,.15));
  // color+=vec3(rotate2d(5.0));
  
  return vec4(color,1.);
}

// basic circle
void main(){
  
  gl_FragColor=main1();
}