module DataMapper
  module Observers
    module Observable
      def self.included(base)
        base.instance_variable_set("@observers", [])
        base.extend ClassMethods
        [:save, :create, :update, :destroy].each do |action|
          base.before action do
            base.notify_observers("before_#{action}", self)
          end
          base.after action do
            base.notify_observers("after_#{action}", self)
          end
        end
      end
    
      module ClassMethods
        def add_observer(observer)
          @observers << observer
        end
      
        def delete_observer(observer)
          @observers.delete(observer)
        end
      
        def notify_observers(hook, object)
          candidates = @observers.select{|observer| observer.methods.include?(hook.to_s)}
          candidates.each do |observer|
            observer.send(hook, object)
          end
        end
      end # module ClassMethods
    end # module Observable
  end # module Observers
end # module DataMapper