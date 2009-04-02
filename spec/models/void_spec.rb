require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Void do
  describe "creation" do
    def do_protx_action
      @authorization = '2;{F48981C8-158B-4EFA-B8A8-635D3B7A86CE};5123;08S2ZURVM4'
      @void = Void.create!(
        :authorization => @authorization
      )
    end

    it_should_behave_like "it uses protx"

    describe "void called on the gateway" do
      it "should be called" do
        @gateway.should_receive(:void)
        do_protx_action
      end

      it "should pass in the authorization" do
        @gateway.should_receive(:void) do |authorization|
          authorization.should == @authorization
        end
        do_protx_action
      end

      it "should store the status" do
        do_protx_action
        @void.status.should == "OK"
      end

      it "should store the status_detail" do
        do_protx_action
        @void.status_detail.should == "The transaction was RELEASEed successfully."
      end
    end
  end
end