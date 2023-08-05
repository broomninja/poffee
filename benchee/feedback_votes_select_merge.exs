alias Poffee.Accounts.User
alias Poffee.Social.BrandPage
alias Poffee.Social.Feedback
alias Poffee.Repo

import Ecto.Query

require Logger

Logger.Config.configure(%{level: :info})

defmodule Benchmark do
  def get_top_streamers_with_most_feedback_votes_with_select(limit \\ 10, parallel \\ true) do
    feedback_with_votes_count_query =
    Feedback
    |> where([fb], fb.status == :feedback_status_active)
    |> join(:left, [fb], v in assoc(fb, :voters))
    |> group_by([fb], [fb.id])
    |> select([fb, v], %{brand_page_id: fb.brand_page_id, votes_count: count(v.id, :distinct)})

    get_top_streamers_with_most_feedback_votes(feedback_with_votes_count_query, limit, parallel)
  end

  def get_top_streamers_with_most_feedback_votes_with_select_merge(limit \\ 10, parallel \\ true) do
    feedback_with_votes_count_query =
    Feedback
    |> where([fb], fb.status == :feedback_status_active)
    |> join(:left, [fb], v in assoc(fb, :voters))
    |> group_by([fb], [fb.id])
    |> select_merge([_, v], %{votes_count: count(v.id, :distinct)})

    get_top_streamers_with_most_feedback_votes(feedback_with_votes_count_query, limit, parallel)
  end

  defp get_top_streamers_with_most_feedback_votes(subquery, limit \\ 10, parallel \\ true) do
    BrandPage
    |> where([bp], bp.status == :brand_page_status_public)
    |> join(:inner, [bp], u in assoc(bp, :owner))
    |> join(:left, [bp], fb in subquery(subquery),
      on: fb.brand_page_id == bp.id
    )
    |> preload([_, u, _], owner: u)
    |> group_by([bp, u, _], [bp.id, u.id])
    |> order_by([_, u, fb], desc: selected_as(:total_feedback_votes_count), asc: u.username)
    |> limit(^limit)
    |> select_merge([..., fb], %{total_feedback_votes_count: fb.votes_count |> sum() |> type(:integer) |> selected_as(:total_feedback_votes_count)})
    |> Repo.all(in_parallel: parallel)
  end
end

Benchee.run(
  %{
    "get_top_streamers_with_most_feedback_votes_with_select async" => 
      fn -> Benchmark.get_top_streamers_with_most_feedback_votes_with_select(20, true) end,
    "get_top_streamers_with_most_feedback_votes_with_select sync" => 
      fn -> Benchmark.get_top_streamers_with_most_feedback_votes_with_select(20, false) end,
    "get_top_streamers_with_most_feedback_votes_with_select_merge async" => 
      fn -> Benchmark.get_top_streamers_with_most_feedback_votes_with_select_merge(20, true) end,
    "get_top_streamers_with_most_feedback_votes_with_select_merge sync" => 
      fn -> Benchmark.get_top_streamers_with_most_feedback_votes_with_select_merge(20, false) end
  },
  time: 10,
  memory_time: 2,
  warmup: 5
)
