require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PrivacyPoliciesController do

  describe "show" do
    it "should not require any session information" do
      get :show
      response.should be_success
    end
  end

end
