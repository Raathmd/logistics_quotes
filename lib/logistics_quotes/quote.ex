defmodule LogisticsQuotes.Quote do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain

  # Non-persisted resource for API integration

  attributes do
    uuid_primary_key(:id)

    # Core quote fields
    attribute(:quote_number, :string)
    attribute(:quote_obj, :decimal)
    attribute(:quote_date, :date)
    attribute(:account_reference, :string)
    attribute(:shipper_reference, :string)
    attribute(:service_type, :string)
    attribute(:service_level, :string)
    attribute(:route, :string)
    attribute(:status, :string)

    # Collection details
    attribute(:collection_company, :string)
    attribute(:collection_contact, :string)
    attribute(:collection_tel, :string)
    attribute(:collection_email, :string)
    attribute(:collection_address_1, :string)
    attribute(:collection_address_2, :string)
    attribute(:collection_address_3, :string)
    attribute(:collection_postal_code, :string)
    attribute(:collection_date, :date)
    attribute(:collection_from_time, :time)
    attribute(:collection_to_time, :time)
    attribute(:collection_instructions, :string)

    # Delivery details
    attribute(:delivery_company, :string)
    attribute(:delivery_contact, :string)
    attribute(:delivery_tel, :string)
    attribute(:delivery_email, :string)
    attribute(:delivery_address_1, :string)
    attribute(:delivery_address_2, :string)
    attribute(:delivery_address_3, :string)
    attribute(:delivery_postal_code, :string)
    attribute(:delivery_date, :date)
    attribute(:delivery_from_time, :time)
    attribute(:delivery_to_time, :time)
    attribute(:delivery_instructions, :string)

    # Quote totals
    attribute(:freight_charge, :decimal)
    attribute(:sundry_charge, :decimal)
    attribute(:insurance_charge, :decimal)
    attribute(:tax_charge, :decimal)
    attribute(:total_charge, :decimal)

    timestamps()
  end

  relationships do
    has_many(:items, LogisticsQuotes.QuoteItem) do
      destination_attribute(:quote_id)
    end

    has_many(:sundries, LogisticsQuotes.QuoteSundry) do
      destination_attribute(:quote_id)
    end

    has_many(:rates, LogisticsQuotes.QuoteRate) do
      destination_attribute(:quote_id)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read(:search) do
      manual(LogisticsQuotes.Actions.SearchQuotes)
      argument(:filters, :map, default: %{})
    end

    create(:quick_quote) do
      manual(LogisticsQuotes.Actions.QuickQuote)
      argument(:shipment_data, :map, allow_nil?: false)
    end

    create(:create_quote) do
      manual(LogisticsQuotes.Actions.CreateQuote)
      argument(:quote_data, :map, allow_nil?: false)
    end

    update(:accept_quote) do
      argument(:quote_number, :string, allow_nil?: false)
      change(set_attribute(:status, "accepted"))
    end

    update(:reject_quote) do
      argument(:quote_number, :string, allow_nil?: false)
      change(set_attribute(:status, "rejected"))
    end
  end

  validations do
    validate(present([:quote_number]))
  end
end
