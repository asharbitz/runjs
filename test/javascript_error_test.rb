require 'test_helper'

describe 'syntax error' do

  specify 'a JavaScript syntax error raises a CompileError' do
    assert_raises(RunJS::CompileError) do
      RunJS.run(']')
    end
  end

  specify 'eval with syntax error raises a JavaScriptError' do
    error = assert_raises(RunJS::JavaScriptError) do
      RunJS.eval(']')
    end
    assert_equal 'SyntaxError', error['name']
  end

  specify 'throw SyntaxError raises a JavaScriptError' do
    error = assert_raises(RunJS::JavaScriptError) do
      RunJS.run('throw new SyntaxError();')
    end
    assert_equal 'SyntaxError', error[:name]
  end

end

describe 'runtime error' do

  describe 'raising a JavaScriptError' do

    specify 'the JavaScript code throws an error' do
      assert_raises(RunJS::JavaScriptError) do
        RunJS.run('throw new Error();')
      end
    end

    specify 'calling an undefined function' do
      assert_raises(RunJS::JavaScriptError) do
        RunJS.call('notAFunction')
      end
    end

    specify 'JSON.stringify gets a cyclic structure' do
      assert_raises(RunJS::JavaScriptError) do
        RunJS.run('var cycle = {}; cycle.self = cycle; return cycle;')
      end
    end

  end

  specify 'the error message' do
    error = RunJS.run('throw new Error("msg");') rescue $!
    assert_equal 'Error: msg', error.message

    error = RunJS.run('throw new Error();') rescue $!
    assert_equal 'Error', error.message

    error = RunJS.run('throw "msg";') rescue $!
    assert_equal 'msg', error.message

    error = RunJS.run('throw "";') rescue $!
    assert_equal '', error.message

    error = RunJS.run('throw [];') rescue $!
    assert_equal '', error.message

    error = RunJS.run('throw 0;') rescue $!
    assert_equal '0', error.message
  end

  describe 'the error object' do

    it 'contains the thrown JavaScript object' do
      error = RunJS.run('throw "msg";') rescue $!
      assert_equal 'msg', error.error

      error = RunJS.run('throw 0;') rescue $!
      assert_equal 0, error.error

      error = RunJS.run('throw null;') rescue $!
      assert_equal nil, error.error
    end

    it 'captures all the properties of the thrown error object' do
      error = assert_raises(RunJS::JavaScriptError) do
        RunJS.run(
          'var err = new Error("msg");' <<
          'err.location = { line: 4, column: 8 };' <<
          'throw err;'
        )
      end
      assert_equal 'Error', error['name']
      assert_equal 'msg', error['message']
      assert_equal 4, error['location']['line']

      skip if RunJS.runtime == RunJS::JScript
      skip if RunJS.runtime == RunJS::TheRubyRhino

      refute_empty error['stack']
    end

    it 'handles array error objects' do
      error = RunJS.run('throw [false];') rescue $!
      assert_equal [false], error.error
      assert_equal false, error[0]
    end

    it 'handles error properties that cannot be stringified (cyclic objects)' do
      error = assert_raises(RunJS::JavaScriptError) do
        context = RunJS.context('var cycle = {}; cycle.self = cycle;')
        context.run('throw { name: "Cycle", cycle: cycle };')
      end
      assert_equal 'Cycle', error['name']
      assert_equal '[object Object]', error['cycle']
    end

    it 'shortens the stack trace produced by SpiderMonkey' do
      error = RunJS.call('notAFunction', 'x' * 2000) rescue $!
      if RunJS.runtime == RunJS::SpiderMonkey
        assert_equal 1005, error.error['stack'].size
        assert_match 'xxx ... xxx', error['stack']
      else
        refute_match ' ... ', error[:stack]
      end
    end

  end

end

describe 'accessing the JavaScript source code that caused the error' do

  def runner(js)
    if RunJS.runtime == RunJS::JScript
      js = [RunJS::JScript::JSON_JS, js].join("\n")
    end
    RunJS::Runtime::RUNNER % js
  end

  specify 'CompileError#source contains the runner code' do
    error = assert_raises(RunJS::CompileError) { RunJS.run('(') }
    assert_equal runner('('), error.source
  end

  specify 'JavaScriptError#source contains the runner code' do
    error = assert_raises(RunJS::JavaScriptError) { RunJS.run('foo();') }
    assert_equal runner('foo();'), error.source
  end

end
