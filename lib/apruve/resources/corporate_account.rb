module Apruve
  class CorporateAccount < Apruve::ApruveObject
    attr_accessor :id, :merchant_uuid, :customer_uuid, :type, :created_at, :updated_at, :payment_term_strategy_name,
                  :disabled_at, :name, :creditor_term_id, :payment_method_id, :status, :trusted_merchant,
                  :authorized_buyers, :credit_available_cents, :credit_balance_cents, :credit_amount_cents

    def self.find(merchant_id, email=nil)
      if email.nil?
        return find_all(merchant_id)
      end
      email = CGI::escape(email)
      response = Apruve.get("merchants/#{merchant_id}/corporate_accounts?email=#{email}")
      CorporateAccount.new(response.body.empty? ? {} : response.body[0])
    end

    def self.find_all(merchant_id)
      response = Apruve.get("merchants/#{merchant_id}/corporate_accounts")
      response.body.map { |ca| CorporateAccount.new(ca.empty? ? {} : ca) }
    end
  end
end