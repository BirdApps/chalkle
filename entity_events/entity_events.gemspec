$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "entity_events/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "entity_events"
  s.version     = EntityEvents::VERSION
  s.authors     = ["Josh Dean"]
  s.email       = ["josh@chalkle.com"]
  s.homepage    = "http://joshdean.co.nz"
  s.summary     = "Saves meta data on entity interactions"
  s.description = "Saves meta data on entity interactions. i.e. when user looks at a post is would store the user as the 'actor', the post as the 'target', and the show as the 'action'."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.19"

  s.add_development_dependency "sqlite3"
end
