module Apruve
  class WebhookEndpoint < Apruve::ApruveObject
    attr_accessor :id, :version, :url, :merchant_id

    def self.find(merchant_id, id)
      response = Apruve.get("merchants/#{merchant_id}/webhook_endpoints/#{id}")
      logger.debug response.body
      WebhookEndpoint.new(response.body)
    end

    def self.where(merchant_id)
      response = Apruve.get("merchants/#{merchant_id}/webhook_endpoints")
      logger.debug response.body
      ret = []
      response.body.each do |i|
        ret << WebhookEndpoint.new(i)
      end
      ret
    end

    def destroy!
      response = Apruve.delete("merchants/#{merchant_id}/webhook_endpoints/#{id}")
      logger.debug response.body
      response.status
    end
    
    def create!
      response = Apruve.post("merchants/#{merchant_id}/webhook_endpoints", {webhook_endpoint: self}.to_json )
      logger.debug response.body
      initialize response.body
    end
  end
end