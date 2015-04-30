module Doorkeeper
	module OAuth

		class DescribableErrorResponse < ErrorResponse
			attr_accessor :description
		end
	end
end