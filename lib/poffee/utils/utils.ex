defmodule Poffee.Utils do
  @spec normalize_string(String.t()) :: String.t()
  def normalize_string(nil), do: nil

  def normalize_string(string) do
    string = String.trim(string)
    if string == "", do: nil, else: string
  end

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
end
