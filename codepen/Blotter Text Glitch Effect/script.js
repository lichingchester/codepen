let blotter = null;
let blotterText = null;
let material = null;

let tweenOffset = null;
let tweenRotation = null;

let controls = {
  offsetMin: 0,
  offsetMax: 0.1,
  offsetDurationMin: 0,
  offsetDurationMax: 0,
  offsetTimeoutMin: 100,
  offsetTimeoutMax: 1000,

  rotationMin: 0,
  rotationMax: 360,
  rotationDurationMin: 0,
  rotationDurationMax: 0,
  rotationTimeoutMin: 100,
  rotationTimeoutMax: 1000

};

let element = document.querySelector(".hello");

function initGUI() {
  const gui = new dat.GUI({
    name: 'Controls'
  });
  gui.width = 400;

  let folder_offset = gui.addFolder('Offset');
  folder_offset.add(controls, 'offsetMin', 0, 0.2);
  folder_offset.add(controls, 'offsetMax', 0, 0.2);
  folder_offset.add(controls, 'offsetDurationMin', 0, 1, 0.1);
  folder_offset.add(controls, 'offsetDurationMax', 0, 1, 0.1);
  folder_offset.add(controls, 'offsetTimeoutMin', 100, 1000, 100);
  folder_offset.add(controls, 'offsetTimeoutMax', 100, 1000, 100);
  // folder_offset.open();

  let folder_rotation = gui.addFolder('Rotation');
  folder_rotation.add(controls, 'rotationMin', 0, 360);
  folder_rotation.add(controls, 'rotationMax', 0, 360);
  folder_rotation.add(controls, 'rotationDurationMin', 0, 1, 0.1);
  folder_rotation.add(controls, 'rotationDurationMax', 0, 1, 0.1);
  folder_rotation.add(controls, 'rotationTimeoutMin', 100, 1000, 100);
  folder_rotation.add(controls, 'rotationTimeoutMax', 100, 1000, 100);
  // folder_rotation.open();
}

function draw() {
  // console.log(Blotter);

  blotterText = new Blotter.Text("HELLO", {
    family: "Oswald",
    size: 200,
    weight: 700,
    fill: "#171717"
  });

  material = new Blotter.ChannelSplitMaterial();
  material.uniforms.uAnimateNoise.value = 1;

  blotter = new Blotter(material, {
    texts: blotterText,
    needsUpdate: true
  });
  blotter.needsUpdate = true;

  const scope = blotter.forText(blotterText);

  scope.appendTo(element);

  runOffsetEffect();
  runRotationEffect();
}

function runOffsetEffect() {
  tweenOffset = gsap.to(
    material.uniforms.uOffset,
    gsap.utils.random(controls.offsetDurationMin, controls.offsetDurationMax), {
      value: gsap.utils.random(controls.offsetMin, controls.offsetMax),
      onComplete: () => {
        setTimeout(() => {
          runOffsetEffect();
        }, gsap.utils.random(controls.offsetTimeoutMin, controls.offsetTimeoutMax));
      }
    }
  );
}

function runRotationEffect() {
  tweenRotation = gsap.to(
    material.uniforms.uRotation,
    gsap.utils.random(controls.rotationDurationMin, controls.rotationDurationMax), {
      value: gsap.utils.random(controls.rotationMin, controls.rotationMax),
      onComplete: () => {
        setTimeout(() => {
          runRotationEffect();
        }, gsap.utils.random(controls.rotationTimeoutMin, controls.rotationTimeoutMax));
      }
    }
  );
}

function loadFont() {
  WebFont.load({
    google: {
      families: ["Oswald"]
    },
    active: () => draw()
  });
}

function init() {
  loadFont();
  initGUI();
}

init();