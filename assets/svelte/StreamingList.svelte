<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { fly } from "svelte/transition"
  import { quadIn } from 'svelte/easing';

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
    pushEvent("display_ready");
  });

  onDestroy(() => {
    window.removeEventListener('resize', debouncedSetWindowWidth);
  });

  // $: console.log("streamers = " + streamers)
  // $: console.log("event = " + event)
  // $: console.log("fly_offset = " + fly_offset)

</script>

<main>
  <div class="flex whitespace-nowrap">
    <div class="pr-3">Live streamers</div>
    <div class="flex">
      {#each streamers as streamer, i (streamer.num)}
        {#if event === "add_streamer" && i == 0}
          <div class="px-3" in:fly={{duration: 1650, easing: quadIn, x: fly_offset}}>{streamer.num}</div>
        {:else}
          <div class="px-3">{streamer.num}</div>
        {/if}
      {/each}
    </div>
  </div>
</main>