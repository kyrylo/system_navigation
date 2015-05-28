require_relative 'helper'

class TestSystemNavigationAllClassesInGemNamed < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_classes_in_gem_named
    skip

    klasses = @sn.all_classes_in_gem_named('minitest')

    refute_empty klasses

    klasses.each do |klass|
      assert_instance_of Class, klasses
    end
  end
end
