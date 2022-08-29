# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unionpei/version'

Gem::Specification.new do |s|
  s.name        = 'unionpei'
  s.version     = UnionPei::VERSION
  s.summary     = 'An unofficial unionpay gem'
  s.description = 'An unofficial unionpay gem'
  s.authors     = ['Shuang']
  s.email       = 'memorycancel@gmail.com'
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.homepage = 'https://rubygems.org/gems/unionpei'
  s.license = 'MIT'
  s.add_runtime_dependency 'iniparse'
  s.add_runtime_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'
  s.add_runtime_dependency 'openssl' if RUBY_PLATFORM == 'ruby'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock'
end
