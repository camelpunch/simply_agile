require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/acceptance_criteria/edit" do

  before :each do
    assigns[:project] = mock_model(Project, 
                                   :stories => [],
                                   :iterations => [],
                                   :criterion => '')
    assigns[:story] = mock_model(Story,
                                 :acceptance_criteria => [],
                                 :content => '')

    assigns[:acceptance_criterion] = mock_model(AcceptanceCriterion,
                                                :criterion => '')

    render 'acceptance_criteria/edit'
  end

  it_should_behave_like "a standard view"

end
