require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    Organisation.create!(@valid_attributes)
  end

  describe "projects" do
    it "should have the writer" do
      Organisation.new.should respond_to(:projects=)
    end
  end

  describe "users" do
    it "should have the writer" do
      Organisation.new.should respond_to(:users=)
    end
  end
end
