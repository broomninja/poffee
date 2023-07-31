<script lang="ts">
  import { has as __has } from "lodash";

  export let feedback;
  export let current_user;
  export let pushEventTo;
  export let max_content_length: number = 500;

  const browser = !!window;

  let formData: HTMLFormElement = {
    content: '',
    user_id: current_user?.id,
    feedback_id: feedback?.id,
  };
  
  const submit_button_id = `create-comment-button-${feedback?.id}`;

  $: chars_remaining = max_content_length - formData.content.length;

  const submitCreateComment: SubmitFunction = async () => {
    if (formData.content.trim().length == 0) return;
    
    // disable submit button
    document.querySelector(`#${submit_button_id}`).disabled = true;

    // send to server and wait for callback
    pushEventTo(`#feedback-${feedback.id}`,
                "create_comment", 
                {content: formData.content, user_id: formData.user_id, feedback_id: formData.feedback_id},
                (reply, ref) => reply_callback(reply, ref));
  };

  const reply_callback = async (reply, ref) => {
    // console.log(`[CreateComment] callback reply = ${JSON.stringify(reply, null, 2)}`);

    // re-enable submit button
    document.querySelector(`#${submit_button_id}`).disabled = false;

    // reset and hide the form if successful, otherwise keep the form shown
    // reply object will have the following entries if comment is created succesfully.
    // reply = {
    //   "create_comment_reply": {
    //     "ok": {
    //       "author": null,
    //       "content": "...",
    //       "feedback": null,
    //       "id": "439846be-7d7c-4590-916c-7740ad8c416a",
    //       "inserted_at": "2023-07-29T00:05:18.800464Z",
    //       "status": "comment_status_active",
    //       "updated_at": "2023-07-29T00:05:18.800464Z"
    //     }
    //   }
    // }

    if (__has(reply, "create_comment_reply.ok.id")) {
      formData.content = '';
      hide_create_comment_form();
    }
  };

  const hide_create_comment_form = async () => {
    let el = document.getElementById(`create-comment-${feedback?.id}`);
    window.liveSocket.execJS(el, el.getAttribute("data-hide-action"));
  };

</script>

<div>
  <form
    method="POST"
    on:submit|preventDefault={submitCreateComment} 
    class="flex flex-col gap-4 mt-2 md:flex-row md:items-start"
  >
    <textarea
        id="reply"
        name="content"
        placeholder="Type your comment here"
        rows="3"
        required
        maxlength={max_content_length}
        bind:value={formData.content}
        class="bg-slate-100 rounded-[5px] py-3 px-4 placeholder:text-sm md:placeholder:text-sm placeholder:text-gray-400 
               text-gray-900 text-sm md:text-sm w-full outline-none ring-blue-400 focus-within:ring-1 hover:ring-1"
    />
        
    <input type="hidden" name="user_id" bind:value={formData.user_id} />
    <input type="hidden" name="feedback_id" bind:value={formData.feedback_id} />

    <div class="flex items-start md:items-center justify-between md:flex-col-reverse md:justify-center md:h-full md:gap-2 md:w-[120px]">
      <div>
        {#if browser}
            <p class="text-xs text-gray-600 whitespace-nowrap">
                {chars_remaining} characters left
            </p>
        {:else}
            <p class="text-xs text-gray-600 whitespace-nowrap">Max {max_content_length} characters</p>
        {/if}
      </div>
      <div>
        <button id={submit_button_id}
                type="submit" disabled={!formData.content.trim()} 
                class="disabled:opacity-30 md:mt-6 py-2 px-4 rounded bg-blue-100 border border-transparent text-sm font-semibold 
                text-blue-500 hover:text-white hover:bg-blue-500 focus:outline-none focus:ring-2 ring-offset-white 
                focus:ring-blue-500 focus:ring-offset-2 transition-all dark:focus:ring-offset-gray-800 dark:bg-gray-900 dark:hover:bg-blue-400 dark:text-white">
            Submit
        </button>
      </div>
    </div>
  </form>
</div>