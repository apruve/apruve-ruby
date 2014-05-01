require 'apruve/version'
require 'net/http'

module Apruve

  @client = nil
  @config = {
      :scheme => 'https',
      :host => 'www.apruve.com',
      :port => 443,
      :version => '1',
  }

  class << self

    attr_accessor :client
    attr_accessor :config

    def configure(api_key=nil, options={})
      @config = @config.merge(options)
      @client = Apruve::Client.new(api_key, @config)
    end
  end

  #
  #class PaymentRequest < Apruve::ApruveObject
  #  require 'digest'
  #  attr_accessor :merchant_id, :amount_cents, :currency, :line_items, :api_key, :recurring
  #
  #  def initialize(args = {})
  #    super args
  #    @line_items = [] if @line_items.nil?
  #  end
  #
  #  def token_input
  #    token_string = to_hash.map do |k, v|
  #      str = ""
  #      if v.kind_of?(Array)
  #        v.each do |item|
  #          str = str + item.map { |q, r| r }.join
  #        end
  #      else
  #        str = v
  #      end
  #      str
  #    end
  #    token_string.join
  #  end
  #
  #  def token
  #    if api_key.nil?
  #      raise "api_key has not been set."
  #    end
  #    Digest::SHA256.hexdigest(api_key+token_input)
  #  end
  #
  #  def validate
  #    if merchant_id.nil? || (amount_cents.nil? and not recurring) || currency.nil? || line_items.size < 1
  #      raise "PaymentRequest must specify merchant_id, amount_cents, currency, and at least one line item."
  #    end
  #    line_items.each { |line_item| line_item.validate }
  #  end
  #end
  #
  #class LineItem < Apruve::ApruveObject
  #  attr_accessor :title, :amount_cents, :quantity, :price_ea_cents, :description, :sku
  #
  #  def validate
  #    if title.nil?
  #      raise "Line items must specifiy title and amount_cents unless the payment_request is recurring."
  #    end
  #  end
  #
  #end
end