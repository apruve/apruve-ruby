module Apruve
  class ApruveObject
    require 'json'

    def initialize(args = {})
      args.each do |k, v|
        instance_variable_set("@#{k}".to_sym, v) unless v.nil?
      end
    end

    def validate
      # default implementation.
    end

    def to_hash
      validate
      hash = {}
      instance_variables.each do |var|
        if instance_variable_get(var).kind_of?(Array)
          array = []
          instance_variable_get(var).each { |aryvar| array.push(aryvar.to_hash) }
          hash[var.to_s.delete('@')] = array
        else
          hash[var.to_s.delete('@')] = instance_variable_get(var)
        end
      end
      hash.reject! { |k, v| v.nil? }
      hash.reject! { |k, v| k == 'api_key' }
      hash
    end

    def to_json(*a)
      to_hash.to_json
    end

    def self.logger
      Apruve.client.config[:logger]
    end

    def logger
      Apruve.client.config[:logger]
    end
  end
end