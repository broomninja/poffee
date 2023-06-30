<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { fly } from "svelte/transition"
  import { quadIn } from 'svelte/easing';

  import Streamer from './Streamer.svelte';

  export let event;
  export let streamers;
  export let pushEvent;

  let fly_offset;

  const debounce = (func, delay) => {
    let timer;

    return function () {
      const context = this;
      const args = arguments;
      clearTimeout(timer);
      timer = setTimeout(() => func.apply(context, args), delay);
    };
  };

  const setWindowWidth = () => {
    fly_offset = window.innerWidth - 260;
    pushEvent("window_width_change", window.innerWidth);
  };

  const debouncedSetWindowWidth = debounce(setWindowWidth, 150);

  onMount(() => {
    window.addEventListener('resize', debouncedSetWindowWidth);
    setWindowWidth();
  });

  onDestroy(() => {
    window.removeEventListener('resize', debouncedSetWindowWidth);
  });

  // $: console.log((Date()) + " streamers = " + streamers.length)
  // $: console.log((Date()) + " event = " + event)

</script>

<main>
  <div class="flex whitespace-nowrap items-center justify-stretch">
    <div class="pr-2 sm:pr-4 font-semibold">Live streamers</div>
    <div class="flex">
      {#each streamers as streamer, i (streamer.user_id)}
        {#if event === "add_streamer" && i == 0}
          <div class="px-1 sm:px-2 " in:fly={{duration: 1650, easing: quadIn, x: fly_offset}}><Streamer streamer={streamer} /></div>
        {:else}
          <div class="px-1 sm:px-2 "><Streamer streamer={streamer} /></div>
        {/if}
      {/each}
    </div>
  </div>
</main>
