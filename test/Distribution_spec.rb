require 'rspec'
require '../lib/distribution'

describe Distribution do

	it 'unknown some distribution' do
			expect{Distribution.new}.to raise_error("unknown_distribution")
	end

	it 'can be normal distribution' do
			dist = Distribution.new(dist: :normal)
			expect(dist.time_unit).to  eq 0
  end

	it 'invalid theta for exponential distribution' do
			expect {Distribution.new(dist: :exponential, theta: -1)}.to raise_error()
	end

	it 'can be exponential distribution' do
		dist = Distribution.new(dist: :exponential, theta: 3.0)
		expect(dist.time_unit).to  eq 0
	end


	it 'can get next values' do
		dist = Distribution.new(dist: :exponential, theta: 10)
		total = 1.upto(10000000).inject(0) { |sum, x |  sum = sum + dist.next }
		p total/10000000
	end




end