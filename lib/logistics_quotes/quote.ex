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
    attribute(:account_reference, :string, allow_nil?: true)
    attribute(:shipper_reference, :string, allow_nil?: true)

    # Service details
    attribute(:service_type, :string, allow_nil?: true)
    attribute(:service_type_description, :string, allow_nil?: true)
    attribute(:consignment_type, :string, allow_nil?: true)
    attribute(:consignment_type_desc, :string, allow_nil?: true)

    # Status
    attribute(:status_code, :string, allow_nil?: true)
    attribute(:status_description, :string, allow_nil?: true)

    # Instructions
    attribute(:collection_instructions, :string, allow_nil?: true)
    attribute(:delivery_instructions, :string, allow_nil?: true)

    # Distance and billing
    attribute(:estimated_kilometres, :integer, allow_nil?: true)
    attribute(:billable_units, :integer, allow_nil?: true)
    attribute(:rate_type, :string, allow_nil?: true)
    attribute(:rate_type_description, :string, allow_nil?: true)

    # Calculated totals
    attribute(:total_quantity, :integer, allow_nil?: true)
    attribute(:total_weight, :decimal, allow_nil?: true)

    # Consignor (Origin) details
    attribute(:consignor_site, :string, allow_nil?: true)
    attribute(:consignor_name, :string, allow_nil?: true)
    attribute(:consignor_building, :string, allow_nil?: true)
    attribute(:consignor_street, :string, allow_nil?: true)
    attribute(:consignor_suburb, :string, allow_nil?: true)
    attribute(:consignor_city, :string, allow_nil?: true)
    attribute(:consignor_postal_code, :string, allow_nil?: true)
    attribute(:consignor_contact_name, :string, allow_nil?: true)
    attribute(:consignor_contact_tel, :string, allow_nil?: true)

    # Consignee (Destination) details
    attribute(:consignee_site, :string, allow_nil?: true)
    attribute(:consignee_name, :string, allow_nil?: true)
    attribute(:consignee_building, :string, allow_nil?: true)
    attribute(:consignee_street, :string, allow_nil?: true)
    attribute(:consignee_suburb, :string, allow_nil?: true)
    attribute(:consignee_city, :string, allow_nil?: true)
    attribute(:consignee_postal_code, :string, allow_nil?: true)
    attribute(:consignee_contact_name, :string, allow_nil?: true)
    attribute(:consignee_contact_tel, :string, allow_nil?: true)

    # Tracking and references
    attribute(:waybill_number, :string, allow_nil?: true)
    attribute(:collection_reference, :string, allow_nil?: true)
    attribute(:order_number, :string, allow_nil?: true)

    # Acceptance/rejection
    attribute(:accepted_by, :string, allow_nil?: true)
    attribute(:reject_reason, :string, allow_nil?: true)

    # Financial details
    attribute(:value_declared, :decimal, allow_nil?: true)
    attribute(:charged_amount, :decimal, allow_nil?: true)
    attribute(:cash_account_type, :string, allow_nil?: true)
    attribute(:paying_party, :string, allow_nil?: true)
    attribute(:vehicle_category, :string, allow_nil?: true)

    # Quick quote specific fields
    attribute(:shipment_date, :date, allow_nil?: true)

    # Quote type indicator (for our internal use)
    attribute(:quote_type, :atom, default: :quick, constraints: [one_of: [:quick, :full]])

    # Embedded collections
    attribute(:items, {:array, :map}, default: [])
    attribute(:sundries, {:array, :map}, default: [])
    attribute(:rates, {:array, :map}, default: [])

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

    # Full quote validations (all required fields per API)
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
        |> Enum.map(&(&1.total_weight || Decimal.new(0)))
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      total_quantity =
        items
        |> Enum.map(&(&1.quantity || 1))
        |> Enum.sum()

      changeset
      |> Ash.Changeset.change_attribute(:total_weight, total_weight)
      |> Ash.Changeset.change_attribute(:total_quantity, total_quantity)
    end)
  end

  actions do
    defaults([:read])

    create :create do
      primary?(true)

      accept([
        :quote_number,
        :account_reference,
        :shipper_reference,
        :service_type,
        :consignment_type,
        :quote_type,
        :rate_type,
        :collection_instructions,
        :delivery_instructions,
        :estimated_kilometres,
        :billable_units,
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
        :waybill_number,
        :collection_reference,
        :order_number,
        :accepted_by,
        :reject_reason,
        :value_declared,
        :paying_party,
        :vehicle_category,
        :shipment_date,
        :items,
        :sundries
      ])
    end

    update :update do
      primary?(true)

      accept([
        :quote_number,
        :account_reference,
        :shipper_reference,
        :service_type,
        :consignment_type,
        :quote_type,
        :rate_type,
        :collection_instructions,
        :delivery_instructions,
        :estimated_kilometres,
        :billable_units,
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
        :waybill_number,
        :collection_reference,
        :order_number,
        :accepted_by,
        :reject_reason,
        :value_declared,
        :paying_party,
        :vehicle_category,
        :shipment_date,
        :items,
        :sundries,
        :rates,
        :charged_amount
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
