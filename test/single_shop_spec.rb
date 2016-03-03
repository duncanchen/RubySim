require 'rspec'
require '../lib/experiment'

context 'SingleService' do

	# In this setup, two sources generating incoming objects at different rates
	# and feeding into a cluster of two services. Again, each service has
	# unique service rate.
  specify 'one service' do
    experiment = RubySim::Experiment.new(name:"singleshop-exp")
    experiment.setup(ticks:500)
    source1 = experiment.exponential_source(10)
    source2 = experiment.uniform_source(1,3)
    service1 = experiment.exponential_service(5)
    service2 = experiment.uniform_service(2,4)
    service1.id, service2.id = 'shop1', 'shop2'
    source1.id, source2.id = 'source1', 'source2'
    experiment.associate([source1, source2], ' -x- ', [service1, service2])
		experiment.as_last([service1, service2])
    experiment.cue_publisher.connect
  end
end