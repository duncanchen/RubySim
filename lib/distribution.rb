require '../lib/sampling'

class Distribution
	include Sampling

	attr_reader :time_unit

	def initialize(dist: nil, theta: nil, mu: nil, sigma: nil, min: nil, max: nil)
		setup_pdf(dist:dist, theta:theta, mu:mu, sigma:sigma, min:min, max:max)
		@time_unit = 0
	end

end