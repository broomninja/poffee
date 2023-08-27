defmodule Poffee.Services.CommentService do
  @moduledoc """
  Context module for Comment
  """

  import Ecto.Query, warn: false
  alias Poffee.Repo

  alias Poffee.Constant
  alias Poffee.EctoUtils
  alias Poffee.Social.Comment

  @type changeset_error :: {:error, Ecto.Changeset.t()}
  @type uuid :: <<_::128>>

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
  Gets a list of comment for a given feedback_id
  """
  @spec get_comments_by_feedback_id(uuid, Keywords.t()) :: Scrivener.Page.t()
  def get_comments_by_feedback_id(feedback_id, options \\ %{})
  def get_comments_by_feedback_id(nil, _), do: EctoUtils.pagination_empty_list()

  def get_comments_by_feedback_id(feedback_id, options) do
    Comment
    |> where([c], c.feedback_id == ^feedback_id and c.status == :comment_status_active)
    |> preload(:author)
    |> order_by(^parse_sort_by(options["sort_by"]))
    |> Repo.paginate(%{
      page: EctoUtils.parse_number(options["page"], 1),
      page_size:
        EctoUtils.parse_number(options["page_size"], Constant.comment_default_page_size())
    })
  end

  defp parse_sort_by("oldest"), do: [asc: dynamic([c], c.inserted_at)]
  defp parse_sort_by("newest"), do: [desc: dynamic([c], c.inserted_at)]
  defp parse_sort_by(_), do: parse_sort_by(Constant.comment_default_sort_by())

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
  @spec create_comment(map, uuid, uuid) :: {:ok, Comment.t()} | changeset_error
  def create_comment(attrs \\ %{}, user_id, feedback_id) do
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
