defmodule Poffee.SeedsTest do
  use Poffee.DataCase, async: true

  alias Poffee.Accounts.User

  test "creates an admin user and one normal user" do
    Poffee.Seeds.run()

    assert admin = Poffee.Repo.one(from u in User, where: u.role == :role_admin)
    assert admin.role == :role_admin

    Poffee.Repo.all(from u in User, where: u.role == :role_user)
    |> Enum.each(&assert(&1.role == :role_user))
  end

  test "user creation is idempotent" do
    Poffee.Seeds.run()
    Poffee.Seeds.run()

    user_count = Poffee.Repo.aggregate(User, :count, :id)
    assert user_count == 3
  end
end
