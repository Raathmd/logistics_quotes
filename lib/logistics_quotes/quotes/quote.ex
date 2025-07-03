defmodule LogisticsQuotes.Quotes.Quote do
  use Ash.Resource,
    domain: LogisticsQuotes.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("quotes")
    repo(LogisticsQuotes.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    # Quote fields
    attribute :quote_number, :string do
      constraints(max_length: 35)
    end

    attribute :quote_obj, :decimal do
      constraints(precision: 15, scale: 2)
    end

    attribute(:quote_date, :date)

    attribute :account_reference, :string do
      constraints(max_length: 15)
    end

    attribute :shipper_reference, :string do
      constraints(max_length: 35)
    end

    attribute :service_type, :string do
      constraints(max_length: 10)
    end

    attribute :service_type_description, :string do
      constraints(max_length: 35)
    end

    attribute :consignment_type, :string do
      constraints(max_length: 10)
    end

    attribute :consignment_type_desc, :string do
      constraints(max_length: 35)
    end

    attribute :status_code, :string do
      constraints(max_length: 3)
    end

    attribute :status_description, :string do
      constraints(max_length: 35)
    end

    attribute :collection_instructions, :string do
      constraints(max_length: 500)
    end

    attribute :delivery_instructions, :string do
      constraints(max_length: 500)
    end

    attribute(:estimated_kilometres, :integer)

    attribute(:billable_units, :integer)

    attribute :rate_type, :string do
      constraints(max_length: 10)
    end

    attribute :rate_type_description, :string do
      constraints(max_length: 35)
    end

    attribute(:total_quantity, :integer)

    attribute :total_weight, :decimal do
      constraints(precision: 15, scale: 2)
    end

    # Consignor fields
    attribute :consignor_site, :string do
      constraints(max_length: 15)
    end

    attribute :consignor_name, :string do
      constraints(max_length: 70)
    end

    attribute :consignor_building, :string do
      constraints(max_length: 500)
    end

    attribute :consignor_street, :string do
      constraints(max_length: 500)
    end

    attribute :consignor_suburb, :string do
      constraints(max_length: 500)
    end

    attribute :consignor_city, :string do
      constraints(max_length: 500)
    end

    attribute :consignor_postal_code, :string do
      constraints(max_length: 30)
    end

    attribute :consignor_contact_name, :string do
      constraints(max_length: 70)
    end

    attribute :consignor_contact_tel, :string do
      constraints(max_length: 15)
    end

    # Consignee fields
    attribute :consignee_site, :string do
      constraints(max_length: 15)
    end

    attribute :consignee_name, :string do
      constraints(max_length: 70)
    end

    attribute :consignee_building, :string do
      constraints(max_length: 500)
    end

    attribute :consignee_street, :string do
      constraints(max_length: 500)
    end

    attribute :consignee_suburb, :string do
      constraints(max_length: 500)
    end

    attribute :consignee_city, :string do
      constraints(max_length: 500)
    end

    attribute :consignee_postal_code, :string do
      constraints(max_length: 30)
    end

    attribute :consignee_contact_name, :string do
      constraints(max_length: 70)
    end

    attribute :consignee_contact_tel, :string do
      constraints(max_length: 15)
    end

    # Additional fields
    attribute :waybill_number, :string do
      constraints(max_length: 35)
    end

    attribute :collection_reference, :string do
      constraints(max_length: 15)
    end

    attribute :accepted_by, :string do
      constraints(max_length: 70)
    end

    attribute :reject_reason, :string do
      constraints(max_length: 500)
    end

    attribute :order_number, :string do
      constraints(max_length: 15)
    end

    attribute :value_declared, :decimal do
      constraints(precision: 15, scale: 2)
    end

    attribute :charged_amount, :decimal do
      constraints(precision: 15, scale: 2)
    end

    attribute :cash_account_type, :string do
      constraints(max_length: 15)
    end

    attribute :paying_party, :string do
      constraints(max_length: 15)
    end

    attribute :vehicle_category, :string do
      constraints(max_length: 10)
    end

    # Embedded items
    attribute :items, {:array, :map} do
      default([])
    end

    # Embedded sundries
    attribute :sundries, {:array, :map} do
      default([])
    end

    timestamps()
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([
        :quote_number,
        :quote_obj,
        :quote_date,
        :account_reference,
        :shipper_reference,
        :service_type,
        :service_type_description,
        :consignment_type,
        :consignment_type_desc,
        :status_code,
        :status_description,
        :collection_instructions,
        :delivery_instructions,
        :estimated_kilometres,
        :billable_units,
        :rate_type,
        :rate_type_description,
        :total_quantity,
        :total_weight,
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
        :accepted_by,
        :reject_reason,
        :order_number,
        :value_declared,
        :charged_amount,
        :cash_account_type,
        :paying_party,
        :vehicle_category,
        :items,
        :sundries
      ])
    end

    create :quick_quote do
      accept([
        :account_reference,
        :service_type,
        :consignment_type,
        :consignor_site,
        :consignor_suburb,
        :consignor_city,
        :consignor_postal_code,
        :consignee_site,
        :consignee_suburb,
        :consignee_city,
        :consignee_postal_code,
        :items,
        :sundries
      ])
    end

    update :update do
      accept([
        :quote_obj,
        :account_reference,
        :shipper_reference,
        :service_type,
        :consignment_type,
        :collection_instructions,
        :delivery_instructions,
        :billable_units,
        :rate_type,
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
        :accepted_by,
        :reject_reason,
        :order_number,
        :value_declared,
        :paying_party,
        :vehicle_category,
        :items,
        :sundries
      ])
    end
  end
end
