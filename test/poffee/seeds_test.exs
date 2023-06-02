defmodule Poffee.SeedsTest do
  use Poffee.DataCase

  alias Poffee.Accounts.User

  test "creates an admin user and one normal user" do
    Poffee.Seeds.run()

    assert admin = Poffee.Repo.one(from u in User, where: u.role == :role_admin)
    assert admin.role == :role_admin
    assert admin = Poffee.Repo.one(from u in User, where: u.role == :role_user)
    assert admin.role == :role_user
  end

  test "user creation is idempotent" do
    Poffee.Seeds.run()
    Poffee.Seeds.run()

    user_count = Poffee.Repo.aggregate(User, :count, :id)
    assert user_count == 2
  end
end
