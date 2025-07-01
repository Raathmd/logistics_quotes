defmodule LogisticsQuotes.QuoteRate do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain

  # Embedded resource for quick quote rate results

  attributes do
    uuid_primary_key(:id)
    attribute(:service_type, :string, allow_nil?: false)
    attribute(:freight_charge, :decimal, allow_nil?: false)
    attribute(:sundry_charge, :decimal, allow_nil?: false)
    attribute(:insurance_charge, :decimal, allow_nil?: false)
    attribute(:tax_charge, :decimal, allow_nil?: false)
    attribute(:total_charge, :decimal, allow_nil?: false)
    attribute(:currency, :string, default: "ZAR")
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

    read(:by_service_type) do
      argument(:service_type, :string, allow_nil?: false)
      filter(expr(service_type == ^arg(:service_type)))
    end
  end

  validations do
    validate(
      present([
        :service_type,
        :freight_charge,
        :sundry_charge,
        :insurance_charge,
        :tax_charge,
        :total_charge
      ])
    )

    validate(numericality(:freight_charge, greater_than_or_equal_to: 0))
    validate(numericality(:sundry_charge, greater_than_or_equal_to: 0))
    validate(numericality(:insurance_charge, greater_than_or_equal_to: 0))
    validate(numericality(:tax_charge, greater_than_or_equal_to: 0))
    validate(numericality(:total_charge, greater_than_or_equal_to: 0))
  end
end
