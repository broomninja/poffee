defmodule Poffee.Streaming.TwitchApiMock.Helix do
  def get_user_info_by_user_id!(_client_id, _app_access_token, _user_id) do
    {:ok, nil}
  end

  def is_live?(_client_id, _app_access_token, _user_id) do
    true
  end

  def list_streamers(_client_id, _app_access_token, _page_size, _cursor \\ nil) do
    {:ok, []}
  end
end
