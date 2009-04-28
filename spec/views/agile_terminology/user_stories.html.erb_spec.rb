require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/agile_terminology/user_stories" do
  before(:each) do
    render 'agile_terminology/user_stories'
  end
  
  it_should_behave_like "a standard view"
end
