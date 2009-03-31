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

  describe "associations" do
    it "should have many projects" do
      Organisation.should have_many(:projects)
    end

    it "should have many stories" do
      Organisation.should have_many(:stories)
    end

    it "should have many iterations" do
      Organisation.should have_many(:iterations)
    end

    it "should have many organisation members" do
      Organisation.should have_many(:organisation_members)
    end

    it "should have many users" do
      Organisation.should have_many(:users)
    end

    it "should have one payment method" do
      Organisation.should have_one(:payment_method)
    end
  end
end
