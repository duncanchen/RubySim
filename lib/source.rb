require 'rx_ruby'
require '../lib/sampling'
require '../lib/logging'

class Source
	include Sampling
	include RubySim::Logging

	attr_reader :check_point
	attr_reader :outbox

	def initialize(dist: nil, theta: nil, mu: nil, sigma: nil, min: nil, max: nil)
		setup_pdf(dist:dist, theta:theta, mu:mu, sigma:sigma, min:min, max:max)
		@check_point = 0
		@outbox = RxRuby::Subject.new
	end

	def cue_observer
		RxRuby::Observer.create(
			lambda {|cue|
				self.trigger(cue)
			},
			lambda {|err|
				puts 'Error: ' + err.to_s
			},
			lambda {
				puts 'Completed'
			})
	end

	def trigger(tick)
		@check_point = self.next if @check_point <= 0
		fired = (tick >= @check_point)
		if fired
			cur_check_point = @check_point
			next_check_point = @check_point + self.next
			logger.info "fired #{tick} > #{cur_check_point}; next is #{next_check_point}"
			@check_point = next_check_point
			@outbox.on_next(RubySim::Cue.new(tick))
		end
	end

end