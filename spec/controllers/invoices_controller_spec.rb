require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvoicesController do

  before :each do
    login
    @invoice = Invoices.create_invoice!
    @user.invoices << @invoice
    @user.save!
  end

  def do_call
    get :index
  end

  describe "index" do
    it_should_behave_like "it's successful"

    it "should assign invoices" do
      do_call
      assigns[:invoices].should include(@invoice)
    end
  end

  describe "show" do
    describe "for current user's invoice" do
      def do_call
        get :show, :id => @invoice.id
      end

      it_should_behave_like "it's successful"
    end

    describe "for another user's invoice" do
      def do_call
        get :show, :id => Invoices.create_invoice!.id
      end

      it "should raise" do
        lambda {do_call}.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
