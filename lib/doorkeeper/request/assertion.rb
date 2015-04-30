require 'doorkeeper/oauth/assertion_access_token_request'

module Doorkeeper
	module Request

		class Assertion
			def self.build(server)
				new(server)
			end

			attr_reader :server

			def initialize(server)
				@server = server
			end

			def request
				@request ||= OAuth::AssertionAccessTokenRequest.new(server, Doorkeeper.configuration)
			end

			def authorize
				request.authorize
			end

		end

	end
end