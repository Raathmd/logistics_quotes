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
    )

    )

    )

    )

