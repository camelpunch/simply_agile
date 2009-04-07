require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SitemapsController do

  describe "show" do
    it "should be successful" do
      get :show
      response.should be_success
    end
  end
end
