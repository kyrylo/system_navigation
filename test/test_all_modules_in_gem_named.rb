require_relative 'helper'

class TestSystemNavigationAllModulesInGemNamed < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_modules_in_gem_named
    skip

    mods = @sn.all_modules_in_gem_named('minitest')

    refute_empty mods

    mods.each do |mod|
      assert_instance_of Module, mod
    end
  end
end
