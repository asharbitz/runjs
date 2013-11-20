require 'tempfile'
require 'rbconfig'
require 'shellwords'

module RunJS

  module OS

    def self.which(cmd)
      cmd += extension(cmd)
      return cmd if executable?(cmd)
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        path = File.join(path, cmd)
        return path if executable?(path)
      end
      nil
    end

    def self.write_tempfile(text, &block)
      file = Tempfile.new(['runjs', '.js'])
      file.binmode  # Required on Windows when writing UTF-16
      file.write(text)
      file.close
      yield file.path
    ensure
      file.close!
    end

    if RUBY_VERSION < '1.9' || RUBY_PLATFORM == 'java'

      extend Encoding

      def self.popen(cmd, options = {})
        cmd = shell_escape(cmd) << ' 2>&1'
        result = IO.popen(cmd) { |io| io.read }
        encode(result, 'UTF-8', options[:external_encoding])
      end

    else

      def self.popen(cmd, options = {})
        cmd = cmd.dup.push({ :err => [:child, :out] })  # Unsupported by JRuby
        options[:internal_encoding] ||= 'UTF-8'
        options[:external_encoding] ||= 'UTF-8'
        IO.popen(cmd, options) { |io| io.read }
      end

    end

    def self.success?
      $?.success?
    end

  private

    def self.extension(cmd)
      (windows? && File.extname(cmd).empty?) ? '.exe' : ''
    end

    def self.windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    end

    def self.executable?(cmd)
      File.file?(cmd) && File.executable?(cmd)
    end

    def self.shell_escape(cmd)
      if windows?
        cmd.map { |arg| '"' + arg.gsub('"', '""') + '"' }.join(' ')
      else
        Shellwords.join(cmd)
      end
    end

    private_class_method(:extension, :windows?, :executable?, :shell_escape)

  end

end
