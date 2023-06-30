<script lang="ts">
  export let streamer;
</script>

<a href="/u/{streamer.display_name}" data-phx-link="redirect" data-phx-link-state="push">
<div class="tooltip bg-secondary-300 rounded-lg p-1">
  <img class="rounded-md inline-block " width=55 height=55 src="{streamer.profile_url}" alt="{streamer.display_name}"/>
  <!-- Tooltip -->
  <span class="tooltiptext">
      {streamer.display_name}
  </span>
  <!-- End Tooltip -->
</div>
</a>

<style>
.tooltip {
  position: relative;
  display: inline-block;
}

.tooltip .tooltiptext {
  visibility: hidden;
  width: 150px;
  background-color: #F7F5B3;
  color: #222;
  text-align: center;
  border-radius: 6px;
  padding: 5px 10px;
  
  /* Position the tooltip */
  position: absolute;
  z-index: 10;
  top: 100%;
  left: 50%;
  margin-left: -75px;
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
  border-color: transparent transparent #F7F5B3 transparent;
}

.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 1;
}
</style>