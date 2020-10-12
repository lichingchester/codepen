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

float shape(vec2 st,float radius,float timeDelta){
  float time=u_time+timeDelta;
  
  // move to center
  st=vec2(.5)-st;
  
  // move the circle
  // st+=vec2(sin(u_time))*.1;
  // st=vec2(cos(u_time))*.1;
  // st+=vec2(random2(vec2(u_time,0.)))*.05;
  // st+=vec2(cos(time),sin(time))*.05;
  st.x+=noise(vec2(time/5.))*.25;
  st.y+=noise(vec2(time/4.))*.25;
  
  // st+=vec2(sin(u_time+2.),sin(u_time-2.))*.01;
  // st+=vec2(sin(u_time+2.),sin(u_time-2.))*.1;
  
  // rotate the circle
  st*=rotate2d(time*.15);
  
  float r=length(st)*2.;
  float a=atan(st.y-0.,st.x-0.);
  float m=abs(mod(a+time*2.,3.14*2.)-3.14)/3.6;
  float f=radius;
  // m+=noise(st+time*.1)*.5;
  // a*=1.+abs(atan(time*.2))*.1;
  // a*=1.+noise(st+time*.1)*.1;
  
  // f+=sin(a*5.)*sin(time)*.1;
  // f+=noise(st+time*.5)*0.2;
  
  // current
  f+=sin(a*3.)*noise(st+time*.2)*.5;
  
  // f+=noise(st+time*.1);
  // f+=noise(st+sin(time));
  // f+=sin(a*50.);
  
  // f+=(sin(a*20.)*.1*pow(m,2.));
  // f+=(sin(20.)*.1);
  
  // return 1.-smoothstep(f,f+.003,r);
  return 1.-smoothstep(f,f+.005,r);
}

float shapeBorder(vec2 st,float radius,float width,float timeDelta){
  // return shape(st,radius);
  return shape(st,radius,timeDelta)-shape(st,radius-width,timeDelta);
}

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  
  for(float i=0.;i<30.;i+=1.){
    // color+=vec3(1.)*shapeBorder(st,i / 100.,.004,float(i)/10.+u_time);
    // color+=vec3(1.)*shapeBorder(st,0.7,.004,float(i)/5.+u_time);
    // color+=vec3(i*0.1,i*0.3,i*0.2)*shapeBorder(st,.8,.004,i/7.);
    color+=vec3(i/10.,i/30.,i/20.)*shapeBorder(st,.8,.004,i/7.);
  }
  
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.1);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.2);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.3);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.4);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.5);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.6);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.7);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.8);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,.9);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.1);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.2);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.3);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.4);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.5);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.6);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.7);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.8);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.9);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,2.);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.);
  // color+=vec3(1.)*shapeBorder(st,.8,.004,1.);
  
  // color=color1+color2+color3+color4+color5+color6;
  
  gl_FragColor=vec4(color,1.);
}
