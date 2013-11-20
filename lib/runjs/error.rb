module RunJS

  class Error < StandardError
  end

  class CompileError < Error

    attr_reader :source

    def initialize(message, source)
      @source = source
      super(message)
    end

  end

  class JavaScriptError < Error

    attr_reader :error
    attr_reader :source

    def initialize(error, source)
      @error = error
      @source = source
      super(get_message)
    end

    def [](key)
      @error[key].nil? ? @error[key.to_s] : @error[key]
    rescue
      nil
    end

  private

    def get_message
      return '' if @error.respond_to?(:empty?) && @error.empty?
      message = [self['name'], self['message']].compact
      message.delete('')
      message.empty? ? @error.to_s : message.join(': ')
    end

  end

  class RuntimeUnavailable < Error

    def initialize(runtime = nil)
      if runtime
        super('Could not find the runtime: ' + runtime.class_name)
      else
        super('Could not find a JavaScript runtime. ' +
              "The supported runtimes are:\n" +
              RUNTIMES.reject(&:deprecated?).map(&:class_name).join(', '))
      end
    end

  end

end
