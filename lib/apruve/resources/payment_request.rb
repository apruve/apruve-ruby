module Apruve
  class PaymentRequest < ApruveObject
    attr_accessor :merchant_id, :merchant_order_id, :amount_cents, :tax_cents,
                  :shipping_cents, :line_items, :api_url, :view_url, :created_at, :updated_at

    def self.find(id)
      Apruve.get("/payment_requests/#{id}")
    end

    def initialize(params)
      super
      @line_items = [] if @line_items.nil?
    end

    def validate
      errors = []
      errors << 'merchant_id must be set' if merchant_id.nil?
      raise Apruve::ValidationError.new(errors) if errors.length > 0
    end

    def value_string
      token_string = to_hash.map do |k, v|
        str = ''
        if v.kind_of?(Array)
          v.each do |item|
            str = str + item.map{|q,r| r}.join
          end
        else
          str = v
        end
        str
      end
      token_string.join
    end

    def secure_hash
      if Apruve.client.api_key.nil?
        raise 'api_key has not been set. Set it with Apruve.configure(api_key, environment, options)'
      end
      Digest::SHA256.hexdigest(Apruve.client.api_key+value_string)
    end
  end
end