class SystemNavigation
  module ArrayUtils
    refine Array do
      # Thanks, Rails.
      def split(value)
        results, arr = [[]], self.dup

        until arr.empty?
          if (idx = arr.index(value))
            results.last.concat(arr.shift(idx))
            arr.shift
            results << []
          else
            results.last.concat(arr.shift(arr.size))
          end
        end

        results
      end
    end
  end
end