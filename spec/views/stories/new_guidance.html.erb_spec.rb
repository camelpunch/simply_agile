require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/new_guidance" do
  before(:each) do
    render 'stories/new_guidance'
  end
  
  it_should_behave_like "guidance"
end
