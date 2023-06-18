<script lang="ts">
    import { fly } from "svelte/transition"
    import { linear } from 'svelte/easing';

    export let event;
    export let streamers;
    export let pushEvent;

    function add_streamer() {
        pushEvent("add_streamer");
    }

    function update_streamer_list() {
        pushEvent("update_streamer_list");
    }

    //$: console.log("streamers = " + streamers)
    //$: console.log("event = " + event)

</script>

<main>
  <div class="flex">
    <div class="pr-3">Live streamers</div>
    <div class="flex">
      {#each streamers as streamer, i (streamer.num)}
        {#if event === "add_streamer" && i == 0}
          <div class="px-3" in:fly={{duration: 1250, easing: linear, x: 700}}>{streamer.num}</div>
        {:else}
          <div class="px-3">{streamer.num}</div>
        {/if}
      {/each}
    </div>
  </div>
</main>