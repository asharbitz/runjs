module RunJS

  class TheRubyRhino < TheRubyRacer

    @lib = 'rhino'
    @deprecated = true

  private

    def error_message(e)
      e.cause ? e.cause.message : e.message
    end

  end

end
