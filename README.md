SystemNavigation
==

* Repository: [https://github.com/kyrylo/system-navigation/](https://github.com/kyrylo/system-navigation/)

Description
-----------

SystemNavigation is a Ruby library that provides support for the navigation and
introspection of Ruby programs. It is inspired by the eponymous class in
Pharo/Squeak.

Sneak peek:

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
#=> [#<UnboundMethod: A#num>, #<UnboundMethod: A(M)#increment>, #<UnboundMethod: A#initialize>]
```

And many more...

Installation
------------

All you need is to install the gem.

    gem install system-navigation

Synopsis
---

### Precaution

The library is very young and its API is far from stable. Some behaviours
might be unexpected or bugged. Feel free to file issues if you feel like the
result you expect isn't what you actually get.

### API

See the [API.md](/doc/API.md) file.

Limitations
-----------

Supports *only* CRuby.

* CRuby 2.2.2 and higher

License
-------

The project uses Zlib License. See LICENCE.txt file for more information.
