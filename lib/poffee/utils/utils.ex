defmodule Poffee.Utils do
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
  returns true if result can be cached
  """
  def can_be_cached?(nil), do: false
  def can_be_cached?({:error, _}), do: false
  def can_be_cached?({:ok, nil}), do: false
  def can_be_cached?({:ok, []}), do: false
  def can_be_cached?({:ok, _}), do: true
  def can_be_cached?([]), do: false
  def can_be_cached?(_), do: true

  # Get the relative time from now, nil if datetime is not in the correct format
  @spec format_time(String.t()) :: String.t() | nil
  def format_time(datetime) do
    with {:ok, relative_str} <- Timex.format(datetime, "{relative}", :relative) do
      relative_str
    end
  end

  # show login modal when user is not logged in
  def get_modal_name(nil, _), do: "live-login-modal"
  def get_modal_name(%Poffee.Accounts.User{id: _}, modal_name), do: modal_name

  # returns the field value of any struct or map, 
  # nil is returned of field does not exist or map is nil
  @spec get_field(any, atom()) :: any | nil
  def get_field(nil, _field), do: nil
  def get_field(struct_or_map, field), do: Map.get(struct_or_map, field)
end
