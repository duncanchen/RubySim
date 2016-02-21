require '../lib/logging'

module RubySim

	# control the flows of the objects after arrival and served
	module Routing

			include Logging

			def ensure(name)
				@storage ||= Hash.new
				@storage[name] ||= Array.new
			end

			def enqueue(name, element)
				logger.info "enqueue #{element} into #{name}"
				self.ensure(name).unshift(element)
			end

			def dequeue(name)
				self.ensure(name).pop
			end

			def outbox_observer(key)
				RxRuby::Observer.create(
					lambda {|x|
						enqueue(key, x)
					},
					lambda {|err|
						puts 'Error: ' + err.to_s
					},
					lambda {
						puts "outbox #{key} completed"
					})
			end

			# create a pathway which links the outboxes from each member of
			# sources into ONE of the services. We need to think
			# how will it work
			def associate(sources, key, services)
				sources.each do |source|
					source.outbox.subscribe(outbox_observer(key))
				end
			end

	end
end

