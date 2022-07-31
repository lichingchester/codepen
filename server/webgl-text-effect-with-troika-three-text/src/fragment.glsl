// #pragma glslify: noise = require(glsl-noise/periodic/3d);
#pragma glslify: noise = require(glsl-noise/classic/3d);
// #pragma glslify: noise = require(glsl-noise/simplex/3d);
#pragma glslify: aastep = require('glsl-aastep')

uniform vec3 uColor;
uniform float uTime;
uniform float uAnimate;

varying vec2 vUv;
varying float vLine;

void main() {
  // float sdf = 1.0;
  float alpha = 0.0;

  // float animValue = pow(abs(uAnimate * 2.0 - 1.0), 12.0 - vLine * 5.0);
  // float threshold = animValue * 0.5 + 0.5;
  // alpha += 0.15 * aastep(threshold, sdf + 0.4 * noise(vec3(vUv * 10.0, uTime)));
  // alpha += 0.35 * aastep(threshold, sdf + 0.1 * noise(vec3(vUv * 50.0, uTime)));
  // alpha += 0.15 * aastep(threshold, sdf);

  // alpha += noise(vec3(vUv * 10.0, uTime)) + uTime * 0.5;
  // alpha += noise(vec3(vUv.x * 50.0, vUv.y * 5.0, uTime * 0.75)) + (sin(uTime * 1.0) + 0.1) * 0.5;
  alpha += noise(vec3(vUv.x * 50.0, vUv.y * 5.0, uTime * 0.75)) + sin(uTime * 0.95) + 0.25;

  gl_FragColor = vec4(uColor, alpha);
}

// void main() {
//   float sdf = 1.0;

//   float alpha = 0.0;
//   float animValue = pow(abs(uAnimate * 2.0 - 1.0), 12.0 - vLine * 5.0);
//   float threshold = animValue * 0.5 + 0.5;
//   alpha += 0.15 * aastep(threshold, sdf + 0.4 * noise(vec3(vUv * 10.0, uTime)));
//   alpha += 0.35 * aastep(threshold, sdf + 0.1 * noise(vec3(vUv * 50.0, uTime)));
//   alpha += 0.15 * aastep(threshold, sdf);

//   vec3 color = uColor;

//   gl_FragColor = vec4(color, alpha);
// }