require "bundler/gem_tasks"

desc 'Start the app'
task :server do
  exec 'bundle exec rackup'
end

desc 'Access app console'
task :console do
  require 'pry'
  require './setup'
  binding.pry
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f documentation", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end
task default: :spec
