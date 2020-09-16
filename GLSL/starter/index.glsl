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
  float length = 0.01;
  return smoothstep(pct - length, pct, st.y) - smoothstep(pct, pct + length, st.y);
}

void main(){
  vec2 st = gl_FragCoord.xy / u_resolution;
  // vec2 mt = u_mouse.xy / u_resolution;

  float y = smoothstep(0.0, 1.0, st.x);
  float timeDelta = u_time / 1.0;
  // y = sin(st.x / 0.15) * timeDelta + 0.5;
  // y = sin(st.x / 0.15) * 0.25 + 0.5;
  y = (sin(st.x * PI + timeDelta * 1.0)) * 0.25 + 0.5;

  vec3 color = vec3(y);

  // // plot a line
  float pct = plot(st, y);
  // pct = sin(pct);

  vec3 backgroundColor = vec3(0.0);

  vec3 green = vec3(0.0, 1.0, 0.0);
  vec3 blue = vec3(0.0, 0.0, 1.0);
  vec3 lineColor = mix(green, blue, abs(sin(u_time)));

  color = backgroundColor;
  color = color + pct * lineColor;

  
  // color = (1.0 - pct) * color + pct * vec3(0.0,1.0,0.0);

  gl_FragColor = vec4(color, 1.0);

  // gl_FragColor = vec4(abs(sin(u_time)),0,0,1.);
  // gl_FragColor = vec4(mt.x,mt.y,0,1);
}

#endif
