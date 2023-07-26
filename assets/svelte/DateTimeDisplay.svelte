<script lang="ts">
	import TimeAgo from './utils/TimeAgo.svelte';
  
  export let prefix;
  export let datetime;
</script>

{prefix} <TimeAgo date="{datetime}" live />
