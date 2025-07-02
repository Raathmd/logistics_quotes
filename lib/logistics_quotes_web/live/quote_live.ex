defmodule LogisticsQuotesWeb.QuoteLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Quote
  alias LogisticsQuotes.QuoteItem

  def mount(_params, _session, socket) do
    # Create empty quote with one item to start
    default_item = %QuoteItem{
      description: "",
      quantity: 1,
      weight: Decimal.new(0),
      length: Decimal.new(0),
      width: Decimal.new(0),
      height: Decimal.new(0)
    }

    quote_attrs = %{
      quote_type: :quick,
      items: [default_item],
      shipment_date: Date.utc_today()
    }

    form = Quote.create(quote_attrs) |> to_form()

    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:quote_type, :quick)
     |> assign(:page_title, "Create Quote")
     |> assign(:loading, false)}
  end

  def handle_event("validate", %{"quote" => quote_params}, socket) do
    # Validate the form and update socket
    case Quote.create(quote_params) do
      {:ok, quote} ->
        form = to_form(quote)
        {:noreply, assign(socket, :form, form)}

      {:error, changeset} ->
        form = to_form(changeset)
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("change_quote_type", %{"type" => type}, socket) do
    quote_type = String.to_existing_atom(type)

    # Get current form data and update quote type
    current_attrs = form_to_attrs(socket.assigns.form)
    updated_attrs = Map.put(current_attrs, :quote_type, quote_type)

    case Quote.create(updated_attrs) do
      {:ok, quote} ->
        form = to_form(quote)

        {:noreply,
         socket
         |> assign(:form, form)
         |> assign(:quote_type, quote_type)}

      {:error, changeset} ->
        form = to_form(changeset)
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("add_item", _params, socket) do
    current_attrs = form_to_attrs(socket.assigns.form)
    current_items = current_attrs[:items] || []

    new_item = %QuoteItem{
      description: "",
      quantity: 1,
      weight: Decimal.new(0),
      length: Decimal.new(0),
      width: Decimal.new(0),
      height: Decimal.new(0)
    }

    updated_attrs = Map.put(current_attrs, :items, current_items ++ [new_item])

    case Quote.create(updated_attrs) do
      {:ok, quote} ->
        form = to_form(quote)
        {:noreply, assign(socket, :form, form)}

      {:error, changeset} ->
        form = to_form(changeset)
        {:noreply, assign(socket, :form, form)}
    end
  end

  def handle_event("remove_item", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    current_attrs = form_to_attrs(socket.assigns.form)
    current_items = current_attrs[:items] || []

    if length(current_items) > 1 do
      updated_items = List.delete_at(current_items, index)
      updated_attrs = Map.put(current_attrs, :items, updated_items)

      case Quote.create(updated_attrs) do
        {:ok, quote} ->
          form = to_form(quote)
          {:noreply, assign(socket, :form, form)}

        {:error, changeset} ->
          form = to_form(changeset)
          {:noreply, assign(socket, :form, form)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("submit_quote", %{"quote" => quote_params}, socket) do
    socket = assign(socket, :loading, true)

    case socket.assigns.quote_type do
      :quick ->
        handle_quick_quote(quote_params, socket)

      :full ->
        handle_create_quote(quote_params, socket)
    end
  end

  defp handle_quick_quote(quote_params, socket) do
    case Quote.quick_quote(quote_params) do
      {:ok, quote_with_rates} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:quote_result, quote_with_rates)
         |> put_flash(:info, "Quick quote generated successfully!")}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Failed to generate quick quote: #{inspect(error)}")}
    end
  end

  defp handle_create_quote(quote_params, socket) do
    case Quote.create_quote(quote_params) do
      {:ok, created_quote} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:quote_result, created_quote)
         |> put_flash(:info, "Quote created successfully!")}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Failed to create quote: #{inspect(error)}")}
    end
  end

  defp form_to_attrs(form) do
    form.params || %{}
  end
end
