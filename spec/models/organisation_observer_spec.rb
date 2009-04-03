require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationObserver do
  before :each do
    @observer = OrganisationObserver.instance
    @organisation = mock_model Organisation
  end

  describe "before_create" do
    def stub_date!(date)
      Date.stub!(:today).and_return(date)
    end

    after :each do
      @observer.before_create(@organisation)
    end

    describe "when on 1st of January" do
      it "should set the next_payment_date to be 1st February" do
        stub_date! Date.new(2009, 1, 1)
        @organisation.should_receive(:next_payment_date=).with(Date.new(2009, 2 ,1))
      end
    end

    describe "when on 28th of January" do
      it "should set the next_payment_date to be 28th February" do
        stub_date! Date.new(2009, 1, 28)
        @organisation.should_receive(:next_payment_date=).with(Date.new(2009, 2, 28))
      end
    end

    describe "when on 29th of January" do
      it "should set the next_payment_date to be 1st March" do
        stub_date! Date.new(2009, 1, 29)
        @organisation.should_receive(:next_payment_date=).with(Date.new(2009, 3, 1))
      end
    end

    describe "when on 1st of February" do
      it "should set the next_payment_date to be 1st March" do
        stub_date! Date.new(2009, 2, 1)
        @organisation.should_receive(:next_payment_date=).with(Date.new(2009, 3, 1))
      end
    end

    describe "when on 31st of August" do
      it "should set the next_payment_date to be 1st October" do
        stub_date! Date.new(2009, 8, 31)
        @organisation.should_receive(:next_payment_date=).with(Date.new(2009, 10, 1))
      end
    end
  end

end
