require 'rspec/core/rake_task'

desc "Run all the tests, called by the CI server"
task :ci => [:spec, :cucumber] do

end

task :default => [:ci]