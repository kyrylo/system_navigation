require_relative '../helper'

class TestSystemNavigationAllClassesInGemNamed < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_classes_in_gem_named
    klasses = @sn.all_classes_in_gem_named('minitest')

    refute_empty klasses

    klasses.each do |klass|
      assert_instance_of Class, klass
    end
  end

  def test_all_classes_in_gem_named_bad_argument
    klasses = @sn.all_classes_in_gem_named('mi')

    assert_empty klasses
  end
end
