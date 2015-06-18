API
---

The public API of this library can be viewed online. The user must interact
with the library via the `SystemNavigation` class. The documentation:

http://www.rubydoc.info/gems/system_navigation/SystemNavigation

Additionally, that class provides methods defined here (through delegation):

http://www.rubydoc.info/gems/system_navigation/SystemNavigation/RubyEnvironment

So in order to use `RubyEnvironment#all_objects` you must to call
`SystemNavigation` like this

```ruby
SystemNavigation.default.all_objects(&block)
```
