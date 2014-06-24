class Product < ActiveRecord::Base
	include ActiveUUID::UUID
	include Patchstream
end
