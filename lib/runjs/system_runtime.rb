module RunJS

  class SystemRuntime < Runtime

    class << self
      attr_accessor :cmd
    end

    def self.available?
      OS.which(@cmd)
    end

    def initialize
      @context = []
    end

    def context(js)
      @context << encode(js, 'UTF-8')
      self
    end

    def run(js)
      js = encode(js, 'UTF-8')
      js = merge_context(js)
      js = merge_runner(js)
      result = popen(js)
      parse_json(result, js)
    end

  private

    def merge_context(js)
      (@context + [js]).join("\n")
    end

    def popen(js)
      OS.write_tempfile(js) do |filename|
        result = OS.popen([self.class.cmd, filename]).strip
        raise CompileError.new(result, js) unless OS.success?
        result
      end
    end

  end

end
