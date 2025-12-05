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
uniform sampler2D uTexture;  // The SVG texture we want to distort
uniform float uTime;         // Elapsed time for animation
uniform float uProgress;     // Animation progress (0.0 to 1.2)

// Distortion parameters
uniform float uDistortionIntensity;  // How strong the distortion effect is (0.08)
uniform float uDistortionSpeed;      // How fast the noise animates (0.3)
uniform float uDistortionScale;      // Base scale of noise patterns (8.0)
uniform float uNoise1Weight;         // Weight of first noise layer (0.5)
uniform float uNoise2Weight;         // Weight of second noise layer (0.3)
uniform float uNoise3Weight;         // Weight of third noise layer (0.2)
uniform float uNoise2Scale;          // Scale multiplier for noise layer 2 (2.0)
uniform float uNoise3Scale;          // Scale multiplier for noise layer 3 (4.0)
uniform float uNoise2Speed;          // Speed multiplier for noise layer 2 (0.7)
uniform float uNoise3Speed;          // Speed multiplier for noise layer 3 (0.5)
uniform float uEdgeWidth;            // Width of the distortion edge transition (0.15)

// Effect parameters
uniform float uChromaticAberration;  // RGB color separation strength (0.003)
uniform float uEdgeFog;              // Frosted glass fog intensity (0.15)
uniform float uVignetteIntensity;    // Edge darkening amount (0.2)
uniform float uNormalMapInfluence;   // How much normal map affects distortion (0.02)
uniform float uNormalMapScale;       // Scale of the normal map patterns (4.0)
uniform float uNormalMapOffset;      // Sample offset for normal calculation (0.001)
uniform float uFlowSpeed;            // Speed of directional flow (0.1)
uniform float uFlowStrength;         // Strength of directional flow (0.2)

// FBM parameters
uniform float uFbmSpeed;       // Speed of FBM animation (0.1)
uniform float uFbmAmplitude;   // Initial amplitude of noise (0.5)
uniform float uFbmFrequency;   // Initial frequency of noise (1.0)
uniform float uFbmLacunarity;  // Frequency multiplier per octave (2.0)
uniform float uFbmGain;        // Amplitude multiplier per octave (0.5)

varying vec2 vUv;  // UV coordinates passed from vertex shader
```

**Understanding Uniforms:**

Uniforms are values that remain constant for all pixels in a single render pass but can be updated from JavaScript. Think of them as the "control knobs" for our shader. They're divided into logical groups:

1. **Core Uniforms**: Time and progress drive the animation
2. **Distortion Group**: Controls the overall distortion behavior
3. **Effects Group**: Fine-tunes visual quality (chromatic aberration, fog, vignette)
4. **FBM Group**: Parameters for the noise generation algorithm

![Shader Uniforms Diagram](./images/shader-uniforms.png)
_How uniforms flow from JavaScript to the shader_

## Step 4: Implementing Gradient Noise

Gradient noise is the foundation of our effect. It creates smooth, organic patterns that look natural rather than random static.

### Helper Functions

First, we need some mathematical helper functions:

```glsl
// Modulo 289 - keeps values in a manageable range
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289_2(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Permutation function - creates pseudo-random values
vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}
```

These helper functions ensure our noise values stay within numerical limits and create deterministic "randomness" - the same input always produces the same output, which is crucial for consistent, smooth noise.

### The Gradient Noise Function

```glsl
float gradientNoise(vec2 v) {
  // Constants for skewing and unskewing
  const vec4 C = vec4(0.211324865405187,   // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,   // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,   // -1.0 + 2.0 * C.x
                      0.024390243902439);  // 1.0 / 41.0

  // First corner - skew the space to determine cell
  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  // Determine which simplex we're in
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

  // Offsets for other corners
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations to avoid repeating patterns
  i = mod289_2(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
    + i.x + vec3(0.0, i1.x, 1.0));

  // Calculate gradients - creates smooth transitions
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m;      // Square it
  m = m*m;      // Square it again for even smoother falloff

  // Calculate final gradient noise
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  // Normalize gradients (prevents artifacts)
  m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);

  // Compute final noise value
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
```

**How It Works:**

1. **Space Skewing**: The input coordinates are skewed to divide space into triangular simplexes (2D) rather than squares. This is more efficient and creates more natural-looking patterns.

2. **Corner Detection**: For any given point, we determine which simplex triangle it falls into and calculate distances to all three corners.

3. **Gradient Calculation**: Each corner has a gradient vector, and we interpolate between them using smooth falloff functions (the `m*m*m*m` creates very smooth transitions).

4. **Final Value**: The dot products between gradients and position vectors create the actual noise pattern, scaled by 130.0 for appropriate output range.

**Why Simplex Noise?**

- **Smoother**: No directional artifacts like grid-based noise
- **Faster**: Fewer calculations than Perlin noise in 2D and higher dimensions
- **Natural**: Creates organic, flowing patterns perfect for liquid effects

![Gradient Noise Pattern](./images/gradient-noise.png)
_Example of gradient noise output - notice the smooth, organic patterns_

## Step 5: Fractal Brownian Motion (FBM)

FBM (Fractal Brownian Motion) combines multiple layers (octaves) of noise at different frequencies to create complex, natural-looking patterns. Think of it like layering musical octaves - each layer adds more detail.

```glsl
float fbm(vec2 p, float time) {
  float value = 0.0;                      // Accumulated noise value
  float amplitude = uFbmAmplitude;        // Start with base amplitude (0.5)
  float frequency = uFbmFrequency;        // Start with base frequency (1.0)

  // Loop through 5 octaves (layers) of noise
  for(int i = 0; i < 5; i++) {
    // Add this octave's contribution to the total value
    // p * frequency: scales the space (higher = more detail)
    // time * uFbmSpeed: animates the noise over time
    value += amplitude * gradientNoise(p * frequency + time * uFbmSpeed);

    // Increase frequency for next octave (default: 2x)
    frequency *= uFbmLacunarity;

    // Decrease amplitude for next octave (default: 0.5x)
    amplitude *= uFbmGain;
  }
  return value;
}
```

**How FBM Creates Realistic Patterns:**

Imagine looking at a coastline:

- **Octave 1** (low frequency, high amplitude): The overall shape of the coast
- **Octave 2**: Major bays and peninsulas
- **Octave 3**: Smaller inlets and outcroppings
- **Octave 4**: Individual rocks and beaches
- **Octave 5**: Tiny pebbles and sand grains

Each octave adds finer detail while contributing less to the overall shape.

**Key Parameters Explained:**

- **Amplitude** (starts at 0.5): Controls the "height" or strength of each layer

  - Octave 1: 0.5 × noise
  - Octave 2: 0.25 × noise (0.5 × 0.5)
  - Octave 3: 0.125 × noise (0.5 × 0.5 × 0.5)
  - And so on...

- **Frequency** (starts at 1.0): Controls the "detail level" or zoom

  - Octave 1: 1.0 × position (broad features)
  - Octave 2: 2.0 × position (medium details)
  - Octave 3: 4.0 × position (fine details)
  - And so on...

- **Lacunarity** (2.0): How much frequency increases per octave

  - Higher values (>2.0) = more dramatic detail jumps (sharper, more chaotic)
  - Lower values (<2.0) = smoother detail transitions (softer, more fluid)

- **Gain** (0.5): How much amplitude decreases per octave
  - Higher values (>0.5) = later octaves contribute more (noisier, rougher)
  - Lower values (<0.5) = later octaves contribute less (smoother, cleaner)

**Example Output:**

```
Octave 1: ~~~~~~~~  (broad waves)
Octave 2: ~~^^~~^^  (medium ripples)
Octave 3: ~^v^v^v^  (fine detail)
Octave 4: ^v^v^v^v  (tiny bumps)
Octave 5: vvvvvvvv  (micro texture)
Combined: ≈≈≈≈≈≈≈≈  (rich, organic pattern)
```

**Why 5 Octaves?**

- Fewer (2-3): Simpler, faster, but less organic
- 5: Sweet spot for realistic detail without performance hit
- More (6-8): Extremely detailed but slower, diminishing returns

![FBM Layers](./images/fbm-layers.png)
_Multiple octaves of noise combined to create FBM - notice how each layer adds finer detail_

## Step 6: Procedural Normal Map Generation

We generate a normal map on-the-fly to add depth and dimension to our distortion. Normal maps store surface orientation information that helps create the illusion of 3D bumps and details on flat surfaces.

```glsl
vec3 generateNormalMap(vec2 uv, float time) {
  float offset = uNormalMapOffset;  // Typically 0.001 - very small sample distance

  // Sample FBM at three points to calculate gradients
  // Think of this as measuring the "height" at three nearby points
  float center = fbm(uv, time);                      // Height at current position
  float right = fbm(uv + vec2(offset, 0.0), time);   // Height slightly to the right
  float top = fbm(uv + vec2(0.0, offset), time);     // Height slightly above

  // Calculate derivatives (rate of change)
  // These tell us how steeply the surface slopes in X and Y directions
  float dx = (right - center) / offset;  // Slope in X direction
  float dy = (top - center) / offset;    // Slope in Y direction
  // Example: If right > center, surface slopes upward to the right

  // Create normal vector from the slopes
  // The normal points perpendicular to the surface
  vec3 normal = normalize(vec3(-dx, -dy, 1.0));
  // -dx and -dy because we want normals to point "outward"
  // 1.0 in Z keeps the normal generally pointing toward camera
  // normalize() ensures the vector has length 1.0

  // Remap from [-1, 1] to [0, 1] for use as texture
  return normal * 0.5 + 0.5;
  // GPU textures store values 0-1, but normals are -1 to 1
  // This converts: -1 becomes 0, 0 becomes 0.5, 1 becomes 1
}
```

**Understanding Normal Maps:**

A normal map is essentially a "bump map" that stores surface orientation. Imagine running your hand over a bumpy surface - the normal map encodes which direction each point is facing.

**The Math Behind It:**

1. **Height Sampling**: We sample our noise function at three points forming an "L" shape:

   ```
   [top]
     |
   [center]--[right]
   ```

2. **Gradient Calculation**: The difference between samples tells us the slope:

   - If `right > center`: Surface slopes up to the right (positive slope)
   - If `right < center`: Surface slopes down to the right (negative slope)
   - Same logic applies for `top` vs `center` in the Y direction

3. **Normal Vector Construction**:
   - `vec3(-dx, -dy, 1.0)` creates a 3D vector
   - The negative signs flip the direction (convention for outward-facing normals)
   - `1.0` in Z means the normal has a strong "forward" component
   - Small dx/dy values = nearly flat surface = normal points mostly forward
   - Large dx/dy values = steep slope = normal tilts significantly

**Why This Creates Depth:**

When we use these normals to influence the distortion:

- Points with normals tilted left push UVs one direction
- Points with normals tilted right push UVs the opposite direction
- This creates the appearance of bumps and valleys
- The effect is subtle but adds organic complexity

**Visualizing the Effect:**

```
Flat Surface:     With Normal Map:
═════════════     ≈≈≈≈≈≈≈≈≈≈≈≈≈
                  (appears bumpy)
```

**Key Parameters:**

- **uNormalMapOffset (0.001)**: Sample distance

  - Smaller = captures fine details, but can be noisy
  - Larger = smoother, but loses detail
  - Too large = creates obvious stepping artifacts

- **uNormalMapScale (4.0)**: UV scaling before sampling

  - Higher = more frequent bumps (fine texture)
  - Lower = fewer, broader bumps (macro details)

- **uNormalMapInfluence (0.02)**: How much the normal affects distortion
  - Higher = more pronounced bumps
  - Lower = subtler effect
  - Zero = normal map disabled (faster performance)

**Performance Note:**

Generating normal maps procedurally requires 3 FBM calls per pixel (center, right, top). Each FBM call runs 5 octaves of noise. That's 15 noise calculations just for the normal map! This is why `uNormalMapInfluence` is kept small - it's expensive but adds important detail.

![Normal Map Generation](./images/normal-map.png)
_How normal maps add depth to flat surfaces - the RGB colors encode surface orientation_

## Step 7: The Frosted Glass Distortion

This is the heart of our effect - combining multiple noise layers with directional flow to create that characteristic frosted glass appearance.

```glsl
vec2 getFrostedGlassDistortion(vec2 uv, float time, float intensity) {
  // Three layers of noise at different scales and speeds
  // Each layer is sampled from the same FBM function but at different scales

  // Layer 1: Base distortion - broad, slow-moving patterns
  float noise1 = fbm(uv * uDistortionScale, time * uDistortionSpeed);
  // Example: uDistortionScale = 8.0, uDistortionSpeed = 0.3

  // Layer 2: Medium detail - faster, finer patterns
  float noise2 = fbm(uv * uDistortionScale * uNoise2Scale,
                     time * uDistortionSpeed * uNoise2Speed);
  // uNoise2Scale = 2.0 → samples at 16.0 scale (8.0 × 2.0)
  // uNoise2Speed = 0.7 → animates at 0.21 speed (0.3 × 0.7)

  // Layer 3: Fine detail - fastest, finest patterns
  float noise3 = fbm(uv * uDistortionScale * uNoise3Scale,
                     time * uDistortionSpeed * uNoise3Speed);
  // uNoise3Scale = 4.0 → samples at 32.0 scale (8.0 × 4.0)
  // uNoise3Speed = 0.5 → animates at 0.15 speed (0.3 × 0.5)

  // Weighted combination of noise layers
  // Each layer contributes to both X and Y distortion
  vec2 distortion = vec2(noise1 * uNoise1Weight +      // 0.5
                         noise2 * uNoise2Weight +      // 0.3
                         noise3 * uNoise3Weight);      // 0.2
  // Total weight = 1.0 (0.5 + 0.3 + 0.2)
  // This creates a single scalar value that becomes both X and Y offset

  // Add directional flow - creates flowing, liquid motion
  float flowAngle = time * uFlowSpeed + noise1;
  // flowAngle changes over time AND varies by position (noise1)
  // This creates swirling, organic motion
  distortion += vec2(cos(flowAngle), sin(flowAngle)) * uFlowStrength;
  // cos/sin converts angle to 2D direction vector
  // uFlowStrength (0.2) controls how strong the flow is

  // Apply overall intensity (controlled by progress mask)
  return distortion * intensity;
  // intensity is typically progressMask, so distortion only appears where sweep is
}
```

**Understanding the Multi-Layer Approach:**

**Layer 1 - Base Distortion (Weight: 0.5)**

- **Scale**: 8.0 (larger patterns, fewer details)
- **Speed**: 0.3 (slow, gentle movement)
- **Purpose**: Establishes the overall flow and shape
- **Appearance**: Like large ripples on water

**Layer 2 - Medium Detail (Weight: 0.3)**

- **Scale**: 16.0 (8.0 × 2.0) (medium patterns)
- **Speed**: 0.21 (0.3 × 0.7) (moderate movement)
- **Purpose**: Adds texture and variation
- **Appearance**: Like smaller waves riding on larger ones

**Layer 3 - Fine Detail (Weight: 0.2)**

- **Scale**: 32.0 (8.0 × 4.0) (fine patterns, many details)
- **Speed**: 0.15 (0.3 × 0.5) (faster relative movement)
- **Purpose**: Creates surface texture and complexity
- **Appearance**: Like tiny ripples and shimmer

**Why This Creates a Glass Effect:**

1. **Multiple Scales**: Real frosted glass has imperfections at different scales - large swirls, medium scratches, fine grain. Our three layers mimic this.

2. **Different Speeds**: In real glass, different parts seem to move at different rates when light plays across it. Our varied speeds create this illusion.

3. **Weighted Combination**: The weights (0.5, 0.3, 0.2) ensure the base layer dominates while details add complexity without overwhelming.

**The Flow Component:**

```glsl
float flowAngle = time * uFlowSpeed + noise1;
distortion += vec2(cos(flowAngle), sin(flowAngle)) * uFlowStrength;
```

This adds directional, swirling motion:

- **`time * uFlowSpeed`**: Constant rotation over time
- **`+ noise1`**: Rotation speed varies by position (creates swirls)
- **`cos/sin`**: Converts angle to circular motion
- **Result**: Each point flows in a slightly different direction, creating organic swirling

**Visualizing the Layers:**

```
Layer 1:  ▓▓▓░░░▓▓▓░░░  (broad strokes)
Layer 2:  ▒▒░▒▒░▒▒░▒▒░  (medium texture)
Layer 3:  ░▒░▒░▒░▒░▒░▒  (fine grain)
Flow:     ↻ ↺ ↻ ↺ ↻ ↺   (swirling motion)
Combined: ≋≋≈≈≋≋≈≈≋≋≈≈  (rich, glass-like)
```

**Tuning the Effect:**

**For Subtle Glass:**

- Increase Layer 1 weight (0.6)
- Decrease Layers 2 & 3 weights (0.25, 0.15)
- Lower flow strength (0.1)

**For Dramatic Distortion:**

- Balance weights more evenly (0.4, 0.35, 0.25)
- Increase flow strength (0.3)
- Increase overall intensity

**For Faster Animation:**

- Increase all speed multipliers
- Increase flow speed (0.2)

**For Finer Detail:**

- Increase all scale multipliers
- Increase Layer 3 weight

**Mathematical Breakdown:**

At any given point, the final distortion is:

```
distortion.x = distortion.y =
  (noise1 × 0.5) + (noise2 × 0.3) + (noise3 × 0.2) +
  cos(time × 0.1 + noise1) × 0.2
```

This single value is used for both X and Y, creating diagonal distortion. In a more advanced version, you could use different noise for X and Y to create more complex patterns.

**Performance Impact:**

This function calls FBM three times, each with 5 octaves:

- Total: 15 noise calculations per pixel per frame
- This is the most expensive part of the shader
- Reducing to 2 layers or 4 octaves per FBM significantly improves performance

**Why Multiple Noise Layers?**

- **Layer 1**: Large-scale distortion (the "glass pane")
- **Layer 2**: Medium details (surface scratches and imperfections)
- **Layer 3**: Fine details (microscopic texture)

This creates a more organic, glass-like appearance than single-layer noise, which would look too uniform and artificial.

![Distortion Layers](./images/distortion-layers.gif)
_Animated visualization of the three noise layers combining to create the final effect_

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

Now let's put it all together in the main function. This is where every pixel's final color is calculated:

```glsl
void main() {
  // Step 1: Get UV coordinates (texture coordinates for this pixel)
  vec2 uv = vUv;  // Range: 0.0 to 1.0 for both x and y

  // Step 2: Scale to 50% and center the logo
  // This makes the logo appear smaller on the canvas
  float scale = 0.5;
  uv = (uv - 0.5) / scale + 0.5;
  // Example: uv (0.5, 0.5) stays at center
  //          uv (0.0, 0.0) becomes (-0.5, -0.5) etc.

  // Step 3: Create animated progress mask
  // This creates the "sweeping" effect from left to right
  float maskStart = uProgress - uEdgeWidth;  // Left edge of distortion
  float maskEnd = uProgress;                  // Right edge of distortion
  float progressMask = smoothstep(maskStart, maskEnd, uv.x);
  // progressMask = 0.0 (no effect) to 1.0 (full effect)
  // smoothstep creates smooth transition instead of hard edge

  // Step 4: Generate procedural normal map
  // This adds depth information for more realistic distortion
  vec3 normalMap = generateNormalMap(uv * uNormalMapScale, uTime);
  // normalMap.xy contains surface gradient information
  // normalMap.z would be the "height" (not used here)

  // Step 5: Calculate the main frosted glass distortion
  float distortionIntensity = uDistortionIntensity * progressMask;
  // Multiply by progressMask so distortion only appears in swept area
  vec2 glassDistortion = getFrostedGlassDistortion(uv, uTime, distortionIntensity);
  // Returns a 2D offset vector for UV coordinates

  // Step 6: Add subtle normal map influence
  // Normal map adds extra "bumps" to the distortion
  glassDistortion += (normalMap.xy - 0.5) * uNormalMapInfluence * progressMask;
  // (normalMap.xy - 0.5) converts from [0,1] to [-0.5, 0.5] range

  // Step 7: Apply distortion to UV coordinates
  vec2 distortedUv = uv + glassDistortion;
  // Original UV + distortion offset = new sampling position

  // Step 8: Bounds checking - discard pixels outside texture
  if (distortedUv.x < 0.0 || distortedUv.x > 1.0 ||
      distortedUv.y < 0.0 || distortedUv.y > 1.0) {
    // If distortion pushed UV outside valid range, render transparent
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    // Step 9: Sample texture with chromatic aberration
    // Use normal map to determine aberration direction
    vec2 aberrationDir = (normalMap.xy - 0.5) * 2.0;  // Convert to [-1, 1]
    float aberrationStrength = uChromaticAberration * progressMask;
    vec3 color = chromaticAberration(uTexture, distortedUv,
                                     aberrationDir, aberrationStrength);
    // This separates RGB channels slightly for glass-like color fringing

    // Step 10: Add frosted glass fog effect at the distortion edge
    // Creates that characteristic "cloudy" look at transition edge
    float edgeFog = smoothstep(maskStart + 0.05, maskEnd - 0.05, uv.x);
    edgeFog = 1.0 - edgeFog;  // Invert so fog is at the edge
    color = mix(color, vec3(1.0), edgeFog * uEdgeFog * progressMask);
    // mix() blends between original color and white based on fog amount

    // Step 11: Apply vignette (darkens edges)
    float vig = vignette(distortedUv, uVignetteIntensity * progressMask);
    color *= vig;  // Multiply to darken
    // Only applied in distorted areas (progressMask)

    // Step 12: Preserve original alpha channel
    float alpha = texture2D(uTexture, distortedUv).a;
    // Keep transparency where SVG is transparent

    // Step 13: Output final color
    gl_FragColor = vec4(color, alpha);
  }
}
```

**Execution Flow Breakdown:**

1. **UV Transformation** (lines 1-7): Prepares coordinates
2. **Progress Mask** (lines 9-14): Determines which pixels are affected
3. **Distortion Calculation** (lines 16-27): Computes UV offset
4. **Safety Check** (lines 29-32): Handles edge cases
5. **Color Sampling** (lines 34-42): Gets distorted color with effects
6. **Post-Processing** (lines 44-52): Applies fog and vignette
7. **Final Output** (line 57): Writes pixel color

**Why This Order Matters:**

- **Early masking**: `progressMask` calculated once and reused
- **Distortion before sampling**: UV must be modified before texture lookup
- **Effects after sampling**: Chromatic aberration needs the texture
- **Post-processing last**: Fog and vignette applied to final color

**Performance Note:**

Each `texture2D()` call is expensive. That's why `chromaticAberration()` does 3 samples (R, G, B) instead of the main shader doing them separately - it's more efficient.

![Shader Pipeline](./images/shader-pipeline.png)
_Step-by-step visualization of the shader processing - each stage builds on the previous_

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
