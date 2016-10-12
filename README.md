# Apruve

Apruve helps B2B merchants by helping manage complex business sales. The apruve gem makes it easier for merchants on
Ruby-based platforms to integrate Apruve!

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

Have a look though our [Getting Started documentation](https://docs.apruve.com/guides/getting-started-f09a17ef-053e-4eba-9141-6fe8ce3b774d) and be sure to use
test.apruve.com for test accounts.

### Initialize the library

For [test.apruve.com](test.apruve.com)
    Apruve.configure('YOUR_APRUVE_API_KEY', 'test')

For [app.apruve.com](app.apruve.com)
    Apruve.configure('YOUR_APRUVE_API_KEY', 'prod')

### Create an Order

    @order = Apruve::Order.new(
          merchant_id: your_merchant_id,
          currency: 'USD',
          amount_cents: 6000,
          shipping_cents: 500
      )

    @order.order_items << Apruve::OrderItem.new(
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

1. use setOrder to set the order JSON and secureHash string
1. register a callback to capture orderId

``` javascript
    apruve.setOrder(<%= @order.to_json %>, '<%= @order.secure_hash %>');
    apruve.registerApruveCallback(apruve.APRUVE_COMPLETE_EVENT, function (orderId) {
        $('#orderId').val(orderId)
        $('#finishOrder').submit();
    });
```

Decide where to put the Apruve button

    <%= Apruve.button %>

### Back on your server...

Use the orderId to issue an Invoice

    apruve_invoice = Apruve::Invoice.new(order_id: params[:order_id], amount_cents: params[:charge], issue_on_create: true)
    apruve_invoice.save!

Save the status and the invoice ID with the payment in your database

    # dependent on your system, but something like this...
    my_invoice.apruve_invoice_id = apruve_invoice.id
    my_invoice.apruve_invoice_status = apruve_payment.status
    my_invoice.save!

(optional) If you track orders separately from payments, save the orderId with your order in your database

    # dependent on your system, but something like this...
    my_order.apruve_order_id = params[:order_id]
    my_order.save

### Create a web hook listener

    # dependent on your system, but if you use Sinatra, it might look something like this...
    post '/webhook_notify' do
      # We got a webhook. You should look up the order in your database and complete or cancel it as appropriate.
      puts "GOT WEBHOOK DATA FOR INVOICE #{@webhook_data}"
      my_invoice.find_by(apruve_invoice_id: @webhook_data[:invoice_id])
      my_invoice.apruve_payment_status = @webhook_data[:status]
      if my_invoice.apruve_invoice_status == 'closed'
        my_invoice.complete_order
      elsif my_invoice.apruve_invoice_status == 'canceled'
        my_invoice.cancel_order
      end
    end

## Contributing

1. Fork it ( http://github.com/apruve/apruve_gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
