<script lang="ts">
	import { scale } from 'svelte/transition';

  export let current_user;
  export let feedback;
  export let user_vote;
  export let pushEventTo;
  export let test_voter_count;
  
  const parent_container_id = `feedback-${feedback.id}`;

  console.log(`feedback = ${JSON.stringify(feedback, null, 2)}`);

  const clickVote = async (user_id, feedback_id) => {
    if (!user_id) {
      let el = document.getElementById(parent_container_id);
      window.liveSocket.execJS(el, el.getAttribute("data-show-login"))
      return;
    }
    pushEventTo(`#${parent_container_id}`, "vote", {user_id: user_id, feedback_id: feedback_id});
  }

  const clickUnvote = async (user_id, feedback_id, vote_id) => {
    if (!user_id) {
      let el = document.getElementById(parent_container_id);
      window.liveSocket.execJS(el, el.getAttribute("data-show-login"))
      return;
    }
    pushEventTo(`#${parent_container_id}`, "unvote", {user_id: user_id, feedback_id: feedback_id, vote_id: vote_id});
  }

</script>

<div>
    <button class="group relative inline-block w-12 h-12 mr-5 border border-gray-800 bg-white rounded" 
        on:click={!!user_vote ? 
                  clickUnvote(current_user?.id, feedback?.id, user_vote.id) : 
                  clickVote(current_user?.id, feedback?.id)} 
    >
        <svg class="mx-auto w-5 h-5 bg-white" fill="black" viewBox="3 1 18 18" xmlns="http://www.w3.org/2000/svg">
            <path d="M12.354 8.854l5.792 5.792a.5.5 0 01-.353.854H6.207a.5.5 0 01-.353-.854l5.792-5.792a.5.5 0 01.708 0z"></path>
        </svg>
        {#key test_voter_count}
        <span class="mx-auto inline-block" in:scale>
            {test_voter_count}
        </span>
        {/key}
        <!-- Tooltip -->
        <span class="absolute block hidden group-hover:flex -left-14 -top-3 -translate-y-full w-40 pl-3 pr-3 py-2 bg-gray-500 rounded-lg
                        text-center justify-center text-white text-sm after:content-[''] after:absolute after:left-1/2 after:top-[100%] 
                        after:-translate-x-1/2 after:border-8 after:border-x-transparent after:border-b-transparent after:border-t-gray-500">
        {#if !current_user}
            Click to login and vote
        {:else}
            Click to {!!user_vote ? 'remove' : ''} vote
        {/if}
        </span>
        <!-- End Tooltip -->
        
    </button>
</div>