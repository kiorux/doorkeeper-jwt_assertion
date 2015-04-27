module Doorkeeper
	module JWTAssertion
		class Railtie < ::Rails::Railtie
			initializer "doorkeeper.jwt_assertion" do
				Doorkeeper::Helpers::Controller.send :include, Doorkeeper::JWTAssertion
			end
		end
	end
end