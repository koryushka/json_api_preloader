# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_api_preloader/version'

Gem::Specification.new do |s|
  s.name      = 'json_api_preloader'
  s.version   = JsonApiPreloader::VERSION
  s.authors   = ['Kiryl Karetnikau']
  s.license   = 'MIT'
  s.email     = 'kiryl.karetnikau@gmail.com'
  s.homepage  = 'https://github.com/koryushka/json_api_preloader'
  s.summary   = 'Preloads associations based on request param `included`'
  s.files     = `git ls-files -z`.split("\x0")

  s.add_development_dependency 'rspec', '~> 3.9.0'
  s.add_dependency 'activesupport', '~> 4.0', '>= 4.0.2'
end
