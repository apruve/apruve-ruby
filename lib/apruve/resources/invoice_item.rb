module Apruve
  class InvoiceItem < Apruve::ApruveObject
    attr_accessor :title, :price_total_cents, :price_ea_cents, :quantity, :description, :variant_info, :sku,
                  :vendor, :view_product_url

  end
end