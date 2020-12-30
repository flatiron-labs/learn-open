# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learn_open/version'

Gem::Specification.new do |spec|
  spec.name          = 'learn-open'
  spec.version       = LearnOpen::VERSION
  spec.authors       = ['Flatiron School']
  spec.email         = ['learn@flatironschool.com']
  spec.summary       = 'Open Learn lessons locally'
  spec.homepage      = 'https://github.com/learn-co/learn-open'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib bin]

  spec.add_development_dependency 'bundler', '~> 2.2.0'
  spec.add_development_dependency 'diff-lcs', '~> 1.3'
  spec.add_development_dependency 'fakefs', '~> 1.3.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.0'
  spec.add_development_dependency 'pry',     '~> 0.13.1'
  spec.add_development_dependency 'rake',    '~> 13.0'
  spec.add_development_dependency 'rspec-core', '~> 3.10.0'
  spec.add_development_dependency 'rspec-mocks', '~> 3.10.0'

  spec.add_runtime_dependency 'git'
  spec.add_runtime_dependency 'learn-web', '>= 1.5.2'
  spec.add_runtime_dependency 'netrc'
end
