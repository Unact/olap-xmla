begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  puts 'You must `gem install rspec` and `bundle install` to run rake tasks'
end
