defmodule Poffee.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID

      @type t :: %__MODULE__{}
    end
  end
end
