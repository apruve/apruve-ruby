module Apruve
  class LineItem < Apruve::ApruveObject
    attr_accessor :id, :title, :amount_cents, :price_ea_cents, :quantity, :description,
                  :variant_info, :sku, :vendor, :view_product_url, :plan_code, :line_item_api_url,
                  :subscription_url

    def value_string
      "#{title}#{amount_cents}#{price_ea_cents}#{quantity}#{description}#{variant_info}#{sku}"\
      "#{vendor}#{view_product_url}#{plan_code}"
    end

    def validate
      errors = []
      errors << 'title not set' if title.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end
  end
end