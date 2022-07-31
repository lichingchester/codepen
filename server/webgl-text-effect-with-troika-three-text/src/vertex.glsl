#pragma glslify: noise = require(glsl-noise/simplex/3d);

uniform float uTime;
attribute float line;
varying vec2 vUv;
varying float vLine;

void main() {
  vUv = uv;
  vLine = line;

  vec4 modalPosition = modelMatrix * vec4(position, 1.0);
  // modalPosition.x += sin(uTime);
  // modalPosition.x += noise(position + vec3(0.0, 0.0, uTime)) * uTime;
  // modalPosition.y += noise(position + vec3(0.0, 0.0, uTime)) * uTime;
  modalPosition.x += noise((position + 2.0) * 0.5 + uTime * 0.2);
  modalPosition.y += noise(position * 0.5 + uTime * 0.2);
  // modalPosition.z += sin(position.x * 10.0 + uTime);

  gl_Position = projectionMatrix * viewMatrix * modalPosition;
}