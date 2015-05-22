SystemNavigation
==

* Repository: [https://github.com/kyrylo/system-navigation/](https://github.com/kyrylo/system-navigation/)

Description
-----------

SystemNavigation is a Ruby library that provides support for the navigation and
introspection of Ruby programs. It is inspired by the eponymous class in
Pharo/Squeak.

Installation
------------

All you need is to install the gem.

    gem install system-navigation

Synopsis
---
### API

Create a new instance of SystemNavigation.

```ruby
require 'system-navigation'

sn = SystemNavigation.default
```

The term `method` implies an instance of the `UnboundMethod` class.

#### all_accesses(to:, from:)

Returns an Array of all methods of the class `from` or its sub/superclasses that
refer to the instance variable `to`.

```ruby
class A
  def initialize
    @foo = 1
  end
end

sn.all_accesses(to: :@foo, from: A) #=> [#<UnboundMethod: A#initialize>]
```

#### all_calls(on:, from: nil)

Returns an Array of all methods of the class `from` or its subclasses that call
the `on` Symbol. If the `from` parameter is omitted, returns an Array of all
methods that call `on`.

```ruby
class A
  def initialize
    :foo
  end
end

sn.all_accesses(to: :foo, from: A) #=> [#<UnboundMethod: A#initialize>]
sn.all_accesses(to: :foo) #=> [#<UnboundMethod: ...>, ..., #<UnboundMethod: ...>]
```

Limitations
-----------

* CRuby 2.2.2 and higher

License
-------

The project uses Zlib License. See LICENCE.txt file for more information.
