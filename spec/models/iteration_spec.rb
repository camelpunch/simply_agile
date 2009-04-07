require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iteration do
  before(:each) do
    @story = mock_model(Story, :valid? => true, :[]= => nil, :save => nil)
    @valid_attributes = {
      :name => "value for name",
      :duration => "1",
      :start_date => Date.today,
      :stories => [@story],
    }
  end

  it "should create a new instance given valid attributes" do
    iteration = Iteration.new
    iteration.project_id = Projects.create_project!.id
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
      project = Projects.create_project!(:name => "woo")
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
        :project_id => Projects.create_project!.id)
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

    it "should require the duration be a number" do
      @iteration.duration = 'a'
      @iteration.valid?
      @iteration.errors.on(:duration).should_not be_nil
    end

    it "should require the duration to be >= 1" do
      @iteration.duration = 0
      @iteration.valid?
      @iteration.errors.on(:duration).should_not be_nil
    end

    it "should require the duration to be an integer" do
      @iteration.duration = 1.5
      @iteration.valid?
      @iteration.errors.on(:duration).should_not be_nil
    end

    it "should require a project" do
      @iteration.errors.on(:project_id).should_not be_nil
    end

    it "should require some stories" do
      @iteration.errors.on(:stories).should_not be_nil
    end

    describe "limiting" do
      before :each do
        Project.delete_all
        Iteration.delete_all
        @project = Projects.create_project!
        @limit = @project.organisation.payment_plan.active_iteration_limit

        @create = lambda {
          Iteration.create!(@valid_attributes.
                            merge(:start_date => Date.today, # active
                                  :project => @project))
        }
      end

      it "should require free active iteration slots in the organisation" do
        @limit.times { |i| @create.call }
        @create.should raise_error(ActiveRecord::RecordInvalid)
      end

      it "should allow unlimited planned iterations" do
        @limit.times { |i| @create.call }
        lambda { 
          Iteration.create!(@valid_attributes.
                            merge(:start_date => nil,
                                  :project => @project))
        }.should_not raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "setting the duration after the start date" do
    it "should set the end_date" do
      iteration = Iteration.new
      iteration.start_date = Date.today
      iteration.duration = 7
      iteration.end_date.should == 7.days.from_now.to_date
    end
  end

  describe "story points" do
    before :each do
      project = Projects.simply_agile
      @iteration = Iterations.create_iteration!(:project => project)

      @stories = []
      @estimate = 0
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 5)
      @estimate += 5
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 8)
      @estimate += 8
      @stories << Stories.create_story!(:iteration => @iteration, :estimate => 2)
      @estimate += 2
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
      Burndown.should_receive(:new).with(@iteration, {})
      @iteration.burndown
    end

    it "should pass the width to the burndown object" do
      Burndown.should_receive(:new).with(@iteration, :width => 300)
      @iteration.burndown(300)
    end
  end

  describe "creating new burndown data points" do
    before :each do
      @iteration = Iterations.active_iteration
    end

    it "should have many burndown data points" do
      Iteration.should have_many(:burndown_data_points)
    end

    it "should not create data points if the iteration is not active" do
      @iteration.update_attributes(:start_date => nil)
      @iteration.update_burndown_data_points
      @iteration.burndown_data_points.should be_empty
    end

    it "should not create data points if the interation has less than one day to go" do
      @iteration.update_attributes(
        :end_date => Date.today
      )
      @iteration.update_burndown_data_points
      @iteration.burndown_data_points.should be_empty
    end

    it "should update today's data point if one exists" do
      @data_point = BurndownDataPoint.create!(
        :iteration => @iteration,
        :story_points => 10,
        :date => Date.today
      )
      @iteration.update_burndown_data_points
      @data_point.reload
      @data_point.story_points.should == @iteration.story_points_remaining
    end

    it "should create a new data point for today if none exists" do
      @iteration.update_burndown_data_points
      @data_point = BurndownDataPoint.find(
        :first,
        :conditions => {
          :date => Date.today,
          :iteration_id => @iteration.id,
          :story_points => @iteration.story_points_remaining
        }
      )
      @data_point.should_not be_nil
    end
  end
  
  describe "named finders" do
    before :each do
      Iteration.destroy_all
      @active = Iterations.active_iteration
      @recently_finished = Iterations.recently_finished_iteration
      @pending = Iterations.first_iteration
      @finished = Iterations.finished_iteration
    end
    
    describe "active" do
      it "should only return active iterations" do
        Iteration.active.should == [@active]
      end
    end

    describe "recently_finished" do
      it "should return iterations finished less than 7 days ago" do
        Iteration.recently_finished.should == [@recently_finished]
      end

      it "should not return iterations finished greater than 7 days ago" do
        Iteration.recently_finished.should_not include(@finished)
      end
    end

    describe "pending" do
      it "should only return pending iterations" do
        Iteration.pending.should == [@pending]
      end
    end

    describe "finished" do
      it "should only return finished iterations" do
        Iteration.finished.sort.should == [@recently_finished, @finished].sort
      end
    end
  end

  describe "updating all burndown data points" do
    before :each do
      @it1 = mock_model(Iteration)
      @it2 = mock_model(Iteration)
      Iteration.stub!(:active).and_return([@it1, @it2])
      @it3 = mock_model(Iteration)
      @it4 = mock_model(Iteration)

      @it1.stub!(:update_burndown_data_points)
      @it2.stub!(:update_burndown_data_points)
    end

    it "should call update_burndown_data_points on all active iterations" do
      @it1.should_receive(:update_burndown_data_points)
      @it2.should_receive(:update_burndown_data_points)
      Iteration.update_burndown_data_points_for_all_active
    end

    it "should not call update_burndown_data_points on inactive iterations" do
      @it3.should_not_receive(:update_burndown_data_points)
      @it4.should_not_receive(:update_burndown_data_points)
      Iteration.update_burndown_data_points_for_all_active
    end
  end

  describe "starting" do
    before :each do
      @iteration = Iterations.first_iteration
    end

    it "should return false if there are no estimates" do
      story1 = Stories.create_story! :estimate => 0
      story2 = Stories.create_story! :estimate => ''
      @iteration.stories = [story1, story2]
      @iteration.start.should be_false
    end

    it "should set the start_date to today" do
      @iteration.start
      @iteration.reload
      @iteration.start_date.should == Date.today
    end

    it "should set the end_date to today + duration" do
      @iteration.start
      @iteration.reload
      @iteration.end_date.should == 7.days.from_now.to_date
    end

    it "should set the initial estimate" do
      @iteration.start
      @iteration.reload
      @iteration.initial_estimate.should == @iteration.story_points_remaining
    end

    it "should be finished if finished" do
      @iteration.end_date = 2.days.ago
      @iteration.should be_finished
    end

    it "should be finished if finished today" do
      @iteration.end_date = Date.today
      @iteration.should be_finished
    end

    it "should be pending if not started" do
      @iteration.should be_pending
    end

    it "should not be pending if started" do
      @iteration.start
      @iteration.should_not be_pending
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
