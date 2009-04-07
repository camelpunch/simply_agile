require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/public/show" do
  before(:each) do
    render 'public/show'
  end
  
  it_should_behave_like "a standard view"

  it "should have a form for logging in" do
    response.should have_tag('form[action=?][method=?]', session_url, 'post')
  end
end
