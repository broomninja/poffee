// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";


// LiveView Hooks
let Hooks = {};

Hooks.FlashAutoHideHook = {
  HIDE_AFTER_MS: 4000,

  mounted() {
    let hide = () =>
      liveSocket.execJS(this.el, this.el.getAttribute('phx-click'));
    this.timer = setTimeout(() => hide(), this.HIDE_AFTER_MS);
    this.el.addEventListener('phx:hide-start', () => clearTimeout(this.timer));
    this.el.addEventListener('mouseover', () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => hide(), this.HIDE_AFTER_MS);
    });
  },
  destroyed() {
    clearTimeout(this.timer);
  },
};

Hooks.SearchBarHook = {

  mounted() {
    const searchBarContainer = this.el;
    document.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') {
        return;
      }

      const focusElemnt = document.querySelector(':focus');

      if (!focusElemnt) {
        return;
      }

      if (!searchBarContainer.contains(focusElemnt)) {
        return;
      }

      event.preventDefault();

      const tabElements = document.querySelectorAll(
        '#search-input, #searchbox__results_list a',
      );
      const focusIndex = Array.from(tabElements).indexOf(focusElemnt);
      const tabElementsCount = tabElements.length - 1;

      if (event.key === 'ArrowUp') {
        tabElements[focusIndex > 0 ? focusIndex - 1 : tabElementsCount].focus();
      }

      if (event.key === 'ArrowDown') {
        tabElements[focusIndex < tabElementsCount ? focusIndex + 1 : 0].focus();
      }
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29D" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(180));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
