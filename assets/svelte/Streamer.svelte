<script lang="ts">
  import TooltipDiv from './TooltipDiv.svelte';
  export let streamer;
</script>

<TooltipDiv text={streamer.display_name} classes="bg-secondary-700 rounded-lg p-1">
   <a href="/u/{streamer.display_name}" data-phx-link="redirect" data-phx-link-state="push">
    <img class="rounded-md inline-block" width=55 height=55 src="{streamer.profile_image_url}" alt="{streamer.display_name}"/>
  </a>
</TooltipDiv>
