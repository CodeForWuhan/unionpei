Gem::Specification.new do |s|
  s.name        = 'unionpei'
  s.version     = '1.0.0'
  s.summary     = "An unofficial unionpay gem"
  s.description = "An unofficial unionpay gem"
  s.authors     = ["Shuang"]
  s.email       = 'memorycancel@gmail.com'
  s.files       = [
                    "lib/unionpei.rb",
                    "lib/unionpei/version.rb",
                    "lib/unionpei/sdk_config.rb",
                    "lib/unionpei/log_util.rb",
                    "lib/unionpei/cert_util.rb",
                    "lib/unionpei/sdk_util.rb",
                    "lib/unionpei/acp_service.rb",
                    "lib/unionpei/payment.rb",
                    "lib/unionpei/acp_sdk.ini"
                  ]
  s.homepage    =
    'https://rubygems.org/gems/unionpei'
  s.license       = 'MIT'

  s.add_runtime_dependency "iniparse"
  s.add_runtime_dependency "jruby-openssl" if RUBY_PLATFORM == "java"
  s.add_runtime_dependency "openssl" if RUBY_PLATFORM == "ruby"
end
