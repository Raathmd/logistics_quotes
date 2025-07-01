defmodule LogisticsQuotes.Organization do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("organizations")
    repo(LogisticsQuotes.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:code, :string, allow_nil?: false, public?: true)
    attribute(:active, :boolean, default: true, public?: true)

    timestamps()
  end

  relationships do
    has_many(:accounts, LogisticsQuotes.Account) do
      destination_attribute(:organization_id)
    end

    has_many(:branches, LogisticsQuotes.Branch) do
      destination_attribute(:organization_id)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read(:by_code) do
      argument(:code, :string, allow_nil?: false)
      get?(true)
      filter(expr(code == ^arg(:code)))
    end
  end

  validations do
    validate(present([:name, :code]))
    validate(unique([:code]))
  end

  identities do
    identity(:unique_code, [:code])
  end
end
