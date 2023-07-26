defmodule Poffee.Streaming.TwitchApiMock.Auth do
  @doc """
  {:ok, %{"access_token" => access_token, "token_type" => token_type, "expires_in" => expires_in}} = get_app_access_token!(client_id, client_secret)```
  """
  def get_app_access_token!(_client_id, _client_secret) do
    {:ok,
     %{
       "access_token" => "dummy_access_token",
       "token_type" => "dummy_token_type",
       "expires_in" => 1_000_000
     }}
  end

  # Not implemented
  def get_user_access_token!(_access_token) do
    nil
  end
end
