require 'rspec'
require '../lib/experiment'

context 'My context' do

  specify 'one service' do
    experiment = RubySim::Experiment.new(name:"singleshop")
    experiment.setup(ticks:200)
    source1 = experiment.exponential_source(10)
    source2 = experiment.uniform_source(1,3)
    service1 = experiment.exponential_service(5)
    service2 = experiment.uniform_service(2,4)
    experiment.associate([source1, source2], ' -x- ', [service1, service2])
    experiment.cue_publisher.connect
  end
end