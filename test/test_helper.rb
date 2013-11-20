require 'runjs'

def display_banner(width)
  runtime = RunJS.runtime.class_name rescue ENV['RUNJS_RUNTIME']
  ruby = defined?(JRUBY_VERSION) ? "JRuby #{JRUBY_VERSION}" :
                                   "Ruby #{RUBY_VERSION}"
  puts
  puts '=' * width
  puts "#{runtime} - #{ruby}".center(width)
  puts '=' * width
  puts
end

display_banner(40)
RunJS.runtime rescue abort $!.message  # abort if no runtime is detected

require 'minitest/autorun'
