# frozen_string_literal: true

require 'date'
require File.expand_path('lib/openscap/version', __dir__)

GEMSPEC = Gem::Specification.new do |gem|
  gem.name = 'openscap'
  gem.version = OpenSCAP::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 3.2.2'

  gem.author = 'Simon Lukasik'
  gem.email = 'isimluk@fedoraproject.org'
  gem.homepage = 'https://github.com/isimluk/ruby-openscap'
  gem.license = 'GPL-2.0-only'

  gem.summary = 'A FFI wrapper around the OpenSCAP library'
  gem.description = "A FFI wrapper around the OpenSCAP library.
  Currently it provides only subset of libopenscap functionality."

  gem.add_dependency 'ffi', '~> 1.16.2'

  gem.files = Dir['{lib}/**/*.rb'] + ['COPYING', 'README.md', 'Rakefile']
  gem.require_path = 'lib'
end
