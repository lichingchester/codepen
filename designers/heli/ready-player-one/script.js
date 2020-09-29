document.addEventListener("DOMContentLoaded", function (event) {
  const wrapper = document.querySelector("#wrapper");
  const enterText = document.querySelector("#enter-text");
  const enterText1 = enterText.querySelectorAll("span")[0];
  const enterText2 = enterText.querySelectorAll("span")[1];
  const actor = document.querySelector("#actor");
  const tunnel = document.querySelector("#tunnel");

  function state2() {
    const tl = gsap.timeline();

    tl.set(actor, { zIndex: 1 });
    tl.set(tunnel, { visibility: "visible", zIndex: 2 });

    tl.to(actor, 2.5, {
      scale: 14,
      transformOrigin: "50.5% 44%",
      // ease: "power4.in",
      ease: CustomEase.create(
        "custom",
        "M0,0 C0.39,0 0.437,0.023 0.478,0.05 0.571,0.11 0.522,0.292 0.554,0.502 0.588,0.73 0.586,0.88 0.64,0.928 0.679,0.962 0.698,1 1,1 "
      ),
      // ease: CustomEase.create(
      //   "custom",
      //   "M0,0 C0.46,0 0.509,0.026 0.584,0.074 0.846,0.24 0.792,1 1,1 "
      // ),
    });
    tl.to(
      tunnel,
      0.8,
      {
        opacity: 1,
        // ease: "power4.in",
        // ease: CustomEase.create(
        //   "custom",
        //   "M0,0 C0.272,0 0.644,0.146 0.782,0.5 0.837,0.642 1,1 1,1 "
        // ),
      },
      "-=1.1"
    );
    tl.to(tunnel, 1.2, { scale: 2.5, ease: "power4.Out" }, "-=1.1");
  }

  function state1() {
    wrapper.classList.add("state-1");
    gsap.to([enterText1, enterText2], 0.5, { opacity: 1, y: 0, delay: 0.3 });
  }

  function initial() {
    gsap.set([enterText1, enterText2], { opacity: 0, y: 10 });
  }

  // events
  enterText.addEventListener("click", state2);

  // main process
  function main() {
    initial();

    setTimeout(() => {
      state1();
    }, 1000);
  }

  main();
});
