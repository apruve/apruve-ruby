require 'logger'
require 'uri'
require 'faraday'
require 'faraday_middleware'
require_relative 'response/apruve_exception_middleware'
require_relative 'response/apruve_parse_json'

module Apruve
  class Client
    DEFAULTS = {
        :scheme => 'http',
        :host => 'localhost',
        :port => 3000,
        :version => 'v3',
        :logging_level => 'WARN',
        :connection_timeout => 60,
        :read_timeout => 60,
        :logger => nil,
        :ssl_verify => true,
        :faraday_adapter => Faraday.default_adapter,
        :accept_type => 'application/json'
    }

    # attr_reader :conn
    attr_accessor :api_key, :config, :conn

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

      Faraday::Response.register_middleware :handle_apruve_errors => lambda { Faraday::Response::RaiseApruveError }
      Faraday::Response.register_middleware :apruve_json_parser => lambda { FaradayMiddleware::ApruveParseJson }

      options = {
          :request => {
              :open_timeout => config[:connection_timeout],
              :timeout => config[:read_timeout]
          },
          :ssl => {
              :verify => @config[:ssl_verify] # Only set this to false for testing
          }
      }
      @conn = Faraday.new(url, options) do |builder|
        # Order is kinda important here...
        builder.response :raise_error # raise exceptions on 40x, 50x responses
        builder.use Apruve::FaradayErrorHandler
        builder.request :json
        builder.response :logger, logger
        builder.response :handle_apruve_errors
        builder.response :apruve_json_parser
        builder.adapter config[:faraday_adapter]
      end
      conn.path_prefix = "/api/#{@config[:version]}"
      conn.headers['User-Agent'] = "apruve-ruby/#{Apruve::VERSION}"
      conn.headers['Content-Type'] = 'application/json'
      # conn.headers['Content-Type'] = "application/json;revision=#{@config[:version]}"
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
        conn.headers['Apruve-Api-Key'] = @api_key unless @api_key.nil?
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