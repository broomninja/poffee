defmodule Poffee.StreamingTest do
  use Poffee.DataCase

  alias Poffee.Streaming
  alias Poffee.Streaming.TwitchUser

  import Poffee.StreamingFixtures
  import Poffee.AccountsFixtures

  describe "twitch_users" do
    @invalid_attrs %{
      description: nil,
      display_name: nil,
      login: nil,
      profile_image_url: nil,
      twitch_user_id: nil
    }

    setup do
      user = user_fixture()
      %{user: user, twitch_user: twitch_user_fixture(user)}
    end

    test "list_twitch_users/0 returns all twitch_users", %{twitch_user: twitch_user} do
      assert Streaming.list_twitch_users() == [twitch_user]
    end

    test "get_twitch_user!/1 returns the twitch_user with given id", %{twitch_user: twitch_user} do
      assert Streaming.get_twitch_user!(twitch_user.id) == twitch_user
    end

    test "create_twitch_user/1 with valid data creates a twitch_user", %{user: user} do
      valid_attrs = %{
        description: "some random description",
        display_name: "some some display_name",
        login: "some random login",
        profile_image_url: "some profile_image_url",
        twitch_user_id: "4212546"
      }

      assert {:ok, %TwitchUser{} = twitch_user} = Streaming.create_twitch_user(valid_attrs, user)
      assert twitch_user.description == valid_attrs.description
      assert twitch_user.display_name == valid_attrs.display_name
      assert twitch_user.login == valid_attrs.login
      assert twitch_user.profile_image_url == valid_attrs.profile_image_url
      assert twitch_user.twitch_user_id == valid_attrs.twitch_user_id
    end

    test "create_twitch_user/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Streaming.create_twitch_user(@invalid_attrs, user)
    end

    test "update_twitch_user/2 with valid data updates the twitch_user", %{
      twitch_user: twitch_user
    } do
      update_attrs = %{
        description: "some updated description",
        display_name: "some updated display_name",
        login: "some updated login",
        profile_image_url: "some updated profile_image_url",
        twitch_user_id: "43335222"
      }

      assert {:ok, %TwitchUser{} = twitch_user} =
               Streaming.update_twitch_user(twitch_user, update_attrs)

      assert twitch_user.description == update_attrs.description
      assert twitch_user.display_name == update_attrs.display_name
      assert twitch_user.login == update_attrs.login
      assert twitch_user.profile_image_url == update_attrs.profile_image_url
      assert twitch_user.twitch_user_id == update_attrs.twitch_user_id
    end

    test "update_twitch_user/2 with invalid data returns error changeset", %{
      twitch_user: twitch_user
    } do
      assert {:error, %Ecto.Changeset{}} =
               Streaming.update_twitch_user(twitch_user, @invalid_attrs)

      assert twitch_user == Streaming.get_twitch_user!(twitch_user.id)
    end

    test "delete_twitch_user/1 deletes the twitch_user", %{twitch_user: twitch_user} do
      assert {:ok, %TwitchUser{}} = Streaming.delete_twitch_user(twitch_user)
      assert_raise Ecto.NoResultsError, fn -> Streaming.get_twitch_user!(twitch_user.id) end
    end

    test "change_twitch_user/1 returns a twitch_user changeset", %{twitch_user: twitch_user} do
      assert %Ecto.Changeset{} = Streaming.change_twitch_user(twitch_user)
    end
  end
end
