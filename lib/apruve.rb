# $:.unshift File.join(File.dirname(__FILE__), 'apruve', 'resources')
# $:.unshift File.join(File.dirname(__FILE__), 'apruve', 'response')

require 'thread'
require_relative 'apruve/client'
require_relative 'apruve/version'
require_relative 'apruve/error'
require_relative 'apruve/faraday_error_handler'
require_relative 'apruve/utils'

module Apruve
  Thread.current[:client] = nil
  Thread.current[:config] = {
    scheme: 'http',
    host: 'localhost',
    port: 3000,
    version: 'v4'
  }

  class << self
    PROD = 'prod'.freeze
    TEST = 'test'.freeze
    LOCAL = 'local'.freeze

    def configure(api_key=nil, environment=LOCAL, options={})
      self.config = config.merge(configure_environment(environment)).merge(options)
      self.client = Apruve::Client.new(api_key, config)
    end

    def config
      Thread.current[:config]
    end

    def config=(c)
      Thread.current[:config] = c
    end

    def client
      Thread.current[:client]
    end

    def client=(c)
      Thread.current[:client] = c
    end

    def js(display=nil)
      display_param = display.nil? ? '' : "?display=#{display}"
      "<script type=\"text/javascript\" src=\"#{js_url}#{display_param}\"></script>"
    end

    def button
      '<div id="apruveDiv"></div>'
    end

    def default_currency
      'USD'
    end

    def get(*args, &block)
      self.client.get *args
    rescue URI::InvalidURIError
      handle_invalid_url(args[0])
    end

    def post(*args, &block)
      self.client.post *args
    rescue URI::InvalidURIError
      handle_invalid_url(args[0])
    end

    def put(*args, &block)
      self.client.put *args
    rescue URI::InvalidURIError
      handle_invalid_url(args[0])
    end

    def patch(*args, &block)
      self.client.patch *args
    rescue URI::InvalidURIError
      handle_invalid_url(args[0])
    end

    def unstore(*args, &block)
      self.client.delete *args
    rescue URI::InvalidURIError
      handle_invalid_url(args[0])
    end

    alias_method :delete, :unstore

    # run configure on import so we have a default configuration
    # that will run without an api-key

    private

    def handle_invalid_url(url)
      client.config[:logger].warn 'Invalid URL'
      raise Apruve::NotFound.new(body: {}, status: 404, headers: {}, url: url)
    end

    def configure_environment(env)
      if env == PROD
        { scheme: 'https', host: 'app.apruve.com', port: 443 }
      elsif env == TEST
        { scheme: 'https', host: 'test.apruve.com', port: 443 }
      elsif env == LOCAL
        { scheme: 'http', host: 'localhost', port: 3000 }
      else
        raise 'unknown environment'
      end
    end

    def js_url
      port_param = [443, 80].include?(config[:port]) ? '' : ":#{config[:port]}"
      "#{config[:scheme]}://#{config[:host]}#{port_param}/js/v4/apruve.js"
    end
  end

  configure
end

# require all the resources! this is needed at the end because
# the module needs to be defined first, as it contains the registry
require_relative 'apruve/resources'
