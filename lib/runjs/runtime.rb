begin
  require 'json'
rescue LoadError
  require 'rubygems'
  require 'json'
end

module RunJS

  class Runtime

    def self.deprecated?
      @deprecated ||= false
    end

    def self.available?
      false
    end

    def self.class_name
      name.split('::').last
    end

    def context(js)
      raise NotImplementedError
    end

    def run(js)
      raise NotImplementedError
    end

    def call(function, *args)
      apply(function, 'this', *args)
    end

    def apply(function, this, *args)
      this = 'null' if this.nil?
      args = args.to_json
      run("return #{function}.apply(#{this}, #{args});")
    end

    def eval(js)
      js = js.to_json
      run("return eval(#{js});")
    end

  private

    include Encoding

    RUNNER = File.read(File.expand_path('../support/runner.js', __FILE__))

    def merge_runner(js)
      RUNNER % js
    end

    def parse_json(result, js)
      result, ok = JSON.parse(result)
      raise JavaScriptError.new(result, js) unless ok
      result
    end

  end

end
