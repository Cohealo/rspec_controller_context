# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_controller_context/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec_controller_context"
  spec.version       = RspecControllerContext::VERSION
  spec.authors       = ["Andy Hartford"]
  spec.email         = ["andy.hartford@cohealo.com"]
  spec.summary       = %q{Rspec Controller Context. Adds a DSL to controller specs to help build the request.}
  spec.description   = %q{Adds a DSL to the controller specs to configure request options. The config is inheritable and very flexible.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activesupport", '>= 4'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
end
