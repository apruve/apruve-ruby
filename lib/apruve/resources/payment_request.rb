module Apruve
  class PaymentRequest < ApruveObject
    attr_accessor :merchant_id, :merchant_order_id, :amount_cents, :tax_cents,
                  :shipping_cents, :line_items, :api_url, :view_url, :created_at, :updated_at

    def initialize(params)
      super
      @line_items = [] if @line_items.nil?
    end

    def value_string
      "#{merchant_id}#{merchant_order_id}#{amount_cents}#{tax_cents}#{shipping_cents}#{line_item_values}"\
      "#{api_url}#{view_url}"
    end

    def secure_hash
      if Apruve.client.api_key.nil?
        raise 'api_key has not been set. Set it with Apruve.configure(api_key, environment, options)'
      end
      Digest::SHA256.hexdigest(Apruve.client.api_key+value_string)
    end

    def validate
      errors = []
      errors << 'merchant_id must be set' if merchant_id.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    private

    def line_item_values
      item_value = ''
      unless line_items.nil? || line_items.size == 0
        line_items.each do |line_item|
          item_value += line_item.value_string
        end
      end
      item_value
    end
  end
end