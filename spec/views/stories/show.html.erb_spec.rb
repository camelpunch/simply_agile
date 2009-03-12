require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/show" do

  before :each do
    assigns[:project] = mock_model(Project, 
                                   :stories => [],
                                   :iterations => [],
                                   :name => '')
    assigns[:story] = mock_model(Story,
                                 :acceptance_criteria => [],
                                 :estimate? => nil,
                                 :content => '')

    render 'stories/show'
  end

  it_should_behave_like "a standard view"

end
