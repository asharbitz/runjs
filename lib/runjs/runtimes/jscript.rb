module RunJS

  class JScript < SystemRuntime

    @cmd = 'cscript'

    def initialize
      super
      context(JSON_JS)
    end

  private

    JSON_JS = File.read(File.expand_path('../../vendor/json2.js', __FILE__))

    def popen(js)
      OS.write_tempfile(encode(js, 'UTF-16LE', 'UTF-8')) do |filename|
        cmd = [self.class.cmd, '//E:jscript', '//Nologo', '//U', filename]
        result = OS.popen(cmd, :external_encoding => 'UTF-16LE').strip
        raise CompileError.new(error_message(result, cmd), js) unless OS.success?
        result
      end
    end

    def error_message(message, cmd)
      if message.empty?  # Hack to get the error message on Windows 8
        cmd.delete('//U')
        OS.popen(cmd).strip
      else
        message
      end
    end

  end

end
