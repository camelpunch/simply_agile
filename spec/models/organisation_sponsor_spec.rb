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

    it "should require a sponsor id" do
      @organisation_sponsor.errors.invalid?(:user_id).should be_true
    end

    it "should require an organisation id" do
      @organisation_sponsor.errors.invalid?(:user_id).should be_true
    end
  end
end
