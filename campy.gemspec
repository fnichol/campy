# -*- encoding: utf-8 -*-
require File.expand_path('../lib/campy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = %q{Tiny Campfire Ruby client so you can get on with it.}
  gem.summary       = %q{Tiny Campfire Ruby client so you can get on with it. It's implemented on top of Net::HTTP and only requires the multi_json gem for Ruby compatibilities.}
  gem.homepage      = "http://fnichol.github.com/campy/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "campy"
  gem.require_paths = ["lib"]
  gem.version       = Campy::VERSION

  gem.add_dependency "multi_json", "~> 1.0"

  gem.add_development_dependency "minitest", "< 5.0"
  gem.add_development_dependency "webmock", "~> 1.8.5"
  gem.add_development_dependency "simplecov", "~> 0.6.1"
end
