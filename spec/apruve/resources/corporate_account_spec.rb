require 'spec_helper'

describe Apruve::CorporateAccount do
  before :each do
    Apruve.configure('7ec4e1ae7c96fceba0d599da541912b7', 'local')
  end

  let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
  let (:merchant_uuid) { '89ea2488fe0a5c7bb38aa7f9b088874b' }
  let (:customer_uuid) { '89ea2488fe0a5c7bb38aa7f9b088874c' }
  let (:type) { 'CorporateAccount' }
  let (:payment_term_strategy_name) { 'EOMNet15' }
  let (:name) { 'A name' }
  let (:email) { Faker::Internet.email }

  let (:corporate_account) do
    Apruve::CorporateAccount.new(
        id: id,
        merchant_uuid: merchant_uuid,
        customer_uuid: customer_uuid,
        type: type,
        payment_term_strategy_name: payment_term_strategy_name,
        name: name,
    )
  end
  subject { corporate_account }

  it { should respond_to(:id) }
  it { should respond_to(:merchant_uuid) }
  it { should respond_to(:customer_uuid) }
  it { should respond_to(:type) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:payment_term_strategy_name) }
  it { should respond_to(:disabled_at) }
  it { should respond_to(:name) }
  it { should respond_to(:creditor_term_id) }
  it { should respond_to(:payment_method_id) }
  it { should respond_to(:status) }
  it { should respond_to(:trusted_merchant) }
  it { should respond_to(:authorized_buyers) }

  describe '#find' do
    context 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_uuid}/corporate_accounts?email=#{email}") { [200, {}, '{}'] }
        end
      end
      it 'should get a corporate account' do
        Apruve::CorporateAccount.find(merchant_uuid, email)
        stubs.verify_stubbed_calls
      end
    end

    context 'when not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_uuid}/corporate_accounts?email=#{email}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise not found' do
        expect { Apruve::CorporateAccount.find(merchant_uuid, email) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#find_all' do
    describe 'successful response' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/merchants/#{merchant_uuid}/corporate_accounts") { [200, {} ,  '{}'] }
        end
      end
      it 'should get all corporate accounts for a merchant' do
        Apruve::CorporateAccount.find_all(merchant_uuid)
        stubs.verify_stubbed_calls
      end
    end
  end
end
