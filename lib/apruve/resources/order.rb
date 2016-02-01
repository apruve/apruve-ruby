module Apruve
  class Order < Apruve::ApruveObject
    attr_accessor :id, :merchant_id, :customer_id, :merchant_order_id, :status, :amount_cents, :currency, :tax_cents,
                  :shipping_cents, :expire_at, :order_items, :accepts_payments_via, :accepts_payment_terms, :payment_terms,
                  :created_at, :updated_at, :final_state_at, :default_payment_method, :links, :finalize_on_create, :invoice_on_create

    def self.find(id)
      response = Apruve.get("orders/#{id}")
      logger.debug response.body
      Order.new(response.body)
    end

    def self.finalize!(id)
      response = Apruve.post("orders/#{id}/finalize")
      logger.debug response.body
      Order.new(response.body)
    end

    def self.invoices_for(order_id)
      response = Apruve.get("orders/#{order_id}/invoices")
      ret = []
      response.body.each do |i|
        ret << Invoice.new(i)
      end
      ret
    end
    
    def update!
      response = Apruve.patch("orders/#{id}", self.to_json)
      logger.debug response.body
      initialize response.body
    end

    def initialize(params)
      super
      # hydrate line items if appropriate
      if @order_items.nil?
        @order_items = []
      elsif @order_items.is_a?(Array) && @order_items.first.is_a?(Hash)
        hydrated_items = []
        @order_items.each do |item|
          hydrated_items << Apruve::OrderItem.new(item)
        end
        @order_items = hydrated_items
      end
    end

    def validate
      errors = []
      errors << 'merchant_id must be set' if merchant_id.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def value_string
      # add each field in the PR
      str = "#{merchant_id}#{merchant_order_id}#{amount_cents}#{currency}#{tax_cents}#{shipping_cents}#{expire_at}#{accepts_payment_terms}#{finalize_on_create}#{invoice_on_create}"

      # add the line items
      self.order_items.each do |item|
        str += "#{item.title}#{item.plan_code}#{item.amount_cents}#{item.price_ea_cents}"\
        "#{item.quantity}#{item.merchant_notes}#{item.description}#{item.variant_info}#{item.sku}"\
        "#{item.vendor}#{item.view_product_url}"
      end

      str
    end

    def secure_hash
      if Apruve.client.api_key.nil?
        raise 'api_key has not been set. Set it with Apruve.configure(api_key, environment, options)'
      end
      Digest::SHA256.hexdigest(Apruve.client.api_key+value_string)
    end
  end
end