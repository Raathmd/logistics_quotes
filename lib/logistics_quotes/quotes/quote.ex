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

    attribute :quote_number, :string do
      allow_nil?(false)
      constraints(min_length: 1, max_length: 50)
    end

    attribute :customer_name, :string do
      allow_nil?(false)
      constraints(min_length: 1, max_length: 255)
    end

    attribute :customer_email, :string do
      allow_nil?(false)
      constraints(match: ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    end

    attribute :customer_phone, :string do
      constraints(min_length: 1, max_length: 20)
    end

    attribute :origin_address, :string do
      allow_nil?(false)
      constraints(min_length: 1, max_length: 500)
    end

    attribute :destination_address, :string do
      allow_nil?(false)
      constraints(min_length: 1, max_length: 500)
    end

    attribute :pickup_date, :date do
      allow_nil?(false)
    end

    attribute(:delivery_date, :date)

    attribute :quote_type, :atom do
      constraints(one_of: [:quick, :full])
      default(:quick)
    end

    attribute :status, :atom do
      constraints(one_of: [:draft, :sent, :accepted, :declined, :expired])
      default(:draft)
    end

    attribute :total_amount, :decimal do
      constraints(precision: 10, scale: 2)
    end

    attribute :notes, :string do
      constraints(max_length: 1000)
    end

    attribute :items, {:array, :map} do
      default([])
    end

    timestamps()
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([
        :quote_number,
        :customer_name,
        :customer_email,
        :customer_phone,
        :origin_address,
        :destination_address,
        :pickup_date,
        :delivery_date,
        :quote_type,
        :status,
        :total_amount,
        :notes,
        :items
      ])
    end

    update :update do
      accept([
        :quote_number,
        :customer_name,
        :customer_email,
        :customer_phone,
        :origin_address,
        :destination_address,
        :pickup_date,
        :delivery_date,
        :quote_type,
        :status,
        :total_amount,
        :notes,
        :items
      ])
    end
  end
end
