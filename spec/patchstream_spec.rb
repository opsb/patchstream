require 'spec_helper'

describe Patchstream do
	let(:now){ Time.at(1403579955) }
	before{ Timecop.freeze(now) }

	context "when a record is created" do
		let(:output){ [] }

		before do
			Product.add_patch_stream(output)
			@product = Product.create name: "Bike", price: 20, id: "3b01d506-8e5b-4ae4-8860-4f2d54106ff1"
		end

		it "should generate a patch" do
			output.first.should == {
				:op => :add, 
				:path => "/products/3b01d506-8e5b-4ae4-8860-4f2d54106ff1", 
				:value =>  { 
					:id => @product.id,
					:name => "Bike", 
					:price => 20.0,
					:created_at => "2014-06-24T03:19:15.000Z",
					:updated_at => "2014-06-24T03:19:15.000Z" 
				}.as_json
			}
		end
	end
end