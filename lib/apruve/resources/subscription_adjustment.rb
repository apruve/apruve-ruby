module Apruve
  class SubscriptionAdjustment < Apruve::ApruveObject
    attr_accessor :id, :subscription_id, :status, :title, :amount_cents, :price_ea_cents, :quantity, :description,
                  :variant_info, :sku, :vendor, :view_product_url, :api_url, :merchant_notes

    def self.find(subscription_id, id)
      response = Apruve.get("subscriptions/#{subscription_id}/adjustments/#{id}")
      logger.debug response.body
      SubscriptionAdjustment.new(response.body)
    end

    def self.find_all(subscription_id)
      response = Apruve.get("subscriptions/#{subscription_id}/adjustments")
      logger.debug response.body
      SubscriptionAdjustment.new(response.body)
    end

    def save!
      validate
      response = Apruve.post("subscriptions/#{self.subscription_id}/adjustments", self.to_json)
      self.id = response.body['id']
      self.status = response.body['status']
      self.api_url = response.body['api_url']
      self.status
    end

    def delete!
      response = Apruve.delete("subscriptions/#{self.subscription_id}/adjustments/#{id}")
      logger.debug response.body
      nil
    end
  end
end