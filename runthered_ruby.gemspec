Gem::Specification.new do |s|
  s.name        = 'runthered_ruby'
  s.version     = '1.0.1'
  s.add_development_dependency "minitest", '~> 0'
  s.add_development_dependency "webmock", '~> 0'
  s.add_development_dependency "rake", '~> 0'
  s.date        = '2015-09-14'
  s.summary     = "Run The Red HTTP Gateway library"
  s.description = "Wrapper library for calling Run The Red's HTTP gateway from ruby."
  s.authors     = ["Finn Colman"]
  s.email       = 'finn.colman@runthered.com'
  s.files       = ["lib/runthered_ruby.rb", "lib/http_gateway/rtr_http_gateway.rb", "lib/push_api/rtr_push_api.rb"]
  s.homepage    =
    'http://rubygems.org/gems/rtr_http_gateway'
  s.license       = 'MIT'
end