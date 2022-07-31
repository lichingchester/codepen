uniform float uTime;

varying vec2 vUv;

void main() {
  vUv = uv;

  vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    // gl_PointSize = scale * (300.0 / - mvPosition.z);
    // gl_PointSize = 2.0;
  gl_Position = projectionMatrix * mvPosition;

    // gl_Position.x += sin(position.x * 10.0 + uTime) * 0.1;
}