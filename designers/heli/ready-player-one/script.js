document.addEventListener("DOMContentLoaded", function (event) {
  const wrapper = document.querySelector("#wrapper");
  const enterText = document.querySelector("#enter-text");
  const enterText1 = enterText.querySelectorAll("span")[0];
  const enterText2 = enterText.querySelectorAll("span")[1];
  const actor = document.querySelector("#actor");
  const tunnel = document.querySelector("#tunnel");
  const slider = document.querySelector("#slider");
  let swiper = {};

  // go inside transition
  function state2() {
    wrapper.classList.add("state-2");

    const tl = gsap.timeline();

    tl.set(actor, { zIndex: 1 });
    tl.set(tunnel, { visibility: "visible", zIndex: 2 });
    tl.set(slider, { visibility: "visible", opacity: 0, scale: 0.8 });

    tl.to(actor, 1, {
      scale: 14,
      ease: CustomEase.create(
        "custom",
        "M0,0 C0.39,0 0.437,0.023 0.478,0.05 0.571,0.11 0.522,0.292 0.554,0.502 0.588,0.73 0.586,0.88 0.64,0.928 0.679,0.962 0.698,1 1,1 "
      ),
    });

    tl.to(
      tunnel,
      0.8,
      {
        opacity: 1,
      },
      "-=0.7"
    );
    tl.to(tunnel, 2.5, { scale: 3, ease: "power4.out" }, "-=1");
    tl.add(() => swiper.slideTo(2, 1200), "-=2.2");
    tl.to(slider, 1, { scale: 1, opacity: 1, ease: "power2.out" }, "-=1.9");
  }

  // show text effect
  function state1() {
    wrapper.classList.add("state-1");
    gsap.fromTo(
      [enterText1, enterText2],
      0.5,
      {
        opacity: 0,
        scale: 0.9,
      },
      {
        opacity: 1,
        scale: 1,
        delay: 0.3,
      }
    );
  }

  // init
  function initial() {
    // init text
    gsap.set([enterText1, enterText2], { opacity: 0 });

    // init swiper
    swiper = new Swiper(".swiper-container", {
      effect: "coverflow",
      speed: 500,
      grabCursor: true,
      centeredSlides: true,
      slidesPerView: "auto",
      slideToClickedSlide: true,
      coverflowEffect: {
        rotate: 0,
        stretch: -80,
        depth: 200,
        modifier: 2,
        slideShadows: true,
      },
      scrollbar: {
        el: ".swiper-scrollbar",
        draggable: true,
      },
    });
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
