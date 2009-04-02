require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Capture do
  describe "creation" do
    def do_protx_action
      @amount = 100
      @authorization = '2;{F48981C8-158B-4EFA-B8A8-635D3B7A86CE};5123;08S2ZURVM4'
      @capture = Capture.create!(
        :authorization => @authorization,
        :amount => @amount
      )
    end

    it_should_behave_like "it uses protx"

    describe "capture on the gateway" do
      it "should be called" do
        @gateway.should_receive(:capture)
        do_protx_action
      end

      it "should pass in the amount" do
        @gateway.should_receive(:capture) do |amount, authorization|
          amount.should == @amount
        end
        do_protx_action
      end

      it "should pass in the authorization" do
        @gateway.should_receive(:capture) do |amount, authorization|
          authorization.should == @authorization
        end
        do_protx_action
      end

      it "should store the status" do
        do_protx_action
        @capture.status.should == "OK"
      end

      it "should store the status_detail" do
        do_protx_action
        @capture.status_detail.should == "The transaction was RELEASEed successfully."
      end
    end
  end
end
