# encoding: UTF-8

require 'test_helper'

describe 'run JavaScript' do

  specify 'call' do
    assert_equal 5, RunJS.call('Math.sqrt', 25)
    assert_equal 0, RunJS.call('Date.parse', 'Jan 1 1970 UTC')
  end

  specify 'apply' do
    result = RunJS.apply('Array.prototype.concat', '["cat"]', 2, :food => nil)
    assert_equal ['cat', 2, { 'food' => nil }], result

    skip if RunJS.runtime == RunJS::JScript

    result = RunJS.apply('Array.prototype.slice', 'cat'.to_json)
    assert_equal ['c', 'a', 't'], result
  end

  specify 'run' do
    assert_nil RunJS.run('true;')
    assert_nil RunJS.run('return undefined;')
    assert_equal 4, RunJS.run('return 2 + 2;')
    assert_equal false, RunJS.run('var x = 2, y = 2; return x > y;')
    assert_equal [1, 'cat'], RunJS.run('return [1].concat("cat");')
    assert_equal '\\', RunJS.run('return "\\\\";')
  end

  describe 'eval' do

    specify 'eval' do
      assert_nil RunJS.eval(nil)
      assert_nil RunJS.eval('')
      assert_equal 4, RunJS.eval('2 + 2')
      assert_equal 4, RunJS.eval('var x = 2, y = 2; x + y')
      assert_equal ['c', 'a', 't'], RunJS.eval('"cat".split("")')
    end

    it 'requires parentheses around objects' do
      assert_equal Hash['one' => 1], RunJS.eval('({ one: 1 })')
    end

    it 'requires parentheses around anonymous functions' do
      assert_nil RunJS.eval('(function() {})')
      assert_nil RunJS.eval('function notAnonymous() {}')
      assert_nil RunJS.eval('var notAnonymous = function() {}')
    end

  end

  describe 'context' do

    it 'supports nested context' do
      js = 'a = {}; a.b = {}; a.b.c = function(d) { return d; }'
      assert_equal 'nest', RunJS.context(js).call('a.b.c', 'nest')
    end

    it 'supports many contexts' do
      heart    = 'function heart(s) { return "♥ " + s + " ♥"; }'
      upcase   = 'function upcase(s) { return s.toUpperCase(); }'
      decorate = 'function decorate(s) { return heart(upcase(s)); }'
      context  = RunJS.context(upcase).context(heart).context(decorate)
      assert_equal '♥ RUBY ♥', context.call('decorate', 'ruby')
    end

    specify 'using a runtime instance' do
      instance = RunJS.runtime.new
      instance.context('function upcase(s) { return s.toUpperCase(); }')
      instance.context('function star(s) { return "★" + upcase(s) + "★"; }')
      assert_equal '★RUBY★', instance.run('return star("ruby");')
      assert_equal '★RUBY★', instance.apply('star', nil, 'ruby')
      assert_equal '★RUBY★', instance.call('star', 'ruby')
      assert_equal '★RUBY★', instance.eval('star("ruby")')
    end

  end

  it 'does not use strict mode by default' do
    js = 'aGlobalVariable = true; return aGlobalVariable;'
    assert_equal true, RunJS.run(js)

    skip if RunJS.runtime == RunJS::JScript
    skip if RunJS.runtime == RunJS::TheRubyRhino

    error = assert_raises(RunJS::JavaScriptError) do
      RunJS.run("'use strict'; #{js}")
    end
    assert_equal 'ReferenceError', error[:name]
  end

end
