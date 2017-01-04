require 'spec_helper'

describe Apruve::ShipmentItem do
  let (:shipment_item) {Apruve::ShipmentItem.new}
  subject { shipment_item }

  it { should respond_to(:title) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:price_total_cents) }
  it { should respond_to(:shipping_cents) }
  it { should respond_to(:tax_cents) }
  it { should respond_to(:quantity) }
  it { should respond_to(:description) }
  it { should respond_to(:variant_info) }
  it { should respond_to(:sku) }
  it { should respond_to(:vendor) }
  it { should respond_to(:currency) }
  it { should respond_to(:view_product_url) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:taxable) }
  it { should respond_to(:shipment_id) }
  it { should respond_to(:uuid) }

end