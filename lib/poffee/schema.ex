defmodule Poffee.Schema do
  defmacro __using__(_opts) do
    quote do
      use TypedEctoSchema
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Poffee.EctoUtils

      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID

      # using typed_ecto_schema so can comment out the following
      # @type t :: %__MODULE__{}
    end
  end
end
