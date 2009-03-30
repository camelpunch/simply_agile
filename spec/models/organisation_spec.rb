require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :payment_plan_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Organisation.create!(@valid_attributes)
  end

  describe "protection" do
    before :each do
      @user = Users.create_user!
    end

    it "should not allow mass-assignment of user ids" do
      organisation = Organisation.create! @valid_attributes.merge(:user_ids => [@user.id])
      organisation.users.should be_empty
    end

    it "should allow mass-assignment of users" do
      organisation = Organisation.create! @valid_attributes.merge(:users => [@user])
      organisation.users.should == [@user]
    end
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
  end

  describe "validations" do
    before :each do
      @organisation = Organisation.new
      @organisation.valid?
    end

    it "should require a name" do
      @organisation.should have(1).error_on(:name)
    end

    it "should require a payment plan" do
      @organisation.should have(1).error_on(:payment_plan_id)
    end
  end
end
