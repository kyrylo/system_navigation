require_relative 'helper'

class TestSystemNavigation < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  # A shared pool represents a set of bindings which are accessible to all
  # classes which import the pool in its 'pool dictionaries'. SharedPool is NOT
  # a dictionary but rather a name space. Bindings are represented by 'class
  # variables' - as long as we have no better way to represent them at least.
  # def test_all_classes_using_shared_pool
  #   skip
  #   assert_equal true, true
  # end

  def test_all_accesses
    parent_class = Class.new do
      attr_reader :ivar

      def dynamic_read
        self.instance_variable_get(:@ivar)
      end

      def eval_write
        eval('@ivar = 100')
      end

      def parent_method
        @another_ivar
      end
    end

    test_class = Class.new(parent_class) do
      def initialize
        @ivar = 0
      end

      def read_and_write
        @ivar += 1
      end

      def mixed_write
        @another_ivar = 1
        @ivar = 99
        @and_another_ivar = 3
      end

      def dynamic_write
        self.instance_variable_set(:@ivar, 69)
      end

      def nested_eval
        eval("eval('@ivar')")
      end

      def random
        :empty
      end
    end

    child_class = Class.new(test_class) do
      attr_writer :ivar

      def method_read
        @ivar.succ
      end

      def eval_read
        eval('@ivar')
      end

      def empty
        :random
      end
    end

    actual_methods = @sn.all_accesses(to: :@ivar, from: test_class).sort_by(&:hash)
    expected_methods = [
      parent_class.instance_method(:ivar),
      parent_class.instance_method(:dynamic_read),
      parent_class.instance_method(:eval_write),
      test_class.instance_method(:initialize),
      test_class.instance_method(:read_and_write),
      test_class.instance_method(:mixed_write),
      test_class.instance_method(:nested_eval),
      child_class.instance_method(:method_read),
      child_class.instance_method(:eval_read),
      child_class.instance_method(:ivar=),
    ].sort_by(&:hash)
    assert_equal expected_methods, actual_methods

    methods = @sn.all_accesses(to: :@nonexisting, from: test_class)
    assert_equal [], methods
  end

  def test_all_accesses_private
    test_class = Class.new do
      def initialize(ivar)
        @ivar = ivar
      end

      private

      def private_read
        @ivar
      end

      def private_write
        @ivar = 11
      end
    end

    actual_methods = @sn.all_accesses(to: :@ivar, from: test_class).sort_by(&:hash)
    expected_methods = [
      test_class.instance_method(:initialize),
      test_class.instance_method(:private_write),
      test_class.instance_method(:private_read),
    ].sort_by(&:hash)

    assert_equal expected_methods, actual_methods
  end

  def test_all_accesses_fuzzy_match
    test_class = Class.new do
      def initialize(ivar)
        @ivar = ivar
      end

      private def check
        @ivar.succ
      end
    end

    actual_methods = @sn.all_accesses(to: :'@', from: test_class)
    assert_equal [], actual_methods
  end
end
