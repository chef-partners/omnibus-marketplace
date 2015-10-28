# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marketplace/version'
require 'find'

Gem::Specification.new do |spec|
  spec.name          = 'chef-marketplace'
  spec.version       = Marketplace::VERSION
  spec.authors       = ['Ryan Cragun']
  spec.email         = ['me@ryan.ec']
  spec.summary       = 'Chef Marketplace libraries'
  spec.description   = spec.summary
  spec.license       = 'Apachev2'

  spec.files         = Find.find('./').select { |f| !File.directory?(f) }
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']

  spec.add_dependency 'sequel'
  spec.add_dependency 'highline'
  spec.add_dependency 'chef'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-rescue'
end
