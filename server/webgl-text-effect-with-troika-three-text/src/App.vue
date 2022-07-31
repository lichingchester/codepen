<script setup>
import { onMounted } from "vue";
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";
import { Text } from "troika-three-text";
import font from "@/assets/font.otf";
import vertexShader from "@/vertex.glsl";
import fragmentShader from "@/fragment.glsl";

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
  // scene.add(object);

  // Text
  // const textMaterial = new THREE.MeshBasicMaterial({
  //   color: 0xffffff,
  //   side: THREE.DoubleSide,
  // });
  const textMaterial = new THREE.ShaderMaterial({
    uniforms: {
      uColor: { value: new THREE.Color(0xffffff) },
      uTime: { value: 1.0 },
      uAnimate: { type: "f", value: 1 },
    },
    vertexShader,
    fragmentShader,
    side: THREE.DoubleSide,
  });

  const text = new Text();
  scene.add(text);

  // Set properties to configure:
  text.font = font;
  text.text = "Aequam memento rebus in arduis servare mentem";
  text.fontSize = 20;
  text.outlineWidth = 0.01;
  // text.textAlign = "center";
  // text.anchorX = "100%";
  // text.position.y = 5;
  // text.position.x = -5;
  // text.position.z = 100;
  // text.rotation.x = Math.PI * 0.1;
  // text.rotation.z = Math.PI * 0.1;
  // text.quaternion.setFromEuler(new THREE.Euler(1, 0, 0, "XYZ"));
  // text.curveRadius = -32;
  text.material = textMaterial;

  text.geometry.computeBoundingBox();
  const xMid =
    -0.5 * (text.geometry.boundingBox.max.x - text.geometry.boundingBox.min.x);
  text.geometry.translate(xMid, 0, 0);

  // Update the rendering:
  text.sync();

  console.log(text);

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
  const duration = 3;
  let time = 0;

  const tick = () => {
    const elapsedTime = clock.getElapsedTime();
    // const elapsedTime = Date.now() * 0.01;
    // time += elapsedTime / 1000;
    // time += 0.01;

    // if (time > duration) {
    //   time = 0;
    // }

    // text.rotation.y += 0.01;
    textMaterial.uniforms.uTime.value = elapsedTime;
    // textMaterial.uniforms.uTime.value = time;
    // textMaterial.uniforms.uAnimate.value = time / duration;

    // console.log("time", time);

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
