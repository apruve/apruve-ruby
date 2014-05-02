require 'spec_helper'

describe 'PaymentRequest' do
  before :each do
    Apruve.configure 'an-api-key'
  end

  let (:payment_request) { Apruve::PaymentRequest.new }
  subject { payment_request }

  describe 'attributes' do
    let (:title) { Faker::Lorem.words }
    before :each do
      payment_request.title = title
    end

    it 'foo' do
      expect(payment_request.title).to eq title
    end

    # its(:title).should eq title
  end
end