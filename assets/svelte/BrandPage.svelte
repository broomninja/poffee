<script lang="ts">
  import { DoubleBounce, Moon } from 'svelte-loading-spinners';

  export let streamer;
  export let twitch_user;
  export let streaming_status;
  export let current_user;

  let brand_page = streamer?.brand_page;
  let feedbacks = brand_page?.feedbacks;

  console.log(`streamer = ${JSON.stringify(streamer, null, 2)}`);

</script>

{#if !!twitch_user}
<a href="https://www.twitch.tv/{twitch_user.login}" target="_blank">
  {twitch_user.display_name}
</a>
{/if}


{#if !!current_user}
<a href="/">
Create Feedback
</a>
{:else}
aaaa
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
