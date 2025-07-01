defmodule LogisticsQuotes.QuoteSundry do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain

  # Embedded resource for quote sundries

  attributes do
    uuid_primary_key(:id)
    attribute(:service_type, :string, allow_nil?: false)
    attribute(:sundry_code, :string, allow_nil?: false)
    attribute(:sundry_description, :string)
    attribute(:sundry_direction, :string, allow_nil?: false)
    attribute(:sundry_charge, :decimal, allow_nil?: false)
    attribute(:sundry_currency, :string, default: "ZAR")
    attribute(:sundry_taxable, :boolean, default: false)
    attribute(:quote_id, :uuid)

    timestamps()
  end

  relationships do
    belongs_to(:quote, LogisticsQuotes.Quote) do
      source_attribute(:quote_id)
      destination_attribute(:id)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read(:by_quote) do
      argument(:quote_id, :uuid, allow_nil?: false)
      filter(expr(quote_id == ^arg(:quote_id)))
    end

    read(:by_direction) do
      argument(:direction, :string, allow_nil?: false)
      filter(expr(sundry_direction == ^arg(:direction)))
    end

    read(:taxable_sundries) do
      filter(expr(sundry_taxable == true))
    end
  end

  validations do
    validate(present([:service_type, :sundry_code, :sundry_direction, :sundry_charge]))
    validate(one_of(:sundry_direction, ["C", "D", "BOTH"]))
    validate(numericality(:sundry_charge, greater_than_or_equal_to: 0))
  end
end
