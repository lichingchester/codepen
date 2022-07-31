#pragma glslify: noise = require(glsl-noise/simplex/3d);

uniform vec3 uColor;
uniform float uTime;

varying vec2 vUv;

void main() {
  float alpha = 1.0;

  vec3 color = uColor;
  float noised = noise(vec3(vUv * 0.1, uTime * 0.1));

  gl_FragColor = vec4(color.r, color.g, noised, alpha);
}