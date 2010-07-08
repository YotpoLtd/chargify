# chargify

Ruby wrapper for the chargify.com SAAS and billing API

## Installation

    gem install chargify
    
## Example Usage

### Create, cancel, then reactivate subscription
    attributes   = { :product_handle => 'basic' ... }
    @client      = Chargify::Client.new(:api_key => 'InDhcXAAAAAg7juDD', :subdomain => 'xxx-test')
    subscription = @client.create_subscription(attributes)
    @client.cancel_subscription(subscription[:id], "Canceled due to bad customer service.") 
    @client.reactivate_subscription(subscription[:id]) #Made him an offer he couldn't refuse!

## Rails Usage

### config/initializers/chargify.rb
    Chargify::Config.setup do |config|
      config[:subdomain] = 'xxx-test'
      config[:api_key]   = 'InDhcXAAAAAg7juDD'
    end

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright (c) 2009 [Wynn Netherland](http://wynnnetherland.com). See LICENSE for details.
