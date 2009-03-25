require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sessions/new" do
  before(:each) do
    render 'sessions/new'
  end
  
  it_should_behave_like "a standard view"

  it "should have a form for logging in" do
    response.should have_tag('form[action=?][method=?]', session_path, 'post')
  end
end
