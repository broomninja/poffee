defmodule Poffee.Accounts.User do
  use Poffee.Schema
  import EctoEnum

  alias Poffee.Constant
  alias Poffee.Utils
  alias Poffee.Social.BrandPage
  alias Poffee.Social.Feedback

  defenum(RolesEnum, :role, [
    :role_user,
    # :role_sub_owner,
    :role_admin
  ])

  typed_schema "users" do
    field :username, :string
    # field :first_name, :string
    # field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime
    field :role, RolesEnum, default: :role_user

    has_one :brand_page, BrandPage, foreign_key: :owner_id
    has_many :feedbacks, Feedback, foreign_key: :author_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_unqiue_mail` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_username(opts)
  end

  defp validate_username(changeset, opts) do
    changeset
    |> format_string(:username)
    |> validate_required([:username])
    |> validate_format(:username, ~r/^[\d\w_]+$/,
      message: "can only contain letters, numbers and _"
    )
    |> validate_length(:username,
      min: Constant.username_min_length(),
      max: Constant.username_max_length()
    )
    |> validate_unique_username(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> format_string(:email, true)
    |> validate_required([:email])
    |> EctoCommons.EmailValidator.validate_email(:email, checks: [:html_input])
    |> validate_length(:email, max: Constant.email_max_length())
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password,
      min: Constant.password_min_length(),
      max: Constant.password_max_length()
    )
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_unqiue_mail, true) do
      changeset
      |> unsafe_validate_unique(:email, Poffee.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp validate_unique_username(changeset, _opts) do
    changeset
    |> unsafe_validate_unique(:username, Poffee.Repo)
    |> unique_constraint(:username)
  end

  # def roles_changeset(%__MODULE__{} = actor, %__MODULE__{} = user, attrs) do
  #   user
  #   |> cast(attrs, [:roles])
  #   |> validate_roles(actor, user)
  # end

  @doc """
  A user changeset for registering admins.
  """
  def admin_registration_changeset(user, attrs) do
    user
    |> registration_changeset(attrs)
    |> prepare_changes(&set_admin_role/1)
  end

  defp set_admin_role(changeset) do
    changeset
    |> put_change(:role, :role_admin)
  end

  @spec format_string(t, atom, boolean()) :: t
  defp format_string(changeset, field, force_lowercase \\ false) do
    case Map.get(changeset.changes, field) do
      nil ->
        changeset

      unformatted ->
        formatted =
          unformatted
          |> Utils.maybe_if(force_lowercase, &String.downcase/1)
          |> String.trim()

        put_change(changeset, field, formatted)
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Poffee.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
