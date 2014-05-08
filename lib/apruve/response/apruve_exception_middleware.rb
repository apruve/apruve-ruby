require 'faraday'
require 'apruve/error'

# @api private
module Faraday

  class Response::RaiseApruveError < Response::Middleware

    HTTP_STATUS_CODES = {
        400 => Apruve::BadRequest,
        401 => Apruve::Unauthorized,
        403 => Apruve::Forbidden,
        404 => Apruve::NotFound,
        405 => Apruve::MethodNotAllowed,
        406 => Apruve::AccessDenied,
        409 => Apruve::Conflict,
        410 => Apruve::Gone,
        500 => Apruve::InternalServerError,
        501 => Apruve::NotImplemented,
        502 => Apruve::BadGateway,
        503 => Apruve::ServiceUnavailable,
        504 => Apruve::GatewayTimeout,
    }

    def on_complete(response)
      status_code = response[:status].to_i
      # if response.key? :body and response[:body] != nil and response[:body]['errors']
      #   category_code = response[:body]['errors'][0]['category_code']
      # else
      #   category_code = nil
      # end
      error_class = HTTP_STATUS_CODES[status_code]
      # error_class = CATEGORY_CODE_MAP[category_code] || HTTP_STATUS_CODES[status_code]
      raise error_class.new(response) if error_class
    end

  end

end