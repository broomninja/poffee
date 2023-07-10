<script lang="ts">
  export let text;
  export let background_color = "#FFE";
  export let text_color = "#222";
  export let classes = "";
</script>

<div class="tooltip {classes}">
  <slot></slot>
  <!-- Tooltip -->
  <span class="tooltiptext whitespace-nowrap text-sm font-semibold" 
        style="--background_color: {background_color}; --text_color: {text_color};">
      {text}
  </span>
  <!-- End Tooltip -->
</div>

<style>
  .tooltip {
    position: relative;
    display: inline-block;
  }

  .tooltip .tooltiptext {
    visibility: hidden;
    width: auto;
    background-color: var(--background_color);
    color: var(--text_color);
    text-align: center;
    border-radius: 6px;
    padding: 5px 15px;
    
    /* Position the tooltip */
    position: absolute;
    z-index: 10;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    opacity: 0;
    transition: opacity 0.3s;

  }

  .tooltip .tooltiptext::after {
    content: "";
    position: absolute;
    left: 50%;
    bottom: 100%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: transparent transparent var(--background_color) transparent;
  }

  .tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
  }
</style>