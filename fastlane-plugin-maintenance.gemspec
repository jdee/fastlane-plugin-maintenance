lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/maintenance/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-maintenance'
  spec.version       = Fastlane::Maintenance::VERSION
  spec.author        = 'Jimmy Dee'
  spec.email         = 'jgvdthree@gmail.com'

  spec.summary       = 'Maintenance actions for plugin repos.'
  spec.homepage      = "https://github.com/jdee/fastlane-plugin-maintenance"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency "pattern_patch", ">= 0.5.4"

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane', '>= 2.69.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '0.52.0'
  spec.add_development_dependency 'simplecov'
end
