# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doorkeeper/jwt_assertion/version'

Gem::Specification.new do |spec|
	spec.name          = "doorkeeper-jwt_assertion"
	spec.version       = Doorkeeper::JwtAssertion::VERSION
	spec.authors       = ["Omac"]
	spec.email         = ["omar@kioru.com"]
	spec.summary       = 'OAuth JWT assertion extension for Doorkeeper'
	spec.description   = 'Extend your Doorkeeper implementation adding a new grant type: assertion. And decoding JWT claim messages to generate access tokens.'
	spec.homepage      = 'https://github.com/kioru/doorkeeper-jwt_assertion'
	spec.license       = "MIT"

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "doorkeeper", '~> 2.1'
	spec.add_dependency "jwt", '~> 1.4'

	spec.add_development_dependency "bundler", "~> 1.7"
	spec.add_development_dependency "rake", "~> 10.0"
end
