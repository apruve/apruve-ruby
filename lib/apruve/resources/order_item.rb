module Apruve
  class OrderItem < Apruve::ApruveObject
    attr_accessor :id, :title, :amount_cents, :price_ea_cents, :quantity, :description, :merchant_notes,
                  :variant_info, :sku, :vendor, :view_product_url, :plan_code, :line_item_api_url,
                  :subscription_url

    def validate
      errors = []
      errors << 'title must be set on line items' if title.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end
  end
end