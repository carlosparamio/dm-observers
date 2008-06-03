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
    
    class MyModelObserver < DataMapper::Observers::Observer
    end
  end
  
  it "should be a singleton class" do
    MyModelObserver.should be_a_singleton_class
  end
  
  it "should be added to the observed model automatically" do
    MyModel.should_receive(:add_observer).with(MyModelObserver.instance).once
  end
end