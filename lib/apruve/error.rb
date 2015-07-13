module Apruve

  # Custom error class for rescuing from all API response-related Apruve errors
  class Error < ::StandardError
    attr_reader :response

    # @param [Hash] response the decoded json response body
    def initialize(response=nil)
      @response = response
      unless response.nil?
        super error_message
        # super 'Error!'
      end
    end

    # @return [Hash]
    def body
      @body ||= begin
        return {} unless response[:body]
        Utils.indifferent_read_access(response[:body])
      end
    end

    def error_message
      # set_attrs
      errors = body.fetch('errors', nil)
      unless errors.nil?
        error = errors[0]
        extra = error[:detail] ? " -- #{error[:detail]}" : ""
        extra += error[:source] ? " -- #{error[:source][:parameter]}" : ""
        "#{self.class.name}(#{response[:status]}):: "\
        "#{response[:method].to_s.upcase} #{response[:url].to_s}: "\
        "#{error[:title]} #{extra}"
      end
    end
  end

  # General error class for non API response exceptions
  class StandardError < Error
    attr_reader :message
    alias :error_message :message

    # @param [String, nil] message a description of the exception
    def initialize(message = nil)
      @message = message
      super(message)
    end
  end

  # Raised when Apruve returns a 400 HTTP status code
  class BadRequest < Error;
  end

  # Raised when Apruve returns a 401 HTTP status code
  class Unauthorized < Error;
  end

  # Raised when Apruve returns a 403 HTTP status code
  class Forbidden < Error;
  end

  # Raised when Apruve returns a 404 HTTP status code
  class NotFound < Error;
  end

  # Raised when Apruve returns a 405 HTTP status code
  class MethodNotAllowed < Error;
  end

  # Raised when Apruve returns a 406 HTTP status code
  class AccessDenied < Error;
  end

  # Raised when Apruve returns a 409 HTTP status code
  class Conflict < Error;
  end

  # Raised when Apruve returns a 410 HTTP status code
  class Gone < Error;
  end

  # Raised when Apruve returns a 500 HTTP status code
  class InternalServerError < Error;
  end

  # Raised when Apruve returns a 501 HTTP status code
  class NotImplemented < Error;
  end

  # Raised when Apruve returns a 502 HTTP status code
  class BadGateway < Error;
  end

  # Raised when Apruve returns a 503 HTTP status code
  class ServiceUnavailable < Error;
  end

  # Raised when Apruve returns a 504 HTTP status code
  class GatewayTimeout < Error;
  end

  # Raised when cannot connect to Apruve
  class ServiceUnreachable < Error;
  end

  # Raised when we get a Faraday::ParseError
  class ResponseUnreadable < Error;
  end

  # Raised when we haven't a clue
  class UnknownError < Error;
  end


  # custom mapped exceptions
  # class ValidationError < Error; end
end