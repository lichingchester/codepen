#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#if defined(VERTEX)

attribute vec4 a_position;

void main(void){
  gl_Position = a_position;
}

#else// fragment shader

#ifdef GL_ES
precision mediump float;
#endif

void main(){
  vec2 st = gl_FragCoord.xy / u_resolution;
  // gl_FragColor = vec4(abs(sin(u_time)),0,0,1.);
  gl_FragColor = vec4(st.x,st.y,0.5,1);
}

#endif
