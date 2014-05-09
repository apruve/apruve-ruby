require 'spec_helper'

describe Apruve::PaymentItem do
  let (:payment_item) {Apruve::PaymentItem.new}
  subject { payment_item }

  it { should respond_to(:title) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:quantity) }
  it { should respond_to(:description) }
  it { should respond_to(:variant_info) }
  it { should respond_to(:sku) }
  it { should respond_to(:vendor) }
  it { should respond_to(:view_product_url) }

end