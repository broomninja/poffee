<script lang="ts">
  import { DoubleBounce } from 'svelte-loading-spinners';

  // size in px
  export let size = 20;
  export let color = "#6bc655";
  export let duration = "1.5s";

</script>

<div>
  <DoubleBounce size={size} color={color} unit="px" duration={duration} />
</div>