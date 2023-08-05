defmodule Poffee.EctoUtils do
  @type uuid :: <<_::128>>

  @spec sanitize_field(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def sanitize_field(changeset, field) do
    case Map.get(changeset.changes, field) do
      nil ->
        changeset

      unformatted ->
        formatted =
          unformatted
          |> HtmlSanitizeEx.strip_tags()
          # trimming must be the last action since HTML stripping can turn "<b> <b>" into " "
          |> String.trim()

        Ecto.Changeset.put_change(changeset, field, formatted)
    end
  end

  @spec jason_encode(map, list(atom), map) :: map
  def jason_encode(struct, fields, opts) do
    struct
    |> Map.take(fields)
    |> Enum.into(%{}, fn
      {key, %Ecto.Association.NotLoaded{}} -> {key, nil}
      {key, value} -> {key, value}
    end)
    |> Jason.Encoder.encode(opts)
  end

  @spec binary_to_ecto_uuid(uuid) :: Ecto.UUID.t()
  def binary_to_ecto_uuid(uuid) when is_binary(uuid), do: uuid |> Ecto.UUID.dump() |> elem(1)
end
