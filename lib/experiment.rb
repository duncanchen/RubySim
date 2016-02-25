require 'rx_ruby'
require 'logger'
require '../lib/cue'
require '../lib/source'
require '../lib/logging'
require '../lib/routing'
require '../lib/service'

module  RubySim
	class Experiment

		include Logging
		include Routing

		attr_reader :cue_publisher

		def initialize(name:'')
			logger.formatter = proc do |severity, datetime, progname, msg|
				date_format = datetime.strftime("%H:%M:%S.%L")
				"#{date_format} [#{severity}] #{msg}\n"
			end
			logger.info "experiment '#{name}' started"
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
					x + 1
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



	end

end

