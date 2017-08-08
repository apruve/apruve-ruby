module Apruve
  class Shipment < Apruve::ApruveObject
    attr_accessor :id, :invoice_id, :amount_cents, :currency, :shipper, :shipped_at,
                  :tracking_number, :delivered_at, :merchant_notes, :shipment_items,
                  :tax_cents, :shipping_cents, :status, :merchant_shipment_id

    def self.find(invoice_id, id)
      response = Apruve.get("invoices/#{invoice_id}/shipments/#{id}")
      Shipment.new(response.body)
    end

    def self.find_all(invoice_id)
      response = Apruve.get("invoices/#{invoice_id}/shipments")
      logger.debug response.body
      response.body.map { |shipment| Shipment.new(shipment) }
    end

    def initialize(params)
      super
      # hydrate payment items if appropriate
      if @shipment_items.nil?
        @shipment_items = []
      elsif @shipment_items.is_a?(Array) && @shipment_items.first.is_a?(Hash)
        hydrated_items = []
        @shipment_items.each do |item|
          hydrated_items << Apruve::ShipmentItem.new(item)
        end
        @shipment_items = hydrated_items
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
      Apruve.patch("invoices/#{self.invoice_id}/shipments/#{id}", self.to_json)
    end
  end
end