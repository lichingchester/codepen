#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

void main(){
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  vec2 bl = step(vec2(0.1), st);
  vec2 tr = step(vec2(0.1), 1.0 - st);

  float left = step(0.1, st.x);
  float right = 1.0 - step(0.9, st.x);
  float top = 1.0 - step(0.9, st.y);
  float bottom = step(0.1, st.y);

  // color = vec3((left * right * top * bottom));
  color = vec3(bl.x * bl.y * tr.x * tr.y);

  gl_FragColor = vec4(color, 1.0);
}