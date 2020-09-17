#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

// extra
vec4 extraMain(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec2 mouse=u_mouse/u_resolution;
  vec3 color=vec3(0.);
  float pct=0.;
  
  float d=0.;
  
  //
  // move to -1, 1
  // st = st *2.0 - 1.0;
  st=st*2.-1.;
  
  // d = length(abs(st) - 0.3);
  // d = length(min(abs(st) - 0.3, 0.0));
  // d = length(max(abs(st) - 0.3, 0.0));
  
  d=length(abs(cos(st*
      1.))+u_time/10.-mouse/5.-0.);
      // d = length(abs(st) - u_time / 5.0);
      
      color=vec3(fract((d*10.)));
      //
      
      return vec4(color,1.);
    }
    
    // step2Main
    vec4 step2Main(){
      vec2 st=gl_FragCoord.xy/u_resolution.xy;
      vec3 color=vec3(0.);
      
      vec2 pos=vec2(.5)-st;
      // pos = st;
      
      float r=length(pos)*3.;
      // r = length(pos) * 1.0;
      // r = length(pos) * 3.0;
      // r = pos.x * 2.0;
      
      float a=atan(pos.y,pos.x)+u_time/5.;
      // a = atan(pos.x, pos.y);
      
      float f=sin(a*5.);
      // f = abs(sin(a * 3.0));
      // f = abs(cos(a*3.));
      // f = abs(cos(a*2.5))*.5+.3;
      // f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
      // f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;
      
      color=vec3(1.-smoothstep(f,f+.02,r));
      // color = vec3(0.0 - step(f, r));
      
      return vec4(color,1.);
    }
    
    vec4 step3Main(){
      vec2 st=gl_FragCoord.xy/u_resolution.xy;
      st.x*=u_resolution.x/u_resolution.y;
      vec3 color=vec3(0.);
      float d=0.;
      
      // Remap the space to -1. to 1.
      st=st*2.-1.;
      
      // Number of sides of your shape
      int N=3;
      
      // Angle and radius from the current pixel
      float a=atan(st.x,st.y)+PI;
      // a = atan(st.x, st.y) + 0.0;
      
      float r=TWO_PI/float(N);
      r=TWO_PI/float(N);
      
      // Shaping function that modulate the distance
      d=cos(floor(.5+a/r)*r-a)*length(st);
      d=cos(floor(.5+a/r)*r-a)*length(st);
      
      color=vec3(1.-smoothstep(.4,.41,d));
      // color = vec3(d);
      
      return vec4(color,1.);
    }
    
    // basic circle
    void main(){
      // vec2 st = gl_FragCoord.xy / u_resolution.xy;
      // vec3 color = vec3(0.0);
      // float pct = 0.0;
      
      // pct = distance(st, vec2(0.5));
      // pct = 1.0 - smoothstep(0.0, 1.0, pct);
      
      // color = vec3(pct);
      
      // gl_FragColor = vec4(color, 1.0);
      
      // gl_FragColor = extraMain();
      // gl_FragColor = step2Main();
      gl_FragColor=step3Main();
    }