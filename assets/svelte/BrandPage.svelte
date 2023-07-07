<script lang="ts">
  import { DoubleBounce, Moon } from 'svelte-loading-spinners';

  export let streamer;
  export let streaming_status;
  export let current_user;

  let brand_page = streamer?.brand_page;
  let feedbacks = brand_page?.feedbacks;

  console.log(`streamer = ${JSON.stringify(streamer, null, 2)}`);

</script>

<a href="/u/{streamer.username}" data-phx-link="redirect" data-phx-link-state="push">
  {streamer.username}
</a>

{#if !!current_user}
<a href="/">
Create Feedback
</a>
{:else}
aaaa
{/if}

{#if streaming_status === "online" }
  <DoubleBounce size="40" color="#6bc655" unit="px" duration="1.5s" />
{:else if streaming_status === "offline" }
  Offline
{:else}
  <Moon size="30" color="#FF3E00" unit="px" duration="1.5s" />
{/if}

<div class="columns-3">
    <!-- fixed-width -->
    <div class="w-fixed w-full  px-4 border border-black">
A  
    </div>
    <div class="w-fixed w-full  px-4 border border-black">
B
    </div>
    <div class="w-fixed w-full px-4 border border-black">
C
    </div>

</div>
