require_relative 'helper'

class TestSystemNavigationAllCalls < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_accesses
    parent_class = Class.new do
      attr_reader :ivar

      def dynamic_read; self.instance_variable_get(:@ivar); end
      def eval_write; eval('@ivar = 100'); end
      def parent_method; @another_ivar; end
    end

    test_class = Class.new(parent_class) do
      def initialize; @ivar = 0; end
      def read_and_write; @ivar += 1; end
      def mixed_write
        @another_ivar = 1
        @ivar = 99
        @and_another_ivar = 3
      end

      def dynamic_write; self.instance_variable_set(:@ivar, 69); end
      def nested_eval; eval("eval('@ivar')"); end
      def random; :empty; end
    end

    child_class = Class.new(test_class) do
      attr_writer :ivar

      def method_read; @ivar.succ; end
      def eval_read; eval('@ivar'); end
      def empty; :random; end
    end

    expected = [
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
    ]

    assert_equal expected, @sn.all_accesses(to: :@ivar, from: test_class)
    assert_equal [], @sn.all_accesses(to: :@nonexisting, from: test_class)
  end

  def test_all_accesses_private
    test_class = Class.new do
      def initialize(ivar); @ivar = ivar; end

      private

      def private_read; @ivar; end
      def private_write; @ivar = 11; end
    end

    expected = [
      test_class.instance_method(:initialize),
      test_class.instance_method(:private_write),
      test_class.instance_method(:private_read),
    ]

    assert_equal expected, @sn.all_accesses(to: :@ivar, from: test_class)
  end

  def test_all_accesses_fuzzy_match
    test_class = Class.new do
      def initialize(ivar); @ivar = ivar; end
      private def check; @ivar.succ; end
    end

    assert_equal [], @sn.all_accesses(to: :'@', from: test_class)
  end

  def test_all_accesses_basicobject_fuzzy
    assert_equal [], @sn.all_accesses(to: :'@', from: BasicObject)
  end

  def test_all_accesses_extend_include_prepend
    test_module_ext = Module.new do
      def ext; @ivar = 1; end
    end

    test_module_deep_incl = Module.new do
      def deep_incl; @ivar; end
    end

    test_module_incl = Module.new do
      include test_module_deep_incl
      def incl; @ivar; end
    end

    test_module_prep = Module.new do
      def prep
        @ivar = 1
        @ivar
      end
    end

    test_class = Class.new do
      extend test_module_ext
      include test_module_incl
      prepend test_module_prep
    end

    expected = [
      test_class.instance_method(:incl),
      test_class.instance_method(:deep_incl),
      test_class.instance_method(:prep),
    ]
    assert_equal expected, @sn.all_accesses(to: :@ivar, from: test_class)

    expected = [
      test_class.singleton_class.instance_method(:ext),
    ]
    assert_equal expected, @sn.all_accesses(to: :@ivar, from: test_class.singleton_class)
  end
end
