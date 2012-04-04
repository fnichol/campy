# -*- encoding: utf-8 -*-
require File.expand_path('../lib/campy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "campy"
  gem.require_paths = ["lib"]
  gem.version       = Campy::VERSION

  gem.add_dependency "multi_json", "~> 1.0"

  gem.add_development_dependency "minitest", "~> 2.12.0"
  gem.add_development_dependency "webmock", "~> 1.8.5"
end
