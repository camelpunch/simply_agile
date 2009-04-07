require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/public/show" do
  before(:each) do
    render 'public/show'
  end
  
  it_should_behave_like "a standard view"
end
