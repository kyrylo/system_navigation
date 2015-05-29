require_relative '../helper'

class TestSystemNavigationAllModulesInGemNamed < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_modules_in_gem_named
    mods = @sn.all_modules_in_gem_named('minitest')

    refute_empty mods

    mods.each do |mod|
      assert_instance_of Module, mod
    end
  end

  def test_all_modules_in_gem_named_bad_argument
    mods = @sn.all_modules_in_gem_named('mi')

    assert_empty mods
  end
end
