require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationSponsor do
  describe "associations" do
    it "should belong to a user" do
      OrganisationSponsor.should belong_to(:user)
    end

    it "should belong to a sponsor" do
      OrganisationSponsor.should belong_to(:sponsor)
    end

    it "should belong to an organisation" do
      OrganisationSponsor.should belong_to(:organisation)
    end
  end

  describe "validations" do
    before :each do
      @organisation_sponsor = OrganisationSponsor.new
      @organisation_sponsor.valid?
    end

    it "should require a user id" do
      @organisation_sponsor.errors.invalid?(:user_id).should be_true
    end

    it "should require a valid user"
#    do
#      @organisation_sponsor.user_id = 9999999
#      @organisation_sponsor.valid?
#      @organisation_sponsor.errors.invalid?(:user_id).should be_true
#    end

    it "should require a sponsor id" do
      @organisation_sponsor.errors.invalid?(:user_id).should be_true
    end

    it "should require a valid sponsor"
#    do
#      @organisation_sponsor.sponsor_id = 9999999
#      @organisation_sponsor.valid?
#      @organisation_sponsor.errors.invalid?(:sponsor).should be_true
#    end

    it "should require an organisation id" do
      @organisation_sponsor.errors.invalid?(:user_id).should be_true
    end

    it "should require a valid organisation"
#    do
#      @organisation_sponsor.organisation_id = 9999999
#      @organisation_sponsor.valid?
#      @organisation_sponsor.errors.invalid?(:organisation).should be_true
#    end
  end
end
