require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sitemaps/show" do
  before(:each) do
    render 'sitemaps/show.xml.builder'
  end
  
  it "should be successful" do
    response.should be_success
  end
end
