require 'logger'
require 'uri'
require 'faraday'
require 'faraday_middleware'
# require 'apruve_exception_middleware'

module Apruve
  class Client
    DEFAULTS = {
        :scheme => 'http',
        :host => 'localhost',
        :port => 3000,
        :version => '3',
        :logging_level => 'WARN',
        :connection_timeout => 60,
        :read_timeout => 60,
        :logger => nil,
        :ssl_verify => true,
        :faraday_adapter => Faraday.default_adapter,
        :accept_type => 'application/vnd.api+json'
    }

    attr_reader :conn
    attr_accessor :api_key, :config

    def initialize(api_key, options={})
      @api_key = api_key.nil? ? api_key : api_key.strip
      @config = DEFAULTS.merge options
      build_conn
    end


    def build_conn
      if config[:logger]
        logger = config[:logger]
      else
        logger = Logger.new(STDOUT)
        logger.level = Logger.const_get(config[:logging_level].to_s)
      end

      # Faraday::Response.register_middleware :handle_balanced_errors => lambda { Faraday::Response::RaiseApruveError }

      options = {
          :request => {
              :open_timeout => config[:connection_timeout],
              :timeout => config[:read_timeout]
          },
          :ssl => {
              :verify => @config[:ssl_verify] # Only set this to false for testing
          }
      }
      @conn = Faraday.new(url, options) do |cxn|
        cxn.request :json

        cxn.response :logger, logger
        # cxn.response :handle_balanced_errors
        cxn.response :json
        # cxn.response :raise_error # raise exceptions on 40x, 50x responses
        cxn.adapter config[:faraday_adapter]
      end
      conn.path_prefix = '/'
      conn.headers['User-Agent'] = "apruve-ruby/#{Apruve::VERSION}"
      conn.headers['Content-Type'] = "application/json;revision=#{@config[:version]}"
      conn.headers['Accept'] = "#{@config[:accept_type]};revision=#{@config[:version]}"
    end

    def url
      builder = (config[:scheme] == 'http') ? URI::HTTP : URI::HTTPS

      builder.build({:host => config[:host],
                     :port => config[:port],
                     :scheme => config[:scheme]})
    end

    def method_missing(method, *args, &block)
      if is_http_method? method
        conn.basic_auth(api_key, '') unless api_key.nil?
        conn.send method, *args
      else
        super method, *args, &block
      end
    end

    private

    def is_http_method? method
      [:get, :post, :put, :delete].include? method
    end

    def respond_to?(method, include_private = false)
      if is_http_method? method
        true
      else
        super method, include_private
      end
    end
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