module Apruve
  class Merchant < Apruve::ApruveObject
    attr_accessor :id, :name, :email, :web_url, :phone

    def self.find(id)
      response = Apruve.get("merchants/#{id}")
      logger.debug response.body
      Merchant.new(response.body)
    end
  end
end