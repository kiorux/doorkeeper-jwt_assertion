# Doorkeeper JWT Assertion

## Description

Extending (Doorkeeper)[https://github.com/doorkeeper-gem/doorkeeper] to support JWT Assertion grant type using a secret or a private key file.

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
end
```

This will automatically push `assertion` into the Doorkeeper's grant_types configuration attribute.

You can also use the `resource_owner_authenticator` in the configuration to identify the owner based on the JWT claim values.
If the client request a token with an invalid assertion, an error will be raised. So you can rely on the `jwt` getter if an assertion grant was requested.

``` ruby
Doorkeeper.configure do
	
	resource_owner_authenticator do

		if jwt
			head :unauthorized unless user = User.where(:email => jwt['prn']).first
			return user
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
           :iss => 'issuer',
           :scope => 'scope',
           :exp => Time.now.utc.to_i + 5.minutes }

token = client.assertion.get_token(params)
```

## TO DO

* Better error handling
* Testing