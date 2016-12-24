module Apruve
  class Shipment < Apruve::ApruveObject
    attr_accessor :id, :invoice_id, :amount_cents, :currency, :shipper, :shipped_at, :tracking_number, :delivered_at, :merchant_notes, :invoice_items

    def self.find(invoice_id, id)
      response = Apruve.get("invoices/#{invoice_id}/shipments/#{id}")
      Shipment.new(response.body)
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
      errors << 'invoice_id must be set' if invoice_id.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def save!
      validate
      response = Apruve.post("invoices/#{self.invoice_id}/shipments", self.to_json)
      self.id = response.body['id']
    end

    def update!
      validate
      response = Apruve.patch("invoices/#{self.invoice_id}/shipments/#{id}", self.to_json)
    end
  end
end