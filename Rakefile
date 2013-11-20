$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'runjs'
require 'rake/testtask'

desc 'Run tests for all the runtimes'
task :test do
  RunJS::RUNTIMES.each { |runtime| run_tests(runtime) }
end

RunJS::RUNTIMES.each do |runtime|
  desc "Run tests for #{runtime.class_name}"
  task "test:#{runtime.class_name.downcase}" do
    run_tests(runtime)
  end
end

Rake::TestTask.new 'test:runtime' do |test|
  test.libs << 'test'
  test.pattern = 'test/*_test.rb'
  test.warning = true
end
Rake::Task['test:runtime'].clear_comments
Rake::Task['test:runtime'].comment = 'Run tests for the default runtime'

def run_tests(runtime)
  ENV['RUNJS_RUNTIME'] = runtime.class_name
  Rake::Task['test:runtime'].execute
rescue SignalException
  raise unless RUBY_PLATFORM == 'java'
rescue
end
