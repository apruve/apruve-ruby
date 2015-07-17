module Apruve
  class Invoice < Apruve::ApruveObject
    attr_accessor :id, :order_id, :status, :amount_cents, :currency, :merchant_notes, :merchant_invoice_id, :shipping_cents,
                  :tax_cents, :invoice_items, :payments, :created_at, :opened_at, :due_at, :final_state_at, :auto_issue, :links

    def self.find(id)
      response = Apruve.get("invoices/#{id}")
      Invoice.new(response.body)
    end
    
    def self.index(order_id)
      response = Apruve.get("orders/#{order_id}/invoices")
      ret = []
      response.body.each do |i|
        ret << Invoice.new(i)
      end
      ret
    end

    def initialize(params)
      super
      # hydrate payment items if appropriate
      if @invoice_items.nil?
        @invoice_items = []
      elsif @invoice_items.is_a?(Array) && @invoice_items.first.is_a?(Hash)
        hydrated_items = []
        @invoice_items.each do |item|
          hydrated_items << Apruve::OrderItem.new(item)
        end
        @invoice_items = hydrated_items
      end
      @currency = Apruve.default_currency if currency.nil?
    end

    def validate
      errors = []
      errors << 'order_id must be set' if order_id.nil?
      errors << 'amount_cents must be set' if amount_cents.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def save!
      validate
      response = Apruve.post('invoices', self.to_json)
      self.id = response.body['id']
      self.status = response.body['status']
      self.status
    end

    def update!
      validate
      response = Apruve.patch("invoices/#{id}", self.to_json)
      self.status = response.body['status']
      self.status
    end

    def issue!
      validate
      response = Apruve.post("invoices/#{id}/issue")
      self.status = response.body['status']
      self.status
    end

    def close!
      validate
      response = Apruve.post("invoices/#{id}/close")
      self.status = response.body['status']
      self.status
    end

    def cancel!
      validate
      response = Apruve.post("invoices/#{id}/cancel")
      self.status = response.body['status']
      self.status
    end
  end
end