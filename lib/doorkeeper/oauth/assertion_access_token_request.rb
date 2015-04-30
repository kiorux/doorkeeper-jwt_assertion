require 'doorkeeper/oauth/describable_error_response'

module Doorkeeper
	module OAuth
		class AssertionAccessTokenRequest
			
			include Validations
			include OAuth::RequestConcern
			include OAuth::Helpers

			attr_accessor :server, :original_scopes
			attr_reader :resource_owner, :client, :configuration, :access_token, :response, :error_description

			validate :assertion,      error: :invalid_grant
			validate :client,         error: :invalid_client
			validate :scopes,         error: :invalid_scope
			validate :resource_owner, error: :invalid_grant
			validate :access_token,   error: :invalid_grant
			

			##
			# @see https://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-12#section-2.1
			#
			def initialize(server, configuration)
				@server          = server
				@configuration   = configuration
				@response        = nil
				@original_scopes = server.parameters[:scope]
			end

			def authorize
				validate
				if valid?
					@response = TokenResponse.new(access_token)
				else
					@response = DescribableErrorResponse.from_request(self)
					@response.description = error_description
					@response
				end
			end



			private

				##
				# >   The value of the "grant_type" is "urn:ietf:params:oauth:grant-
				# >   type:jwt-bearer".
				# >   The value of the "assertion" parameter MUST contain a single JWT.
				# > - draft-ietf-oauth-jwt-bearer-12
				#
				# @see https://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-12#section-2.1
				#
				# >   assertion_type
				# >         REQUIRED.  The format of the assertion as defined by the
				# >         authorization server.  The value MUST be an absolute URI.
				# >
				# >   assertion
				# >         REQUIRED.  The assertion.
				# >
				# > - draft-ietf-oauth-v2-10
				# @see http://tools.ietf.org/html/draft-ietf-oauth-v2-10#section-4.1.3
				#
				# Newer versions of ietf-oauth-v2 don't need assertion_type. So it's still optional.
				def validate_assertion
					assertion, assertion_type = server.parameters.values_at(:assertion, :assertion_type)

					if assertion_type and assertion_type != 'urn:ietf:params:oauth:grant-type:jwt-bearer'
						raise StandardError.new('Assertion type not valid. Expected urn:ietf:params:oauth:grant-type:jwt-bearer') 
					end

					payload, header  = JWT.decode(assertion, configuration.jwt_key)
					server.jwt = payload
					server.jwt_header = header

				rescue => error
					@error_description = error.message
					false
				end



				##
				# If `jwt_use_issuer_as_client_id` is `true` then validate the client using the issuer as the client_id.
				# Otherwise, use the client_id directly from the parameters.
				#
				# >   Authentication of the client is optional, as described in
				# >   Section 3.2.1 of OAuth 2.0 [RFC6749] and consequently, the
				# >   "client_id" is only needed when a form of client authentication that
				# >   relies on the parameter is used.
				# > - draft-ietf-oauth-assertions-18
				#
				# @see https://tools.ietf.org/html/draft-ietf-oauth-assertions-18#section-4.1
				#
				# >   The JWT MUST contain an "iss" (issuer) claim that contains a
				# >   unique identifier for the entity that issued the JWT.  
				# > - draft-ietf-oauth-jwt-bearer-12
				#
				# @see https://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-12#section-3
				#
				def validate_client
					@client ||= if configuration.jwt_use_issuer_as_client_id
						OAuth::Client.find(server.jwt['iss']) if server.jwt['iss'].present?
					
					elsif sever.parameters[:client_id].present?
						OAuth::Client.find( sever.parameters[:client_id] )

					end 
				end


				##
				# >   The "scope" parameter may be used, as defined in the Assertion
				# >   Framework for OAuth 2.0 Client Authentication and Authorization
				# >   Grants [I-D.ietf-oauth-assertions] specification, to indicate the
				# >   requested scope.
				#
				# @see https://tools.ietf.org/html/draft-ietf-oauth-jwt-bearer-12#section-2.1
				#
				def validate_scopes
					return true unless @original_scopes.present?
					ScopeChecker.valid? @original_scopes, configuration.scopes, client.try(:scopes)
				end


				def validate_resource_owner
					resource_owner || (@resource_owner = server.current_resource_owner)
				end

				def validate_access_token
					access_token or create_token
				end


				##
				# >  [...] refresh tokens are not issued
				# >  in response to assertion grant requests and access tokens will be
				# >  issued with a reasonably short lifetime.
				#
				# @see https://tools.ietf.org/html/draft-ietf-oauth-assertions-18#section-4.1
				#
				def create_token
					expires_in = Authorization::Token.access_token_expires_in(configuration, client)
					@access_token = AccessToken.find_or_create_for(client, resource_owner.id, scopes, expires_in, false)
				end
			
		end
	end
end
