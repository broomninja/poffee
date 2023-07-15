<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import ClockIcon from './icons/ClockIcon.svelte';
  import VoteCounter from './VoteCounter.svelte';
	import DateTimeDisplay from './DateTimeDisplay.svelte';

  export let current_user;
  //export let brand_page;
  export let feedback;
  export let user_vote;
  //export let pushEvent;

  let test_voter_count = 3;

  onMount(async () => create_subscription());

  onDestroy(async() => delete_subscription());

  console.log(`feedback = ${JSON.stringify(feedback, null, 2)}`);

  const create_subscription = async () => {

  }

  const delete_subscription = async () => {
  }

</script>

<div id={`feedback-${feedback.id}`} class="pt-5">
  <!-- Feedback -->
  <div class="grid grid-cols-9 gap-1 pt-4 pb-4 pl-2 bg-slate-100 rounded-md">
    <!-- Feedback title -->
    <div class="col-span-7 ml-1 mb-1 text-lg font-bold text-gray-800 lg:leading-tight dark:text-white">
      {feedback.title}
    </div>
    <!-- End Feedback title -->
    <!-- Vote Counter -->
    <div class="col-span-2 row-span-2 text-right">
      <VoteCounter {current_user} {feedback} {test_voter_count} {user_vote} />
    </div>
    <!-- End Vote Counter -->
    <!-- Author -->
    <div class="col-span-7 ml-1">
      {feedback.author_id}
    </div>
    <!-- End Author -->
    <!-- Feedback content -->
    <div class="col-span-9 mt-3 ml-1 mr-5 md:mr-16 text-sm text-gray-800">
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
  </div>
  <!-- End Feedback -->
</div>