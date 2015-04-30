# Doorkeeper JWT Assertion

Extending [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) to support JWT Assertion grant type using a secret or a private key file.

**This library is in alpha. Future incompatible changes may be necessary.**

## Install

Add the gem to the Gemfile

```ruby
gem 'doorkeeper-jwt_assertion'
```

## Configuration

Inside your doorkeeper configuration file add the one of the fallowing:

``` ruby
Doorkeeper.configure do
	
	jwt_private_key Rails.root.join('config', 'keys', 'private.key')

	jwt_secret 'notasecret'

	# Optional
	jwt_use_issuer_as_client_id true
end
```

This will automatically push `assertion` into the Doorkeeper's grant_types configuration attribute.

When `jwt_use_issuer_as_client_id` is set to false then the `client_id` MUST be available from the parameters. By default it will extract the 'iss' and use it as the client_id to retrieve the oauth application.

Use the `resource_owner_authenticator` in the configuration to identify the owner based on the JWT claim values. This values can be accessible from `jwt`.
If the client request a token with an invalid assertion, or an expired JWT claim, an :invalid_grant error response will be generated before retrieving the resource_owner.

``` ruby
Doorkeeper.configure do
	
	resource_owner_authenticator do

		if jwt
			jwt['prn'].present? and User.find_by_email(jwt['prn'])
		end

	end

end

```

## Client Usage

Generate an assertion request token using a private key file or a secret:

``` ruby
client = OAuth2::Client.new('client_id', 'client_secret', :site => 'http://my-site.com')

p12 = OpenSSL::PKCS12.new( Rails.root.join('config', 'keys', 'private.p12').open )

params = { :private_key => p12.key,
           :aud => 'audience',
           :prn => 'person', # or :sub => 'subject', not suported on OAuth2 1.0.0 yet.
           :iss => 'client_id',
           :scope => 'scope',
           :exp => Time.now.utc.to_i + 5.minutes }

token = client.assertion.get_token(params)
```

>  "[...] refresh tokens are not issued
>  in response to assertion grant requests and access tokens will be
>  issued with a reasonably short lifetime."
> - [draft-ietf-oauth-assertions-18](https://tools.ietf.org/html/draft-ietf-oauth-assertions-18#section-4.1)

## TO DO

* Better error handling
* JWT Client Authentication Flow
* Testing