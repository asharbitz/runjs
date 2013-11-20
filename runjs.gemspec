Gem::Specification.new do |spec|
  spec.name        = 'runjs'
  spec.version     = '0.1.0'
  spec.license     = 'MIT'

  spec.author      = 'AS Harbitz'
  spec.email       = 'asharbitz@gmail.com'
  spec.homepage    = 'https://github.com/asharbitz/runjs'

  spec.summary     = 'Run JavaScript code from Ruby'
  spec.description = 'You can run JavaScript code from Ruby with RunJS. ' +
                     'The supported JavaScript engines are: Node, V8, ' +
                     'TheRubyRacer, JavaScriptCore and JScript.'

  spec.files       = Dir['LICENSE', 'Rakefile', 'runjs.gemspec', '*.md',
                         'lib/**/*.*']
  spec.test_files  = Dir['test/**/*.*']

  spec.add_development_dependency 'minitest',             '~> 4.0'
  spec.add_development_dependency 'coffee-script-source', '>= 1.6.2'
  spec.add_development_dependency 'therubyracer'
  spec.add_development_dependency 'therubyrhino'

  spec.required_ruby_version = '>= 1.8.7'

  spec.post_install_message  = <<-EOF.gsub('    ', '')

    If your version of ruby is older than 1.9, you may need to install json:
    gem install json || gem install json_pure

  EOF
end
