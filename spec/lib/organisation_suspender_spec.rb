require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationSuspender do

  describe "run" do
    before :all do
      Organisation.delete_all
      period = OrganisationSuspender::GRACE_PERIOD
      @one_day_past = Organisations.
        create_organisation!(:name => 'one day past')
      @one_day_past.update_attribute(:next_payment_date, (period + 1).days.ago)

      @at_start = Organisations.
        create_organisation!(:name => 'at start')
      @at_start.update_attribute(:next_payment_date, period.days.ago)

      @inside = Organisations.
        create_organisation!(:name => 'inside')
      @inside.update_attribute(:next_payment_date, (period - 1).days.ago)

      OrganisationSuspender.run
    end

    it "should suspend organisations past grace period" do
      @one_day_past.reload.should be_suspended 
    end

    it "should not suspend organisations at start of grace period" do
      @at_start.reload.should_not be_suspended 
    end

    it "should not suspend organisations inside grace period" do
      @inside.should_not be_suspended 
    end
  end

end
