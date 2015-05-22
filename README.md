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

#### all_behaviors(&block)

If called without the `block`, returns an Enumerator that iterates over all
classes and their eigenclasses, modules and their eigenclasses. Given the block
it enumerates with `#each`.

```ruby
sn.all_behaviors.select { |behavior| behavior.kind_of?(Enumerable) }
#=> [Etc::Group, Etc::Passwd, Gem::Specification]

sn.all_behaviors { |behavior| ... }
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

#### all_classes(&block)

If called without the `block`, returns an Enumerator that iterates over all
classes. Given the block it enumerates with `#each`.

```ruby
sn.all_classes.select { |klass| klass.superclass == BasicObject } #=> [Object]
sn.all_classes { |klass| ... }
```

#### all_modules(&block)

If called without the `block`, returns an Enumerator that iterates over all
modules. Given the block it enumerates with `#each`.

```ruby
sn.all_modules.select { |mod| mod.include?(FileUtils) }
#=> [FileUtils::NoWrite, FileUtils::Verbose, FileUtils::DryRun]
sn.all_modules { |mod| ... }
```

#### all_classes_and_modules(&block)

If called without the `block`, returns an Enumerator that iterates over all
classes and modules. Given the block it enumerates with `#each`.

```ruby
sn.all_classes_and_modules.select { |mod| mod.include?(Comparable) }
#=> [Complex, Rational, Time, File::Stat, Bignum, ..., String]
sn.all_classes_and_modules.modules { |mod| ... }
```

#### all_objects(&block)

If called without the `block`, returns an Enumerator that iterates over all
classes and modules. Given the block it enumerates with `#each`.

```ruby
sn.all_objects.group_by(&:class)[Symbol].count #=> 5463
sn.all_objects { |obj| ... }
```

Limitations
-----------

Supports *only* CRuby.

* CRuby 2.2.2 and higher

License
-------

The project uses Zlib License. See LICENCE.txt file for more information.
