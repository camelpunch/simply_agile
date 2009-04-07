require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SitemapsController do

  describe "show" do
    it "should be successful" do
      session[:user_id] = nil
      session[:organisation_id] = nil
      get :show, :format => :xml
      response.should be_success
    end
  end
end
