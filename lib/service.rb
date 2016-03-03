require 'rx_ruby'
require '../lib/sampling'
require '../lib/logging'

module RubySim

	class Service
		include Sampling
		include RubySim::Logging

		attr_reader :mode
		attr_reader :idle
		attr_accessor :id
		attr_reader :wip_item
		attr_reader :leaving


		def initialize(dist: nil, theta: nil, mu: nil, sigma: nil, min: nil, max: nil, id: nil)
			setup_pdf(dist:dist, theta:theta, mu:mu, sigma:sigma, min:min, max:max)
			@check_point = 0
			@leaving = RxRuby::Subject.new
			@mode = :idle
			@idle = RxRuby::Subject.new
			@id ||= rand(36**12).to_s(36)
			@current_tick = 0
			@wip_item = nil
		end

		def on_cue
			RxRuby::Observer.create(
				lambda {|t|
					self.trigger(t)
				},
				lambda {|err|
					puts 'Error: ' + err.to_s
				},
				lambda {
					puts 'Completed'
				})
		end

		def on_incoming
			RxRuby::Observer.create(
				lambda {|c|
					logger.info "coming #{c} into #{id}" if c
					if c
						@mode = :wip
						@wip_item = c
						@check_point = @current_tick + self.next
					end
				},
				lambda {|err|
					puts 'Error: ' + err.to_s
				},
				lambda {
					puts 'Completed'
				})
		end

		def trigger(tick)
			@current_tick = tick
			case @mode
				when :idle
							#let's see if we can dequeue one from storage
							@idle.on_next(@id)
				when :wip
							if tick > @check_point
								# we are ready to release it
								p "#{id} let go #{@wip_item} at #{@current_tick}"
								releasing = @wip_item
								@wip_item = nil
								@leaving.on_next(releasing)
								@mode = :idle
							end
			end
		end

	end

end

