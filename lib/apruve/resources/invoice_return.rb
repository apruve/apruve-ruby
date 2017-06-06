module Apruve
  class InvoiceReturn < Apruve::ApruveObject
    attr_accessor :id, :invoice_id, :amount_cents, :currency, :uuid, :reason, :merchant_notes, :created_by_id,
                  :created_at, :updated_at

    def self.find(invoice_id, id)
      response = Apruve.get("invoices/#{invoice_id}/invoice_returns/#{id}")
      logger.debug response.body
      InvoiceReturn.new(response.body)
    end

    def validate
      errors = []
      errors << 'amount_cents must be set' if amount_cents.nil?
      errors << 'reason must be set' if reason.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def self.find_all(invoice_id)
      response = Apruve.get("invoices/#{invoice_id}/invoice_returns")
      response.body.map { |invoice_return| InvoiceReturn.new(invoice_return) }
    end

    def update!
      validate
      response = Apruve.put("invoices/#{self.invoice_id}/invoice_returns/#{self.id}", self.to_json)
      logger.debug response.body
    end

    def save!
      validate
      response = Apruve.post("invoices/#{self.invoice_id}/invoice_returns", self.to_json)
      logger.debug response.body
      self.id = response.body['id']
    end
  end
end