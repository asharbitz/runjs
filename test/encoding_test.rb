# encoding: UTF-8

require 'test_helper'

describe 'encoding' do

  it 'handles UTF-8 characters' do
    skip if RunJS.runtime == RunJS::SpiderMonkey  # SpiderMonkey does not support UTF-8

    upcase = RunJS.run('return "ꝏå＠ø\ua74f".toUpperCase();')
    if [RunJS::JScript, RunJS::TheRubyRhino].include?(RunJS.runtime)
      assert_equal 'ꝏÅ＠Øꝏ', upcase
    else
      assert_equal 'ꝎÅ＠ØꝎ', upcase
    end
  end

  it 'converts other encodings to UTF-8 (if ruby version >= 1.9)' do
    skip unless defined? Encoding
    skip if RunJS.runtime == RunJS::SpiderMonkey

    context = 'function star(text) { return text.split("").join("★"); }'
    context = RunJS.context(context.encode('Shift_JIS'))
    [
      context.apply('star', 'this', 'スター'),
      context.call('star', 'スター'.encode('Shift_JIS')),
      context.eval('star("スター")'.encode('UTF-16LE')),
      context.run('return star("スター");'.encode('UTF-16'))
    ].each do |star|
      assert_equal 'ス★タ★ー', star
      assert_equal 'UTF-8', star.encoding.name
    end
  end

end
