#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// extra
vec4 extraMain(){
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec2 mouse = u_mouse / u_resolution;
  vec3 color=vec3(0.);
  float pct=0.;

  float d = 0.0;
  
  // 
  // move to -1, 1
  st = st *2.0 - 1.0;

  d = length(abs(st) - 0.3);
  // d = length(min(abs(st) - 0.3, 0.0));
  // d = length(max(abs(st) - 0.3, 0.0));

  // d = length(abs((st * 0.5)) - u_time / 10.0 - mouse / 5.0 - 1.0);
  // d = length(abs(st) - u_time / 2.0);

  color = vec3(fract((d * 10.0)));
  // 

  return vec4(color,1.);
}

// step2Main
vec4 step2Main(){
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  vec2 pos = vec2(0.5) - st;

  float r = length(pos) * 3.0;
  float a = atan(pos.y, pos.x);

  float f = sin(a * 3.0);
  f = abs(sin(a * 3.0));
  // f = abs(cos(a*3.));
  // f = abs(cos(a*2.5))*.5+.3;
  // f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
  // f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

  color = vec3(1.0 - smoothstep(f, f + 0.02, r));

  return vec4(color, 1.0);
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
  gl_FragColor = step2Main();
}