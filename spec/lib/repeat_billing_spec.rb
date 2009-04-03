require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Billable
  include RepeatBilling
  cattr_accessor :instance1, :instance2

  attr_accessor :name

  def initialize(name)
    self.name = name
  end

  def self.billable
    [@@instance1, @@instance2]
  end

  def take_payment
    true
  end
end

describe RepeatBilling do
  before :each do
    Billable.instance1 = Billable.new("instance 1")
    Billable.instance2 = Billable.new("instance 2")
  end

  it "should call take payment on all billable instances" do
    Billable.instance1.should_receive(:take_payment)
    Billable.instance2.should_receive(:take_payment)
    Billable.repeat_billing
  end

  it "should continue on other instances if an exception is raised" do
    Billable.instance1.stub!(:take_payment).and_raise(StandardError)
    Billable.instance2.should_receive(:take_payment)
    Billable.repeat_billing
  end


  describe "logging" do
    before :each do
      @log_file_name = File.join(RAILS_ROOT, 'log', 'repeat_billing.log')
    end

    it "should create a log file" do
      File.unlink(@log_file_name) if File.exists?(@log_file_name)
      Billable.repeat_billing
      File.should be_exists(@log_file_name)
    end

    it "should write an entry for each instance" do
      Billable.repeat_billing
      File.readlines(@log_file_name).detect do |line|
        %r{#{Billable.instance1.name}}.match(line)
      end.should_not be_nil
    end
  end
end