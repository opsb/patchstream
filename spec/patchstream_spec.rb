require 'spec_helper'

describe Patchstream do
	let(:now){ Time.at(1403579955) }
	let(:output){ [] }

	before do 
		Timecop.freeze(now)
		Product.patch_streams.add(output)
	end

	context "when a record is created" do
		before do
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

	context "when a record is updated" do
		before do
			@product = Product.create name: "Bike", price: 20, id: "3b01d506-8e5b-4ae4-8860-4f2d54106ff1"
			output.clear
			@product.update_attributes name: "Bicycle", price: 30
		end

		it "should generate a patch" do
			output.should == [
				{:op=>:replace, :path=>"/products/3b01d506-8e5b-4ae4-8860-4f2d54106ff1/name", :value=>"Bicycle"},
				{:op=>:replace, :path=>"/products/3b01d506-8e5b-4ae4-8860-4f2d54106ff1/price", :value=>30.0}
			] 
		end
	end	

	context "when a record is destroyed" do
		before do
			@product = Product.create name: "Bike", price: 20, id: "3b01d506-8e5b-4ae4-8860-4f2d54106ff1"
			output.clear
			@product.destroy
		end

		it "should generate a patch" do
			output.should == [
				{:op=>:remove, :path=>"/products/3b01d506-8e5b-4ae4-8860-4f2d54106ff1"},
			]
		end
	end
end