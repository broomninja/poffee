alias Poffee.Accounts
alias Poffee.Accounts.User
alias Poffee.Social.BrandPage
alias Poffee.Social.Feedback
alias Poffee.Repo

import Ecto.Query

defmodule Benchmark do

  # This will issue two queries
  def get_brand_page_with_feedbacks_by_user_two_queries(%User{} = user, parallel \\ true) do
    # we should only retrieve the active feedbacks
    feedback_preload_query = from fb in Feedback, where: fb.status == :feedback_status_active

    user
    |> Ecto.assoc(:brand_page)
    |> preload(feedbacks: ^feedback_preload_query)
    |> Repo.one(in_parallel: parallel)
  end

  # Same as get_brand_page_with_feedbacks_by_user_two_queries but this will generate a single join query
  def get_brand_page_with_feedbacks_by_user_single_join(%User{} = user, parallel \\ true) do
    BrandPage
    |> where([bp], bp.owner_id == ^user.id)
    |> join(:inner, [bp], fb in Feedback,
      on: fb.brand_page_id == bp.id and fb.status == :feedback_status_active
    )
    |> preload([bp, fb], feedbacks: fb)
    |> Repo.one(in_parallel: parallel)
  end

end

u1 = Accounts.get_user_by_email("bob@test.cc")

Benchee.run(
  %{
    "Preload single join query async" => fn -> Benchmark.get_brand_page_with_feedbacks_by_user_single_join(u1) end,
    "Preload single join query sync" => fn -> Benchmark.get_brand_page_with_feedbacks_by_user_single_join(u1, false) end,
    "Preload 2 query async" => fn -> Benchmark.get_brand_page_with_feedbacks_by_user_two_queries(u1) end,
    "Preload 2 query sync" => fn -> Benchmark.get_brand_page_with_feedbacks_by_user_two_queries(u1, false) end
  },
  time: 10,
  memory_time: 2,
  warmup: 5
)