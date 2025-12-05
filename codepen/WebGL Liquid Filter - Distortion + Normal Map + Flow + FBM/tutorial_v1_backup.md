# Creating a Liquid Glass Distortion Effect with WebGL and GLSL Shaders

In this tutorial, we'll create a stunning liquid glass distortion effect that sweeps across text or logos. This effect combines several advanced shader techniques including Fractal Brownian Motion (FBM), normal map generation, chromatic aberration, and more.

![Final Result](./images/final-result.gif)
_The final liquid glass effect sweeping across the logo_

## What You'll Learn

- Setting up a WebGL scene with Three.js
- Converting SVG content to texture
- Writing custom GLSL shaders
- Implementing Fractal Brownian Motion (FBM) for organic noise
- Creating procedural normal maps
- Adding post-processing effects (chromatic aberration, vignette)
- Building an interactive debug UI with Tweakpane
- Animating shader uniforms with GSAP

## Prerequisites

- Basic understanding of HTML, CSS, and JavaScript
- Familiarity with Three.js (helpful but not required)
- Basic knowledge of GLSL shaders (we'll explain as we go)

## Project Setup

First, let's set up our HTML structure with all the necessary dependencies:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Liquid Glass Effect</title>
    <style>
      html,
      body {
        margin: 0;
        background-color: #222;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      .webgl {
        outline: none;
      }
    </style>
  </head>
  <body>
    <canvas class="webgl"></canvas>

    <!-- Dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/gsap@3.12.2/dist/gsap.min.js"></script>

    <script type="module">
      // Our code will go here
    </script>
  </body>
</html>
```

### Dependencies Explained

- **Three.js**: A WebGL library that makes 3D graphics easier
- **GSAP**: For smooth animations
- **Tweakpane**: To build an interactive debug UI

## Step 1: Basic Scene Setup

Let's start by importing our dependencies and setting up a basic Three.js scene:

```javascript
import * as THREE from "https://cdn.skypack.dev/three@0.133.1/build/three.module";
import { Pane } from "https://cdn.jsdelivr.net/npm/tweakpane@4.0.5/dist/tweakpane.min.js";

// Get the canvas element
const canvas = document.querySelector("canvas.webgl");

// Create the scene
const scene = new THREE.Scene();

// Set up sizes
const width = 622 * 1.5;
const height = 157 * 1.5;
const canvasWidth = width;
const canvasHeight = height;
const aspectRatio = canvasWidth / canvasHeight;

// Create orthographic camera
const frustumSize = 1;
const camera = new THREE.OrthographicCamera(
  (frustumSize * aspectRatio) / -2,
  (frustumSize * aspectRatio) / 2,
  frustumSize / 2,
  frustumSize / -2,
  0.1,
  1000
);
camera.position.z = 1;
scene.add(camera);

// Create renderer
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
  alpha: true,
  antialias: true,
});
renderer.setSize(canvasWidth, canvasHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
```

![Scene Setup](./images/scene-setup.png)
_Basic Three.js scene structure_

## Step 2: Loading SVG as Texture

One of the key parts of this effect is converting SVG content into a texture that our shader can manipulate:

```javascript
// Your SVG content
const svgContent = `
<svg width="622" height="157" viewBox="0 0 622 157" fill="none">
  <!-- Your SVG paths here -->
</svg>
`;

// Create image from SVG
const img = new Image();
img.width = width * 2;
img.height = height * 2;

const svgBlob = new Blob([svgContent], { type: "image/svg+xml" });
const url = URL.createObjectURL(svgBlob);

img.onload = () => {
  // Convert to canvas for better quality
  const canvasEl = document.createElement("canvas");
  canvasEl.width = width * 2;
  canvasEl.height = height * 2;
  const ctx = canvasEl.getContext("2d");
  ctx.drawImage(img, 0, 0, canvasEl.width, canvasEl.height);

  // Create Three.js texture
  const texture = new THREE.CanvasTexture(canvasEl);
  texture.minFilter = THREE.LinearFilter;
  texture.magFilter = THREE.LinearFilter;

  // Continue with shader material setup...
};

img.src = url;
```

## Step 3: Creating the Shader Material

Now comes the exciting part - writing our custom shaders! Let's start with a simple vertex shader:

### Vertex Shader

```glsl
varying vec2 vUv;

void main() {
  vUv = uv;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
```

The vertex shader is straightforward - it just passes the UV coordinates to the fragment shader.

### Fragment Shader - Part 1: Uniforms

The fragment shader is where all the magic happens. Let's start by defining our uniforms:

```glsl
uniform sampler2D uTexture;
uniform float uTime;
uniform float uProgress;

// Distortion parameters
uniform float uDistortionIntensity;
uniform float uDistortionSpeed;
uniform float uDistortionScale;
uniform float uNoise1Weight;
uniform float uNoise2Weight;
uniform float uNoise3Weight;
uniform float uNoise2Scale;
uniform float uNoise3Scale;
uniform float uNoise2Speed;
uniform float uNoise3Speed;
uniform float uEdgeWidth;

// Effect parameters
uniform float uChromaticAberration;
uniform float uEdgeFog;
uniform float uVignetteIntensity;
uniform float uNormalMapInfluence;
uniform float uNormalMapScale;
uniform float uNormalMapOffset;
uniform float uFlowSpeed;
uniform float uFlowStrength;

// FBM parameters
uniform float uFbmSpeed;
uniform float uFbmAmplitude;
uniform float uFbmFrequency;
uniform float uFbmLacunarity;
uniform float uFbmGain;

varying vec2 vUv;
```

![Shader Uniforms Diagram](./images/shader-uniforms.png)
_How uniforms flow from JavaScript to the shader_

## Step 4: Implementing Gradient Noise

Gradient noise is the foundation of our effect. It creates smooth, organic patterns:

```glsl
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289_2(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float gradientNoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,
                      0.366025403784439,
                     -0.577350269189626,
                      0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289_2(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
    + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m;
  m = m*m;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
```

This is a simplex noise implementation that creates smooth, continuous random values.

![Gradient Noise Pattern](./images/gradient-noise.png)
_Example of gradient noise output_

## Step 5: Fractal Brownian Motion (FBM)

FBM combines multiple layers of noise at different frequencies to create complex, natural-looking patterns:

```glsl
float fbm(vec2 p, float time) {
  float value = 0.0;
  float amplitude = uFbmAmplitude;
  float frequency = uFbmFrequency;

  for(int i = 0; i < 5; i++) {
    value += amplitude * gradientNoise(p * frequency + time * uFbmSpeed);
    frequency *= uFbmLacunarity;
    amplitude *= uFbmGain;
  }
  return value;
}
```

**Key Parameters:**

- **Amplitude**: Controls the strength of each noise layer
- **Frequency**: Controls the detail level
- **Lacunarity**: How quickly frequency increases with each octave
- **Gain**: How quickly amplitude decreases with each octave

![FBM Layers](./images/fbm-layers.png)
_Multiple octaves of noise combined to create FBM_

## Step 6: Procedural Normal Map Generation

We generate a normal map on-the-fly to add depth and dimension to our distortion:

```glsl
vec3 generateNormalMap(vec2 uv, float time) {
  float offset = uNormalMapOffset;

  // Sample FBM at three points to calculate gradients
  float center = fbm(uv, time);
  float right = fbm(uv + vec2(offset, 0.0), time);
  float top = fbm(uv + vec2(0.0, offset), time);

  // Calculate derivatives
  float dx = (right - center) / offset;
  float dy = (top - center) / offset;

  // Create normal vector
  vec3 normal = normalize(vec3(-dx, -dy, 1.0));

  // Remap from [-1, 1] to [0, 1] for use as texture
  return normal * 0.5 + 0.5;
}
```

This technique samples the noise field at slightly offset positions to calculate surface gradients, creating the illusion of 3D bumps.

![Normal Map Generation](./images/normal-map.png)
_How normal maps add depth to flat surfaces_

## Step 7: The Frosted Glass Distortion

This is the heart of our effect - combining multiple noise layers with flow:

```glsl
vec2 getFrostedGlassDistortion(vec2 uv, float time, float intensity) {
  // Three layers of noise at different scales and speeds
  float noise1 = fbm(uv * uDistortionScale, time * uDistortionSpeed);
  float noise2 = fbm(uv * uDistortionScale * uNoise2Scale,
                     time * uDistortionSpeed * uNoise2Speed);
  float noise3 = fbm(uv * uDistortionScale * uNoise3Scale,
                     time * uDistortionSpeed * uNoise3Speed);

  // Weighted combination of noise layers
  vec2 distortion = vec2(noise1 * uNoise1Weight +
                         noise2 * uNoise2Weight +
                         noise3 * uNoise3Weight);

  // Add directional flow
  float flowAngle = time * uFlowSpeed + noise1;
  distortion += vec2(cos(flowAngle), sin(flowAngle)) * uFlowStrength;

  return distortion * intensity;
}
```

**Why Multiple Noise Layers?**

- **Layer 1**: Large-scale distortion
- **Layer 2**: Medium details
- **Layer 3**: Fine details

This creates a more organic, glass-like appearance than single-layer noise.

![Distortion Layers](./images/distortion-layers.gif)
_Animated visualization of the three noise layers_

## Step 8: Post-Processing Effects

### Chromatic Aberration

Simulates the way light splits through glass:

```glsl
vec3 chromaticAberration(sampler2D tex, vec2 uv, vec2 direction, float strength) {
  vec2 offset = direction * strength;
  float r = texture2D(tex, uv + offset).r;
  float g = texture2D(tex, uv).g;
  float b = texture2D(tex, uv - offset).b;
  return vec3(r, g, b);
}
```

![Chromatic Aberration Effect](./images/chromatic-aberration.png)
_RGB color separation creating a glass-like effect_

### Vignette

Darkens the edges for a more focused look:

```glsl
float vignette(vec2 uv, float intensity) {
  vec2 centered = uv - 0.5;
  float dist = length(centered);
  return 1.0 - smoothstep(0.3, 0.8, dist) * intensity;
}
```

## Step 9: The Main Shader Function

Now let's put it all together in the main function:

```glsl
void main() {
  vec2 uv = vUv;

  // Scale to 50% and center
  float scale = 0.5;
  uv = (uv - 0.5) / scale + 0.5;

  // Create animated progress mask
  float maskStart = uProgress - uEdgeWidth;
  float maskEnd = uProgress;
  float progressMask = smoothstep(maskStart, maskEnd, uv.x);

  // Generate normal map
  vec3 normalMap = generateNormalMap(uv * uNormalMapScale, uTime);

  // Get frosted glass distortion
  float distortionIntensity = uDistortionIntensity * progressMask;
  vec2 glassDistortion = getFrostedGlassDistortion(uv, uTime, distortionIntensity);

  // Apply normal map influence
  glassDistortion += (normalMap.xy - 0.5) * uNormalMapInfluence * progressMask;

  // Final distorted UV
  vec2 distortedUv = uv + glassDistortion;

  // Check bounds
  if (distortedUv.x < 0.0 || distortedUv.x > 1.0 ||
      distortedUv.y < 0.0 || distortedUv.y > 1.0) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    // Sample texture with chromatic aberration
    vec2 aberrationDir = (normalMap.xy - 0.5) * 2.0;
    float aberrationStrength = uChromaticAberration * progressMask;
    vec3 color = chromaticAberration(uTexture, distortedUv,
                                     aberrationDir, aberrationStrength);

    // Add frosted glass fog effect
    float edgeFog = smoothstep(maskStart + 0.05, maskEnd - 0.05, uv.x);
    edgeFog = 1.0 - edgeFog;
    color = mix(color, vec3(1.0), edgeFog * uEdgeFog * progressMask);

    // Apply vignette
    float vig = vignette(distortedUv, uVignetteIntensity * progressMask);
    color *= vig;

    // Sample original texture alpha
    float alpha = texture2D(uTexture, distortedUv).a;

    gl_FragColor = vec4(color, alpha);
  }
}
```

![Shader Pipeline](./images/shader-pipeline.png)
_Step-by-step visualization of the shader processing_

## Step 10: Creating the Shader Material

Back in JavaScript, let's set up our shader material with all the uniforms:

```javascript
const params = {
  // Distortion
  distortionIntensity: 0.08,
  distortionSpeed: 0.3,
  distortionScale: 8.0,
  noise1Weight: 0.5,
  noise2Weight: 0.3,
  noise3Weight: 0.2,
  noise2Scale: 2.0,
  noise3Scale: 4.0,
  noise2Speed: 0.7,
  noise3Speed: 0.5,

  // Animation
  animationDuration: 3.8,
  animationDelay: 0.5,
  edgeWidth: 0.15,

  // Effects
  chromaticAberration: 0.003,
  edgeFog: 0.15,
  vignetteIntensity: 0.2,
  normalMapInfluence: 0.02,

  // Normal Map
  normalMapScale: 4.0,
  normalMapOffset: 0.001,

  // Flow
  flowSpeed: 0.1,
  flowStrength: 0.2,

  // FBM
  fbmSpeed: 0.1,
  fbmAmplitude: 0.5,
  fbmFrequency: 1.0,
  fbmLacunarity: 2.0,
  fbmGain: 0.5,
};

const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0 },
    uTexture: { value: texture },
    uProgress: { value: 0 },
    uDistortionIntensity: { value: params.distortionIntensity },
    uDistortionSpeed: { value: params.distortionSpeed },
    // ... all other uniforms
  },
  transparent: true,
});
```

## Step 11: Animation with GSAP

Use GSAP to animate the progress uniform, creating the sweeping effect:

```javascript
const progressAnimation = gsap.to(material.uniforms.uProgress, {
  value: 1.2,
  duration: params.animationDuration,
  ease: "power2.inOut",
  repeat: -1,
  yoyo: false,
  repeatDelay: params.animationDelay,
});
```

![Animation Timeline](./images/animation-timeline.gif)
_The progress value animating from 0 to 1.2_

## Step 12: The Animation Loop

Create the render loop to update time and render the scene:

```javascript
const clock = new THREE.Clock();

const tick = () => {
  const elapsedTime = clock.getElapsedTime();

  if (material) {
    material.uniforms.uTime.value = elapsedTime;
  }

  renderer.render(scene, camera);
  window.requestAnimationFrame(tick);
};

tick();
```

## Step 13: Building the Debug UI

Tweakpane allows us to interactively adjust parameters:

```javascript
const pane = new Pane({
  title: "Liquid Logo Controls",
  expanded: true,
});

// Distortion folder
const distortionFolder = pane.addFolder({
  title: "Frosted Glass Distortion",
  expanded: true,
});

distortionFolder
  .addBinding(params, "distortionIntensity", {
    min: 0,
    max: 0.3,
    step: 0.001,
    label: "Intensity",
  })
  .on("change", (ev) => {
    if (material) material.uniforms.uDistortionIntensity.value = ev.value;
  });

// Add more controls for other parameters...
```

![Tweakpane UI](./images/tweakpane-ui.png)
_The complete debug interface_

## Step 14: Fine-Tuning the Effect

Here are some tips for getting the best results:

### Distortion Settings

- **Intensity (0.05-0.15)**: Higher values create more dramatic distortion
- **Speed (0.2-0.5)**: Controls how fast the distortion animates
- **Scale (4-12)**: Affects the size of distortion patterns

### Noise Weights

Balance the three layers for optimal organic feel:

- **Noise 1**: 0.4-0.6 (base layer)
- **Noise 2**: 0.2-0.4 (medium details)
- **Noise 3**: 0.1-0.3 (fine details)

### Animation

- **Duration (2-5s)**: How long the sweep takes
- **Edge Width (0.1-0.2)**: Sharpness of the transition

### Effects

- **Chromatic Aberration (0.001-0.005)**: Subtle color splitting
- **Edge Fog (0.1-0.2)**: Creates the frosted glass look
- **Vignette (0.1-0.3)**: Focuses attention on center

![Parameter Comparison](./images/parameter-comparison.png)
_Side-by-side comparison of different parameter settings_

## Performance Considerations

### Optimization Tips

1. **Reduce FBM Octaves**: The loop in `fbm()` runs 5 times. Reducing to 3-4 can improve performance.

2. **Lower Pixel Ratio**: For lower-end devices:

   ```javascript
   renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
   ```

3. **Simplify Normal Maps**: If not critical, reduce `uNormalMapScale` or remove normal mapping entirely.

4. **Conditional Effects**: Disable chromatic aberration and vignette on mobile devices.

## Common Issues and Solutions

### Issue 1: Effect is Too Subtle

- Increase `distortionIntensity`
- Increase noise weights
- Decrease `distortionScale`

### Issue 2: Effect is Too Choppy

- Reduce FBM octaves
- Lower resolution/pixel ratio
- Simplify noise calculations

### Issue 3: Colors Look Wrong

- Check that texture is loaded correctly
- Verify alpha channel is preserved
- Adjust chromatic aberration strength

### Issue 4: Animation Feels Wrong

- Adjust GSAP easing function
- Modify `edgeWidth` for sharper/softer transitions
- Change `animationDuration` for speed

## Advanced Customization

### Custom SVG Content

Replace the `svgContent` string with your own SVG:

```javascript
const svgContent = `
<svg width="800" height="200" viewBox="0 0 800 200">
  <!-- Your custom SVG paths -->
</svg>
`;
```

### Multiple Materials

Create variations with different parameters:

```javascript
const materials = [
  createMaterial(subtleParams),
  createMaterial(dramaticParams),
  createMaterial(fastParams),
];
```

### Interactive Controls

Add mouse interaction:

```javascript
window.addEventListener("mousemove", (e) => {
  material.uniforms.uMouse.value.x = e.clientX / window.innerWidth;
  material.uniforms.uMouse.value.y = 1.0 - e.clientY / window.innerHeight;
});
```

## Exporting Your Work

The included export functionality lets you save your parameter configurations:

```javascript
pane.addButton({ title: "Export Config" }).on("click", () => {
  const config = {
    distortionIntensity: params.distortionIntensity,
    // ... all parameters
  };

  const configJson = JSON.stringify(config, null, 2);
  // Download as JSON file
});
```

![Export Dialog](./images/export-config.png)
_Exporting your custom configuration_

## Real-World Applications

This effect works great for:

- **Logo Reveals**: Product launches, branding
- **Text Animations**: Headlines, call-to-actions
- **Transitions**: Between sections or pages
- **Loading States**: Creative loading indicators
- **Hover Effects**: Interactive elements

## Browser Compatibility

This effect requires:

- WebGL 1.0 support
- ES6+ JavaScript
- Modern browser (Chrome 60+, Firefox 55+, Safari 12+, Edge 79+)

### Fallback Strategy

```javascript
if (!renderer.capabilities.isWebGL2) {
  // Show fallback content
  console.warn("WebGL not supported");
}
```

## Conclusion

You've now created a sophisticated liquid glass distortion effect using WebGL and GLSL shaders! This effect combines multiple advanced techniques:

✅ Fractal Brownian Motion for organic noise
✅ Procedural normal map generation
✅ Multi-layer distortion
✅ Chromatic aberration and post-processing
✅ Smooth animations with GSAP
✅ Interactive debugging with Tweakpane

## Next Steps

- Experiment with different SVG content
- Try adjusting parameters for unique looks
- Combine with other effects (blur, glow)
- Add interactivity (mouse tracking, scroll)
- Optimize for production use

## Resources

- [Three.js Documentation](https://threejs.org/docs/)
- [The Book of Shaders](https://thebookofshaders.com/)
- [GSAP Documentation](https://greensock.com/docs/)
- [Tweakpane Documentation](https://cocopon.github.io/tweakpane/)

## Complete Source Code

The full source code for this tutorial is available in the project files:

- `index.html` - Complete working example
- `LiquidLogo8.vue` - Vue.js component version

---

**Questions or Issues?** Feel free to experiment and make this effect your own!

![Thank You](./images/thank-you.gif)
_Happy coding! ✨_
