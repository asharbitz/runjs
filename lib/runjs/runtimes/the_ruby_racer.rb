module RunJS

  class TheRubyRacer < Runtime

    @lib = 'v8'

    def self.available?
      require @lib
      true
    rescue LoadError
      false
    end

    def initialize
      require lib
      @context = lib_module::Context.new
    end

    def context(js)
      js = encode(js, 'UTF-8')
      context_eval(js)
      self
    end

    def run(js)
      js = encode(js, 'UTF-8')
      js = merge_runner(js)
      result = context_eval(js)
      parse_json(result, js)
    end

  private

    def lib
      self.class.instance_variable_get(:@lib)
    end

    def lib_module
      Object.const_get(lib.capitalize)
    end

    def context_eval(js)
      @context.eval(js)
    rescue lib_module::JSError => e
      raise CompileError.new(error_message(e), js)
    end

    def error_message(e)
      [e.value['name'], e.message].compact.join(': ')
    end

  end

end
