<script lang="ts">
  import TimeAgo from './utils/TimeAgo.svelte';
  import TooltipDiv from './TooltipDiv.svelte';

  export let prefix;
  export let datetime;

  const formatted_datetime = new Date(datetime);
</script>

<TooltipDiv text="{formatted_datetime}" text_size="text-xs">
{prefix} <TimeAgo date="{datetime}" live />
</TooltipDiv>
