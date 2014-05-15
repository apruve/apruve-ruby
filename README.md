# Apruve

Apruve helps B2B merchants by making it easier for customers to buy what they need for
their jobs. The apruve gem makes it easier for merchants on Ruby-based platforms to
integrate Apruve!

## Installation

Add this line to your application's Gemfile:

    gem 'apruve'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apruve

## Usage (merchant integration)

The following snippets are based on our apruve-ruby-demo project, which is a functional demo of how a merchant can
integrate Apruve.

[https://github.com/apruve/apruve-ruby-demo](https://github.com/apruve/apruve-ruby-demo)

### Create an account on Apruve.

Have a look though our [Getting Started documentation](https://www.apruve.com/doc/developers/) and be sure to use
test.apruve.com for test accounts.

### Initialize the library

For [test.apruve.com](test.apruve.com)
    Apruve.configure('YOUR_APRUVE_API_KEY', 'test')

For [www.apruve.com](www.apruve.com)
    Apruve.configure('YOUR_APRUVE_API_KEY', 'prod')

### Create a PaymentRequest

    @payment_request = Apruve::PaymentRequest.new(
          merchant_id: your_merchant_id,
          currency: 'USD',
          amount_cents: 6000,
          shipping_cents: 500
      )

    @payment_request.line_items << Apruve::LineItem.new(
          title: 'Letter Paper',
          description: '20 lb ream (500 Sheets). Paper dimensions are 8.5 x 11.00 inches.',
          sku: 'LTR-20R',
          price_ea_cents: 1200,
          quantity: 3,
          amount_cents: 3600,
          view_product_url: 'https://www.example.com/letter-paper'
      )

### On your web page...

(example in ERB...)

At the top of the file, import the apruve.js script.

    <%= Apruve.js %>

Write a little Javascript to configure apruve.js

1. set the secure hash
2. set the payment request
3. register a callback to capture apruve.paymentRequestId


    apruve.secureHash = '<%= @payment_request.secure_hash %>';
    apruve.paymentRequest = <%= @payment_request.to_json %>;
    apruve.registerApruveCallback(apruve.APRUVE_COMPLETE_EVENT, function () {
        $('#paymentRequestId').val(apruve.paymentRequestId)
        $('#finishOrder').submit();
    });

Decide where to put the Apruve button

    <%= Apruve.button %>

### Back on your server...

Use the paymentRequestId to create a Payment

    apruve_payment = Apruve::Payment.new(payment_request_id: params[:payment_request_id], amount_cents: 12345)
    apruve_payment.save!

Save the status and the payment ID with the payment in your database

    # dependent on your system, but something like this...
    my_payment.apruve_payment_id = apruve_payment.id
    my_payment.apruve_payment_status = apruve_payment.status
    my_payment.save!

(optional) If you track orders separately from payments, save the paymentRequestId with your order in your database

    # dependent on your system, but something like this...
    my_order.apruve_payment_request = params[:payment_request_id]
    my_order.save

### Create a web hook listener

    # dependent on your system, but if you use Sinatra, it might look something like this...
    post '/webhook_notify' do
      # We got a webhook. You should look up the order in your database and complete or cancel it as appropriate.
      puts "GOT WEBHOOK DATA FOR PAYMENT #{@webhook_data}"
      my_payment.find_by_apruve_payment_id(@webhook_data[:payment_id])
      my_payment.apruve_payment_status = @webhook_data[:status]
      if my_payment.apruve_payment_status == 'captured'
        my_payment.complete_order
      elsif my_payment.apruve_payment_status == 'rejected'
        my_payment.cancel_order
      end
    end

## Contributing

1. Fork it ( http://github.com/apruve/apruve_gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
