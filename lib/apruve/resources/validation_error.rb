module Apruve
  class ValidationError < StandardError
    attr_accessor :errors
    def initialize(errors)
      @errors = errors
    end

    def message
      @errors.to_s
    end
  end
end