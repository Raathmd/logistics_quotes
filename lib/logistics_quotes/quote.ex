defmodule LogisticsQuotes.Quote do
  use Ash.Resource,
    domain: LogisticsQuotes.Domain,
    data_layer: :embedded

  attributes do
    uuid_primary_key(:id)

    # Quote identification
    attribute(:quote_number, :string, allow_nil?: true)
    attribute(:quote_obj, :decimal, allow_nil?: true)
    attribute(:quote_date, :date, allow_nil?: true)
    attribute(:reference, :string, allow_nil?: true)
    attribute(:account_reference, :string, allow_nil?: true)
    attribute(:shipper_reference, :string, allow_nil?: true)

    attribute :status, :atom, default: :draft do
      constraints(one_of: [:draft, :pending, :quoted, :booked, :cancelled])
    end

    attribute(:status_code, :string, allow_nil?: true)
    attribute(:status_description, :string, allow_nil?: true)

    # Service details
    attribute :service_type, :atom, default: :standard do
      constraints(one_of: [:standard, :express, :economy, :premium])
    end

    attribute(:service_type_description, :string, allow_nil?: true)
    attribute(:consignment_type, :string, allow_nil?: true)
    attribute(:consignment_type_desc, :string, allow_nil?: true)

    attribute :quote_type, :atom, default: :quick do
      constraints(one_of: [:quick, :full])
    end

    attribute(:rate_type, :string, allow_nil?: true)
    attribute(:rate_type_description, :string, allow_nil?: true)

    # Instructions
    attribute(:collection_instructions, :string, allow_nil?: true)
    attribute(:delivery_instructions, :string, allow_nil?: true)
    attribute(:special_instructions, :string, allow_nil?: true)

    # Shipment details - Origin (Consignor)
    attribute(:consignor_site, :string, allow_nil?: true)
    attribute(:consignor_name, :string)
    attribute(:consignor_building, :string)
    attribute(:consignor_street, :string)
    attribute(:consignor_suburb, :string)
    attribute(:consignor_city, :string)
    attribute(:consignor_postal_code, :string)
    attribute(:consignor_contact_name, :string)
    attribute(:consignor_contact_tel, :string)

    # Legacy origin fields for backward compatibility
    attribute(:origin_city, :string, allow_nil?: true)
    attribute(:origin_state, :string, allow_nil?: true)
    attribute(:origin_postal_code, :string, allow_nil?: true)
    attribute(:origin_country, :string, default: "AU")

    # Shipment details - Destination (Consignee)
    attribute(:consignee_site, :string, allow_nil?: true)
    attribute(:consignee_name, :string)
    attribute(:consignee_building, :string)
    attribute(:consignee_street, :string)
    attribute(:consignee_suburb, :string)
    attribute(:consignee_city, :string)
    attribute(:consignee_postal_code, :string)
    attribute(:consignee_contact_name, :string)
    attribute(:consignee_contact_tel, :string)

    # Legacy destination fields for backward compatibility
    attribute(:destination_city, :string, allow_nil?: true)
    attribute(:destination_state, :string, allow_nil?: true)
    attribute(:destination_postal_code, :string, allow_nil?: true)
    attribute(:destination_country, :string, default: "AU")

    # Dates and times
    attribute(:pickup_date, :date, allow_nil?: true)
    attribute(:delivery_date, :date, allow_nil?: true)
    attribute(:ready_time, :time, allow_nil?: true)
    attribute(:close_time, :time, allow_nil?: true)
    attribute(:shipment_date, :date, allow_nil?: true)

    # Legacy contact information for backward compatibility
    attribute(:shipper_name, :string, allow_nil?: true)
    attribute(:shipper_contact, :string, allow_nil?: true)
    attribute(:shipper_email, :string, allow_nil?: true)
    attribute(:shipper_phone, :string, allow_nil?: true)

    attribute(:consignee_name_legacy, :string, allow_nil?: true)
    attribute(:consignee_contact_legacy, :string, allow_nil?: true)
    attribute(:consignee_email, :string, allow_nil?: true)
    attribute(:consignee_phone, :string, allow_nil?: true)

    # Quote totals and calculations
    attribute(:estimated_kilometres, :integer, allow_nil?: true)
    attribute(:billable_units, :integer, allow_nil?: true)
    attribute(:total_quantity, :integer, allow_nil?: true)
    attribute(:total_weight, :decimal, allow_nil?: true)
    attribute(:total_volume, :decimal, allow_nil?: true)
    attribute(:total_amount, :decimal, allow_nil?: true)
    attribute(:charged_amount, :decimal, allow_nil?: true)
    attribute(:currency, :string, default: "AUD")

    # Financial details
    attribute(:value_declared, :decimal, allow_nil?: true)
    attribute(:cash_account_type, :string, allow_nil?: true)
    attribute(:paying_party, :string, allow_nil?: true)

    # Special handling
    attribute(:dangerous_goods, :boolean, default: false)
    attribute(:insurance_required, :boolean, default: false)
    attribute(:insurance_value, :decimal, allow_nil?: true)
    attribute(:vehicle_category, :string, allow_nil?: true)

    # References and tracking
    attribute(:waybill_number, :string, allow_nil?: true)
    attribute(:collection_reference, :string, allow_nil?: true)
    attribute(:order_number, :string, allow_nil?: true)

    # Acceptance/rejection
    attribute(:accepted_by, :string, allow_nil?: true)
    attribute(:reject_reason, :string, allow_nil?: true)

    # API related
    attribute(:account_code, :string, allow_nil?: true)
    attribute(:external_quote_id, :string, allow_nil?: true)

    # Embedded quote items
    attribute(:items, {:array, LogisticsQuotes.QuoteItem}, default: [])
    # Embedded sundries
    attribute(:sundries, {:array, LogisticsQuotes.QuoteSundry}, default: [])
    # Embedded rates (for quick quote results)
    attribute(:rates, {:array, LogisticsQuotes.QuoteRate}, default: [])

    timestamps()
  end

  validations do
    # Quick quote validations (minimal required fields)
    validate(present([:consignor_suburb, :consignor_city, :consignor_postal_code]),
      where: [quote_type: :quick]
    )

    validate(present([:consignee_suburb, :consignee_city, :consignee_postal_code]),
      where: [quote_type: :quick]
    )

    # Full quote validations (all required fields)
    validate(
      present([
        :consignor_name,
        :consignor_building,
        :consignor_street,
        :consignor_suburb,
        :consignor_city,
        :consignor_postal_code,
        :consignor_contact_name,
        :consignor_contact_tel
      ]),
      where: [quote_type: :full]
    )

    validate(
      present([
        :consignee_name,
        :consignee_building,
        :consignee_street,
        :consignee_suburb,
        :consignee_city,
        :consignee_postal_code,
        :consignee_contact_name,
        :consignee_contact_tel
      ]),
      where: [quote_type: :full]
    )

    validate(present(:pickup_date), where: [quote_type: :full])

    validate(fn changeset, _context ->
      items = Ash.Changeset.get_attribute(changeset, :items) || []

      if Enum.empty?(items) do
        {:error, field: :items, message: "must have at least one item"}
      else
        :ok
      end
    end)
  end

  changes do
    change(fn changeset, _context ->
      items = Ash.Changeset.get_attribute(changeset, :items) || []

      total_weight =
        items
        |> Enum.map(&(&1.weight || Decimal.new(0)))
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      total_volume =
        items
        |> Enum.map(fn item ->
          if item.length && item.width && item.height do
            Decimal.mult(
              Decimal.mult(item.length, item.width),
              item.height
            )
          else
            Decimal.new(0)
          end
        end)
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      total_quantity =
        items
        |> Enum.map(&(&1.quantity || 1))
        |> Enum.sum()

      changeset
      |> Ash.Changeset.change_attribute(:total_weight, total_weight)
      |> Ash.Changeset.change_attribute(:total_volume, total_volume)
      |> Ash.Changeset.change_attribute(:total_quantity, total_quantity)
    end)
  end

  actions do
    defaults([:read])

    create :create do
      primary?(true)

      accept([
        :quote_number,
        :reference,
        :account_reference,
        :shipper_reference,
        :status,
        :service_type,
        :consignment_type,
        :quote_type,
        :rate_type,
        :collection_instructions,
        :delivery_instructions,
        :special_instructions,
        :consignor_site,
        :consignor_name,
        :consignor_building,
        :consignor_street,
        :consignor_suburb,
        :consignor_city,
        :consignor_postal_code,
        :consignor_contact_name,
        :consignor_contact_tel,
        :consignee_site,
        :consignee_name,
        :consignee_building,
        :consignee_street,
        :consignee_suburb,
        :consignee_city,
        :consignee_postal_code,
        :consignee_contact_name,
        :consignee_contact_tel,
        :pickup_date,
        :delivery_date,
        :ready_time,
        :close_time,
        :shipment_date,
        :estimated_kilometres,
        :billable_units,
        :value_declared,
        :paying_party,
        :dangerous_goods,
        :insurance_required,
        :insurance_value,
        :vehicle_category,
        :waybill_number,
        :collection_reference,
        :order_number,
        :accepted_by,
        :reject_reason,
        :account_code,
        :items,
        :sundries
      ])
    end

    update :update do
      primary?(true)

      accept([
        :quote_number,
        :reference,
        :account_reference,
        :shipper_reference,
        :status,
        :service_type,
        :consignment_type,
        :quote_type,
        :rate_type,
        :collection_instructions,
        :delivery_instructions,
        :special_instructions,
        :consignor_site,
        :consignor_name,
        :consignor_building,
        :consignor_street,
        :consignor_suburb,
        :consignor_city,
        :consignor_postal_code,
        :consignor_contact_name,
        :consignor_contact_tel,
        :consignee_site,
        :consignee_name,
        :consignee_building,
        :consignee_street,
        :consignee_suburb,
        :consignee_city,
        :consignee_postal_code,
        :consignee_contact_name,
        :consignee_contact_tel,
        :pickup_date,
        :delivery_date,
        :ready_time,
        :close_time,
        :shipment_date,
        :estimated_kilometres,
        :billable_units,
        :value_declared,
        :paying_party,
        :dangerous_goods,
        :insurance_required,
        :insurance_value,
        :vehicle_category,
        :waybill_number,
        :collection_reference,
        :order_number,
        :accepted_by,
        :reject_reason,
        :account_code,
        :items,
        :sundries,
        :rates,
        :total_amount,
        :charged_amount,
        :external_quote_id
      ])
    end
  end

  # Manual actions for API integration
  actions do
    action(:search_quotes, LogisticsQuotes.Actions.SearchQuotes)
    action(:quick_quote, LogisticsQuotes.Actions.QuickQuote)
    action(:create_quote, LogisticsQuotes.Actions.CreateQuote)
  end
end
