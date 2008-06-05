require 'singleton'

module DataMapper
  module Observers
    class Observer
      include Singleton

      attr_reader :observed_class

      def initialize
        klass = inferred_observed_class
        self.observed_class = klass if klass.is_a?(Class)
      end
      
      def observed_class=(klass)
        raise "The observed class was already assigned: #{@observer_class.name}" unless @observed_class.nil?
        @observed_class = klass
        @observed_class.add_observer(self)
        attach_hooks
      end

      def inferred_observed_class
        eval(self.class.name.scan(/(.*)Observer/)[0][0]) rescue nil
      end

      def attach_hooks
        self.class.hooks.each do |type, hooks|
          hooks.each do |target_method, hook_methods|
            hook_methods.each do |hook_method|
              @observed_class.send(type, target_method) do
                self.class.notify_observers("#{hook_method}", self)
              end
            end
          end
        end
      end
      
      def self.hooks
        @hooks ||= {}
      end
      
      def self.before(target_method, &block)
        define_block_method(:before, target_method, &block)
      end
      
      def self.after(target_method, &block)
        define_block_method(:after, target_method, &block)
      end

      # FIXME: This doesn't work
      # def self.before_class_method(target_method, &block)
      #   define_block_method(:before_class_method, target_method, &block)
      # end
      # 
      # def self.after_class_method(target_method, &block)
      #   define_block_method(:after_class_method, target_method, &block)
      # end
      
      def self.define_block_method(type, target_method, &block)
        self.hooks[type] ||= {}
        new_block_method = "__#{self.name}_observer_hooks_#{self.instance_methods.select{|m| m =~ /__#{self.name}_observer_hooks_/}.size}"
        define_method(new_block_method, &block)
        self.hooks[type][target_method] ||= []
        self.hooks[type][target_method] << new_block_method
      end

    end # class Observer
  end # module Observers
end # module DataMapper