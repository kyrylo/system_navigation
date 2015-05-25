require_relative 'helper'

class TestSystemNavigation < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_stores
    test_class = Class.new do
      def bingo
        @cool_object = 1
      end

      def bango
        @cool_object
      end

      def bongo
        @cool_object.girls_love_me
      end

      def bish
        @cool_object += 1
      end
    end

    expected_methods = [
      test_class.instance_method(:bingo),
      test_class.instance_method(:bish)
    ].sort_by(&:hash)

    actual_methods = @sn.all_stores(into: :@cool_object, from: test_class).sort_by(&:hash)
    assert_equal expected_methods, actual_methods
  end
end
