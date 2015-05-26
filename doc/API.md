API
---

This file _might_ be out of date. The best reference is the unit tests of this
project. The detailed description of parameters can be found in
`./lib/system-navigation.rb`.

## Description

Create a new instance of SystemNavigation.

```ruby
require 'system-navigation'

sn = SystemNavigation.default
```

The term `method` implies an instance of the `UnboundMethod` class.

#### all_accesses(to:, from:, only_get:, only_set:)

Returns an Array of all methods of the class `from` or its sub/superclasses that
refer to the instance variable `to`.

```ruby
class A
  def initialize
    @foo = 1
  end
end

class B
  attr_reader :foo
end

sn.all_accesses(to: :@foo) #=> [#<UnboundMethod: A#initialize>]
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

#### all_calls(on:, from: nil, gem: nil)

Returns an Array of all methods of the behavior `from` and its
sub/superclasses/ancestors that call the `on` literal. Accepts either `from` or
`gem` arguments, but not both. If both of these arguments are omitted, returns
an Array of all methods that call `on` globally.

Literal is

```ruby
class A
  def bing
    :foo
  end
end

class B < A
  def bang
    :foo
  end
end

sn.all_calls(on: :foo, from: A)
#=> [#<UnboundMethod: A#bing>, #<UnboundMethod: B#bong>]

sn.all_calls(on: :foo, gem: 'minitest')
#=> [...]

sn.all_calls(on: :foo)
#=> [..., ..., ...]

sn.all_calls(on: :foo, from: A, gem: 'minitest')
#=> ArgumentError
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

#### all_classes_implementing(selector)

Returns an Array of all classes that implement the `selector`, which is a Symbol,
representing a method name.

```ruby
sn.all_classes_implementing(:last) #=> [Range, Array]
```

#### all_modules_implementing(selector)

Returns an Array of all modules that implement the `selector`, which is a Symbol,
representing a method name.

```ruby
sn.all_modules_implementing(:first) #=> [Enumerable]
```

#### all_implementors_of(selector)

```ruby
sn.all_implementors_of(:first) #=> [Range, Array, Enumerable]
```

#### all_classes_in_gem_named(gem_name)

Returns an Array of all classes in a RubyGem `gem_name`.

```ruby
sn.all_classes_in_gem_named('pry')
#=> [Pry::Editor, Pry::PluginManager::Plugin, ..., Pry::PluginManager::NoPlugin]
```

#### all_modules_in_gem_named(gem_name)

Returns an Array of all modules in a RubyGem `gem_name`.

```ruby
sn.all_modules_in_gem_named('pry')
#=> [Pry::RbxPath, Pry::Command::Ls::MethodsHelper, ..., Pry::Command::Ls::JRubyHacks]
```

#### all_classes_and_modules_in_gem_named(gem_name)

Returns an Array of all classes and modules in a RubyGem `gem_name`.

```ruby
sn.all_classes_and_modules_in_gem_named('pry')
#=> [Pry::Editor, Pry::Command::JumpTo, ..., Pry::Command::BangPry]
```

#### all_local_calls(on:, from:)

```ruby
sn.all_local_calls(on: :foo, from: A) #=> [#<UnboundMethod: A#initialize>]
```
