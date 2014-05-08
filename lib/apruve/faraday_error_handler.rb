module Apruve
  # @api private
  class FaradayErrorHandler < Faraday::Middleware
    def call(env)
      begin
        @app.call(env)
      rescue Faraday::ConnectionFailed
        raise Apruve::ServiceUnreachable.new
        rescue Faraday::ParsingError
          raise Apruve::ResponseUnreadable.new
        rescue Faraday::ClientError
          raise Apruve::UnknownError.new
      end
    end
  end
end