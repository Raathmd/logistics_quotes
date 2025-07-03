defmodule LogisticsQuotes.User do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  postgres do
    table("users")
    repo(LogisticsQuotes.Repo)
  end

  authentication do
    domain(LogisticsQuotes.Domain)

    strategies do
      password :password do
        identity_field(:email)
        hashed_password_field(:hashed_password)
        hash_provider(AshAuthentication.BcryptProvider)
        confirmation_required?(false)
        sign_in_tokens_enabled?(false)
      end
    end
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:email, :string, allow_nil?: false, public?: true)
    attribute(:username, :string, allow_nil?: false, public?: true)
    attribute(:hashed_password, :string, allow_nil?: false, sensitive?: true)
    attribute(:active, :boolean, default: true, public?: true)
    attribute(:last_seen_at, :utc_datetime, public?: true)
    attribute(:organization_id, :uuid, allow_nil?: false, public?: true)
    attribute(:account_id, :uuid, allow_nil?: false, public?: true)
    attribute(:branch_id, :uuid, allow_nil?: false, public?: true)

    timestamps()
  end

  relationships do
    belongs_to(:organization, LogisticsQuotes.Organization) do
      source_attribute(:organization_id)
      destination_attribute(:id)
    end

    belongs_to(:account, LogisticsQuotes.Account) do
      source_attribute(:account_id)
      destination_attribute(:id)
    end

    belongs_to(:branch, LogisticsQuotes.Branch) do
      source_attribute(:branch_id)
      destination_attribute(:id)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :email, :username, :organization_id, :account_id, :branch_id])
    end

    update :update do
      accept([:name, :email, :username, :organization_id, :account_id, :branch_id])
    end

    read(:by_organization) do
      argument(:organization_id, :uuid, allow_nil?: false)
      filter(expr(organization_id == ^arg(:organization_id)))
    end

    read(:by_account) do
      argument(:account_id, :uuid, allow_nil?: false)
      filter(expr(account_id == ^arg(:account_id)))
    end

    read(:by_branch) do
      argument(:branch_id, :uuid, allow_nil?: false)
      filter(expr(branch_id == ^arg(:branch_id)))
    end

    read(:online_users) do
      filter(expr(last_seen_at > ago(5, :minute)))
    end

    update(:update_last_seen) do
      change(set_attribute(:last_seen_at, &DateTime.utc_now/0))
    end
  end

  validations do
    validate(present([:name, :email, :username, :organization_id, :account_id, :branch_id]))
  end

  identities do
    identity(:unique_email, [:email])
    identity(:unique_username, [:username])
  end
end
