<script setup>
import { Application } from "@splinetool/runtime";
import { onMounted } from "vue";

const SPLINE_URL = "/scene.splinecode";
// const SPLINE_URL =
//   "https://prod.spline.design/ugcZaAvIQPgvlWk9/scene.splinecode";

onMounted(() => {
  const canvas = document.getElementById("canvas3d");
  const spline = new Application(canvas);
  spline.load(SPLINE_URL).then(() => {
    const obj = spline.findObjectByName("Trigger");
    console.log("then", obj);
  });
});

/**
 * Three.js example
 */
// import * as THREE from "three";
// import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
// import SplineLoader from "@splinetool/loader";

// // camera
// const camera = new THREE.OrthographicCamera(
//   window.innerWidth / -2,
//   window.innerWidth / 2,
//   window.innerHeight / 2,
//   window.innerHeight / -2,
//   -100000,
//   100000
// );
// camera.position.set(0, 0, 1000);
// camera.quaternion.setFromEuler(new THREE.Euler(0, 0, 0));

// // scene
// const scene = new THREE.Scene();

// // spline scene
// const loader = new SplineLoader();
// loader.load(
//   "https://prod.spline.design/ugcZaAvIQPgvlWk9/scene.splinecode",
//   (splineScene) => {
//     scene.add(splineScene);
//   }
// );

// // renderer
// const renderer = new THREE.WebGLRenderer({ antialias: true });
// renderer.setSize(window.innerWidth, window.innerHeight);
// renderer.setAnimationLoop(animate);
// document.body.appendChild(renderer.domElement);

// // scene settings
// renderer.shadowMap.enabled = true;
// renderer.shadowMap.type = THREE.PCFShadowMap;

// scene.background = new THREE.Color("#4724c6");
// renderer.setClearAlpha(1);

// // orbit controls
// const controls = new OrbitControls(camera, renderer.domElement);
// controls.enableDamping = true;
// controls.dampingFactor = 0.125;

// window.addEventListener("resize", onWindowResize);
// function onWindowResize() {
//   camera.left = window.innerWidth / -2;
//   camera.right = window.innerWidth / 2;
//   camera.top = window.innerHeight / 2;
//   camera.bottom = window.innerHeight / -2;
//   camera.updateProjectionMatrix();
//   renderer.setSize(window.innerWidth, window.innerHeight);
// }

// function animate(time) {
//   controls.update();
//   renderer.render(scene, camera);
// }
</script>

<template>
  <div class="webgl">
    <canvas id="canvas3d"></canvas>
  </div>
  <!-- <canvas class="webgl"></canvas> -->
</template>

<style>
html,
body {
  margin: 0;
}

.webgl {
  position: absolute;
  left: 30rem;
  top: 15rem;
  width: 700px;
  height: 700px;
}

canvas {
  display: block;
}

/* .webgl,
#canvas3d {
  position: fixed;
  left: 0;
  top: 0;
  outline: none;
} */

/* #canvas3d {
  width: 500px;
  height: 500px;
} */
</style>
