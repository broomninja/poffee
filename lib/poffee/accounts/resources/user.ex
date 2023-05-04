defmodule Poffee.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  # alias AshHq.Calculations.Decrypt

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    # attribute :encrypted_username, :string, allow_nil?: false
    # attribute :encrypted_firstname, :string
    # attribute :encrypted_lastname, :string
  end

  authentication do
    api Poffee.Accounts

    strategies do
      password :password do
        identity_field(:email)
        # hashed_password_field :hashed_password
        sign_in_tokens_enabled?(true)

        resettable do
          sender(Poffee.Accounts.User.Senders.SendPasswordResetEmail)
        end
      end
    end

    tokens do
      enabled?(true)
      token_resource(Poffee.Accounts.Token)

      # signing_secret(Application.compile_env(:poffee, PoffeeWeb.Endpoint)[:secret_key_base])
      signing_secret(fn _, _ ->
        # Application.fetch_env(:poffee, PoffeeWeb.Endpoint)[:secret_key_base]
          Application.fetch_env(:poffee, :signing_secret)
      end)
    end
  end

  postgres do
    table "users"
    repo Poffee.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/), message: "invalid email"
  end

  # calculations do
  #   calculate :username, :string, {Decrypt, field: :encrypted_username}
  #   calculate :firstname, :string, {Decrypt, field: :encrypted_firstname}
  #   calculate :lastname, :string, {Decrypt, field: :encrypted_lastname}
  # end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
