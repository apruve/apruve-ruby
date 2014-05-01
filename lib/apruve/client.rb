class ApruveClient
  APRUVE_URL = ENV['APRUVE_URL']
  APRUVE_USE_SSL = (ENV['APRUVE_USE_SSL'].downcase == 'true' or ENV['APRUVE_USE_SSL'] == '1')
  if (ENV['APRUVE_VERIFY_SSL'] and (ENV['APRUVE_VERIFY_SSL'] == 'false' or ENV['APRUVE_VERIFY_SSL'] == '1'))
    APRUVE_VERIFY_SSL_CERT = OpenSSL::SSL::VERIFY_NONE
  else
    APRUVE_VERIFY_SSL_CERT = OpenSSL::SSL::VERIFY_PEER
  end

  APRUVE_PAYMENTS_URL = APRUVE_URL + '/api/v3/payment_requests/%s/payments'
  APRUVE_FINALIZE_URL = APRUVE_URL + '/api/v3/payment_requests/%s/finalize'
  APRUVE_JS_URL = APRUVE_URL + '/js/apruve.js?display=compact'

  def create_payment(token)
    url = APRUVE_PAYMENTS_URL % token
    puts url
  end
end

#
#class ApruveObject
#  require 'json'
#
#  def initialize(args = {})
#    args.each do |k, v|
#      instance_variable_set("@#{k}", v) unless v.nil?
#    end
#  end
#
#  def to_hash
#    validate
#    hash = {}
#    instance_variables.each do |var|
#      if instance_variable_get(var).kind_of?(Array)
#        array = []
#        instance_variable_get(var).each { |aryvar| array.push(aryvar.to_hash) }
#        hash[var.to_s.delete("@")] = array
#      else
#        hash[var.to_s.delete("@")] = instance_variable_get(var)
#      end
#    end
#    hash.reject! { |k, v| v.nil? }
#    hash.reject! { |k, v| k == "api_key" }
#    hash
#  end
#
#  def to_json(*a)
#    to_hash.to_json
#  end
#end