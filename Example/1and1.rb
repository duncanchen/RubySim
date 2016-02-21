require '../lib/experiment'
require '../lib/distribution'
require 'rx_ruby'

experiment = RubySim::Experiment.new(name:"1and1")

experiment.setup(ticks:100)

def create_observer(tag)
	RxRuby::Observer.create(
		lambda {|x|
			puts 'Next: ' + tag + x.to_s
		},
		lambda {|err|
			puts 'Error: ' + err.to_s
		},
		lambda {
			puts 'Completed'
		})
end

publisher = experiment.get_publisher
source1 = experiment.exponential_source(10)
source2 = experiment.uniform_source(1,3)
publisher.subscribe(source1.cue_observer)
publisher.subscribe(source2.cue_observer)
experiment.associate([source1], 'path1', nil)
experiment.associate([source2], 'path2', nil)
publisher.connect

p "I finished first!!!!"

subject = RxRuby::Subject.new
subject.subscribe(create_observer(" pig "))
subject.subscribe(create_observer(" dog "))


1.upto(10) do |x|
	subject.on_next(x)
end

p "what is this...................."

