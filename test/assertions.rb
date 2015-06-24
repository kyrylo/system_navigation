module Minitest
  module Assertions
    alias_method :old_assert_equal, :assert_equal

    def assert_equal(exp, act, msg = nil)
      if exp.kind_of?(Array) && act.kind_of?(Array)
        old_assert_equal(exp.sort_by(&:hash), act.sort_by(&:hash), msg)
      else
        old_assert_equal(exp, act, msg)
      end
    end
  end
end
