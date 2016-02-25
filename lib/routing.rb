require 'rx_ruby'
require '../lib/logging'

module RubySim

	# control the flows of the objects after arrival and served
	module Routing

			include Logging

			def incoming(id)
				@incomings ||= Hash.new
				@incomings[id] ||= RxRuby::Subject.new
			end


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

			def on_leaving(key)
				RxRuby::Observer.create(
					lambda {|cue|
						enqueue(key, cue)
						#mark a starting point
						mark_start(key, cue)
					},
					lambda {|err|
						puts 'Error: ' + err.to_s
					},
					lambda {
						puts "outbox #{key} completed"
					})
			end

			def on_idle(key)
				RxRuby::Observer.create(
					lambda {|id|
						cue = dequeue(key)
						if cue
							incoming(id).on_next(cue)
						end
					},
					lambda {|err|
						puts 'Error: ' + err.to_s
					},
					lambda {
						puts "outbox #{key} completed"
					})
			end

			def mark_start(name, cue)

			end

			def mark_end(cue)

			end


			def collect_stat(cue)


			end

			# create a pathway which links the outboxes from each member of
			# sources into ONE of the services. We need to think
			# how will it work
			def associate(sources, key, services)
				sources.each { |s| s.leaving.subscribe(on_leaving(key))}
				services.each { |s| s.idle.subscribe(on_idle(key))} if services
				services.each { |s| incoming(s.id).subscribe(s.on_incoming) } if services
			end

	end
end

