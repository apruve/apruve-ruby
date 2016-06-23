require 'spec_helper'

describe Apruve::OrderItem do
  let (:line_item) do
    Apruve::OrderItem.new(
        title: 'line 2',
        amount_cents: '40'
    )
  end
  subject { line_item }

  it { should respond_to(:title) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:quantity) }
  it { should respond_to(:description) }
  it { should respond_to(:variant_info) }
  it { should respond_to(:sku) }
  it { should respond_to(:vendor) }
  it { should respond_to(:view_product_url) }
  it { should respond_to(:plan_code) }


  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { line_item.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        line_item.title = nil
      end
      it 'should raise on no title' do
        expect { line_item.validate }.to raise_error(Apruve::ValidationError, '["title must be set on line items"]')
      end
    end
  end
end