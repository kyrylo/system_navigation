require 'set'
require 'English'

require 'system_navigation/instruction_stream'
require 'system_navigation/instruction_stream/decoder'
require 'system_navigation/instruction_stream/instruction'
require 'system_navigation/instruction_stream/instruction/attr_instruction'
require 'system_navigation/navigation_capabilities'

class SystemNavigation
  # The VERSION file must be in the root directory of the library.
  VERSION_FILE = File.expand_path('../../VERSION', __FILE__)

  VERSION = File.exist?(VERSION_FILE) ?
              File.read(VERSION_FILE).chomp : '(could not find VERSION file)'

  using NavigationCapabilities

  def self.default
    self.new
  end

  def all_accesses(to:, from:)
    accesses = []

    from.with_all_sub_and_superclasses do |klass|
      klass.which_selectors_access(to).each do |sel|
        accesses.push(klass.instance_method(sel))
      end
    end

    accesses
  end
end
