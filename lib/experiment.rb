require 'rx_ruby'
require 'logger'
require '../lib/cue'
require '../lib/source'
require '../lib/logging'
require '../lib/routing'

module  RubySim
	class Experiment

		include Logging
		include Routing

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

		def exponential_source(theta)
			Source.new(dist: :exponential, theta:theta)
		end

		def uniform_source(min, max)
			Source.new(dist: :uniform, min:min, max:max)
		end

	end

end

