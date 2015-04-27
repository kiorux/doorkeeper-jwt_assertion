module Doorkeeper
	module Request

		class Assertion
			def self.build(server)
				assertion = server.parameters[:assertion]
				begin
					jwt = JWT.decode(assertion, Doorkeeper.configuration.jwt_key)
				rescue JWT::ExpiredSignature => e
					raise Errors::ExpiredSignature
				end
				server.jwt = jwt.is_a?(Array) ? jwt.first : jwt

				new(server.credentials, server.current_resource_owner, server)
			end

			attr_accessor :credentials, :resource_owner, :server

			def initialize(credentials, resource_owner, server)
				@credentials = credentials
				@resource_owner = resource_owner
				@server = server
			end

			def request
				@request ||= OAuth::PasswordAccessTokenRequest.new(
					Doorkeeper.configuration,
					credentials,
					resource_owner,
					server.parameters)
			end

			def authorize
				request.authorize
			end
		end

	end
end