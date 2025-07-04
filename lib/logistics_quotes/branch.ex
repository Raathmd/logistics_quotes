defmodule LogisticsQuotes.Branch do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("branches")
    repo(LogisticsQuotes.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:code, :string, allow_nil?: false, public?: true)
    attribute(:active, :boolean, default: true, public?: true)
    attribute(:organization_id, :uuid, allow_nil?: false, public?: true)

    timestamps()
  end

  relationships do
    belongs_to(:organization, LogisticsQuotes.Organization) do
      source_attribute(:organization_id)
      destination_attribute(:id)
    end

    has_many(:users, LogisticsQuotes.User) do
      destination_attribute(:branch_id)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read(:by_organization) do
      argument(:organization_id, :uuid, allow_nil?: false)
      filter(expr(organization_id == ^arg(:organization_id)))
    end
  end

  validations do
    validate(present([:name, :code, :organization_id]))
  end

  identities do
    identity(:unique_code, [:code])
  end
end
