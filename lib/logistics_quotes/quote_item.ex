defmodule LogisticsQuotes.QuoteItem do
  use Ash.Resource,
    otp_app: :logistics_quotes,
    domain: LogisticsQuotes.Domain

  # Embedded resource for quote items

  attributes do
    uuid_primary_key(:id)
    attribute(:quote_number, :string)
    attribute(:line_number, :integer)
    attribute(:quantity, :integer, allow_nil?: false, default: 1)
    attribute(:product_code, :string)
    attribute(:description, :string)
    attribute(:total_weight, :decimal)
    attribute(:unit_weight, :decimal)
    attribute(:weight_uom, :string, default: "KG")
    attribute(:length, :decimal)
    attribute(:width, :decimal)
    attribute(:height, :decimal)
    attribute(:volume, :decimal)
    attribute(:dimension_uom, :string, default: "CM")
    attribute(:volumetric_weight, :decimal)
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

    create(:calculate_volumetric) do
      change(fn changeset, _context ->
        length = Ash.Changeset.get_attribute(changeset, :length) || 0
        width = Ash.Changeset.get_attribute(changeset, :width) || 0
        height = Ash.Changeset.get_attribute(changeset, :height) || 0

        volume =
          Decimal.mult(Decimal.mult(Decimal.new(length), Decimal.new(width)), Decimal.new(height))

        volumetric_weight = Decimal.div(volume, Decimal.new(5000))

        changeset
        |> Ash.Changeset.change_attribute(:volume, volume)
        |> Ash.Changeset.change_attribute(:volumetric_weight, volumetric_weight)
      end)
    end
  end

  validations do
    validate(present([:quantity]))
    validate(numericality(:quantity, greater_than: 0))
  end
end
