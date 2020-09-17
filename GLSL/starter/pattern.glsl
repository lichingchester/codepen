#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

float circle(in vec2 _st,in float _radius){
  vec2 l=_st-vec2(.5);
  return 1.-smoothstep(_radius-(_radius*.01),
  _radius+(_radius*.01),
  dot(l,l)*4.);
}

vec2 rotate2D(vec2 _st,float _angle){
  _st-=.5;
  _st=mat2(cos(_angle),-sin(_angle),
  sin(_angle),cos(_angle))*_st;
  _st+=.5;
  return _st;
}

vec2 tile(vec2 _st,float _zoom){
  _st*=_zoom;
  return fract(_st);
}

float box(vec2 _st,vec2 _size,float _smoothEdges){
  _size=vec2(.5)-_size*.5;
  vec2 aa=vec2(_smoothEdges*.5);
  vec2 uv=smoothstep(_size,_size+aa,_st);
  uv*=smoothstep(_size,_size+aa,vec2(1.)-_st);
  return uv.x*uv.y;
}

vec4 main1(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  st*=3.;
  // st*=u_time;
  st=fract(st);
  color=vec3(st,0.);
  color=vec3(circle(st,.5));
  
  return vec4(color,1.);
}

vec4 main2(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  // Divide the space in 4
  st=tile(st,5.);
  // st=tile(st,5.);
  
  // Use a matrix to rotate the space 45 degrees
  st=rotate2D(st,PI*.5);
  st=rotate2D((st),PI*u_time);
  
  // Draw a square
  color=vec3(box(st,vec2(.7),.02));
  color=vec3(box(st,vec2(.4),.02));
  // color = vec3(st,0.0);
  
  return vec4(color,1.);
}

// basic circle
void main(){
  // gl_FragColor=main1();
  gl_FragColor=main2();
}