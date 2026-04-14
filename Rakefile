require "bundler/gem_tasks"

task default: %i[spec]

desc "Run rubocop"
task :rubocop do
  require "rubocop/rake_task"

  RuboCop::RakeTask.new do |task|
    task.patterns = ["lib/**/*.rb"]
    task.formatters = ["simple"]
  end
end

desc "Run specs"
task :spec do
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new
end
