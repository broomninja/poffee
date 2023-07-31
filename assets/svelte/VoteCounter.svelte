<script lang="ts">
	import { scale } from 'svelte/transition';
  import { showLoginModal } from './utils/ShowLoginModal.svelte';

  export let current_user;
  export let feedback;
  export let brand_page_id;
  export let has_already_voted;
  export let pushEvent;
  export let pushEventTo;

  // console.log(`feedback = ${JSON.stringify(feedback, null, 2)}`);
  // console.log(`[VoteCounter] brand_page_id = ${JSON.stringify(brand_page_id, null, 2)}`);

  const clickVote = (user, feedback) => {
    if (!user?.id) {
      showLoginModal();
      return;
    }
    // do not allow vote on self feedbacks
    if (feedback?.author?.id == user.id) {
      pushEvent("flash", {level: "warn", message: "Voting own feedback is not permitted"});
      return;
    }
    // send event to BrandPageComponent
    pushEventTo(`#brandpage-${brand_page_id}`, "vote", {user_id: user.id, feedback_id: feedback.id});
  }

  const clickUnvote = (user, feedback_id) => {
    if (!user?.id) {
      showLoginModal();
      return;
    }
    if (feedback?.author?.id == user.id) {
      pushEvent("flash", {level: "warn", message: "Unvoting own feedback is not permitted"});
      return;
    }
    // send event to BrandPageComponent
    pushEventTo(`#brandpage-${brand_page_id}`, "unvote", {user_id: user.id, feedback_id: feedback.id});
  }

</script>

<div>
  <button class="group relative inline-block w-12 h-12 mr-5 border border-gray-800 bg-white rounded" 
      on:click={has_already_voted ? 
                clickUnvote(current_user, feedback) : 
                clickVote(current_user, feedback)} 
  >
    <svg class="mx-auto w-5 h-5 bg-white" fill="black" viewBox="3 1 18 18" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.354 8.854l5.792 5.792a.5.5 0 01-.353.854H6.207a.5.5 0 01-.353-.854l5.792-5.792a.5.5 0 01.708 0z"></path>
    </svg>
    {#key feedback.votes_count}
      <span class="mx-auto inline-block" in:scale>
        {feedback.votes_count}
      </span>
    {/key}
    <!-- Tooltip -->
    <span class="absolute block hidden group-hover:flex -left-14 -top-3 -translate-y-full w-40 pl-3 pr-3 py-2 bg-gray-600 rounded-lg
                 text-center justify-center text-white text-sm after:content-[''] after:absolute after:left-1/2 after:top-[100%] 
                 after:-translate-x-1/2 after:border-8 after:border-x-transparent after:border-b-transparent after:border-t-gray-600">
      {#if !current_user}
          Click to login and vote
      {:else if current_user.id == feedback?.author?.id}
          Unable to vote your own feedback
      {:else}
          Click to {has_already_voted ? 'remove' : ''} vote
      {/if}
    </span>
    <!-- End Tooltip -->
  </button>
</div>