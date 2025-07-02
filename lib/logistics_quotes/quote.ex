defmodule LogisticsQuotes.Quote do
  use Ash.Resource,
    domain: LogisticsQuotes.Domain,
    data_layer: :embedded

  attributes do
    uuid_primary_key(:id)

    # Quote identification
    attribute(:quote_number, :string, allow_nil?: true)
    attribute(:reference, :string, allow_nil?: true)

    attribute :status, :atom, default: :draft do
      constraints(one_of: [:draft, :pending, :quoted, :booked, :cancelled])
    end

    # Service details
    attribute :service_type, :atom, default: :standard do
      constraints(one_of: [:standard, :express, :economy, :premium])
    end

    attribute :quote_type, :atom, default: :quick do
      constraints(one_of: [:quick, :full])
    end

    # Shipment details
    attribute(:origin_city, :string)
    attribute(:origin_state, :string)
    attribute(:origin_postal_code, :string)
    attribute(:origin_country, :string, default: "AU")

    attribute(:destination_city, :string)
    attribute(:destination_state, :string)
    attribute(:destination_postal_code, :string)
    attribute(:destination_country, :string, default: "AU")

    # Dates
    attribute(:pickup_date, :date, allow_nil?: true)
    attribute(:delivery_date, :date, allow_nil?: true)
    attribute(:ready_time, :time, allow_nil?: true)
    attribute(:close_time, :time, allow_nil?: true)

    # Contact information
    attribute(:shipper_name, :string, allow_nil?: true)
    attribute(:shipper_contact, :string, allow_nil?: true)
    attribute(:shipper_email, :string, allow_nil?: true)
    attribute(:shipper_phone, :string, allow_nil?: true)

    attribute(:consignee_name, :string, allow_nil?: true)
    attribute(:consignee_contact, :string, allow_nil?: true)
    attribute(:consignee_email, :string, allow_nil?: true)
    attribute(:consignee_phone, :string, allow_nil?: true)

    # Quote details
    attribute(:total_weight, :decimal, allow_nil?: true)
    attribute(:total_volume, :decimal, allow_nil?: true)
    attribute(:total_amount, :decimal, allow_nil?: true)
    attribute(:currency, :string, default: "AUD")

    # Special instructions
    attribute(:special_instructions, :string, allow_nil?: true)
    attribute(:dangerous_goods, :boolean, default: false)
    attribute(:insurance_required, :boolean, default: false)
    attribute(:insurance_value, :decimal, allow_nil?: true)

    # API related
    attribute(:account_code, :string, allow_nil?: true)
    attribute(:external_quote_id, :string, allow_nil?: true)

    # Embedded quote items
    attribute(:items, {:array, LogisticsQuotes.QuoteItem}, default: [])

    timestamps()
  end

  validations do
    validate(present([:origin_city, :destination_city]))
    validate(present(:pickup_date), where: [quote_type: :full])
    validate(present(:shipper_name), where: [quote_type: :full])
    validate(present(:consignee_name), where: [quote_type: :full])

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

      changeset
      |> Ash.Changeset.change_attribute(:total_weight, total_weight)
      |> Ash.Changeset.change_attribute(:total_volume, total_volume)
    end)
  end

  actions do
    defaults([:read])

    create :create do
      primary?(true)

      accept([
        :quote_number,
        :reference,
        :status,
        :service_type,
        :quote_type,
        :origin_city,
        :origin_state,
        :origin_postal_code,
        :origin_country,
        :destination_city,
        :destination_state,
        :destination_postal_code,
        :destination_country,
        :pickup_date,
        :delivery_date,
        :ready_time,
        :close_time,
        :shipper_name,
        :shipper_contact,
        :shipper_email,
        :shipper_phone,
        :consignee_name,
        :consignee_contact,
        :consignee_email,
        :consignee_phone,
        :special_instructions,
        :dangerous_goods,
        :insurance_required,
        :insurance_value,
        :account_code,
        :items
      ])
    end

    update :update do
      primary?(true)

      accept([
        :quote_number,
        :reference,
        :status,
        :service_type,
        :quote_type,
        :origin_city,
        :origin_state,
        :origin_postal_code,
        :origin_country,
        :destination_city,
        :destination_state,
        :destination_postal_code,
        :destination_country,
        :pickup_date,
        :delivery_date,
        :ready_time,
        :close_time,
        :shipper_name,
        :shipper_contact,
        :shipper_email,
        :shipper_phone,
        :consignee_name,
        :consignee_contact,
        :consignee_email,
        :consignee_phone,
        :special_instructions,
        :dangerous_goods,
        :insurance_required,
        :insurance_value,
        :account_code,
        :items,
        :total_amount,
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
