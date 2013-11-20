# RunJS

With RunJS you can run JavaScript code from Ruby.

```ruby
require 'runjs'
puts RunJS.run('return "Hello World";')
```

## Installation

```bash
$ gem install runjs
```

RunJS depends on the `json` library. Starting with Ruby version 1.9 this is included, but on Ruby 1.8 you have to install the `json` gem. If this causes any problems, install the `json_pure` gem instead.

```bash
$ gem install json || gem install json_pure
```

## JavaScript Runtimes

#### Supported runtimes

* [TheRubyRacer](https://github.com/cowboyd/therubyracer)
* [JavaScriptCore](http://trac.webkit.org/wiki/JavaScriptCore) included with OS X
* [V8](http://code.google.com/p/v8/)
* [Node](http://nodejs.org)
* [JScript](http://msdn.microsoft.com/en-us/library/9bbdkx3k.aspx) on Windows

RunJS will automatically select the first available runtime from the list above.

#### Deprecated runtimes

* [TheRubyRhino](https://github.com/cowboyd/therubyrhino)
* [SpiderMonkey](http://www.mozilla.org/js/spidermonkey)

To use TheRubyRhino or SpiderMonkey you have to set the runtime manually.

#### Set the runtime

You can control which runtime RunJS uses in your Ruby code.

```ruby
RunJS.runtime = RunJS::Node
```

Or with the RUNJS_RUNTIME environment variable.

```bash
$ export RUNJS_RUNTIME=Node
```

<!-- ## API -->

## Examples

```ruby
require 'runjs'

RunJS.run('return 2 + 2;')                     # => 4
RunJS.call('Math.sqrt', 25)                    # => 5
RunJS.apply('Array.prototype.slice', '"cat"')  # => ["c", "a", "t"]
```

#### Compiling CoffeeScript

```ruby
require 'runjs'
require 'open-uri'

url = 'http://jashkenas.github.com/coffee-script/extras/coffee-script.js'
compiler = open(url).read

coffee = 'alert yes'
options = { header: true, bare: true }
RunJS.context(compiler).apply('CoffeeScript.compile', 'CoffeeScript', coffee, options)

# => // Generated by CoffeeScript 1.6.3
# => alert(true);
```

<!-- ## RunJS vs. ExecJS -->

## Credits

Thanks to [Sam Stephenson](https://github.com/sstephenson), [Joshua Peek](https://github.com/josh) and the other contributors to [ExecJS](https://github.com/sstephenson/execjs). Although none of the code is directly copied, the API and code structure is almost identical. While coding, the ExecJS code was consulted all the time, and RunJS ended up like a rewrite of ExecJS.

## License

Copyright (c) 2013 AS Harbitz.

RunJS is released under the [MIT License](http://opensource.org/licenses/MIT).
