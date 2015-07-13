require 'spec_helper'

describe Apruve::Subscription do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
  let (:title) { 'A title' }
  let (:amount_cents) { 12340 }
  let (:price_ea_cents) { 1234 }
  let (:quantity) { 10 }
  let (:notes) { 'notes from merchant' }
  let (:payment_request_id) { '9999' }
  let (:api_url) { Faker::Internet.url }
  let (:subscription) do
    Apruve::Subscription.new(
        id: id,
        title: title,
        payment_request_id: payment_request_id,
        amount_cents: amount_cents,
        price_ea_cents: price_ea_cents,
        quantity: quantity
    )
  end
  subject { subscription }

  # from line_item
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

  describe '#find' do
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/subscriptions/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Subscription.find(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/subscriptions/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Subscription.find(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update!' do
    let (:response) do
      {
          id: id,
          api_url: api_url
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.put(
              "/api/v4/subscriptions/#{id}",
              subscription.to_json,
          ) { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        expect(subscription.update!).to be_nil
        stubs.verify_stubbed_calls
      end
    end

    describe 'subscription not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.put(
              "/api/v4/subscriptions/#{id}",
              subscription.to_json,
          ) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { subscription.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#cancel!' do
    let (:canceled_at) { Time.now }
    let (:end_at) { Time.now }
    let (:response) do
      {
          id: id,
          api_url: api_url,
          canceled_at: canceled_at,
          end_at: end_at
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/subscriptions/#{id}/cancel") { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        subscription.cancel!
        expect(subscription.canceled_at.to_i).to eq canceled_at.to_i
        expect(subscription.end_at.to_i).to eq end_at.to_i
        stubs.verify_stubbed_calls
      end
    end

    describe 'subscription not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/subscriptions/#{id}/cancel") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { subscription.cancel! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end