# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name      = 'json_api_preloader'
  s.version   = '0.0.1'
  s.authors   = ['Kiryl Karetnikau']
  s.license   = 'MIT'
  s.email     = 'kiryl.karetnikau@gmail.com'
  s.homepage  = 'https://github.com/koryushka/json_api_preloader'
  s.summary   = 'Preloads associations based on request param `included`'
  s.files     = `git ls-files -z`.split("\x0")
end
