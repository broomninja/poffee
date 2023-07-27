<script lang="ts">
  import ClockIcon from './icons/ClockIcon.svelte';
  import VoteCounter from './VoteCounter.svelte';
	import DateTimeDisplay from './DateTimeDisplay.svelte';
	import Button from './Button.svelte';

  export let current_user;
  export let brandpage_username;
  export let brandpage_id;
  export let feedback;
  export let has_already_voted;
  export let live_action;
  export let pushEventTo;

  console.log(`feedback = ${JSON.stringify(feedback, null, 2)}`);
  //console.log(`[Feedback] brandpage_id = ${JSON.stringify(brandpage_id, null, 2)}`);

  $: comments_text = feedback?.comments_count > 0 ? "View comments" : "Create a comment";
</script>

<div id={`feedback-${feedback.id}`} class="pt-5">
  <!-- Feedback -->
  <div class="grid grid-cols-9 pt-4 pb-2 pl-2 mb-2 bg-slate-100 rounded-md">
    <!-- Feedback title -->
    {#if live_action === "show_feedbacks"}
      <div class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 hover:text-blue-700 lg:leading-tight dark:text-white">
        <a href={`/u/${brandpage_username}/${feedback.id}`} data-phx-link="redirect" data-phx-link-state="push">
          {feedback.title}
        </a>
      </div>
    {:else if live_action === "show_single_feedback"}
      <div class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 lg:leading-tight dark:text-white">
        {feedback.title}
      </div>
    {/if}
    <!-- End Feedback title -->
    <!-- Vote Counter -->
    <div class="col-span-2 row-span-2 text-right">
      <VoteCounter {current_user} {feedback} {brandpage_id} {has_already_voted} {pushEventTo} />
    </div>
    <!-- End Vote Counter -->
    <!-- Author -->
    <div class="col-span-7 ml-1 mb-1">
      {feedback.author?.username}
    </div>
    <!-- End Author -->
    <!-- Feedback content -->
    <div class="col-span-9 mt-3 ml-1 mr-5 md:mr-16 mb-1 text-sm text-gray-800 lg:leading-relaxed">
      {@html feedback.content}
    </div>
    <!-- End Feedback content -->
    <!-- Created time -->
    <div class="col-span-9 mt-3 flex whitespace-nowrap text-gray-700 text-sm">
      <ClockIcon />
      <span class="pl-1">
        <DateTimeDisplay prefix="created" datetime={feedback.inserted_at} /> 
      </span>
    </div>
    <!-- End Created time -->
    <!-- Comment Link -->
    {#if live_action === "show_feedbacks"}
      <div class="col-span-9 flex whitespace-nowrap text-gray-800 hover:text-blue-700 font-semibold justify-center">
        <a href={`/u/${brandpage_username}/${feedback.id}`} data-phx-link="redirect" data-phx-link-state="push">
          <Button>
            {comments_text}
          </Button>
        </a>
      </div>
    {/if}
    <!-- End Comment Link -->
  </div>
  <!-- End Feedback -->
</div>