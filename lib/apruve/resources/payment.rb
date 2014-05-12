module Apruve
  class Payment < Apruve::ApruveObject
    attr_accessor :id, :payment_request_id, :status, :status, :amount_cents, :currency, :merchant_notes,
                  :payment_items, :api_url, :view_url, :created_at, :updated_at

    def self.find(payment_request_id, id)
      response = Apruve.get("payment_requests/#{payment_request_id}/payments/#{id}")
      Payment.new(response.body)
    end

    def initialize(params)
      super
      # hydrate payment items if appropriate
      if @payment_items.nil?
        @payment_items = []
      elsif @payment_items.is_a?(Array) && @payment_items.first.is_a?(Hash)
        hydrated_items = []
        @payment_items.each do |item|
          hydrated_items << Apruve::LineItem.new(item)
        end
        @payment_items = hydrated_items
      end
      @currency = Apruve.default_currency if currency.nil?
    end

    def validate
      errors = []
      errors << 'payment_request_id must be set' if payment_request_id.nil?
      errors << 'amount_cents must be set' if amount_cents.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def save!
      validate
      response = Apruve.post("payment_requests/#{self.payment_request_id}/payments", self.to_json)
      self.id = response.body['id']
      self.status = response.body['status']
      self.api_url = response.body['api_url']
      self.view_url = response.body['view_url']
      self.status
    end
  end
end