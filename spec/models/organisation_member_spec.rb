require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationMember do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :organisation_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    OrganisationMember.create!(@valid_attributes)
  end

  describe "associations" do
    it "should belong to a user" do
      OrganisationMember.should belong_to(:user)
    end

    it "should belong to an organisation" do
      OrganisationMember.should belong_to(:organisation)
    end
  end
end
