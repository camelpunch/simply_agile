require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/agile_terminology/story" do
  before(:each) do
    render 'agile_terminology/story'
  end
  
  it_should_behave_like "a standard view"
end
