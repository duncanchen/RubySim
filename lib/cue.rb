module RubySim

	class Cue
		attr_reader :tick
		attr_reader :id
		attr_accessor :origin
		def initialize(tick: 0, source: '')
			@tick = tick
			@id = self.next_cue_id
			@origin = source
		end

		def to_s
			"Cue(#{id} @ #{@tick})"
		end

		def next_cue_id
			rand(36**5).to_s(36)
		end

	end
end
