defmodule Poffee.StreamingTest do
  use Poffee.DataCase

  alias Poffee.Streaming

  describe "twitch_users" do
    alias Poffee.Streaming.TwitchUser

    import Poffee.StreamingFixtures

    @invalid_attrs %{
      description: nil,
      display_name: nil,
      login: nil,
      profile_image_url: nil,
      twitch_user_id: nil
    }

    test "list_twitch_users/0 returns all twitch_users" do
      twitch_user = twitch_user_fixture()
      assert Streaming.list_twitch_users() == [twitch_user]
    end

    test "get_twitch_user!/1 returns the twitch_user with given id" do
      twitch_user = twitch_user_fixture()
      assert Streaming.get_twitch_user!(twitch_user.id) == twitch_user
    end

    test "create_twitch_user/1 with valid data creates a twitch_user" do
      valid_attrs = %{
        description: "some description",
        display_name: "some display_name",
        login: "some login",
        profile_image_url: "some profile_image_url",
        twitch_user_id: 42
      }

      assert {:ok, %TwitchUser{} = twitch_user} = Streaming.create_twitch_user(valid_attrs)
      assert twitch_user.description == "some description"
      assert twitch_user.display_name == "some display_name"
      assert twitch_user.login == "some login"
      assert twitch_user.profile_image_url == "some profile_image_url"
      assert twitch_user.twitch_user_id == 42
    end

    test "create_twitch_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Streaming.create_twitch_user(@invalid_attrs)
    end

    test "update_twitch_user/2 with valid data updates the twitch_user" do
      twitch_user = twitch_user_fixture()

      update_attrs = %{
        description: "some updated description",
        display_name: "some updated display_name",
        login: "some updated login",
        profile_image_url: "some updated profile_image_url",
        twitch_user_id: 43
      }

      assert {:ok, %TwitchUser{} = twitch_user} =
               Streaming.update_twitch_user(twitch_user, update_attrs)

      assert twitch_user.description == "some updated description"
      assert twitch_user.display_name == "some updated display_name"
      assert twitch_user.login == "some updated login"
      assert twitch_user.profile_image_url == "some updated profile_image_url"
      assert twitch_user.twitch_user_id == 43
    end

    test "update_twitch_user/2 with invalid data returns error changeset" do
      twitch_user = twitch_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Streaming.update_twitch_user(twitch_user, @invalid_attrs)

      assert twitch_user == Streaming.get_twitch_user!(twitch_user.id)
    end

    test "delete_twitch_user/1 deletes the twitch_user" do
      twitch_user = twitch_user_fixture()
      assert {:ok, %TwitchUser{}} = Streaming.delete_twitch_user(twitch_user)
      assert_raise Ecto.NoResultsError, fn -> Streaming.get_twitch_user!(twitch_user.id) end
    end

    test "change_twitch_user/1 returns a twitch_user changeset" do
      twitch_user = twitch_user_fixture()
      assert %Ecto.Changeset{} = Streaming.change_twitch_user(twitch_user)
    end
  end
end
