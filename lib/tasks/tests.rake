begin
  require 'rspec/core/rake_task'

  desc "Run all the tests, called by the CI server"
  task :ci => [:spec, :cucumber] do

  end

  task :default => [:ci]
rescue Exception
  nil
end
  desc 'run all specs'
  task :all_specs do
    Rake::Task[:spec].invoke
    Rake::Task[:cucumber].invoke
  end

Rake::Task[:default].prerequisites.clear
task :default => :all_specs