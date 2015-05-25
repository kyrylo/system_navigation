class SystemNavigation
  class MethodHash < Hash
    def self.create(**args)
      self.new(args)
    end


    def initialize(based_on: nil, include_super: nil)
      @hash = super()

      if based_on
        @hash.merge!({
          public: {
            instance: based_on.public_instance_methods(include_super),
            singleton: based_on.singleton_class.public_instance_methods(include_super)
          },
          private: {
            instance: based_on.private_instance_methods(include_super),
            singleton: based_on.singleton_class.private_instance_methods(include_super)
          },
          protected: {
            instance: based_on.protected_instance_methods(include_super),
            singleton: based_on.singleton_class.protected_instance_methods(include_super)
          }
        })
      else
        @hash.merge!(empty_hash)
      end
    end

    def as_array
      self.values.map { |h| h[:instance] + h[:singleton] }.flatten.compact
    end

    def empty?
      self == empty_hash
    end

    protected

    def empty_hash
      {
        public: {instance: [], singleton: []},
        private: {instance: [], singleton: []},
        protected: {instance: [], singleton: []}
      }
    end
  end
end
