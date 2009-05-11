require 'rake/testtask'

desc "Run all tests"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['t/*_test.rb']
  t.verbose = true
  t.warning = true
end