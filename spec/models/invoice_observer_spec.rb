require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvoiceObserver do
  before :each do
    @invoice = mock_model(Invoice, 
                          :amount => 9.99,
                          :vat_rate= => nil,
                          :vat_amount= => nil,
                          :vat_amount => 0)
    @observer = InvoiceObserver.instance
  end

  describe "before_validation_on_create" do
    describe "when amount is set" do
      before :each do
        @invoice.stub!(:amount?).and_return(true)
      end

      after :each do
        @observer.before_validation_on_create(@invoice)
      end

      it "should set the VAT rate" do
        @invoice.should_receive(:vat_rate=).with(Invoice::VAT_RATE)
      end

      it "should set the VAT amount" do
        expected_vat_amount = (9.99 * Invoice::VAT_RATE) / 100.0
        @invoice.should_receive(:vat_amount=).with(expected_vat_amount)
      end
    end

    describe "when amount is nil" do
      before :each do
        @invoice.stub!(:amount?).and_return(false)
      end

      it "should return true" do
        @observer.before_validation_on_create(@invoice).
          should be_true
      end
    end
  end

  describe "after_create" do
    after :each do
      @observer.after_create(@invoice)
    end

    it "should send an email to the person who paid" do
      UserMailer.should_receive(:deliver_invoice).with(@invoice)
    end
  end
end
