require 'runjs/encoding'
require 'runjs/error'
require 'runjs/os'
require 'runjs/runtime'
require 'runjs/system_runtime'

require 'runjs/runtimes/java_script_core'
require 'runjs/runtimes/jscript'
require 'runjs/runtimes/node'
require 'runjs/runtimes/spider_monkey'
require 'runjs/runtimes/the_ruby_racer'
require 'runjs/runtimes/the_ruby_rhino'
require 'runjs/runtimes/v8'

module RunJS

  VERSION  = '0.1.0'

  RUNTIMES = [TheRubyRacer, JavaScriptCore, V8, D8, Node, JScript,
              TheRubyRhino, SpiderMonkey]

  def self.runtime=(runtime)
    raise RuntimeUnavailable, runtime unless runtime.available?
    @runtime = runtime
  end

  def self.runtime
    @runtime ||= from_environment(ENV['RUNJS_RUNTIME']) ||
                 RUNTIMES.reject(&:deprecated?).find(&:available?) ||
                 raise(RuntimeUnavailable)
  end

  def self.context(js)
    runtime.new.context(js)
  end

  def self.run(js)
    runtime.new.run(js)
  end

  def self.call(function, *args)
    runtime.new.call(function, *args)
  end

  def self.apply(function, this, *args)
    runtime.new.apply(function, this, *args)
  end

  def self.eval(js)
    runtime.new.eval(js)
  end

private

  def self.from_environment(name)
    name = (name || '').sub(/^RunJS::/, '')
    self.runtime = const_get(name) unless name.empty?
  end

  private_class_method(:from_environment)

end
