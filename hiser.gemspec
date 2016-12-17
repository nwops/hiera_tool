# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiser/version'

Gem::Specification.new do |spec|
  spec.name          = "hiser"
  spec.version       = Hiser::VERSION
  spec.authors       = ["Corey Osman"]
  spec.email         = ["corey@nwops.io"]

  spec.summary       = %q{A simple gem that uses hiera data lookups to create serialized files}
  spec.description   = %q{A simple script that uses hiera data lookups to create
         json or yaml serialized files with custom object mappings
         defined in the hiera common.yaml file}
  spec.homepage      = "https://github.com/nwops/hiser"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "hiera", ">= 3.0"
  spec.add_runtime_dependency 'retrospec', ">= 0.4.0"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "release_me"
end
