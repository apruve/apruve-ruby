require 'spec_helper'

describe Apruve::InvoiceItem do
  let (:invoice_item) {Apruve::InvoiceItem.new}
  subject { invoice_item }

  it { should respond_to(:title) }
  it { should_not respond_to(:amount_cents) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:price_total_cents) }
  it { should respond_to(:quantity) }
  it { should respond_to(:description) }
  it { should respond_to(:variant_info) }
  it { should respond_to(:sku) }
  it { should respond_to(:vendor) }
  it { should respond_to(:view_product_url) }

end