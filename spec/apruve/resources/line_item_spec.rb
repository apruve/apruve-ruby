require 'spec_helper'

describe Apruve::LineItem do
  let (:line_item) { Apruve::LineItem.new }
  let (:title) { Faker::Lorem.sentence }
  let (:amount_cents) { 12340 }
  let (:price_ea_cents) { 1234 }
  let (:quantity) { 10 }
  let (:description) { Faker::Lorem.paragraph }
  let (:variant_info) { Faker::Lorem.sentence }
  let (:sku) { Faker::Lorem.word }
  let (:vendor) { Faker::Name.name }
  let (:view_product_url) { Faker::Internet.url }
  let (:plan_code) { Faker::Lorem.word }
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

  describe 'attributes' do
    before :each do
      line_item.title = title
    end

    its(:title) { should eq title }
  end

  describe '#values' do
    describe 'only title' do
      before :each do
        line_item.title = title
      end
      its(:value_string) { should eq title }
    end

    describe '#value_string' do
      let(:expected) do
        "#{title}#{amount_cents}#{price_ea_cents}#{quantity}#{description}#{variant_info}#{sku}"\
        "#{vendor}#{view_product_url}#{plan_code}"
      end
      before :each do
        line_item.title = title
        line_item.amount_cents = amount_cents
        line_item.price_ea_cents = price_ea_cents
        line_item.quantity = quantity
        line_item.description = description
        line_item.variant_info = variant_info
        line_item.sku = sku
        line_item.vendor = vendor
        line_item.view_product_url = view_product_url
        line_item.plan_code = plan_code
      end
      its(:value_string) { should eq expected }
    end

  end
end