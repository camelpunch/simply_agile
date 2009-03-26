require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  before :each do
    login
    setup_project
  end

  describe "show" do
    def do_call
      get :show
    end

    before :each do
      controller.instance_variable_set("@organisation", @organisation)
    end

    it_should_behave_like "it's successful"
  end

end
