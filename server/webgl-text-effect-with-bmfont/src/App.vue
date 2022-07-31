<script setup>
import { onMounted } from "vue";
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";
import { Text } from "troika-three-text";
// import glsl from "glslify";
import font from "@/assets/font.otf";
import vertexShader from "@/vertex.glsl";
import fragmentShader from "@/fragment.glsl";

// const vertexShader = `
//   uniform float uTime;

//   varying vec2 vUv;

//   void main(){
//     vUv = uv;

//     vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
//     // gl_PointSize = scale * (300.0 / - mvPosition.z);
//     // gl_PointSize = 2.0;
//     gl_Position = projectionMatrix * mvPosition;

//     // gl_Position.x += sin(position.x * 10.0 + uTime) * 0.1;
//   }
// `;
// const fragmentShader = `
//   #pragma glslify: noise = require(glsl-noise/simplex/3d);

//   uniform vec3 uColor;
//   uniform float uTime;

//   varying vec2 vUv;

//   void main(){
//     float alpha = 1.0;

//     vec3 color = uColor;

//     float noise = noise(vec3(vUv * 0.1, uTime * 0.1));

//     gl_FragColor = vec4(color, alpha);
//   }
// `;

onMounted(() => {
  console.log("start");
  // Canvas
  const canvas = document.querySelector("canvas.webgl");

  // Scene
  const scene = new THREE.Scene();

  // Object
  const geometry = new THREE.PlaneGeometry(100, 100);

  // Material
  const material = new THREE.MeshBasicMaterial({
    color: 0xffff00,
    side: THREE.DoubleSide,
  });
  const object = new THREE.Mesh(geometry, material);
  scene.add(object);

  // Text
  // const textMaterial = new THREE.MeshBasicMaterial({
  //   color: 0xffffff,
  //   side: THREE.DoubleSide,
  // });
  const textMaterial = new THREE.ShaderMaterial({
    uniforms: {
      uColor: { value: new THREE.Color(0xffffff) },
      uTime: { value: 1.0 },
    },
    vertexShader,
    fragmentShader,
  });

  const text = new Text();
  scene.add(text);

  // Set properties to configure:
  text.font = font;
  text.text = "Aequam memento rebus in arduis servare mentem";
  text.fontSize = 20;
  text.textAlign = "center";
  text.anchorX = "center";
  text.position.z = 1;
  text.material = textMaterial;

  // Update the rendering:
  text.sync();

  // Sizes
  const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
  };

  // Camera
  const camera = new THREE.PerspectiveCamera(30, sizes.width / sizes.height);
  camera.position.z = 300;
  scene.add(camera);

  // Controls
  const controls = new OrbitControls(camera, canvas);
  controls.enableDamping = true;

  // Renderer
  const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
  });
  renderer.toneMapping = THREE.ReinhardToneMapping;
  renderer.setSize(sizes.width, sizes.height);
  renderer.render(scene, camera);

  // Events
  window.addEventListener("resize", () => {
    sizes.width = window.innerWidth;
    sizes.height = window.innerHeight;

    camera.aspect = sizes.width / sizes.height;
    camera.updateProjectionMatrix();

    renderer.setSize(sizes.width, sizes.height);
    // composer.setSize(sizes.width, sizes.height);
  });

  /**
   * Animate
   */
  const clock = new THREE.Clock();

  const tick = () => {
    const elapsedTime = clock.getElapsedTime();
    // const elapsedTime = Date.now() * 0.01;

    // Update controls
    controls.update();

    // Render
    renderer.render(scene, camera);

    // Call tick again on the next frame
    window.requestAnimationFrame(tick);
  };

  tick();
});
</script>

<template>
  <canvas class="webgl"></canvas>
</template>

<style>
html,
body {
  margin: 0;
}

.webgl {
  position: fixed;
  left: 0;
  top: 0;
  outline: none;
}
</style>
