defmodule Poffee.Utils do
  require Logger

  @spec blank?(String.t()) :: boolean()
  def blank?(nil), do: true

  def blank?(str) do
    "" == str |> to_string() |> String.trim()
  end

  @spec normalize_string(String.t()) :: String.t()
  def normalize_string(nil), do: nil

  def normalize_string(string) do
    string = String.trim(string)
    if string == "", do: nil, else: string
  end

  @spec is_non_empty_list?(any()) :: boolean()
  def is_non_empty_list?([_ | _]), do: true
  def is_non_empty_list?(_), do: false

  @spec maybe_if(any, boolean(), fun()) :: any
  def maybe_if(data, true, action) when is_function(action, 1), do: action.(data)
  def maybe_if(data, false, _action), do: data

  @doc """
  returns true if the url is a valid local (not external) url
  """
  @spec valid_local_url?(String.t()) :: boolean()
  def valid_local_url?(nil), do: false

  def valid_local_url?(""), do: false

  def valid_local_url?(url) do
    uri = URI.parse(url)
    is_nil(uri.scheme) && is_nil(uri.host)
  end

  @doc """
  converts IP in tuple format eg: {212, 21, 83, 15} to string "212.21.83.15"
  """
  @spec ip_tuple_to_string(Tuple.t()) :: String.t()
  def ip_tuple_to_string(nil), do: nil
  def ip_tuple_to_string(ip), do: ip |> :inet.ntoa() |> List.to_string()

  @doc """
  returns true if result can be cached
  """
  def can_be_cached?(nil), do: false
  def can_be_cached?({:error, _}), do: false
  def can_be_cached?({:ok, nil}), do: false
  def can_be_cached?({:ok, []}), do: false
  def can_be_cached?({:ok, _}), do: true
  def can_be_cached?([]), do: false
  def can_be_cached?(_), do: true

  # # Get the relative time from now, nil if datetime is not in the correct format
  # @spec format_time(String.t()) :: String.t() | nil
  # def format_time(datetime) do
  #   with {:ok, relative_str} <- Timex.format(datetime, "{relative}", :relative) do
  #     relative_str
  #   end
  # end

  # show login modal when user is not logged in
  def get_modal_name(nil, _), do: "live-login-modal"
  def get_modal_name(%Poffee.Accounts.User{id: _}, modal_name), do: modal_name

  # returns the field value of any struct or map, 
  # nil is returned of field does not exist or map is nil
  @spec get_field(any, atom()) :: any | nil
  def get_field(nil, _field), do: nil
  def get_field(struct_or_map, field), do: Map.get(struct_or_map, field)

  @doc """
  Convert map atom keys to strings
  """
  def stringify_keys(nil), do: nil

  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end

  # Walk the list and stringify the keys of
  # of any map members
  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end

  # Replace "page=1" with "page=:page" in query string
  # If "page=XX" does not exist then simply add "page=:page" to query string
  def get_pagination_path(current_uri) do
    uri = URI.parse(current_uri)

    # overwrite any existing "page" query string
    query =
      Plug.Conn.Query.decode(uri.query || "")
      |> Map.put("page", "__COLON__page")
      |> Plug.Conn.Query.encode()
      |> String.replace("__COLON__page", ":page")

    new_uri = Map.put(uri, :query, query)

    path =
      %{new_uri | scheme: nil, authority: nil, host: nil}
      |> URI.to_string()

    Logger.debug("[BrandPageComponent.get_pagination_path] returning path = #{path}")

    path
  end
end
