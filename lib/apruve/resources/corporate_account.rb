module Apruve
  class CorporateAccount < Apruve::ApruveObject
    attr_accessor :id, :merchant_uuid, :customer_uuid, :type, :created_at, :updated_at, :payment_term_strategy_name,
                  :disabled_at, :name, :creditor_term_id, :payment_method_id, :status, :trusted_merchant

    def self.find(merchant_id, email)
      begin
        response = Apruve.get("merchants/#{merchant_id}/corporate_accounts?email=#{email}")
        return CorporateAccount.new(response.body[0])
      rescue Apruve::NotFound
        return nil
      end
    end
  end
end