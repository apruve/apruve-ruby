require 'spec_helper'

describe Apruve::Payment do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:payment) do
    Apruve::Payment.new(
        payment_request_id: '9999',
        amount_cents: '12340',
    )
  end
  subject { payment }

  it { should respond_to(:id) }
  it { should respond_to(:payment_request_id) }
  it { should respond_to(:status) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:currency) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:payment_items) }
  it { should respond_to(:api_url) }
  it { should respond_to(:view_url) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  describe '#to_json' do
    let(:expected) do
      "{\"payment_request_id\":\"9999\",\"amount_cents\":\"12340\",\"payment_items\":[],\"currency\":\"USD\"}"
    end
    its(:to_json) { should eq expected }
  end

  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { payment.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        payment.amount_cents = nil
      end
      it 'should raise on no merchant_id' do
        expect { payment.validate }.to raise_error(Apruve::ValidationError, '["amount_cents must be set"]')
      end
    end
  end

  describe '#find' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:payment_request_id) { '8fdc91d337a28633deed058dd2d3fc90' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/payment_requests/#{payment_request_id}/payments/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Payment.find(payment_request_id, id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v3/payment_requests/#{payment_request_id}/payments/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Payment.find(payment_request_id, id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end