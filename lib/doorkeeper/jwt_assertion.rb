require "doorkeeper/jwt_assertion/version"
require "doorkeeper/request/assertion"
require "doorkeeper/jwt_assertion/railtie"

require 'jwt'

module Doorkeeper
	module JWTAssertion
		
		attr_reader :jwt

	end
end

module Doorkeeper
	class Server
		
		attr_reader :jwt

		def jwt=(jwt)
			@jwt = jwt
			context.instance_variable_set('@jwt', jwt)
		end


	end
end

module Doorkeeper
	class Config

		option :jwt_key

		class Builder

			def jwt_secret( key )
				set_jwt(key)
			end

			def jwt_private_key ( key_file, passphrase = nil )
				key = OpenSSL::PKey::RSA.new( File.open(key_file), passphrase )
				set_jwt(key)
			end

			private

				def set_jwt( key )

					Config.class_eval do
						alias_method :remember_calculate_token_grant_types, :calculate_token_grant_types

						define_method :calculate_token_grant_types do
							remember_calculate_token_grant_types << 'assertion'
						end
					end

					jwt_key key

				end

		end
		
	end
end

module Doorkeeper
	module Errors
		class ExpiredSignature < DoorkeeperError
		end
	end
end