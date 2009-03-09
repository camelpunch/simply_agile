require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  before :each do
    login
  end

  describe "show" do
    def do_call
      get :show
    end

    it_should_behave_like "it's successful"
  end

end
