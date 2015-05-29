require_relative '../helper'

class TestSystemNavigationAllClassesAndModulesInGemNamed < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_classes_and_modules_in_gem_named
    klassmods = @sn.all_classes_and_modules_in_gem_named('minitest')

    refute_empty klassmods

    klassmods.each do |klassmod|
      assert_kind_of Module, klassmod
    end
  end

  def test_all_classes_and_modules_in_gem_named_bad_argument
    mods = @sn.all_classes_and_modules_in_gem_named('mi')

    assert_empty mods
  end
end
