module RunJS

  class JavaScriptCore < SystemRuntime
    @cmd = '/System/Library/Frameworks/JavaScriptCore.framework' <<
           '/Versions/Current/Resources/jsc'
  end

end
