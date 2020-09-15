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

#define PI 3.14159265359

float plot(vec2 st, float pct){
  return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);
}

void main(){
  vec2 st = gl_FragCoord.xy / u_resolution;
  // vec2 mt = u_mouse.xy / u_resolution;

  float y = smoothstep(0.0, 1.0, st.x);

  vec3 color = vec3(y);

  // // plot a line
  float pct = plot(st, y);
  color = (1.0 - pct) * color + 0.0 * vec3(0.0,1.0,0.0);
  color = (1.0 - pct) * color + pct * vec3(0.0,1.0,0.0);

  gl_FragColor = vec4(color, 1.0);

  // gl_FragColor = vec4(abs(sin(u_time)),0,0,1.);
  // gl_FragColor = vec4(mt.x,mt.y,0,1);
}

#endif
