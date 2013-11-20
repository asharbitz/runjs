require 'test_helper'

describe 'select a runtime' do

  class AvailableRuntime < RunJS::SystemRuntime
    @cmd = 'ruby'
  end

  class DeprecatedRuntime < RunJS::SystemRuntime
    @cmd = 'ruby'
    @deprecated = true
  end

  class UnavailableRuntime < RunJS::SystemRuntime
    @cmd = 'this is not a command'
  end

  specify 'the runtime is available if @cmd is executable' do
    assert AvailableRuntime.available?
    refute UnavailableRuntime.available?
  end

  specify 'deprecated' do
    refute AvailableRuntime.deprecated?
    assert DeprecatedRuntime.deprecated?
  end

  before { @runtime = RunJS.runtime }
  after  { RunJS.runtime = @runtime }

  describe 'setting the runtime manually' do

    it 'sets the runtime if it is available' do
      RunJS.runtime = AvailableRuntime
      assert_equal AvailableRuntime, RunJS.runtime
    end

    it 'accepts a deprecated runtime' do
      RunJS.runtime = DeprecatedRuntime
      assert_equal DeprecatedRuntime, RunJS.runtime
    end

    it 'raises RuntimeUnavailable if the runtime is unavailable' do
      assert_raises(RunJS::RuntimeUnavailable) do
        RunJS.runtime = UnavailableRuntime
      end
      assert_equal @runtime, RunJS.runtime
    end

  end

  describe 'selecting a runtime automatically' do

    before do
      @runtimes = RunJS::RUNTIMES.dup
      @environment = ENV['RUNJS_RUNTIME']

      ENV['RUNJS_RUNTIME'] = nil
      RunJS.instance_variable_set(:@runtime, nil)
    end

    after do
      RunJS::RUNTIMES.replace(@runtimes)
      ENV['RUNJS_RUNTIME'] = @environment
    end

    it 'selects the first available runtime' do
      RunJS::RUNTIMES.replace([UnavailableRuntime, AvailableRuntime] + @runtimes)
      assert_equal AvailableRuntime, RunJS.runtime
    end

    it 'will not select a deprecated runtime automatically' do
      RunJS::RUNTIMES.replace([DeprecatedRuntime])
      assert_raises(RunJS::RuntimeUnavailable) { RunJS.runtime }
    end

    it 'raises RuntimeUnavailable if none of the supported runtimes are installed' do
      RunJS::RUNTIMES.replace([UnavailableRuntime, DeprecatedRuntime])
      assert_raises(RunJS::RuntimeUnavailable) { RunJS.runtime }
    end

    describe 'the RUNJS_RUNTIME environment variable' do

      it 'selects the runtime set by the environment' do
        ENV['RUNJS_RUNTIME'] = 'AvailableRuntime'
        assert_equal AvailableRuntime, RunJS.runtime
      end

      it 'will accept a deprecated runtime from the environment' do
        ENV['RUNJS_RUNTIME'] = 'DeprecatedRuntime'
        assert_equal DeprecatedRuntime, RunJS.runtime
      end

      it 'raises RuntimeUnavailable if the runtime is unavailable' do
        ENV['RUNJS_RUNTIME'] = 'UnavailableRuntime'
        assert_raises(RunJS::RuntimeUnavailable) { RunJS.runtime }
      end

    end

  end

end
