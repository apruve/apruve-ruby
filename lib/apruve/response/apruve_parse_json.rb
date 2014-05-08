require 'faraday'
require 'faraday_middleware/response_middleware'

module FaradayMiddleware

  class ApruveParseJson < ParseJson
    define_parser do |body|
      ::JSON.parse body unless body.strip.empty? || body.include?('Not Found')
    end
  end
end