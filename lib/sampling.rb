
module Sampling

	def setup_pdf(dist: nil, theta: -1, mu: nil, sigma: nil, min: nil, max: nil)
		@dist = dist
		@theta, @mu, @sigma, @min, @max = theta, mu, sigma, min, max
		case @dist
			when :exponential
				if @theta < 0
					raise "theta must be positive number for exponential distribution."
				end
			when :normal
			when :uniform
			else
				raise "unknown_distribution"
		end
	end

	def next
		case @dist
			when :exponential
						-Math.log(1 - rand) * @theta;
			when :uniform
						@min + (@max - @min) * rand
		end
	end

end