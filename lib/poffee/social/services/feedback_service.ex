defmodule Poffee.Services.FeedbackService do
  @moduledoc """
  Context module for Feedback
  """

  import Ecto.Query, warn: false
  alias Poffee.Repo

  alias Poffee.Accounts.User
  alias Poffee.Social.Feedback
  alias Poffee.Social.FeedbackVote
  alias Poffee.Social.BrandPage

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of feedbacks.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks do
    Repo.all(Feedback)
  end

  @doc """
  Gets a single feedback.

  Raises `Ecto.NoResultsError` if the Feedback does not exist.

  ## Examples

      iex> get_feedback!(123)
      %Feedback{}

      iex> get_feedback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feedback!(id), do: Repo.get!(Feedback, id)

  @doc """
  Gets a single feedback. Returns nil if does not exist.
  """
  def get_feedback(id), do: Repo.get(Feedback, id)

  @doc """
  Creates a feedback.
  """
  @spec create_feedback(map, User.t(), BrandPage.t()) :: {:ok, Feedback.t()} | changeset_error
  def create_feedback(attrs \\ %{}, %User{id: user_id}, %BrandPage{id: brand_page_id}) do
    attrs =
      attrs
      |> Map.put(:author_id, user_id)
      |> Map.put(:brand_page_id, brand_page_id)

    result =
      %Feedback{}
      |> Feedback.changeset(attrs)
      |> Repo.insert()

    with {:ok, _feedback} <- result do
      # :ok = Notifications.feedback_created(feedback)
    end

    result
  end

  @doc """
  Updates a feedback.
  """
  def update_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feedback.
  """
  def delete_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feedback changes.

  ## Examples

      iex> change_feedback(feedback)
      %Ecto.Changeset{data: %Feedback{}}

  """
  def change_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    Feedback.changeset(feedback, attrs)
  end

  ##########################
  # FeedbackVote
  ##########################

  def vote_feedback(%User{id: user_id}, %Feedback{id: feedback_id}) do
    attrs = %{feedback_id: feedback_id, user_id: user_id}

    %FeedbackVote{}
    |> FeedbackVote.changeset(attrs)
    |> Repo.insert()
  end

  def unvote_feedback(%User{id: user_id}, %Feedback{id: feedback_id}) do
    FeedbackVote
    |> where(feedback_id: ^feedback_id)
    |> where(user_id: ^user_id)
    |> Repo.delete_all()
  end
end
