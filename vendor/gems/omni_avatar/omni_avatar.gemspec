$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "omni_avatar/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "omni_avatar"
  s.version     = OmniAvatar::VERSION
  s.authors     = ["Craig Ambrose"]
  s.email       = ["craig@enspiral.com"]
  s.homepage    = 'http://github.com/enspiral/omni_avatar'
  s.summary     = %q{Provides avatars from a variety of sources.}
  s.description = s.description

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "carrierwave", "~> 0.9"
  s.add_dependency "rails", "~> 3.2.14"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'bogus'
end
