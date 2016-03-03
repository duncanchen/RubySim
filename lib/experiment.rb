require 'rx_ruby'
require 'logger'
require '../lib/cue'
require '../lib/source'
require '../lib/logging'
require '../lib/service'

module  RubySim

	module WallClock
		attr  :wall_clock
	end

	module Routing

		include Logging
		include WallClock

		def incoming(id)
			@incomings ||= Hash.new
			@incomings[id] ||= RxRuby::Subject.new
		end

		def obtain_wall_ticks(proc)
			@wall_ticks_proc = proc
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
			logger.debug "hello!*********** #{@wall_clock}"
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

	class Experiment

		include Logging
		include Routing

		attr_reader :cue_publisher
		attr_reader :wall_ticks

		def initialize(name:'')
			logger.formatter = proc do |severity, datetime, progname, msg|
				date_format = datetime.strftime("%H:%M:%S.%L")
				"#{date_format} [#{severity}] #{msg}\n"
			end
			logger.info "experiment '#{name}' started"
			# creat the statistician
			@stat = Statistician.new
			@wall_ticks = 0
		end

		def setup(ticks: 100)
			@ticks = ticks
			logger.info "ready for #{ticks} ticks experiment"
			@cue_publisher = get_publisher
		end

		def get_publisher
			source = RxRuby::Observable.generate(
				0,
				lambda {|x| x < @ticks }, # condition
				lambda do |x|
					logger.debug "tick: #{x+1}"
					@wall_clock = x + 1
				end,
				lambda do |x|
					x
				end
			)
			source.publish
		end

		def subscribe_cue(receiver)
			@cue_publisher.subscribe(receiver.on_cue)
			receiver
		end

		def exponential_source(theta)
			source = Source.new(dist: :exponential, theta:theta)
			subscribe_cue(source)
		end

		def uniform_source(min, max)
			subscribe_cue	Source.new(dist: :uniform, min:min, max:max)
		end

		def exponential_service(theta)
			subscribe_cue Service.new(dist: :exponential, theta:theta)
		end

		def uniform_service(min, max)
			subscribe_cue Service.new(dist: :uniform, min:min, max:max)
		end

		# define the service as the last one of the service chain, so
		# we can collect it for statics
		def as_last(services)
				if services.kind_of?(Array)
						services.each { |s| s.leaving.subscribe(@stat.on_leaving) }
				else
						services.leaving.subscribe(@stat.on_leaving)
				end
		end


	end

	class Statistician
		include Logging

		def initialize
		end

		def on_leaving
			RxRuby::Observer.create(
				lambda {|cue|
					done(cue)
				},
				lambda {|err|
					puts 'Error: ' + err.to_s
				},
				lambda {
					puts 'Completed'
				})
		end

		def done(cue)
			logger.info "#{cue} done!"
		end

	end


end

