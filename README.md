# Patchstream

Emits json patches when active records are updated


## Installation

Add this line to your application's Gemfile:

    gem 'patchstream'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install patchstream

## Usage

    class Product < ActiveRecord::Base
        include Patchstream
    end

    stream = [] # anything that responds to <<
    Product.patch_streams.add(stream)

    product = Product.create name: "Bike", price: 20
    stream == [
    	{op: "add", path: "/products/1", value: { 
    		id: 1, 
    		name: "Bike", 
    		price: 20, 
    		created_at: "2014-06-24T03:19:15.000Z",
    		updated_at: "2014-06-24T03:19:15.000Z"
    	}}
    ]
    stream.clear

    product.update_attributes name: "Bicycle", price: 30
    stream == [
    	{op: "replace", path: "/products/1/name", value: "Bike"},
    	{op: "replace", path: "/products/1/price", value: 20}
    ]
    stream.clear

    product.destroy
	stream == [
		{op: "remove", path: "/products/1/name"}
	]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
