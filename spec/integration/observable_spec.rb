require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

class IncludeObserver
  def initialize(observer)
    @observer = observer
  end

  def matches?(target)
    @target = target
    @target.instance_variable_get("@observers").include?(@observer)
  end

  def failure_message
    "expected #{@target.inspect} to include observer #{@observer.inspect}, but it didn't"
  end

  def negative_failure_message
    "expected #{@target.inspect} not to include observer #{@observer.inspect}, but it did"
  end
end

def include_observer(observer)
  IncludeObserver.new(observer)
end

describe DataMapper::Observers::Observable do

  before :all do
    class MyModel
      include DataMapper::Resource
      include DataMapper::Observers::Observable
      property :id, Integer, :key => true
    end
    
    class MyObserver; end
  end
  
  it "should extend the base class with the method add_observer" do
    MyModel.methods.should include("add_observer")
  end
  
  it "should extend the base class with the method delete_observer" do
    MyModel.methods.should include("delete_observer")
  end
  
  it "should extend the base class with the method notify_observers" do
    MyModel.methods.should include("notify_observers")
  end
  
  it "should allow to add and delete an observer" do
    observer = MyObserver.new
    MyModel.add_observer(observer)
    MyModel.should include_observer(observer)
    MyModel.delete_observer(observer)
    MyModel.should_not include_observer(observer)
  end
  
  it "should notify the observers when a new object is created on save" do
    object = MyModel.new
    MyModel.should_receive(:notify_observers).once.with("before_save", object)
    MyModel.should_receive(:notify_observers).once.with("before_create", object)
    MyModel.should_receive(:notify_observers).once.with("after_create", object)
    MyModel.should_receive(:notify_observers).once.with("after_save", object)
    object.save
  end
  
  it "should notify the observers when a new object is updated on save" do
    object = MyModel.new
    object.stub!(:new_record?).and_return(false)
    MyModel.should_receive(:notify_observers).once.with("before_save", object)
    MyModel.should_receive(:notify_observers).once.with("before_update", object)
    MyModel.should_receive(:notify_observers).once.with("after_update", object)
    MyModel.should_receive(:notify_observers).once.with("after_save", object)
    object.save
  end
end