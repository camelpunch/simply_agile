require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/show" do

  before :each do
    assigns[:project] = mock_model(Project, 
                                   :stories => [],
                                   :iterations => [],
                                   :iteration_id? => false,
                                   :name => '')
    assigns[:story] = mock_model(Story,
                                 :status => 'testing',
                                 :acceptance_criteria => [],
                                 :estimate? => nil,
                                 :iteration_id? => false,
                                 :iteration_id => '',
                                 :iteration => nil,
                                 :users => [],
                                 :team_members => [],
                                 :content => '')
    @active_iteration = mock_model(Iteration, :pending? => false, :active? => true)
    @pending_iteration = mock_model(Iteration, :pending? => true, :active? => false)
  end

  describe "without iteration" do
    before :each do
      render 'stories/show'
    end

    it_should_behave_like "a standard view"

    it "should provide a link to backlog" do
      response.should have_tag('a[href=?]', backlog_project_stories_path(assigns[:project]))
    end
  end

  describe "with pending iteration" do
    before :each do
      assigns[:story].stub!(:iteration_id).and_return(@pending_iteration.id)
      assigns[:story].stub!(:iteration).and_return(@pending_iteration)
      render 'stories/show'
    end

    it_should_behave_like "a standard view"

    it "should provide a link to backlog" do
      response.should have_tag('a[href=?]', backlog_project_stories_path(assigns[:project]))
    end
  end

  describe "with active iteration" do
    before :each do
      assigns[:story].stub!(:iteration_id).and_return(@active_iteration.id)
      assigns[:story].stub!(:iteration).and_return(@active_iteration)
      render 'stories/show'
    end

    it_should_behave_like "a standard view"

    it "should not provide a link to backlog" do
      response.should_not have_tag('a[href=?]', backlog_project_stories_path(assigns[:project]))
    end
  end
end
