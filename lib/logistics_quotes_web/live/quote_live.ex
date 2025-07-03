defmodule LogisticsQuotesWeb.QuoteLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Quotes.Quote

  def mount(_params, _session, socket) do
    # Initialize empty quote form
    quote_attrs = %{
      account_reference: "",
      service_type: "",
      consignment_type: "",
      consignor_site: "",
      consignor_name: "",
      consignor_building: "",
      consignor_street: "",
      consignor_suburb: "",
      consignor_city: "",
      consignor_postal_code: "",
      consignor_contact_name: "",
      consignor_contact_tel: "",
      consignee_site: "",
      consignee_name: "",
      consignee_building: "",
      consignee_street: "",
      consignee_suburb: "",
      consignee_city: "",
      consignee_postal_code: "",
      consignee_contact_name: "",
      consignee_contact_tel: "",
      collection_instructions: "",
      delivery_instructions: "",
      shipper_reference: "",
      order_number: "",
      value_declared: nil,
      paying_party: "",
      vehicle_category: "",
      items: [
        %{
          quantity: 1,
          product_code: "",
          description: "",
          total_weight: 0.1,
          length: 10,
          width: 10,
          height: 10
        }
      ],
      sundries: []
    }

    form = quote_attrs |> to_form()

    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:show_modal, false)
     |> assign(:modal_title, "")
     |> assign(:modal_content, "")
     |> assign(:active_nav, "quotes")}
  end

  def handle_event("validate", %{"quote" => quote_params}, socket) do
    # Update form with new values for live validation
    form = quote_params |> to_form()
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("add_item", _params, socket) do
    current_items = socket.assigns.form.params["items"] || []

    new_item = %{
      "quantity" => "1",
      "product_code" => "",
      "description" => "",
      "total_weight" => "0.1",
      "length" => "10",
      "width" => "10",
      "height" => "10"
    }

    updated_params = Map.put(socket.assigns.form.params, "items", current_items ++ [new_item])
    form = updated_params |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("remove_item", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    current_items = socket.assigns.form.params["items"] || []

    if length(current_items) > 1 do
      updated_items = List.delete_at(current_items, index)
      updated_params = Map.put(socket.assigns.form.params, "items", updated_items)
      form = updated_params |> to_form()
      {:noreply, assign(socket, :form, form)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("quick_quote", %{"quote" => quote_params}, socket) do
    # Clean up params for quick quote action
    cleaned_params = clean_quote_params(quote_params)

    case Ash.create(Quote, :quick_quote, cleaned_params) do
      {:ok, quote} ->
        {:noreply,
         socket
         |> assign(:show_modal, true)
         |> assign(:modal_title, "Quick Quote Result")
         |> assign(:modal_content, format_quick_quote_response(quote))}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:show_modal, true)
         |> assign(:modal_title, "Quick Quote Error")
         |> assign(:modal_content, "Error: #{inspect(error)}")}
    end
  end

  def handle_event("create_quote", %{"quote" => quote_params}, socket) do
    # Clean up params for create action
    cleaned_params = clean_quote_params(quote_params)

    case Ash.create(Quote, :create, cleaned_params) do
      {:ok, quote} ->
        {:noreply,
         socket
         |> assign(:show_modal, true)
         |> assign(:modal_title, "Quote Created")
         |> assign(:modal_content, format_create_quote_response(quote))}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:show_modal, true)
         |> assign(:modal_title, "Quote Creation Error")
         |> assign(:modal_content, "Error: #{inspect(error)}")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  defp clean_quote_params(params) do
    # Convert string values to appropriate types and clean up empty values
    params
    |> Map.update("items", [], fn items ->
      Enum.map(items, fn item ->
        %{
          "quantity" => parse_integer(item["quantity"]),
          "product_code" => item["product_code"] || "",
          "description" => item["description"] || "",
          "total_weight" => parse_decimal(item["total_weight"]),
          "length" => parse_decimal(item["length"]),
          "width" => parse_decimal(item["width"]),
          "height" => parse_decimal(item["height"])
        }
      end)
    end)
    |> Map.update("sundries", [], fn sundries -> sundries end)
    |> Enum.reject(fn {_k, v} -> v == "" or is_nil(v) end)
    |> Map.new()
  end

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> 1
    end
  end

  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(_), do: 1

  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, _} -> decimal
      :error -> Decimal.new("0.1")
    end
  end

  defp parse_decimal(value), do: Decimal.new(to_string(value))

  defp format_quick_quote_response(quote) do
    """
    Quick Quote Generated Successfully!

    Quote ID: #{quote.id}
    Service Type: #{quote.service_type || "Standard"}
    Total Items: #{length(quote.items || [])}

    From: #{quote.consignor_suburb}, #{quote.consignor_city}
    To: #{quote.consignee_suburb}, #{quote.consignee_city}
    """
  end

  defp format_create_quote_response(quote) do
    """
    Quote Created Successfully!

    Quote Number: #{quote.quote_number || "Pending"}
    Quote ID: #{quote.id}
    Service Type: #{quote.service_type || "Standard"}
    Total Items: #{length(quote.items || [])}

    Consignor: #{quote.consignor_name}
    Consignee: #{quote.consignee_name}
    """
  end
end
