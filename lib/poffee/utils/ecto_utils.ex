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

  # the first argument can be in integer or numeric string format, however default will be  
  # returned if num is not a positive integer
  @spec parse_number(Integer.t() | String.t(), Integer.t()) :: Integer.t()
  def parse_number(num, _default) when is_integer(num) and num > 0, do: num

  def parse_number(num_string, default) when is_binary(num_string) do
    with {num, ""} <- Integer.parse(num_string),
         true <- num > 0 do
      num
    else
      _ -> default
    end
  end

  def parse_number(_, default), do: default

  @spec escape_search_string(String.t()) :: String.t()
  def escape_search_string(str) when is_binary(str) do
    str
    |> String.replace("_", "\\_")
    |> String.replace("%", "\\%")
  end

  @spec pagination_empty_list() :: Scrivener.Page.t()
  def pagination_empty_list() do
    %Scrivener.Page{entries: [], page_number: 0, page_size: 0, total_entries: 0, total_pages: 0}
  end
end
