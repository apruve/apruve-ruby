require 'spec_helper'

describe Apruve::Invoice do
  before :each do
    Apruve.configure('f5fbe71d68772d1f562ed6f598b995b3', 'local')
  end

  let (:amount_cents) { 12340 }
  let (:notes) { 'notes from merchant' }
  let (:order_id) { '9999' }
  let (:invoice) do
    Apruve::Invoice.new(
        order_id: order_id,
        amount_cents: amount_cents,
    )
  end
  subject { invoice }

  it { should respond_to(:id) }
  it { should respond_to(:order_id) }
  it { should respond_to(:status) }
  it { should respond_to(:amount_cents) }
  it { should respond_to(:currency) }
  it { should respond_to(:merchant_notes) }
  it { should respond_to(:merchant_invoice_id) }
  it { should respond_to(:shipping_cents) }
  it { should respond_to(:tax_cents) }
  it { should respond_to(:invoice_items) }
  it { should respond_to(:created_at) }
  it { should respond_to(:opened_at) }
  it { should respond_to(:due_at) }
  it { should respond_to(:final_state_at) }
  it { should respond_to(:links) }
  it { should respond_to(:issued_at) }
  it { should respond_to(:amount_due) }
  it { should respond_to(:bill_to_address) }

  describe '#to_json' do
    let(:expected) do
      '{"order_id":"9999","amount_cents":12340,"invoice_items":[],"currency":"USD"}'
    end
    its(:to_json) { should eq expected }

    context 'with addresses' do
      let(:address) do
        {
          address_1: '8995 Creola Ville',
          address_2: 'Apt. 945',
          city: 'Friesentown',
          state: 'MN',
          postal_code: '62685',
          country_code: 'US',
          phone_number: '6123456789',
          fax_number: '6123456789',
          contact_name: 'Zelda Pagac',
          name: 'Jacobson, Conn and Kreiger',
          notes: 'Est corrupti quis cumque.'
        }
      end
      before do
        [:bill_to_address, :fiscal_representative, :remittance_address, :ship_to_address, :sold_to_address].each do |addr|
          invoice.send("#{addr.to_s}=", address)
        end
      end
      it 'jsonifies the address' do
        parsed_invoice = JSON.parse(subject.to_json)
        [:bill_to_address, :fiscal_representative, :remittance_address, :ship_to_address, :sold_to_address].each do |addr|
          parsed_addr = parsed_invoice.fetch addr.to_s
          expect(parsed_addr['address_1']).to eq '8995 Creola Ville'
          expect(parsed_addr['address_2']).to eq 'Apt. 945'
          expect(parsed_addr['city']).to eq 'Friesentown'
          expect(parsed_addr['state']).to eq 'MN'
          expect(parsed_addr['postal_code']).to eq '62685'
          expect(parsed_addr['country_code']).to eq 'US'
          expect(parsed_addr['phone_number']).to eq '6123456789'
          expect(parsed_addr['fax_number']).to eq '6123456789'
          expect(parsed_addr['contact_name']).to eq 'Zelda Pagac'
          expect(parsed_addr['name']).to eq 'Jacobson, Conn and Kreiger'
          expect(parsed_addr['notes']).to eq 'Est corrupti quis cumque.'
        end
      end
    end
  end

  describe '#validate' do
    describe 'no errors' do
      it 'should not raise' do
        expect { invoice.validate }.not_to raise_error
      end
    end
    describe 'errors' do
      before :each do
        invoice.amount_cents = nil
      end
      it 'should raise on no merchant_id' do
        expect { invoice.validate }.to raise_error(Apruve::ValidationError, '["amount_cents must be set"]')
      end
    end
  end

  describe '#find' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{id}") { [200, {}, '{}'] }
        end
      end
      it 'should do a get' do
        Apruve::Invoice.find(id)
        stubs.verify_stubbed_calls
      end
    end

    describe 'not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.get("/api/v4/invoices/#{id}") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { Apruve::Invoice.find(id) }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#save' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'pending' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices",
              invoice.to_json,
          ) { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        invoice.save!
        expect(invoice.id).to eq id
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post(
              "/api/v4/invoices",
              invoice.to_json,
          ) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.save! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#issue' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'open' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    let (:invoice) { Apruve::Invoice.new({id: id, order_id: order_id, amount_cents: amount_cents})}
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/issue") { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        invoice.issue!
        expect(invoice.id).to eq id
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/issue") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.issue! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#update' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'pending' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    let (:invoice) { Apruve::Invoice.new({id: id, order_id: order_id, amount_cents: amount_cents})}
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/invoices/#{id}", invoice.to_json) { [200, {}, response.to_json] }
        end
      end
      it 'should do a patch' do
        invoice.update!
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.patch("/api/v4/invoices/#{id}", invoice.to_json) { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.update! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#close' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'pending' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    let (:invoice) { Apruve::Invoice.new({id: id, order_id: order_id, amount_cents: amount_cents})}
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/close") { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        invoice.close!
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/close") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.close! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#cancel' do
    let (:id) { '89ea2488fe0a5c7bb38aa7f9b088874a' }
    let (:status) { 'pending' }
    let (:api_url) { Faker::Internet.url }
    let (:view_url) { Faker::Internet.url }
    let (:response) do
      {
          id: id,
          status: status,
          api_url: api_url,
          view_url: view_url
      }
    end
    let (:invoice) { Apruve::Invoice.new({id: id, order_id: order_id, amount_cents: amount_cents})}
    describe 'success' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/cancel") { [200, {}, response.to_json] }
        end
      end
      it 'should do a post' do
        invoice.cancel!
        expect(invoice.status).to eq status
        stubs.verify_stubbed_calls
      end
    end

    describe 'invoice request not found' do
      let! (:stubs) do
        faraday_stubs do |stub|
          stub.post("/api/v4/invoices/#{id}/cancel") { [404, {}, 'Not Found'] }
        end
      end
      it 'should raise' do
        expect { invoice.cancel! }.to raise_error(Apruve::NotFound)
        stubs.verify_stubbed_calls
      end
    end
  end
end