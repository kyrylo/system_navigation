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

#### all_accesses(to:, from:)

Returns an array of UnboundMethod objects of all methods of a class `from` or its
sub/superclass that refer to the instance variable `to`.

```ruby
class A
  def initialize
    @foo = 1
  end
end

sn.all_accesses(to: :@foo, from: A) #=> [#<UnboundMethod: A#initialize>]
```

Limitations
-----------

* CRuby 2.2.2 and higher

License
-------

The project uses Zlib License. See LICENCE.txt file for more information.
