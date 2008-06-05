require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

class BeASingletonClass
  def matches?(target)
    @target = target
    @target.included_modules.include?(Singleton)
  end

  def failure_message
    "expected that #{@target.inspect} was a Singleton class"
  end

  def negative_failure_message
    "expected that #{@target.inspect} wasn't a Singleton class"
  end
end

def be_a_singleton_class
  BeASingletonClass.new
end

describe DataMapper::Observers::Observer do
  before :all do
    class MyModel
      include DataMapper::Resource
      include DataMapper::Observers::Observable
      property :id, Integer, :key => true
    end
    
    class MyModelObserver  < DataMapper::Observers::Observer
      before :save do |object|
        puts "before :save with object #{object.inspect}"
      end
      
      before :save do
        puts "before :save"
      end
      
      after :save do
        puts "after :save"
      end
      
      def before_save(object)
        puts "before_save with object #{object.inspect}"
      end
    end
    class MyCustomObserver < DataMapper::Observers::Observer; end
  end
  
  it "should work" do
    MyModelObserver.instance
    MyModel.new.save
  end
  
  it "should attach a hook to the observed class for each before block"
  
  it "should attach a hook to the observed class for each after block"
  
  it "should attach a hook to the observed class for each before_class_method block"
  
  it "should attach a hook to the observed class for each after_class_method block"

end