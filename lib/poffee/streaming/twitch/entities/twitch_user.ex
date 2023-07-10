defmodule Poffee.Streaming.TwitchUser do
  use Poffee.Schema

  alias Poffee.Accounts.User

  typed_schema "twitch_users" do
    field :twitch_user_id, :string
    field :login, :string
    field :display_name, :string
    field :description, :string
    field :profile_image_url, :string

    belongs_to :user, User, foreign_key: :user_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(twitch_user, attrs) do
    twitch_user
    |> cast(attrs, [
      :twitch_user_id,
      :description,
      :display_name,
      :login,
      :profile_image_url,
      :user_id
    ])
    |> validate_required([
      :twitch_user_id,
      :display_name,
      :login,
      :user_id
    ])
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @fields ~w(id twitch_user_id display_name description login profile_image_url user_id inserted_at updated_at)a
    def encode(value, opts), do: jason_encode(value, @fields, opts)
  end
end
