<script lang="ts">
  //
  // Displays a relative time that will live update without
  // user reloading the browser page
  //

  import TimeAgo from './utils/TimeAgo.svelte';
  import TooltipDiv from './TooltipDiv.svelte';

  export let prefix;
  export let datetime;

  const date_object = new Date(datetime);
  const formatted_datetime = date_object.toUTCString();
</script>

<TooltipDiv text="{formatted_datetime}" text_size="text-xs">
  {prefix} <TimeAgo date="{datetime}" live />
</TooltipDiv>
