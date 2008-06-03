require 'singleton'

module DataMapper
  module Observers
    class Observer
      include Singleton

      def initialize
        observed_class.add_observer(self) unless observed_class.nil?
      end

      # The class observed by default is inferred from the observer's class name:
      #   assert_equal [Person], PersonObserver.observed_class
      def observed_class
        if observed_class_name = self.class.name.scan(/(.*)Observer/)[0]
          eval(observed_class_name[0]) rescue nil
        else
          nil
        end
      end
    end # class Observer
  end # module Observers
end # module DataMapper