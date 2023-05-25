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

Hooks.FlashAutoHide = {
  HIDE_AFTER_MS: 5000,

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

// Hooks.SetSession = {
//   DEBOUNCE_MS: 200,

//   mounted() {
//     // `this.el` is the form.
//     this.el.addEventListener("input", (e) => {
//       clearTimeout(this.timeout)
//       this.timeout = setTimeout(() => {
//         // Ajax request to update session.
//         fetch(`/api/session?${e.target.name}=${encodeURIComponent(e.target.value)}`, { method: "post" })

//         // Optionally, include this so other LiveViews can be notified of changes.
//         this.pushEventTo(".phx-hook-subscribe-to-session", "updated_session_data", [e.target.name, e.target.value])
//       }, this.DEBOUNCE_MS)
//     })
//   },
//  }

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
