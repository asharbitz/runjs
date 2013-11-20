# -*- coding: utf-8 -*-

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                         #
#  These tests are copied from ExecJS:                                    #
#  https://github.com/sstephenson/execjs/blob/v1.4.0/test/test_execjs.rb  #
#                                                                         #
#  The purpose is to document the differences between RunJS and ExecJS    #
#                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# require "test/unit"
# require "execjs/module"
#
# begin
#   require "execjs"
# rescue ExecJS::RuntimeUnavailable => e
#   warn e
#   exit 2
# end
#
# class TestExecJS < Test::Unit::TestCase

require "test_helper"
require "runjs" # RunJS does not set the runtime when the file is loaded, so
                # this statement will never raise a RuntimeUnavailable error

class TestRunJS < MiniTest::Unit::TestCase


  # def test_runtime_available
  #   runtime = ExecJS::ExternalRuntime.new(:command => "nonexistent")
  #   assert !runtime.available?
  #
  #   runtime = ExecJS::ExternalRuntime.new(:command => "ruby")
  #   assert runtime.available?
  # end

  def test_runtime_available
    # RunJS::SystemRuntime is equivalent to ExecJS::ExternalRuntime
    # Both available? and cmd= are class methods

    runtime = RunJS::SystemRuntime
    runtime.cmd = "nonexistent"
    assert !runtime.available?

    runtime.cmd = "ruby"
    assert runtime.available?
  ensure
    runtime.cmd = nil
  end


  # def test_runtime_assignment
  #   original_runtime = ExecJS.runtime
  #   runtime = ExecJS::ExternalRuntime.new(:command => "nonexistent")
  #   assert_raises(ExecJS::RuntimeUnavailable) { ExecJS.runtime = runtime }
  #   assert_equal original_runtime, ExecJS.runtime
  #
  #   runtime = ExecJS::ExternalRuntime.new(:command => "ruby")
  #   ExecJS.runtime = runtime
  #   assert_equal runtime, ExecJS.runtime
  # ensure
  #   ExecJS.runtime = original_runtime
  # end

  def test_runtime_assignment
    # RunJS.runtime= accepts a class (and not an instance)

    original_runtime = RunJS.runtime
    runtime = RunJS::SystemRuntime
    runtime.cmd = "nonexistent"
    assert_raises(RunJS::RuntimeUnavailable) { RunJS.runtime = runtime }
    assert_equal original_runtime, RunJS.runtime

    runtime.cmd = "ruby"
    RunJS.runtime = runtime
    assert_equal runtime, RunJS.runtime
  ensure
    RunJS.runtime = original_runtime
    runtime.cmd = nil
  end


  # def test_context_call
  #   context = ExecJS.compile("id = function(v) { return v; }")
  #   assert_equal "bar", context.call("id", "bar")
  # end

  def test_context_call
    # RunJS#context serves the same purpose as ExecJS#compile

    context = RunJS.context("id = function(v) { return v; }")
    assert_equal "bar", context.call("id", "bar")
  end


  # def test_nested_context_call
  #   context = ExecJS.compile("a = {}; a.b = {}; a.b.id = function(v) { return v; }")
  #   assert_equal "bar", context.call("a.b.id", "bar")
  # end

  def test_nested_context_call
    context = RunJS.context("a = {}; a.b = {}; a.b.id = function(v) { return v; }")
    assert_equal "bar", context.call("a.b.id", "bar")
  end


  # def test_context_call_missing_function
  #   context = ExecJS.compile("")
  #   assert_raises ExecJS::ProgramError do
  #     context.call("missing")
  #   end
  # end

  def test_context_call_missing_function
    # RunJS::JavaScriptError is similar to ExecJS::ProgramError

    context = RunJS.context("")
    assert_raises RunJS::JavaScriptError do
      context.call("missing")
    end
  end


  # def test_exec
  #   assert_nil ExecJS.exec("1")
  #   assert_nil ExecJS.exec("return")
  #   assert_nil ExecJS.exec("return null")
  #   assert_nil ExecJS.exec("return function() {}")
  #   assert_equal 0, ExecJS.exec("return 0")
  #   assert_equal true, ExecJS.exec("return true")
  #   assert_equal [1, 2], ExecJS.exec("return [1, 2]")
  #   assert_equal "hello", ExecJS.exec("return 'hello'")
  #   assert_equal({"a"=>1,"b"=>2}, ExecJS.exec("return {a:1,b:2}"))
  #   assert_equal "café", ExecJS.exec("return 'café'")
  #   assert_equal "☃", ExecJS.exec('return "☃"')
  #   assert_equal "☃", ExecJS.exec('return "\u2603"')
  #   assert_equal "\\", ExecJS.exec('return "\\\\"')
  # end

  def test_exec
    # RunJS.run is equivalent to ExecJS.exec

    assert_nil RunJS.run("1")
    assert_nil RunJS.run("return")
    assert_nil RunJS.run("return null")
    assert_nil RunJS.run("return function() {}")
    assert_equal 0, RunJS.run("return 0")
    assert_equal true, RunJS.run("return true")
    assert_equal [1, 2], RunJS.run("return [1, 2]")
    assert_equal "hello", RunJS.run("return 'hello'")
    assert_equal({"a"=>1,"b"=>2}, RunJS.run("return {a:1,b:2}"))
    assert_equal "café", RunJS.run("return 'café'")
    assert_equal "☃", RunJS.run('return "☃"')

    if RunJS.runtime != RunJS::SpiderMonkey
      assert_equal "☃", RunJS.run('return "\u2603"')
    else
      assert_raises(JSON::ParserError) { RunJS.run('return "\u2603"') }
      # result == "[\"\u0003\",true]"
    end

    assert_equal "\\", RunJS.run('return "\\\\"')
  end


  # def test_eval
  #   assert_nil ExecJS.eval("")
  #   assert_nil ExecJS.eval(" ")
  #   assert_nil ExecJS.eval("null")
  #   assert_nil ExecJS.eval("function() {}")
  #   assert_equal 0, ExecJS.eval("0")
  #   assert_equal true, ExecJS.eval("true")
  #   assert_equal [1, 2], ExecJS.eval("[1, 2]")
  #   assert_equal [1, nil], ExecJS.eval("[1, function() {}]")
  #   assert_equal "hello", ExecJS.eval("'hello'")
  #   assert_equal ["red", "yellow", "blue"], ExecJS.eval("'red yellow blue'.split(' ')")
  #   assert_equal({"a"=>1,"b"=>2}, ExecJS.eval("{a:1,b:2}"))
  #   assert_equal({"a"=>true}, ExecJS.eval("{a:true,b:function (){}}"))
  #   assert_equal "café", ExecJS.eval("'café'")
  #   assert_equal "☃", ExecJS.eval('"☃"')
  #   assert_equal "☃", ExecJS.eval('"\u2603"')
  #   assert_equal "\\", ExecJS.eval('"\\\\"')
  # end

  def test_eval
    # RunJS does not wrap the string to eval in parentheses

    assert_nil RunJS.eval("")
    assert_nil RunJS.eval(" ")
    assert_nil RunJS.eval("null")

    # assert_nil ExecJS.eval("function() {}")
    assert_nil RunJS.eval("(function() {})")

    assert_equal 0, RunJS.eval("0")
    assert_equal true, RunJS.eval("true")
    assert_equal [1, 2], RunJS.eval("[1, 2]")
    assert_equal [1, nil], RunJS.eval("[1, function() {}]")
    assert_equal "hello", RunJS.eval("'hello'")
    assert_equal ["red", "yellow", "blue"], RunJS.eval("'red yellow blue'.split(' ')")

    # assert_equal({"a"=>1,"b"=>2}, ExecJS.eval("{a:1,b:2}"))
    assert_equal({"a"=>1,"b"=>2}, RunJS.eval("({a:1,b:2})"))

    # assert_equal({"a"=>true}, ExecJS.eval("{a:true,b:function (){}}"))
    assert_equal({"a"=>true}, RunJS.eval("({a:true,b:function (){}})"))

    assert_equal "café", RunJS.eval("'café'")
    assert_equal "☃", RunJS.eval('"☃"')
    assert_equal "☃", RunJS.eval('"\u2603"') if RunJS.runtime != RunJS::SpiderMonkey
    assert_equal "\\", RunJS.eval('"\\\\"')
  end


  # if defined? Encoding
  #   def test_encoding
  #     utf8 = Encoding.find('UTF-8')
  #
  #     assert_equal utf8, ExecJS.exec("return 'hello'").encoding
  #     assert_equal utf8, ExecJS.eval("'☃'").encoding
  #
  #     ascii = "'hello'".encode('US-ASCII')
  #     result = ExecJS.eval(ascii)
  #     assert_equal "hello", result
  #     assert_equal utf8, result.encoding
  #
  #     assert_raise Encoding::UndefinedConversionError do
  #       binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
  #       ExecJS.eval(binary)
  #     end
  #   end

  def test_encoding
    skip unless defined? Encoding

    utf8 = Encoding.find('UTF-8')

    assert_equal utf8, RunJS.run("return 'hello'").encoding
    assert_equal utf8, RunJS.eval("'☃'").encoding

    ascii = "'hello'".encode('US-ASCII')
    result = RunJS.eval(ascii)
    assert_equal "hello", result
    assert_equal utf8, result.encoding

    assert_raises Encoding::UndefinedConversionError do
      binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
      RunJS.eval(binary)
    end
  end


  #   def test_encoding_compile
  #     utf8 = Encoding.find('UTF-8')
  #
  #     context = ExecJS.compile("foo = function(v) { return '¶' + v; }".encode("ISO8859-15"))
  #
  #     assert_equal utf8, context.exec("return foo('hello')").encoding
  #     assert_equal utf8, context.eval("foo('☃')").encoding
  #
  #     ascii = "foo('hello')".encode('US-ASCII')
  #     result = context.eval(ascii)
  #     assert_equal "¶hello", result
  #     assert_equal utf8, result.encoding
  #
  #     assert_raise Encoding::UndefinedConversionError do
  #       binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
  #       context.eval(binary)
  #     end
  #   end
  # end

  def test_encoding_compile
    skip unless defined? Encoding

    utf8 = Encoding.find('UTF-8')

    context = RunJS.context("foo = function(v) { return '¶' + v; }".encode("ISO8859-15"))

    assert_equal utf8, context.run("return foo('hello')").encoding
    assert_equal utf8, context.eval("foo('☃')").encoding

    ascii = "foo('hello')".encode('US-ASCII')
    result = context.eval(ascii)
    assert_equal "¶hello", result
    assert_equal utf8, result.encoding

    assert_raises Encoding::UndefinedConversionError do
      binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
      context.eval(binary)
    end
  end


  # def test_compile
  #   context = ExecJS.compile("foo = function() { return \"bar\"; }")
  #   assert_equal "bar", context.exec("return foo()")
  #   assert_equal "bar", context.eval("foo()")
  #   assert_equal "bar", context.call("foo")
  # end

  def test_compile
    context = RunJS.context("foo = function() { return \"bar\"; }")
    assert_equal "bar", context.run("return foo()")
    assert_equal "bar", context.eval("foo()")
    assert_equal "bar", context.call("foo")
  end


  # def test_this_is_global_scope
  #   assert_equal true, ExecJS.eval("this === (function() {return this})()")
  #   assert_equal true, ExecJS.exec("return this === (function() {return this})()")
  # end

  def test_this_is_global_scope
    assert_equal true, RunJS.eval("this === (function() {return this})()")
    assert_equal true, RunJS.run("return this === (function() {return this})()")
  end


  # def test_commonjs_vars_are_undefined
  #   assert ExecJS.eval("typeof module == 'undefined'")
  #   assert ExecJS.eval("typeof exports == 'undefined'")
  #   assert ExecJS.eval("typeof require == 'undefined'")
  # end

  def test_commonjs_vars_are_undefined
    # The test passes if the end of lib/runjs/support/runner.js is changed to:
    # })(function(module, exports, require, console) { %s });
    skip if RunJS.runtime == RunJS::Node

    assert RunJS.eval("typeof module == 'undefined'")
    assert RunJS.eval("typeof exports == 'undefined'")
    assert RunJS.eval("typeof require == 'undefined'")
  end


  # def test_console_is_undefined
  #   assert ExecJS.eval("typeof console == 'undefined'")
  # end

  def test_console_is_undefined
    skip if RunJS.runtime == RunJS::Node

    assert RunJS.eval("typeof console == 'undefined'")
  end


  # def test_compile_large_scripts
  #   body = "var foo = 'bar';\n" * 100_000
  #   assert ExecJS.exec("function foo() {\n#{body}\n};\nreturn true")
  # end

  def test_compile_large_scripts
    # RunJS::TheRubyRhino (but not ExecJS::Runtimes::RubyRhino) causes this warning:
    # [INFO] Rhino byte-code generation failed forcing org.mozilla.javascript.Context@37eaab into interpreted mode

    body = "var foo = 'bar';\n" * 100_000
    assert RunJS.run("function foo() {\n#{body}\n};\nreturn true")
  end


  # def test_syntax_error
  #   assert_raise ExecJS::RuntimeError do
  #     ExecJS.exec(")")
  #   end
  # end

  def test_syntax_error
    # RunJS::CompileError is similar to ExecJS::RuntimeError

    assert_raises RunJS::CompileError do
      RunJS.run(")")
    end
  end


  # def test_thrown_exception
  #   assert_raise ExecJS::ProgramError do
  #     ExecJS.exec("throw 'hello'")
  #   end
  # end

  def test_thrown_exception
    assert_raises RunJS::JavaScriptError do
      RunJS.run("throw 'hello'")
    end
  end


  # def test_coffeescript
  #   require "open-uri"
  #   assert source = open("http://jashkenas.github.com/coffee-script/extras/coffee-script.js").read
  #   context = ExecJS.compile(source)
  #   assert_equal 64, context.call("CoffeeScript.eval", "((x) -> x * x)(8)")
  # end

  begin
    require 'coffee_script/source'
    COFFEE = File.read(CoffeeScript::Source.bundled_path)
  rescue LoadError
    COFFEE = nil
  end

  def test_coffeescript
    skip unless COFFEE

    context = RunJS.context(COFFEE)
    assert_equal 64, context.call("CoffeeScript.eval", "((x) -> x * x)(8)")
  end

end
