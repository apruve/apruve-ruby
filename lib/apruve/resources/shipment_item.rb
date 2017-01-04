module Apruve
  class ShipmentItem < Apruve::ApruveObject
    attr_accessor :title,
                  :amount_cents,
                  :price_ea_cents,
                  :price_total_cents,
                  :shipping_cents,
                  :tax_cents,
                  :quantity,
                  :description,
                  :variant_info,
                  :sku,
                  :vendor,
                  :currency,
                  :view_product_url,
                  :price_ea_cents,
                  :taxable,
                  :shipment_id,
                  :uuid

  end
end