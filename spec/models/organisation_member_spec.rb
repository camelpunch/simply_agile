require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationMember do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :organisation_id => 1
    }
  end

  it "should have an email_address accessor" do
    OrganisationMember.new.email_address = 'asdf'
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
        @organisation.members.create!(:user => @user)
    end

    it "should be created with membership" do
      @organisation_member.acknowledgement_token.should_not be_nil
    end

    it "should be unique" do
      new_user = Users.create_user!
      new_organisation_member =
        @organisation.members.create!(:user => new_user)
      new_organisation_member.acknowledgement_token.should_not ==
        @organisation_member.acknowledgement_token
    end
  end

  describe "validations" do
    before :each do
      @organisation_member = OrganisationMember.new
      @organisation_member.valid?
    end

    it "should require that the organisation is not suspended" do
      organisation = Organisations.create_organisation!
      organisation.update_attribute :suspended, true
      @organisation_member.organisation = organisation
      @organisation_member.valid?
      @organisation_member.should have(1).error_on(:organisation)
    end

    it "should require a user" do
      @organisation_member.should have(1).error_on(:user_id)
    end

    it "should require unique users within an organisation" do
      OrganisationMember.create!(:user_id => 1, :organisation_id => 1)
      lambda {OrganisationMember.create!(:user_id => 1, :organisation_id => 1)}.
        should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require free user slots in the organisation" do
      Project.delete_all
      organisation = Organisations.create_organisation!
      project = 
        Projects.create_project! :organisation => organisation
      limit = project.organisation.payment_plan.user_limit

      create = lambda {
        OrganisationMember.create!(@valid_attributes.merge(:user => Users.create_user!,
                                                           :organisation => organisation))
      }

      limit.times { |i| create.call }

      create.should raise_error(ActiveRecord::RecordInvalid)
    end
    
  end
end
