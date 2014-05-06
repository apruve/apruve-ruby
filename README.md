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

## Usage

### Create a store on Apruve. Use test.apruve.com for test accounts.

### Create a PaymentRequest
    @pr = Apruve::PaymentRequest.new
    @pr.merchant_id =

### On your web page, declare apruve.js


3. Load the PaymentRequest and it's hash into apruve.js
4. Decide where to put the Apruve button
5. Register a call-back function to get the transaction ID back to your server
6. Tell Apruve to create a payment against the transaction ID
7. Process the webhook from Apruve when payment is received

## Contributing

1. Fork it ( http://github.com/apruve/apruve_gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
