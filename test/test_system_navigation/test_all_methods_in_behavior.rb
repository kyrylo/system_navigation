require_relative '../helper'

class TestSystemNavigationAllMethodsInBehavior < Minitest::Test
  def setup
    @sn = SystemNavigation.default
  end

  def test_all_methods_in_behavior
    test_class = Class.new do
      class << self
        def public_singleton_method
        end

        private

        def private_singleton_method
        end

        protected

        def protected_singleton_method
        end
      end

      def public_instance_method
      end

      private

      def private_instance_method
      end

      protected

      def protected_instance_method
      end
    end

    expected = {
      public: {
        instance: [
          test_class.instance_method(:public_instance_method)
        ],
        singleton: [
          test_class.singleton_class.instance_method(:public_singleton_method)
        ]
      },
      private: {
        instance: [
          test_class.instance_method(:private_instance_method)
        ],
        singleton: [
          test_class.singleton_class.instance_method(:private_singleton_method)
        ]
      },
      protected: {
        instance: [
          test_class.instance_method(:protected_instance_method)
        ],
        singleton: [
          test_class.singleton_class.instance_method(:protected_singleton_method)
        ]
      }
    }

    assert_equal expected, @sn.all_methods_in_behavior(test_class)
  end
end
