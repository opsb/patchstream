require "patchstream/version"

module Patchstream
	extend ActiveSupport::Concern

	included do
		around_create PatchStreamCallbacks.new
		around_update PatchStreamCallbacks.new
	end

	class PatchStreamCallbacks
		def around_create(record, &block)
			record.class.patch_streams.emit_create(record, &block)
		end

		def around_update(record, &block)
			record.class.patch_streams.emit_update(record, &block)
		end
	end

	module ClassMethods
		def patch_streams
			@patch_streams ||= PatchStreams.new
		end

		class PatchStreams
			def add(stream)
				streams << stream
			end

			def emit_create(record, &block)
				emit(build_create_patch(record), &block)
			end

			def emit_update(record, &block)
				emit_all(build_update_patches(record), &block)
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

			def streams
				@streams ||= []
			end

			def emit(patch)
				yield if block_given?
				@streams.each{ |s| s << patch}
			end

			def emit_all(patches)
				patches.each{ |patch| emit(patch) }
			end
		end
	end
end
