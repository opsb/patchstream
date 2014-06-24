require "patchstream/version"

module Patchstream
	extend ActiveSupport::Concern

	included do
		around_create PatchStreamCallbacks.new
		around_update PatchStreamCallbacks.new
		around_destroy PatchStreamCallbacks.new
	end

	class PatchStreamCallbacks
		def around_create(record, &block)
			record.class.patch_streams.emit_create(record, &block)
		end

		def around_update(record, &block)
			record.class.patch_streams.emit_update(record, &block)
		end

		def around_destroy(record, &block)
			record.class.patch_streams.emit_destroy(record, &block)
		end
	end

	module ClassMethods
		def patch_streams
			@patch_streams ||= PatchStreams.new
		end

		class Stream < Struct.new(:stream, :policy)
			def policy_permits?(operation, record)
				return true unless policy
				policy.permits?(operation, record)
			end
		end

		class StreamPolicyWrapper < Struct.new(:callback)
			def policy_permits?(operation, record)
				callback.call(operation, record)
			end
		end

		class PatchStreams
			def add(stream, stream_policy=nil, &block)
				policy = stream_policy || block && StreamPolicyWrapper.new(&block)
				streams << Stream.new(stream, stream_policy)
			end

			def emit_create(record)
				patch = build_create_patch(record)
				yield
				streams.each do |stream|
					if stream.policy_permits?(:create, record)
						stream.stream << patch
					end
				end
			end

			def emit_update(record)
				patches = build_update_patches(record)
				yield
				streams.each do |stream|
					if stream.policy_permits?(:update, record)
						patches.each do |patch|
							stream.stream << patch
						end
					end
				end
			end		

			def emit_destroy(record)
				patch = build_destroy_patch(record)
				yield
				streams.each do |stream|
					if stream.policy_permits?(:destroy, record)
						stream.stream << patch
					end
				end
			end

			private			
			def build_create_patch(record)
				{
					:op => :add, 
					:path => "/#{record.class.name.tableize}/#{record.id}", 
					:value => record.changes.inject({}) do |additions, (key, (_, new_value))|
						additions[key] = new_value.as_json
						additions
					end
				}
			end

			def build_update_patches(record)
				record.changes.inject([]) do |changes, (key, (_, new_value))|
					changes << {
						:op => :replace,
						:path => "/#{record.class.name.tableize}/#{record.id}/#{key}",
						:value => new_value
					}
					changes
				end
			end	

			def build_destroy_patch(record)
				{
					:op => :remove, 
					:path => "/#{record.class.name.tableize}/#{record.id}"
				}
			end

			def streams
				@streams ||= []
			end
		end
	end
end
