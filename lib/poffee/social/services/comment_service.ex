defmodule Poffee.Services.CommentService do
  @moduledoc """
  Context module for Comment
  """

  import Ecto.Query, warn: false
  alias Poffee.Repo

  alias Poffee.Accounts.User
  alias Poffee.Social.Comment
  alias Poffee.Social.Feedback

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_comment(map, User.t(), Feedback.t()) :: {:ok, Comment.t()} | changeset_error
  def create_comment(attrs \\ %{}, %User{id: user_id}, %Feedback{id: feedback_id}) do
    attrs =
      attrs
      |> Map.put(:author_id, user_id)
      |> Map.put(:feedback_id, feedback_id)

    result =
      %Comment{}
      |> Comment.changeset(attrs)
      |> Repo.insert()

    with {:ok, _comment} <- result do
      # :ok = Notifications.comment_created(comment)
    end

    result
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
