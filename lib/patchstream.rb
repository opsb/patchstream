require "patchstream/version"

module Patchstream
	extend ActiveSupport::Concern

	included do
		before_create :stream_create_patch
	end

	def stream_create_patch
		patch = build_add_patch
		self.class.streams.each{ |s| s << patch }
	end

	def build_add_patch
		{
			:op => :add, 
			:path => "/#{self.class.name.tableize}/#{id}", 
			:value => changes.inject({}) do |additions, (key, (_, new_value))|
				additions[key] = new_value.as_json
				additions
			end
		}
	end

	module ClassMethods
		attr_reader :streams

		def add_patch_stream(stream)
			@streams ||= []
			@streams << stream
		end
	end
end
