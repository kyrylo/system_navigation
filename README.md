SystemNavigation
==

* [Repository](https://github.com/kyrylo/system_navigation/)
* [Documentation](http://www.rubydoc.info/gems/system_navigation)

Description
-----------

System Navigation is a Ruby library that provides capabilities for navigation
and introspection of Ruby programs at runtime. Smalltalk users may recognise
it. The library provides a group of useful methods that allow:

* finding instance, class or global variables in methods
* finding literals such as numbers, strings, symbols, etc.
* finding methods that contain a specific string (method source search)
* finding classes and modules that implement given methods
* finding classes and modules that send messages
* finding all classes and modules in gems
* and more...

For the complete list of features please read the documentation. All interaction
with the library is done via the `SystemNavigation` class and its class
methods. The description of the methods can be found in these places:

* [SystemNavigation](http://www.rubydoc.info/gems/system_navigation/SystemNavigation)
* [SystemNavigation::RubyEnvironment](http://www.rubydoc.info/gems/system_navigation/SystemNavigation/RubyEnvironment)

Examples (full list in the documentation)
--

### #all_accesses

Retrieve all methods that access instance variables in the given class/module
including its ancestors and children.

```ruby
module M
  def increment
    @num + 1
  end
end

class A
  include M

  attr_reader :num

  def initialize(num)
    @num = num
  end
end

sn = SystemNavigation.default

sn.all_accesses(to: :@num, from: A)
#=> [#<UnboundMethod: A#num>, #<UnboundMethod: A(M)#increment>, #<UnboundMethod: A#initialize>]
```

### #all_implementors_of

Find all classes and modules that implement the given message.

```ruby
sn = SystemNavigation.default

sn.all_implementors_of(:puts)
#=> [ARGF.class, IO, Kernel, ..., YARD::Logger]
```

### #all_calls

Find all methods in Bundler that invoke the `1` literal.

```ruby
require 'bundler'

sn = SystemNavigation.default

sn.all_calls(on: 1, gem: 'bundler')
#=> [#<UnboundMethod: #<Class:Bundler>#with_clean_env>, #<UnboundMethod: #<Class:Bundler>#eval_gemspec>]
```

### #all_objects

Retrieve all objects defined in the system.

```ruby
sn = SystemNavigation.default

sn.all_objects.map(&:class).uniq.count #=> 158
```

And many more...

Installation
------------

All you need is to install the gem.

    gem install system_navigation

Limitations
-----------

Supports *only* CRuby.

* CRuby 2.2.2 and higher

License
-------

The project uses Zlib License. See LICENCE.txt file for more information.
