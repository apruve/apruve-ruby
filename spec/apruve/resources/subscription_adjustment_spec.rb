require 'spec_helper'

describe Apruve::SubscriptionAdjustment do
  before :each do
    Apruve.configure('e5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:id) { '99ea2488fe0a5c7bb38aa7f9b088874a' }
  let (:subscription_id) { 'e5fbe71d68772d1f562ed6f598b995b3'}
  let (:title) { 'A test title' }
  let (:status) { 'approved' }
  let (:amount_cents) { 123456 }
  let (:price_ea_cents) { 12345 }
  let (:quantity) { 100 }
  let (:description) { 'description from merchant' }
  let (:variant_info) { 'variant 1000' }
  let (:sku) { 'PAPER123' }
  let (:vendor) { 'vendor9000' }
  let (:view_product_url) { Faker::Internet.url }
  let (:api_url) { Faker::Internet.url }
  let (:merchant_notes) { 'merchant notes' }
  let (:adjustment) do
    Apruve::SubscriptionAdjustment.new(
        id: id,
        subscription_id: subscription_id,
        title: title,
        amount_cents: amount_cents,
        price_ea_cents: price_ea_cents,
        quantity: quantity,
        description: description,
        variant_info: variant_info,
        sku: sku,
        vendor: vendor,
        view_product_url: view_product_url,
        merchant_notes: merchant_notes
    )
  end
  subject { adjustment }

  # from line_item
  it { should respond_to(:title) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:quantity) }
  it { should respond_to(:price_ea_cents) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:description) }
  it { should respond_to(:variant_info) }
  it { should respond_to(:sku) }
  it { should respond_to(:vendor) }
  it { should respond_to(:view_product_url) }

  describe '#find' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/subscriptions/#{subscription_id}/adjustments/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::SubscriptionAdjustment.find(subscription_id, id)
        stubs.verify_stubbed_calls
      end
    end
    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/subscriptions/#{subscription_id}/adjustments/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::SubscriptionAdjustment.find(subscription_id, id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#delete' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v3/subscriptions/#{subscription_id}/adjustments/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a delete' do
        Apruve::SubscriptionAdjustment.delete(subscription_id, id)
        stubs.verify_stubbed_calls
      end
    end
    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v3/subscriptions/#{subscription_id}/adjustments/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::SubscriptionAdjustment.delete(subscription_id, id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#delete!' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v3/subscriptions/#{adjustment.subscription_id}/adjustments/#{adjustment.id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a delete' do
        adjustment.delete!
        stubs.verify_stubbed_calls
      end
    end
    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.delete("/api/v3/subscriptions/#{adjustment.subscription_id}/adjustments/#{adjustment.id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect {adjustment.delete!}.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#find_all' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/subscriptions/#{subscription_id}/adjustments") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::SubscriptionAdjustment.find_all(subscription_id)
        stubs.verify_stubbed_calls
      end
    end
    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/subscriptions/#{subscription_id}/adjustments") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::SubscriptionAdjustment.find_all(subscription_id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#save!' do
    let (:response) do
      {
          subscription_id: subscription_id,
          title: title,
          amount_cents: amount_cents,
          price_ea_cents: price_ea_cents,
          quantity: quantity,
          description: description,
          variant_info: variant_info,
          sku: sku,
          vendor: vendor,
          view_product_url: view_product_url,
          merchant_notes: merchant_notes
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v3/subscriptions/#{subscription_id}/adjustments", adjustment.to_json) { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        adjustment.save!
        stubs.verify_stubbed_calls
      end
    end
    describe 'payment request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v3/subscriptions/#{subscription_id}/adjustments", adjustment.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { adjustment.save! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end



