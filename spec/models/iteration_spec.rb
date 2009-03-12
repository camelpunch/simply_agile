require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iteration do
  before(:each) do
    @story = mock_model(Story, :valid? => true, :[]= => nil, :save => nil)
    @valid_attributes = {
      :name => "value for name",
      :duration => "1",
      :started_on => Date.today,
      :finished_on => Date.today,
      :stories => [@story],
    }
  end

  it "should create a new instance given valid attributes" do
    iteration = Iteration.new
    iteration.project_id = 1
    iteration.update_attributes!(@valid_attributes)
  end

  describe "save_with_planned_stories_attributes!" do
    before :all do
      @to_be_added = Stories.create_story!(:name => 'include me')
      @to_be_removed = Stories.create_story!(:name => 'exclude me')
      @iteration = Iterations.create_iteration!(:name => 'planning',
                                                :stories => [@to_be_removed])
      @iteration.duration = 6
      @iteration.save_with_planned_stories_attributes!({
        @to_be_added.id.to_s => { 'include' => '1', 'estimate' => '5' },
        @to_be_removed.id.to_s => { 'include' => '0', 'estimate' => '4' },
      })
    end

    it "should include" do
      @iteration.reload.stories.should include(@to_be_added)
    end

    it "should exclude" do
      @iteration.reload.stories.should_not include(@to_be_removed)
    end

    it "should set the estimate on an included story" do
      @to_be_added.reload
      @to_be_added.estimate.should == 5
    end

    it "should set the estimate on an included story" do
      @to_be_removed.reload
      @to_be_removed.estimate.should == 4
    end

    it "should save the iteration" do
      @iteration.reload
      @iteration.duration.should == 6
    end

    it "should retain the planned stories in memory" do
      @iteration.planned_stories.should include(@to_be_added)
      @iteration.planned_stories.should include(@to_be_removed)
    end
  end

  describe "default name" do
    it "should use a default name if none is assigned" do
      project = Project.create(:name => "woo")
      iteration = project.iterations.build
      iteration.name.should == "Iteration #{project.iterations.count + 1}"
    end
    
    it "should use the assigned name if available" do
      name = "Iteration Name"
      project = Project.create(:name => "woo")
      iteration = project.iterations.build(:name => name)
      iteration.name.should == name
    end
  end

  describe "attribute protection" do
    it "should prevent project_id from being mass-assigned" do
      iteration = Iteration.new(:name => 'asdf',
        :duration => 1,
        :project_id => 132)
      iteration.project_id.should be_blank
    end
  end

  describe "project" do
    it "should provide the writer" do
      Iteration.new.should respond_to(:project=)
    end
  end

  describe "stories" do
    it "should provide the writer" do
      Iteration.new.should respond_to(:stories=)
    end
  end

  describe "validations" do
    before :each do
      @iteration = Iteration.new
      @iteration.valid?
    end

    it "should require a name" do
      @iteration.errors.on(:name).should_not be_nil
    end

    it "should require a duration" do
      @iteration.errors.on(:duration).should_not be_nil
    end

    it "should require a project" do
      @iteration.errors.on(:project_id).should_not be_nil
    end

    it "should require some stories" do
      @iteration.errors.on(:stories).should_not be_nil
    end
  end

  describe "story points" do
    before :each do
      project = Projects.simply_agile
      @iteration = Iterations.create_iteration(:project => project)

      @stories = []
      @estimate = 0
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 5)
      @estimate += 5
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 8)
      @estimate += 8
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 2)
      @estimate += 2
      @stories << Stories.create_story!(:iteration => @iteration)
    end

    it "should respond to intial_estimate" do
      @iteration.should respond_to(:initial_estimate)
    end

    it "should calculate story_points_remaining from stories" do
      @iteration.stories.should_receive(:incomplete).and_return(@stories)
      @iteration.story_points_remaining.should == @estimate
    end
  end

  describe "burndown" do
    before :each do
      @iteration = Iteration.new
    end

    it "should create a new burndown object" do
      Burndown.should_receive(:new).with(@iteration)
      @iteration.burndown
    end
  end

  describe "starting" do
    before :each do
      @iteration = Iterations.first_iteration
    end

    it "should set the start_date to today" do
      @iteration.start
      @iteration.reload
      @iteration.start_date.should == Date.today
    end

    it "should set the initial estimate" do
      @iteration.start
      @iteration.reload
      @iteration.initial_estimate.should == @iteration.story_points_remaining
    end

    it "should return false to #active? if not started" do
      @iteration.active?.should == false
    end

    it "should return true to #active? if started" do
      @iteration.start
      @iteration.active?.should == true
    end
    
    describe "already started" do
      before :each do
        @start_date = 2.days.ago.to_date
        @iteration.update_attributes(:start_date => @start_date)
      end
      
      it "should not change the start date" do
        @iteration.start
        @iteration.reload
        @iteration.start_date.should == @start_date
      end

      it "should return the end date" do
        @iteration.end_date.should == @start_date + @iteration.duration
      end

      it "should return the number of days remaining" do
        @iteration.days_remaining.should == 5 # duration is 7, started 2 days ago
      end
    end
  end
end
