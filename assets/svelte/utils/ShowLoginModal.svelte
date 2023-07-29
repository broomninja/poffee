<script context="module" lang="ts">
  const container_id = "header-live";
  export function showLoginModal() {
    let el = document.getElementById(container_id);
    window.liveSocket.execJS(el, el.getAttribute("data-show-login"));
  }
</script>