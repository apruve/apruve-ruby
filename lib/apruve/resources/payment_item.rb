module Apruve
  class PaymentItem < Apruve::ApruveObject
    attr_accessor :title, :amount_cents, :price_ea_cents, :quantity, :description, :variant_info, :sku,
                  :vendor, :view_product_url

  end
end