defmodule Poffee.Streaming do
  @moduledoc """
  The Streaming context.
  """

  import Ecto.Query, warn: false
  alias Poffee.Repo
  alias Poffee.Accounts.User
  alias Poffee.Streaming.TwitchUser

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @type uuid :: <<_::128>>

  @doc """
  Returns the list of twitch_users.

  ## Examples

      iex> list_twitch_users()
      [%TwitchUser{}, ...]

  """
  def list_twitch_users do
    Repo.all(TwitchUser)
  end

  @doc """
  Gets a single twitch_user.

  Raises `Ecto.NoResultsError` if the Twitch user does not exist.

  ## Examples

      iex> get_twitch_user!(123)
      %TwitchUser{}

      iex> get_twitch_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_twitch_user!(uuid()) :: TwitchUser.t()
  def get_twitch_user!(id), do: Repo.get!(TwitchUser, id)

  @spec get_twitch_user_by_user_id(uuid()) :: TwitchUser.t()
  def get_twitch_user_by_user_id(user_id) do
    TwitchUser
    |> where(user_id: ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a twitch_user.

  ## Examples

      iex> create_twitch_user(%{field: value}, %User{})
      {:ok, %TwitchUser{}}

      iex> create_twitch_user(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_twitch_user(map, User.t()) :: {:ok, TwitchUser.t()} | changeset_error
  def create_twitch_user(attrs \\ %{}, user) do
    attrs = Map.put(attrs, :user_id, user.id)

    %TwitchUser{}
    |> TwitchUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a twitch_user.

  ## Examples

      iex> update_twitch_user(twitch_user, %{field: new_value})
      {:ok, %TwitchUser{}}

      iex> update_twitch_user(twitch_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_twitch_user(%TwitchUser{} = twitch_user, attrs) do
    twitch_user
    |> TwitchUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a twitch_user.

  ## Examples

      iex> delete_twitch_user(twitch_user)
      {:ok, %TwitchUser{}}

      iex> delete_twitch_user(twitch_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_twitch_user(%TwitchUser{} = twitch_user) do
    Repo.delete(twitch_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking twitch_user changes.

  ## Examples

      iex> change_twitch_user(twitch_user)
      %Ecto.Changeset{data: %TwitchUser{}}

  """
  def change_twitch_user(%TwitchUser{} = twitch_user, attrs \\ %{}) do
    TwitchUser.changeset(twitch_user, attrs)
  end
end
