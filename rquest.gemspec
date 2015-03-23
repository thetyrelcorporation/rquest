# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rquest/version'

Gem::Specification.new do |spec|
  spec.name          = "rquest"
  spec.version       = Rquest::VERSION
  spec.authors       = ["The Tyrel Corporation"]
  spec.email         = ["cloud.tycorp@gmail.com"]

  if spec.respond_to?(:metadata)
  end

  spec.summary       = %q{A helper library to easily define restful web requests in ruby. It wraps NET::HTTP in an intuitive work flow modeled off of the Postman Chrome extension.}
  spec.description   = %q{RQuest makes it easy to build request and gives you full control over every aspect of the request. I modeled it after the chrome extension postman. Everything you can do with postman you can do with RQuest and it follows the same intuitive work flow.}
  spec.homepage      = "https://github.com/thetyrelcorporation/rquest"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec"
	spec.add_development_dependency "guard"
	spec.add_development_dependency "guard-rspec"
	spec.add_development_dependency "multipart-post"
	spec.add_development_dependency  "mimemagic"
end
