require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/edit" do

  before :each do
    assigns[:project] = mock_model(Project, 
                                   :stories => [],
                                   :iterations => [],
                                   :iteration_id? => false,
                                   :name => '')
    assigns[:story] = mock_model(Story,
                                 :name => '',
                                 :acceptance_criteria => [],
                                 :estimate? => nil,
                                 :content => '')

    @iteration = mock_model Iteration
  end

  describe "when iteration_id set" do
    before :each do
      assigns[:story].stub!(:iteration_id?).and_return(true)
      assigns[:story].stub!(:iteration).and_return(@iteration)
      render 'stories/edit'
    end

    it_should_behave_like "a standard view"
  end

  describe "when iteration_id not set" do
    before :each do
      assigns[:story].stub!(:iteration_id?).and_return(false)
      assigns[:story].stub!(:iteration).and_return(nil)
      render 'stories/edit'
    end

    it_should_behave_like "a standard view"
  end

end
