require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublicController do

  describe "show" do
    def do_call
      get :show
    end

    it_should_behave_like "it's successful"

    it "should render the sessions/new template" do
      do_call
      response.should render_template('sessions/new')
    end
  end

end
