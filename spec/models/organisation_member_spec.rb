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

    it "should belong to a sponsor" do
      OrganisationMember.should belong_to(:sponsor)
    end
  end

  describe "acknowledgement token" do
    before :each do
      @user = Users.create_user!
      @organisation = Organisations.create_organisation!
      @organisation_member =
        @organisation.organisation_members.create!(:user => @user)
    end

    it "should be created with membership" do
      @organisation_member.acknowledgement_token.should_not be_nil
    end

    it "should be unique" do
      new_user = Users.create_user!
      new_organisation_member =
        @organisation.organisation_members.create!(:user => new_user)
      new_organisation_member.acknowledgement_token.should_not ==
        @organisation_member.acknowledgement_token
    end
  end
end
