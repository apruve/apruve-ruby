$:.unshift File.join(File.dirname(__FILE__), 'apruve', 'resources')
$:.unshift File.join(File.dirname(__FILE__), 'apruve', 'response')

require 'apruve/client'
require 'apruve/version'
require 'apruve/error'
require 'apruve/faraday_error_handler'
require 'apruve/utils'

module Apruve

  @client = nil
  @config = {
      :scheme => 'http',
      :host => 'localhost',
      :port => 3000,
      :version => 'v3',
  }

  class << self

    attr_accessor :client
    attr_accessor :config

    PROD = 'prod'
    TEST = 'test'
    LOCAL = 'local'

    def configure(api_key=nil, environment=LOCAL, options={})
      configure_environment environment
      @config = @config.merge(options)
      @client = Apruve::Client.new(api_key, @config)
    end

    def js(display=nil)
      display_param = display.nil? ? '' : "?display=#{display}"
      "<script type=\"text/javascript\" src=\"#{js_url}#{display_param}\"></script>"
    end

    def button
      '<div id="apruveDiv"></div>'
    end

    def get(*args, &block)
      self.client.get *args
    end

    def post(*args, &block)
      self.client.post *args
    end

    def put(*args, &block)
      self.client.put *args
    end

    def unstore(*args, &block)
      self.client.unstore *args
    end

    alias_method :delete, :unstore

    # run configure on import so we have a default configuration
    # that will run without an api-key

    private

    def configure_environment(env)
      if env == PROD
        @config[:scheme] = 'https'
        @config[:host] = 'www.apruve.com'
        @config[:port] = 443
      elsif env == TEST
        @config[:scheme] = 'https'
        @config[:host] = 'test.apruve.com'
        @config[:port] = 443
      elsif env == LOCAL
        @config[:scheme] = 'http'
        @config[:host] = 'localhost'
        @config[:port] = 3000
      else
        raise 'unknown environment'
      end
    end

    def js_url
      port_param = [443, 80].include?(@config[:port]) ? '' : ":#{@config[:port]}"
      "#{@config[:scheme]}://#{@config[:host]}#{port_param}/js/apruve.js"
    end
  end

  configure
end


# require all the resources! this is needed at the end because
# the module needs to be defined first, as it contains the registry
require 'apruve/resources'