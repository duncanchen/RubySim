require 'rspec'
require '../lib/distribution'

describe Distribution do

	it 'has time' do
			dist = Distribution.new
			expect(dist.time_unit) == 0
  end

end