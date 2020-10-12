// Find the latest version by visiting https://unpkg.com/three. The URL will
// redirect to the newest stable release.
import * as THREE from "https://cdnjs.cloudflare.com/ajax/libs/three.js/r121/three.module.js";

var width = window.innerWidth;
var height = window.innerHeight;
var camera, scene, renderer;
var geometry, uniforms, material, mesh;

function render() {
  uniforms.time.value += 0.05;
  renderer.render(scene, camera);
}

function animate() {
  requestAnimationFrame(animate);
  render();
}

function onWindowResize(event) {
  width = window.innerWidth;
  height = window.innerHeight;
  renderer.setSize(width, height);

  uniforms.resolution.value.x = renderer.domElement.width;
  uniforms.resolution.value.y = renderer.domElement.height;
}

function onMouseMove(event) {
  uniforms.mouse.value.x = event.clientX;
  uniforms.mouse.value.y = event.clientY;
}

function init() {
  // setup scene
  scene = new THREE.Scene();

  // setup camera
  camera = new THREE.Camera();
  camera.position.z = 1;

  geometry = new THREE.PlaneBufferGeometry(2, 2);
  uniforms = {
    time: {
      type: "f",
      value: 1.0,
    },
    resolution: {
      type: "v2",
      value: new THREE.Vector2(),
    },
    mouse: {
      type: "v2",
      value: new THREE.Vector2(),
    },
  };
  material = new THREE.ShaderMaterial({
    uniforms: uniforms,
    vertexShader: document.getElementById("vertexShader").textContent,
    fragmentShader: document.getElementById("fragmentShader").textContent,
  });

  mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);

  // setup renderer
  renderer = new THREE.WebGLRenderer();
  renderer.setSize(width, height);
  renderer.setClearColor(0x000000);

  document.body.appendChild(renderer.domElement);

  onWindowResize();
  window.addEventListener("resize", onWindowResize, false);
  window.addEventListener("mousemove", onMouseMove, false);
}

init();
animate();
