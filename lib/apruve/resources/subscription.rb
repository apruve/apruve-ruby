module Apruve
  class Subscription < Apruve::LineItem
    attr_accessor :id, :start_at, :next_charge_at, :last_charge_at, :end_at, :canceled_at

    def self.find(id)
      response = Apruve.get("subscriptions/#{id}")
      logger.debug response.body
      Subscription.new(response.body)
    end

    def update!
      validate
      response = Apruve.put("subscriptions/#{self.id}", self.to_json)
      logger.debug response.body
      nil
    end

    def cancel!
      response = Apruve.post("subscriptions/#{self.id}/cancel")
      logger.debug response.body
      self.canceled_at = Time.parse(response.body['canceled_at']) unless response.body['canceled_at'].nil?
      self.end_at = Time.parse(response.body['end_at']) unless response.body['end_at'].nil?
      nil
    end
  end
end