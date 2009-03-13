require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "description for project",
      :organisation_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Project.create!(@valid_attributes)
  end

  describe "available_stories" do
    before :all do
      @project = Projects.create_project! 
      @story_with = Stories.create_story!(:name => 'bob', 
                                          :iteration_id => 123,
                                          :project => @project)
      @story_without = Stories.create_story!(:name => 'bill',
                                             :project => @project)
    end

    it "should not include stories with iteration ids" do
      @project.available_stories.should_not include(@story_with)
    end

    it "should include stories without iteration ids" do
      @project.available_stories.should include(@story_without)
    end
  end

  describe "priorities=" do
    before :each do
      @project = Projects.create_project! :name => 'some project'
      @priority_1_to_2 = Stories.create_story! :priority => 1, :project => @project
      @priority_3_to_1 = Stories.create_story! :priority => 3, :project => @project
    end

    it "should reprioritise all of the stories" do
      @project.priorities = { 
        @priority_1_to_2.id.to_s => '2',
        @priority_3_to_1.id.to_s => '1',
      }

      @priority_1_to_2.reload.priority.should == 2
      @priority_3_to_1.reload.priority.should == 1
    end
  end

  describe "protection" do
    it "should protect organisation_id from being mass-assigned" do
      project = Project.new(:name => 'asdf',
                            :organisation_id => 132)
      project.organisation_id.should be_blank
    end
  end

  describe "destroy" do
    before :each do
      @project = Project.create! @valid_attributes
      @iteration = @project.iterations.build :name => 'asdf', :duration => 1
      @iteration.stories.stub!(:empty?).and_return(false)
      @iteration.save!
      @story = @project.stories.build(:name => 'asdf', :content => 'asdf')
      @story.save!
    end

    it "should destroy iterations" do
      @project.destroy
      lambda {@iteration.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should destroy stories" do
      @project.destroy
      lambda {@story.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "iterations" do
    it "should have the writer" do
      Project.new.should respond_to(:iterations=)
    end
  end

  describe "organisation" do
    it "should have the writer" do
      Project.new.should respond_to(:organisation=)
    end
  end

  describe "stories" do
    it "should have the writer" do
      Project.new.should respond_to(:stories=)
    end
  end
end
