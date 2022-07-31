#pragma glslify: noise = require(glsl-noise/simplex/3d);
#pragma glslify: aastep = require('glsl-aastep')

uniform vec3 uColor;
uniform float uTime;
uniform float uAnimate;

varying vec2 vUv;
varying float vLine;

void main() {
  // float sdf = 1.0;

  // float alpha = 0.0;
  // float animValue = pow(abs(uAnimate * 2.0 - 1.0), 12.0 - vLine * 5.0);
  // float threshold = animValue * 0.5 + 0.5;
  // alpha += 0.15 * aastep(threshold, sdf + 0.4 * noise(vec3(vUv * 10.0, uTime)));
  // alpha += 0.35 * aastep(threshold, sdf + 0.1 * noise(vec3(vUv * 50.0, uTime)));
  // alpha += 0.15 * aastep(threshold, sdf);

  gl_FragColor = vec4(uColor, 1.0);
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