require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/agile_terminology/iteration" do
  before(:each) do
    render 'agile_terminology/iteration'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/agile_terminology/iteration])
  end
end
